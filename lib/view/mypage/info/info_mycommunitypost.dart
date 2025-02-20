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
    // 커스텀 색상 테마를 가져옴
    final customColors = ref.watch(customColorsProvider);
    // 현재 로그인한 사용자 정보 가져오기
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // 커스텀 앱바 사용 (제목: '커뮤니티 작성글')
      appBar: CustomAppBar_2depth_4(
        title: '커뮤니티 작성글',
      ),
      // Firestore에서 게시글 데이터를 실시간으로 가져오는 StreamBuilder
      body: StreamBuilder<List<Post>>(
        stream: _communityService.getPosts(), // 게시글 목록 가져오기
        builder: (context, snapshot) {
          // 데이터 로딩 중일 때 로딩 인디케이터 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 오류 발생 시 오류 메시지 표시
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '오류가 발생했습니다.',
                style: body_small(context).copyWith(color: customColors.neutral60),
              ),
            );
          }
          // 게시글이 없을 경우 메시지 표시
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

          // 사용자가 작성한 글이 없을 경우 메시지 표시
          if (posts.isEmpty) {
            return Center(
              child: Text(
                '내가 작성한 글이 없습니다.',
                style: body_small(context).copyWith(color: customColors.neutral60),
              ),
            );
          }

          // 게시글 리스트 출력 (게시글 사이에 구분선 추가)
          return ListView.builder(
            itemCount: posts.length * 2 - 1, // 구분선을 포함한 아이템 개수 설정
            itemBuilder: (context, index) {
              if (index.isOdd) {
                // 홀수 인덱스에는 구분선 추가
                return const BigDivider();
              } else {
                // 짝수 인덱스에는 게시글 출력
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
