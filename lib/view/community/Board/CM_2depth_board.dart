//
// // post_detail_page.dart
// import 'package:flutter/material.dart';
// import '../../../theme/font.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../viewmodel/custom_colors_provider.dart';
// import '../../components/custom_app_bar.dart';
// import 'CM_2depth_boardMain_firebase.dart';
// import 'community_data.dart';
//
// class PostDetailPage extends ConsumerWidget {
//   final Post post;
//
//   const PostDetailPage({Key? key, required this.post}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final customColors = ref.watch(customColorsProvider);
//     return Scaffold(
//       appBar: CustomAppBar_2depth_4(title: '게시판'),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Row(
//                     children: post.tags
//                         .map<Widget>((tag) => Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: Text(
//                         tag,
//                         style: body_xsmall(context).copyWith(color: customColors.primary60),
//                       ),
//                     ))
//                         .toList(),
//                   ),
//                   Expanded(
//                     child: Align(
//                       alignment: Alignment.centerRight, // Align to the right
//                       child: Text(
//                         formatPostDate(post.createdAt),
//                         style: body_xsmall(context).copyWith(color: customColors.neutral60),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 post.title,
//                 style: heading_medium(context),
//               ),
//               const SizedBox(height: 10),
//               Text(post.content, style: reading_exercise(context),),
//               const SizedBox(height: 20),
//               // 프로필 정보
//               Row(
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         backgroundImage: NetworkImage(post.profileImage),
//                         radius: 16, // Adjusted profile image size
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         post.authorName,
//                         style: body_xsmall_semi(context).copyWith(color: customColors.neutral30),
//                       ),
//                     ],
//                   ),
//                   Expanded( // Ensure this is wrapping the whole content
//                     child: Align(
//                       alignment: Alignment.centerRight, // Align to the right
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end, // Ensures the likes/views are pushed to the right
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.favorite, size: 20, color: customColors.neutral60),
//                               const SizedBox(width: 4),
//                               Text(
//                                 post.likes.toString(),
//                                 style: body_xsmall_semi(context).copyWith(color: customColors.neutral60),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(width: 8),
//                           Row(
//                             children: [
//                               Icon(Icons.remove_red_eye, size: 20, color: customColors.neutral60),
//                               const SizedBox(width: 4),
//                               Text(
//                                 post.views.toString(),
//                                 style: body_xsmall_semi(context).copyWith(color: customColors.neutral60),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//   String formatPostDate(DateTime? postDate) {
//     if (postDate == null) {
//       return '알 수 없음'; // Handle the case when the postDate is null
//     }
//
//     final now = DateTime.now();
//     final difference = now.difference(postDate);
//
//     if (difference.inDays > 1) {
//       return '${postDate.month}/${postDate.day}/${postDate.year}';
//     } else if (difference.inDays == 1) {
//       return '어제';
//     } else if (difference.inHours > 1) {
//       return '${difference.inHours}시간 전';
//     } else if (difference.inMinutes > 1) {
//       return '${difference.inMinutes}분 전';
//     } else {
//       return '방금 전';
//     }
//   }
// }
