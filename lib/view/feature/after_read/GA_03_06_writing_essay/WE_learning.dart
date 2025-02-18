// import 'package:flutter/material.dart';
// import 'package:readventure/theme/font.dart';
// import 'package:readventure/view/components/custom_app_bar.dart';
// import 'package:readventure/view/components/my_divider.dart';
// import '../../../../theme/theme.dart';
// import '../widget/answer_section.dart';
// import '../widget/CustomAlertDialog.dart';
// import '../widget/text_section.dart';
// import '../widget/title_section_learning.dart';
//
// class WELearning extends StatefulWidget {
//   const WELearning({super.key});
//
//   @override
//   State<WELearning> createState() => _CELearningState();
// }
//
// class _CELearningState extends State<WELearning> {
//   final TextEditingController _controller = TextEditingController();
//   bool _isButtonEnabled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(_updateButtonState);
//   }
//
//   @override
//   void dispose() {
//     _controller.removeListener(_updateButtonState);
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _updateButtonState() {
//     setState(() {
//       _isButtonEnabled = _controller.text.isNotEmpty;
//     });
//   }
//
//   // 결과창 띄우기
//   void _showAlertDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return const CustomAlertDialog();
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final customColors = Theme.of(context).extension<CustomColors>()!;
//     final data = "저는 학창 시절에 교과서 중심의 학습 방식이 재미없게 느껴졌습니다. 흥미를 느낄 수 있는 자료가 부족해 독서에 대한 의욕이 점점 줄었고, 성적도 좋지 않았습니다. 반면, 흥미로운 소설이나 관심 분야의 책을 읽을 때는 집중력이 높아졌습니다. 맞춤형 읽기 도구는 개인의 수준과 흥미를 고려해 자료를 제공하여 이런 문제를 해결할 수 있을 것입니다. 이는 학습 효율을 높이고, 읽기에 대한 자신감을 키우는 데 큰 도움이 될 것이라 생각합니다.";
//
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: CustomAppBar_2depth_8(title: "에세이 작성"),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // 스크롤 가능한 콘텐츠
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // 타이머와 제목 섹션
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: TitleSection_withIcon(
//                         customColors: Theme.of(context).extension<CustomColors>()!, // CustomColors 가져오기
//                         title: "자신의 경험과 의견을 작성해 주세요!",               // 제목
//                         subtitle: "개인의 수준과 흥미를 고려한 읽기 도구의 필요성",                           // 부제목
//                         author: "AI",                                         // 작성자                         // 아이콘 (기본값: Icons.import_contacts)
//                       ),
//                     ),
//                     // 본문 텍스트
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Text_Section(text: data,),
//                     ),
//                     SizedBox(height: 8,),
//                     BigDivider(),
//                     BigDivider(),
//                     SizedBox(height: 8,),
//                     // 사용자 입력 영역
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Answer_Section(
//                         controller: _controller,
//                         customColors: customColors,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // 제출 버튼
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: buildButton(customColors),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   SizedBox buildButton(CustomColors customColors) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isButtonEnabled ? _showAlertDialog : null,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: customColors.primary,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 16.0),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           disabledBackgroundColor: customColors.primary20,
//           disabledForegroundColor: Colors.white,
//         ),
//         child: const Text("제출하기", style: TextStyle(fontSize: 16)),
//       ),
//     );
//   }
// }
