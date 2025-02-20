/*
// PostActionBottomSheet: 게시글의 편집, 삭제, 공유 등의 액션을 제공하는 BottomSheet 위젯입니다.
// 사용 예시:
// void showPostActionBottomSheet(BuildContext context, Post post, CustomColors customColors, BuildContext parentContext) {
//   showModalBottomSheet(
//     context: context,
//     builder: (context) => PostActionBottomSheet(
//       post: post,
//       customColors: customColors,
//       parentContext: parentContext,
//     ),
//   );
// }
*/

import 'package:flutter/material.dart';
import 'package:readventure/view/community/Board/post_editPage.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../components/alarm_dialog.dart';
import '../community_data_firebase.dart';
import '../community_service.dart';

// PostActionBottomSheet 클래스
// 게시글에 대한 여러 가지 액션(편집, 삭제, 공유)을 선택할 수 있는 BottomSheet 위젯.
class PostActionBottomSheet extends StatelessWidget {
  final Post post;  // 처리할 게시글 데이터
  final CustomColors customColors;  // 사용자 정의 색상
  final BuildContext parentContext;  // 부모 컨텍스트

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
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),  // BottomSheet의 내부 여백
        child: Column(
          mainAxisSize: MainAxisSize.min,  // 최소 크기로 설정하여 BottomSheet가 커지지 않도록 함
          children: [
            // 편집 버튼
            ListTile(
              title: Center(child: Text('편집', style: body_large(context))),  // 편집 텍스트
              onTap: () {
                Navigator.pop(context);  // BottomSheet 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostEditPage(post: post)),  // 편집 페이지로 이동
                );
              },
            ),
            const SizedBox(height: 10),  // 버튼 간 간격
            // 삭제 버튼
            ListTile(
              title: Center(child: Text('삭제', style: body_large(context))),  // 삭제 텍스트
              onTap: () {
                Navigator.pop(context);  // BottomSheet 닫기
                showResultSaveDialog(
                  parentContext,
                  customColors,
                  "삭제하시겠습니까?",  // 삭제 확인 메시지
                  "취소",
                  "삭제",
                      (ctx) async {
                    try {
                      await CommunityService().deletePost(post.id);  // 게시글 삭제
                    } catch (e) {
                      // 오류 처리
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 10),  // 버튼 간 간격
            // 공유 버튼
            ListTile(
              title: Center(child: Text('공유', style: body_large(context))),  // 공유 텍스트
              onTap: () {
                Navigator.pop(context);  // BottomSheet 닫기
                Share.share('${post.title}\n${post.content}');  // 게시글 제목과 내용 공유
              },
            ),
          ],
        ),
      ),
    );
  }
}
