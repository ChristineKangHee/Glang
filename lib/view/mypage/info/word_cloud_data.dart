import 'package:word_cloud/word_cloud_data.dart';
import 'package:word_cloud/word_cloud_view.dart';
import 'package:flutter/material.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';

Widget buildWordCloudBox(BuildContext context, CustomColors customColors) {
  final wordCloudData = WordCloudData(
    data: [
      {'text': '책', 'value': 20},
      {'text': '독서', 'value': 15},
      {'text': '문장', 'value': 12},
      {'text': '이해력', 'value': 10},
      {'text': '지식', 'value': 8},
      {'text': '어휘력', 'value': 7},
      {'text': '읽기', 'value': 6},
      {'text': '학습', 'value': 5},
      {'text': '사고력', 'value': 5},
      {'text': '요약', 'value': 4},
    ],
  );

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: customColors.neutral100,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200, // 워드 클라우드 높이 조정
          child: WordCloudView(
            data: wordCloudData,
            mapwidth: 300,  // 너비 지정
            mapheight: 200, // 높이 지정
          ),
        ),
      ],
    ),
  );
}
