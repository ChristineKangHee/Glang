import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../community_data_firebase.dart';
import '../component_community_post_firebase.dart';

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
        // 태그 리스트
        CommunityTagList(context),
        // 작성 일자
        WrittenDate(context),
      ],
    );
  }

  Widget WrittenDate(BuildContext context) {
    return Container(
        child: Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              formatPostDate(post.createdAt),
              style:
              body_xxsmall(context).copyWith(color: customColors.neutral60),
            ),
          ),
        ),
      );
  }

  Widget CommunityTagList(BuildContext context) {
    return Container(
        child: Row(
          children: post.tags
              .map(
                (tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '#$tag',
                style: body_xxsmall(context)
                    .copyWith(color: customColors.primary60),
              ),
            ),
          )
              .toList(),
        ),
      );
  }
}
