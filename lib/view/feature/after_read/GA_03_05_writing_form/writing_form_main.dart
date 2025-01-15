import 'package:flutter/material.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:flutter/material.dart';

class SentencePractice extends StatefulWidget {
  @override
  _SentencePracticeState createState() => _SentencePracticeState();
}

class _SentencePracticeState extends State<SentencePractice> {
  final String structure = "○○는 □□에서 가장 ○○한 인물이다";
  final Map<int, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      controllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  String buildSentence() {
    List<String> inputs = controllers.values.map((c) => c.text).toList();
    String result = structure;
    for (int i = 0; i < inputs.length; i++) {
      result = result.replaceFirst(RegExp(r"○○|□□"), inputs[i].isEmpty ? "____" : inputs[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("문장 연습"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 문장 형식과 빈칸 미리보기
            Text(
              "문장 형식:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              structure.replaceAllMapped(RegExp(r"○○|□□"), (match) => "____"),
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),

            // 빈칸 입력 필드
            Column(
              children: List.generate(controllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: controllers[index],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "빈칸 ${index + 1}",
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                );
              }),
            ),

            // 완성된 문장 미리보기
            SizedBox(height: 16),
            Text(
              "완성된 문장:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              buildSentence(),
              style: TextStyle(fontSize: 18),
            ),

            // 저장 및 초기화 버튼
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 저장 로직 (예: DB나 로컬 파일에 저장 가능)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("문장이 저장되었습니다.")),
                    );
                  },
                  child: Text("저장"),
                ),
                ElevatedButton(
                  onPressed: () {
                    for (var controller in controllers.values) {
                      controller.clear();
                    }
                    setState(() {});
                  },
                  child: Text("초기화"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
