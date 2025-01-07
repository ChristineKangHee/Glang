// import 'package:flutter/material.dart';
// import 'package:readventure/theme/theme.dart';
// import 'package:readventure/util/box_shadow_styles.dart';
// import 'package:readventure/theme/font.dart';
// import '../course/course_subdetail.dart';
// import '../../model/section_data.dart';
//
// /// LearningCard
// /// - 학습 상태(학습 대상, 완료, 진행 불가)에 따라 UI와 동작을 변경.
// class LearningCard extends StatelessWidget {
//   final SectionData data;
//   final int index;
//   final LearningCardState state; // 카드 상태 전달.
//
//   const LearningCard({
//     super.key,
//     required this.data,
//     required this.index,
//     required this.state,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final customColors = Theme.of(context).extension<CustomColors>()!;
//
//     // 상태에 따른 카드 배경색
//     final Color backgroundColor = _getBackgroundColor(customColors, state);
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 70.0),
//       child: Container(
//         decoration: BoxDecoration(
//           color: backgroundColor, // 상태에 따른 배경색
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: BoxShadowStyles.shadow1(context),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _CardHeader(data: data, index: index, state: state),
//               const SizedBox(height: 32),
//               _CardDetails(data: data, index: index),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // 상태에 따른 배경색 반환
//   Color _getBackgroundColor(CustomColors customColors, LearningCardState state) {
//     switch (state) {
//       case LearningCardState.targetNotStarted:
//         return customColors.primary10; // 시작 전
//       case LearningCardState.targetInProgress:
//         return customColors.primary20; // 이어하기
//       case LearningCardState.completed:
//         return customColors.success; // 완료
//       case LearningCardState.locked:
//         return customColors.neutral30; // 잠김
//     }
//   }
// }
//
// enum LearningCardState {
//   targetNotStarted, // 학습 대상 (시작 전)
//   targetInProgress, // 학습 대상 (이어하기)
//   completed,        // 학습 완료
//   locked,           // 학습 진행 불가
// }
//
// /// _CardHeader
// /// - 상태에 따라 버튼과 UI 동작 변경.
// class _CardHeader extends StatelessWidget {
//   final SectionData data;
//   final int index;
//   final LearningCardState state;
//
//   const _CardHeader({
//     required this.data,
//     required this.index,
//     required this.state,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final customColors = Theme.of(context).extension<CustomColors>()!;
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               data.title,
//               style: body_xsmall_semi(context).copyWith(color: customColors.neutral100),
//             ),
//             Text(
//               data.subdetailTitle[index],
//               style: body_large_semi(context).copyWith(color: customColors.neutral100),
//             ),
//           ],
//         ),
//         _buildButton(context, state, customColors), // 상태에 따른 버튼 표시
//       ],
//     );
//   }
//
//   // 상태에 따른 버튼 동작 및 스타일 설정
//   Widget _buildButton(BuildContext context, LearningCardState state, CustomColors customColors) {
//     switch (state) {
//       case LearningCardState.targetNotStarted:
//         return _buildActionButton(context, '시작하기', customColors.primary, () {
//           // 시작하기 버튼 동작
//           _navigateToDetailPage(context);
//         });
//       case LearningCardState.targetInProgress:
//         return _buildActionButton(context, '이어하기', customColors.primary40, () {
//           // 이어하기 버튼 동작
//           _navigateToDetailPage(context);
//         });
//       case LearningCardState.completed:
//         return Icon(Icons.check, color: customColors.success, size: 24); // 완료 상태 표시
//       case LearningCardState.locked:
//         return Icon(Icons.lock, color: customColors.neutral60, size: 24); // 잠김 상태 표시
//     }
//   }
//
//   // 공통 버튼 생성
//   Widget _buildActionButton(BuildContext context, String label, Color color, VoidCallback onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       ),
//       child: Text(
//         label,
//         style: body_xsmall_semi(context),
//       ),
//     );
//   }
//
//   // 상세 페이지로 이동
//   void _navigateToDetailPage(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CourseDetailPage(
//           title: data.subdetailTitle[index],
//           time: data.totalTime[index],
//           level: data.difficultyLevel[index],
//           description: data.textContents[index],
//           imageUrl: data.imageUrls[index],
//           mission: data.missions[index],
//           effect: data.effects[index],
//         ),
//       ),
//     );
//   }
// }
//
// /// _CardDetails
// /// - 하단의 아이콘 및 텍스트 영역은 기존 방식 유지.
// class _CardDetails extends StatelessWidget {
//   final SectionData data;
//   final int index;
//
//   const _CardDetails({required this.data, required this.index});
//
//   @override
//   Widget build(BuildContext context) {
//     final customColors = Theme.of(context).extension<CustomColors>()!;
//
//     return Row(
//       children: [
//         _IconWithText(
//           icon: Icons.check_circle, // 달성률 아이콘
//           text: '${data.achievement[index]}%', // 달성률 텍스트
//           color: customColors,
//         ),
//         const SizedBox(width: 8),
//         _IconWithText(
//           icon: Icons.timer, // 시간 아이콘
//           text: '${data.totalTime[index]}분', // 시간 텍스트
//           color: customColors,
//         ),
//         const SizedBox(width: 8),
//         _IconWithText(
//           icon: Icons.star, // 난이도 아이콘
//           text: data.difficultyLevel[index], // 난이도 텍스트
//           color: customColors,
//         ),
//       ],
//     );
//   }
// }
//
// /// _IconWithText
// /// - 아이콘과 텍스트를 조합하여 표시.
// class _IconWithText extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   final CustomColors color;
//
//   const _IconWithText({required this.icon, required this.text, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, color: color.neutral90, size: 16),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: body_xsmall_semi(context).copyWith(color: color.neutral90),
//         ),
//       ],
//     );
//   }
// }
