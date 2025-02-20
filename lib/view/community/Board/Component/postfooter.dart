import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../community_data_firebase.dart';

class PostFooter extends StatelessWidget {
  final Post post;
  final CustomColors customColors;
  /// 인터랙티브한 좋아요 버튼이 필요한 경우 true로 설정하고 onLikePressed를 전달하세요.
  final bool isInteractive;
  final VoidCallback? onLikePressed;

  const PostFooter({
    Key? key,
    required this.post,
    required this.customColors,
    this.isInteractive = false,
    this.onLikePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 작성자 정보
        WriterInformation(context),
        // 좋아요 및 조회수 통계
        LikeAndView(context),
      ],
    );
  }

  Widget LikeAndView(BuildContext context) {
    return Container(
        child: Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 좋아요 부분
                PreviewLike(context),
                const SizedBox(width: 8),
                // 조회수 부분
                PreviewView(context),
              ],
            ),
          ),
        ),
      );
  }

  Widget PreviewView(BuildContext context) {
    return Container(
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye,
                        size: 16, color: customColors.neutral60),
                    const SizedBox(width: 4),
                    Text(
                      post.views.toString(),
                      style: body_xxsmall_semi(context)
                          .copyWith(color: customColors.neutral60),
                    ),
                  ],
                ),
              );
  }

  Widget PreviewLike(BuildContext context) {
    return Container(
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: customColors.neutral60,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.likes.toString(),
                      style: body_xxsmall_semi(context)
                          .copyWith(color: customColors.neutral60),
                    ),
                  ],
                ),
              );
  }

  Widget WriterInformation(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(post.authorId)
          .get(),
      builder: (context, snapshot) {
        String imageUrl = 'assets/images/default_avatar.png';

        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중에는 기본 아바타 또는 로딩 인디케이터 표시
          return Row(
            children: [
              CircleAvatar(
                backgroundColor: customColors.neutral90,
                radius: 12,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(
                post.nickname,
                style: body_xsmall_semi(context)
                    .copyWith(color: customColors.neutral30),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          // 에러 발생 시 기본 아바타 사용
          imageUrl = 'assets/images/default_avatar.png';
        } else if (snapshot.hasData) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null &&
              userData['photoURL'] != null &&
              userData['photoURL'].toString().isNotEmpty) {
            imageUrl = userData['photoURL'];
          }
        }

        return Row(
          children: [
            CircleAvatar(
              backgroundColor: customColors.neutral90,
              backgroundImage: imageUrl.startsWith('http')
                  ? NetworkImage(imageUrl)
                  : AssetImage(imageUrl) as ImageProvider,
              radius: 12,
            ),
            const SizedBox(width: 8),
            Text(
              post.nickname,
              style: body_xsmall_semi(context)
                  .copyWith(color: customColors.neutral30),
            ),
          ],
        );
      },
    );
  }

}
