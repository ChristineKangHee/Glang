import 'package:flutter/material.dart';

import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../CM_2depth_board.dart';
import '../firebase/CM_2depth_boardMain_firebase.dart';
import '../community_data.dart';
import '../firebase/posting_detail_page.dart';
import 'community_data_firebase.dart';

class PostItemContainer extends StatelessWidget {
  final Post post;
  final CustomColors customColors;
  final BuildContext context;

  PostItemContainer({
    required this.post,
    required this.customColors,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailPage(post: post),
          ),
        );
      },
      child: Container(
        color: customColors.neutral100,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: post.tags
                      .map<Widget>((tag) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '#'+tag,
                      style: body_xxsmall(context).copyWith(color: customColors.primary60),
                    ),
                  ))
                      .toList(),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      formatPostDate(post.createdAt),
                      style: body_xxsmall(context).copyWith(color: customColors.neutral60),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.title,
              style: body_small_semi(context),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: body_xxsmall(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(post.profileImage),
                      radius: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      post.authorName,
                      style: body_xsmall_semi(context).copyWith(color: customColors.neutral30),
                    ),
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, size: 16, color: customColors.neutral60),
                            const SizedBox(width: 4),
                            Text(
                              post.likes.toString(),
                              style: body_xxsmall_semi(context).copyWith(color: customColors.neutral60),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(Icons.remove_red_eye, size: 16, color: customColors.neutral60),
                            const SizedBox(width: 4),
                            Text(
                              post.views.toString(),
                              style: body_xxsmall_semi(context).copyWith(color: customColors.neutral60),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatPostDate(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return "방금 전";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}분 전";
    } else if (difference.inHours < 24) {
      return "${(difference.inMinutes / 60).ceil()}시간 전"; // 79분이면 2시간 전
    } else {
      return "${difference.inDays}일 전";
    }
  }
}
