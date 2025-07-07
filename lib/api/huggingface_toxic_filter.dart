import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경 변수(.env 파일)에서 API 키를 로드하기 위한 패키지

class HuggingFaceToxicFilter {
  static const String _apiUrl = 'https://api-inference.huggingface.co/models/unitary/toxic-bert';

  static Future<bool> isToxic(String text) async {
    final String? apiKey = dotenv.env['HUGGING_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API 키를 찾을 수 없습니다.');
    }

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': text}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> result = jsonDecode(response.body);

      if (result.isEmpty || result[0].isEmpty) {
        throw Exception('API 응답이 비어 있습니다.');
      }

      final List<dynamic> predictions = result[0];
      final toxicPrediction = predictions.firstWhere(
            (item) => item['label'].toString().toLowerCase() == 'toxic',
        orElse: () => null,
      );

      if (toxicPrediction == null) {
        throw Exception('Toxic 레이블이 응답에 없습니다.');
      }

      final double toxicScore = (toxicPrediction['score'] as num).toDouble();
      return toxicScore >= 0.7; // 임계값 조정 가능
    } else {
      throw Exception('HuggingFace Toxicity Check 실패: ${response.statusCode}\nBody: ${response.body}');
    }
  }

}
