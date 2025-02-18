/*
// 사용 예시
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
*/

import 'package:flutter/material.dart';
import 'package:readventure/view/community/Board/post_editPage.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../components/alarm_dialog.dart';
import '../community_data_firebase.dart';
import '../community_service.dart';

class PostActionBottomSheet extends StatelessWidget {
  final Post post;
  final CustomColors customColors;
  final BuildContext parentContext;

  const PostActionBottomSheet({
    Key? key,
    required this.post,
    required this.customColors,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Center(child: Text('편집', style: body_large(context))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostEditPage(post: post)),
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Center(child: Text('삭제', style: body_large(context))),
              onTap: () {
                Navigator.pop(context);
                showResultSaveDialog(
                  parentContext,
                  customColors,
                  "삭제하시겠습니까?",
                  "취소",
                  "삭제",
                      (ctx) async {
                    try {
                      await CommunityService().deletePost(post.id);
                    } catch (e) {
                      // 오류 처리
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Center(child: Text('공유', style: body_large(context))),
              onTap: () {
                Navigator.pop(context);
                Share.share('${post.title}\n${post.content}');
              },
            ),
          ],
        ),
      ),
    );
  }
}

