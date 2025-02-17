import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../firebase/community_data_firebase.dart';

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
    return Container(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: customColors.neutral90,
              backgroundImage: post.profileImage.startsWith('http')
                  ? NetworkImage(post.profileImage)
                  : AssetImage(post.profileImage) as ImageProvider,
              radius: 12,
            ),
            const SizedBox(width: 8),
            Text(
              post.nickname,
              style: body_xsmall_semi(context)
                  .copyWith(color: customColors.neutral30),
            ),
          ],
        ),
      );
  }
}
