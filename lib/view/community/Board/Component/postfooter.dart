/// 파일: postfooter.dart
/// 목적: 게시글 하단에 작성자 정보, 좋아요 및 조회수를 표시하는 UI 및 로직 제공
/// 작성자: 강희
/// 생성일: 2024-12-28
/// 마지막 수정일: 2024-12-28 by 강희

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../community_data_firebase.dart';

/// 포스트 하단 정보를 표시하는 위젯
///
/// - 작성자 정보
/// - 좋아요 개수
/// - 조회수
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
        /// 작성자 정보를 표시하는 위젯
        _buildWriterInformation(context),

        /// 좋아요 및 조회수 정보를 오른쪽 정렬하여 표시하는 위젯
        _buildLikeAndView(context),
      ],
    );
  }

  /// 좋아요 및 조회수 정보를 오른쪽에 정렬하여 표시하는 위젯
  Widget _buildLikeAndView(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildPreviewLike(context), // 좋아요 개수 표시
            const SizedBox(width: 8),
            _buildPreviewView(context), // 조회수 표시
          ],
        ),
      ),
    );
  }

  /// 좋아요 개수를 표시하는 위젯
  Widget _buildPreviewLike(BuildContext context) {
    return Row(
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
    );
  }

  /// 조회수 정보를 표시하는 위젯
  Widget _buildPreviewView(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.remove_red_eye,
          size: 16,
          color: customColors.neutral60,
        ),
        const SizedBox(width: 4),
        Text(
          post.views.toString(),
          style: body_xxsmall_semi(context)
              .copyWith(color: customColors.neutral60),
        ),
      ],
    );
  }

  /// 작성자 정보를 표시하는 위젯
  ///
  /// Firebase Firestore에서 작성자 정보를 가져와 프로필 이미지를 표시합니다.
  Widget _buildWriterInformation(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(post.authorId)
          .get(),
      builder: (context, snapshot) {
        // 기본 아바타 이미지 경로
        String imageUrl = 'assets/images/default_avatar.png';

        if (snapshot.connectionState == ConnectionState.waiting) {
          /// 로딩 중이면 기본 아바타와 로딩 인디케이터를 표시
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
        }

        // 데이터 로드 성공 시 프로필 이미지 적용
        if (snapshot.hasData) {
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
