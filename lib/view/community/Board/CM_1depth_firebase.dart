/// File: CM_1depth_firebase.dart
/// Purpose: 커뮤니티 메인 페이지
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/community/Board/posting_detail_page.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_navigation_bar.dart';
import '../../widgets/DoubleBackToExitWrapper.dart';
import 'Component/postHeader.dart';
import 'Component/postfooter.dart';
import 'CM_2depth_boardMain_firebase.dart';
import 'community_data_firebase.dart';
import 'community_searchpage_firebase.dart';
import '../Ranking/CM_2depth_ranking.dart';
import '../Ranking/ranking_component.dart';
import 'community_service.dart';

/// 커뮤니티 메인 페이지
class CommunityMainPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);  // 커스텀 색상 정보 가져오기
    final communityService = CommunityService();  // 커뮤니티 서비스 객체 생성

    return DoubleBackToExitWrapper(  // 뒤로가기 두 번으로 앱 종료 기능 래핑
      child: Scaffold(
        backgroundColor: customColors.neutral90,  // 배경 색상 설정
        appBar: CustomAppBar_Community(  // 커스텀 앱바
          onSearchPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),  // 검색 페이지로 이동
            );
          },
        ),
        body: StreamBuilder<List<Post>>(  // 게시글 데이터를 스트림으로 받기
          stream: communityService.getPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());  // 로딩 중일 때 로딩 표시
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("게시글이 없습니다."));  // 데이터가 없으면 게시글이 없다는 메시지 표시
            }

            final posts = snapshot.data!;

            return SingleChildScrollView(  // 스크롤 가능 영역 설정
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildRankingPreview(context, customColors),  // 랭킹 미리보기 빌드
                  ),
                  const SizedBox(height: 24),
                  CommunityPreview(posts, context, customColors),  // 커뮤니티 미리보기 빌드
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const CustomNavigationBar(),  // 커스텀 네비게이션 바
      ),
    );
  }

  /// 랭킹 미리보기 위젯
  Widget _buildRankingPreview(BuildContext context, CustomColors customColors) {
    return Column(
      children: [
        _buildRankingNavigation(context, customColors),  // 랭킹 내비게이션
        Container(
          decoration: BoxDecoration(
            color: customColors.neutral100,  // 배경 색상 설정
            borderRadius: BorderRadius.circular(16),  // 둥근 모서리
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildTopThreeWithPodium(context, customColors),  // 상위 3명 랭킹 표시
            ],
          ),
        ),
      ],
    );
  }

  /// 랭킹 내비게이션
  Widget _buildRankingNavigation(BuildContext context, CustomColors customColors) {
    return ListTile(
      contentPadding: EdgeInsets.zero,  // 패딩 제거
      title: Text(
        '랭킹',  // 제목: 랭킹
        style: body_small_semi(context),
      ),
      trailing: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RankingPage()),  // 랭킹 페이지로 이동
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '더보기',  // 더보기 버튼
              style: body_xxsmall_semi(context),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,  // 화살표 아이콘
              size: 16,
              color: customColors.neutral0,  // 아이콘 색상
            ),
          ],
        ),
      ),
    );
  }
}

/// 커뮤니티 미리보기 페이지
class CommunityPreview extends StatefulWidget {
  final List<Post> posts;  // 게시글 목록
  final BuildContext context;  // 빌드 컨텍스트
  final CustomColors customColors;  // 커스텀 색상

  const CommunityPreview(
      this.posts,
      this.context,
      this.customColors, {
        Key? key,
      }) : super(key: key);

  @override
  _CommunityPreviewState createState() => _CommunityPreviewState();
}

class _CommunityPreviewState extends State<CommunityPreview> {
  late PageController _pageController;  // 페이지 컨트롤러

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);  // 페이지 컨트롤러 초기화
  }

  @override
  void dispose() {
    _pageController.dispose();  // 페이지 컨트롤러 리소스 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 좋아요 수 기준 내림차순 정렬 후 상위 3개의 게시글 선택
    List<Post> sortedPosts = List.from(widget.posts)
      ..sort((a, b) => b.likes.compareTo(a.likes));
    final topPosts = sortedPosts.take(3).toList();  // 상위 3개 게시글만 가져오기

    return Column(
      children: [
        _buildPostNavigation(context, widget.customColors),  // 게시판 내비게이션
        SizedBox(
          height: 190,  // 게시글 미리보기 높이 설정
          child: PageView.builder(
            padEnds: false,
            controller: _pageController,
            itemCount: topPosts.length,
            itemBuilder: (context, index) {
              final post = topPosts[index];
              // 첫번째는 왼쪽 마진 16, 나머지는 8; 마지막은 오른쪽 마진 16, 나머지는 8
              final double leftMargin = index == 0 ? 16.0 : 8.0;
              final double rightMargin = index == topPosts.length - 1 ? 16.0 : 8.0;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailPage(post: post),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: EdgeInsets.only(left: leftMargin, right: rightMargin),
                  decoration: BoxDecoration(
                    color: widget.customColors.neutral100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더: 태그와 날짜 표시
                      PostHeader(post: post, customColors: widget.customColors),
                      const SizedBox(height: 8),
                      Text(
                        post.title,  // 게시글 제목
                        style: body_small_semi(context),
                        overflow: TextOverflow.ellipsis,  // 제목이 길어지면 생략 표시
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          post.content,  // 게시글 내용
                          style: body_xxsmall(context),
                          maxLines: 2,  // 내용 최대 2줄 표시
                          overflow: TextOverflow.ellipsis,  // 내용이 길어지면 생략 표시
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 풋터: 작성자, 좋아요, 조회수 표시
                      PostFooter(post: post, customColors: widget.customColors),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 게시판 내비게이션
  Widget _buildPostNavigation(BuildContext context, CustomColors customColors) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        '게시판',  // 제목: 게시판
        style: body_small_semi(context),
      ),
      trailing: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Cm2depthBoardmain()),  // 게시판 상세 페이지로 이동
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '더보기',  // 더보기 버튼
              style: body_xxsmall_semi(context),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,  // 화살표 아이콘
              size: 16,
              color: customColors.neutral0,  // 아이콘 색상
            ),
          ],
        ),
      ),
    );
  }
}
