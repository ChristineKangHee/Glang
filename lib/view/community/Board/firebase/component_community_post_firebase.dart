import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readventure/view/community/Board/firebase/post_editPage.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../components/alarm_dialog.dart';
import '../CM_2depth_board.dart';
import '../Component/postHeader.dart';
import '../Component/postaction_bottomsheet.dart';
import '../Component/postfooter.dart';
import '../firebase/CM_2depth_boardMain_firebase.dart';
import '../community_data.dart';
import '../firebase/posting_detail_page.dart';
import 'community_data_firebase.dart';
import 'community_service.dart'; // 삭제/수정 기능 사용을 위한 서비스
import 'package:share_plus/share_plus.dart';

class PostItemContainer extends StatelessWidget {
  final Post post;
  final CustomColors customColors;
  final BuildContext parentContext; // 부모 컨텍스트 (필요시 사용)

  const PostItemContainer({
    Key? key,
    required this.post,
    required this.customColors,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: 태그와 작성 일자
            PostHeader(post: post, customColors: customColors),
            const SizedBox(height: 8),
            // 제목과 내가 쓴 게시물인 경우 more_vert 아이콘을 Row로 배치
            Row(
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: body_small_semi(context),
                  ),
                ),
                if (currentUser != null && post.authorId == currentUser.uid)
                  IconButton(
                    icon: Icon(Icons.more_vert_rounded, color: customColors.neutral80),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      showPostActionBottomSheet(context, post, customColors, parentContext);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: body_xsmall(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Footer: 작성자, 좋아요, 조회수
            PostFooter(post: post, customColors: customColors),
          ],
        ),
      ),
    );
  }

  void showPostActionBottomSheet(BuildContext context, Post post, CustomColors customColors, BuildContext parentContext) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PostActionBottomSheet(
        post: post,
        customColors: customColors,
        parentContext: parentContext,
      ),
    );
  }

}

String formatPostDate(DateTime createdAt) {
  final now = DateTime.now();
  final difference = now.difference(createdAt);

  if (difference.inMinutes < 1) {
    return "방금 전";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes}분 전";
  } else if (difference.inHours < 24) {
    return "${(difference.inMinutes / 60).ceil()}시간 전";
  } else if (difference.inDays <= 3) { // 3일 이내
    return "${difference.inDays}일 전";
  } else { // 3일 초과
    return "${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}";
  }
}
