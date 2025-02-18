import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../community/Board/community_data_firebase.dart';
import '../../community/Board/community_service.dart';
import '../../community/Board/component_community_post_firebase.dart';
import '../../components/custom_app_bar.dart';
import '../../components/my_divider.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../../viewmodel/custom_colors_provider.dart';

class MyPostsPage extends ConsumerWidget {
  final CommunityService _communityService = CommunityService();

  MyPostsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '커뮤니티 작성글',
      ),
      body: StreamBuilder<List<Post>>(
        stream: _communityService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '오류가 발생했습니다.',
                style: body_small(context).copyWith(color: customColors.neutral60),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                '게시글이 없습니다.',
                style: body_small(context).copyWith(color: customColors.neutral60),
              ),
            );
          }

          // 현재 로그인한 사용자가 작성한 게시글만 필터링
          List<Post> posts = snapshot.data!
              .where((post) => post.authorId == currentUser?.uid)
              .toList();

          if (posts.isEmpty) {
            return Center(
              child: Text(
                '내가 작성한 글이 없습니다.',
                style: body_small(context).copyWith(color: customColors.neutral60),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length * 2 - 1,
            itemBuilder: (context, index) {
              if (index.isOdd) {
                return const BigDivider();
              } else {
                final post = posts[index ~/ 2];
                return PostItemContainer(
                  post: post,
                  customColors: customColors,
                  parentContext: context,
                );
              }
            },
          );
        },
      ),
    );
  }
}
