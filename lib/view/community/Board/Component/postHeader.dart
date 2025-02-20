/// File: postHeader.dart
/// Purpose: 게시글 헤더 위젯
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희
import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../community_data_firebase.dart';
import '../component_community_post_firebase.dart';

/// 게시글 헤더 위젯
/// - 태그 리스트 및 작성 일자를 표시
class PostHeader extends StatelessWidget {
  final Post post;
  final CustomColors customColors;

  const PostHeader({
    Key? key,
    required this.post,
    required this.customColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 게시글 태그 리스트
        _buildCommunityTagList(context),
        // 작성 일자
        _buildWrittenDate(context),
      ],
    );
  }

  /// 작성 일자를 표시하는 위젯
  Widget _buildWrittenDate(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          formatPostDate(post.createdAt), // 날짜 포맷팅 함수 호출
          style: body_xxsmall(context).copyWith(color: customColors.neutral60),
        ),
      ),
    );
  }

  /// 커뮤니티 태그 리스트를 표시하는 위젯
  Widget _buildCommunityTagList(BuildContext context) {
    return Row(
      children: post.tags
          .map(
            (tag) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            '#$tag', // 태그 앞에 '#' 추가
            style: body_xxsmall(context)
                .copyWith(color: customColors.primary60),
          ),
        ),
      )
          .toList(),
    );
  }
}
