// import 'package:flutter/material.dart';
// import 'package:readventure/view/components/custom_learning_card.dart';
// import 'package:readventure/model/section_data.dart';
//
// class ExamplePage extends StatelessWidget {
//   const ExamplePage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final sectionData = SectionData(
//       section: 1,
//       title: '코스1',
//       sectionDetail: '코스1의 설명입니다.',
//       subdetailTitle: ['학습 목표 1', '학습 목표 2'],
//       totalTime: ['10', '20'],
//       achievement: ['50', '70'],
//       difficultyLevel: ['쉬움', '보통'],
//       textContents: ['내용 1', '내용 2'],
//       imageUrls: [
//         'https://example.com/image1.jpg',
//         'https://example.com/image2.jpg',
//       ],
//       missions: [
//         ['미션 1-1', '미션 1-2'],
//         ['미션 2-1', '미션 2-2'],
//       ],
//       effects: [
//         ['효과 1-1', '효과 1-2'],
//         ['효과 2-1', '효과 2-2'],
//       ],
//       status: ['completed', 'before_completion'],
//       cardStates: [
//         LearningCardState.targetNotStarted, // 첫 번째 카드: 학습 대상 (시작 전)
//         LearningCardState.locked,          // 두 번째 카드: 진행 불가
//       ],
//     );
//
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Custom Learning Card Example')),
//       body: ListView.builder(
//         itemCount: sectionData.subdetailTitle.length, // 학습 목표 개수만큼 생성
//         itemBuilder: (context, index) {
//           return LearningCard(
//             data: sectionData,
//             index: index, state: LearningCardState.targetNotStarted,
//           );
//         },
//       ),
//     );
//   }
// }