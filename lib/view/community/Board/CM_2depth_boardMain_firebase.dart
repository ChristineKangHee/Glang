/// File: CM_2depth_boardMain_firebase.dart
/// Purpose: 커뮤니티 게시판 화면 (Cm2depthBoardmain)
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../components/my_divider.dart';
import 'community_data_firebase.dart';
import 'community_searchpage_firebase.dart';
import 'community_service.dart';
import 'component_community_post_firebase.dart';
import 'essay_posting_firebase.dart';
import 'free_posting_firebase.dart';
import 'mission_posting.dart';

/// 🔹 커뮤니티 게시판 화면 (Cm2depthBoardmain)
class Cm2depthBoardmain extends ConsumerWidget {
  final CommunityService _communityService = CommunityService(); // 🔹 커뮤니티 서비스 인스턴스

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider); // 🔹 사용자 정의 색상
    final isDialOpen = ValueNotifier(false); // 🔹 플로팅 액션 버튼 상태

    return Scaffold(
      appBar: CustomAppBar_2depth_5( // 🔹 커스텀 앱바
        title: '게시판', // 🔹 제목
        onIconPressed: () { // 🔹 아이콘 클릭 시 검색 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
        },
      ),
      body: DefaultTabController(
        length: 3, // 🔹 탭 개수
        child: Column(
          children: [
            TabBar(
              labelStyle: body_small_semi(context), // 🔹 탭 라벨 스타일
              indicatorColor: customColors.primary, // 🔹 탭 선택 색상
              dividerColor: customColors.neutral80, // 🔹 탭 구분선 색상
              tabs: const [
                Tab(text: '전체'), // 🔹 전체 탭
                Tab(text: '에세이'), // 🔹 에세이 탭
                Tab(text: '자유글'), // 🔹 자유글 탭
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPostList(context, customColors, category: null), // 🔹 전체 게시글 리스트
                  _buildPostList(context, customColors, category: '에세이'), // 🔹 에세이 게시글 리스트
                  _buildPostList(context, customColors, category: '자유글'), // 🔹 자유글 게시글 리스트
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDial(context, isDialOpen, customColors), // 🔹 플로팅 액션 버튼
    );
  }

  /// 🔹 Firestore에서 게시글을 가져와 표시하는 위젯
  Widget _buildPostList(BuildContext context, CustomColors customColors, {dynamic category}) {
    return StreamBuilder<List<Post>>(
      stream: _communityService.getPosts(), // 🔹 게시글 데이터 스트림
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { // 🔹 데이터 로딩 중
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) { // 🔹 에러 발생 시
          return SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) { // 🔹 데이터가 없을 경우
          return Center(
            child: Text(
              '게시글이 없습니다.',
              style: body_small(context).copyWith(color: customColors.neutral60),
            ),
          );
        }

        // 🔹 카테고리 필터 적용 (category가 null이면 전체 게시글을 반환)
        List<Post> posts = snapshot.data!.where((post) {
          if (category == null) return true;
          if (category is List<String>) return category.contains(post.category);
          return post.category == category;
        }).toList();

        if (posts.isEmpty) { // 🔹 필터링된 게시글이 없을 경우
          return Center(
            child: Text(
              '해당 카테고리에 게시글이 없습니다.',
              style: body_small(context).copyWith(color: customColors.neutral60),
            ),
          );
        }

        return ListView.builder(
          itemCount: posts.length * 2 - 1, // 🔹 게시글 항목 개수
          itemBuilder: (context, index) {
            if (index.isOdd) { // 🔹 짝수 번째는 구분선
              return BigDivider();
            } else {
              var post = posts[index ~/ 2]; // 🔹 게시글 항목
              return PostItemContainer(
                post: post,
                customColors: customColors,
                parentContext: context,
              );
            }
          },
        );
      },
    );
  }

  /// 🔹 플로팅 버튼 (글쓰기 기능)
  Widget _buildSpeedDial(BuildContext context, ValueNotifier<bool> isDialOpen, CustomColors customColors) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDialOpen,
      builder: (context, isOpen, _) {
        return SpeedDial(
          icon: isOpen ? Icons.close : Icons.create, // 🔹 버튼 아이콘
          backgroundColor: customColors.primary, // 🔹 버튼 배경색
          overlayColor: customColors.neutral0, // 🔹 오버레이 색상
          overlayOpacity: 0.5, // 🔹 오버레이 투명도
          onOpen: () => isDialOpen.value = true, // 🔹 버튼 열기
          onClose: () => isDialOpen.value = false, // 🔹 버튼 닫기
          children: [
            SpeedDialChild(
              child: Icon(Icons.article, color: customColors.neutral30), // 🔹 자유글 아이콘
              label: '자유글',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FreeWritingPage()),
                );
              },
              shape: CircleBorder(),
              labelShadow: [],
              labelStyle: body_small_semi(context).copyWith(color: customColors.neutral100),
              labelBackgroundColor: Colors.transparent,
              backgroundColor: customColors.primary20,
            ),
            SpeedDialChild(
              child: Icon(Icons.lightbulb, color: customColors.neutral30), // 🔹 에세이 아이콘
              label: '에세이',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EssayPostPage()),
                );
              },
              shape: CircleBorder(),
              labelShadow: [],
              labelStyle: body_small_semi(context).copyWith(color: customColors.neutral100),
              labelBackgroundColor: Colors.transparent,
              backgroundColor: customColors.primary20,
            ),
            // SpeedDialChild(
            //   child: Icon(Icons.upload_rounded, color: customColors.neutral30),
            //   label: '미션 글 업로드',
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => MissionPostPage()),
            //     );
            //   },
            //   shape: CircleBorder(),
            //   labelShadow: [],
            //   labelStyle: body_small_semi(context).copyWith(color: customColors.neutral100),
            //   labelBackgroundColor: Colors.transparent,
            //   backgroundColor: customColors.primary20,
            // ),
          ],
        );
      },
    );
  }
}
