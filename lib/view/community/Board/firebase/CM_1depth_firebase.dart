import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/custom_navigation_bar.dart';
import '../CM_2depth_board.dart';
import '../CM_2depth_boardMain.dart';
import 'CM_2depth_boardMain_firebase.dart';
import '../community_searchpage.dart';
import 'community_data_firebase.dart';
import 'community_searchpage_firebase.dart';
import 'posting_detail_page.dart';
import '../../Ranking/CM_2depth_ranking.dart';
import '../../Ranking/ranking_component.dart';
import '../community_data.dart';
import 'community_service.dart';

class CommunityMainPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final communityService = CommunityService(); // CommunityService 인스턴스 생성

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_Community(
        onSearchPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()), // 검색 페이지 이동
          );
        },
      ),
      body: StreamBuilder<List<Post>>(
        stream: communityService.getPosts(), // Firestore에서 게시글 목록 가져오기
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 데이터 로딩 중 표시
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("게시글이 없습니다.")); // 데이터가 없는 경우 처리
          }

          final posts = snapshot.data!; // Firestore에서 가져온 게시글 리스트

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: RankingPreview(context, customColors),
                ),
                SizedBox(height: 24),
                CommunityPreview(posts, context, customColors), // 게시글 미리보기
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }


  Widget CommunityPreview(posts, BuildContext context, CustomColors customColors) {
    // 게시글을 좋아요 수 기준 내림차순 정렬합니다.
    List<Post> sortedPosts = List.from(posts);
    sortedPosts.sort((a, b) => b.likes.compareTo(a.likes));

    // 정렬된 게시글 중 상위 3개만 사용합니다.
    final topPosts = sortedPosts.take(3).toList();

    return Column(
      children: [
        postnavigation(context, customColors),
        Container(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topPosts.length,
            itemBuilder: (context, index) {
              var post = topPosts[index];
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
                  width: 250,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: customColors.neutral100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Row(
                            children: post.tags
                                .map<Widget>((tag) => Padding(
                              padding:
                              const EdgeInsets.only(right: 8),
                              child: Text(
                                '#'+tag,
                                style: body_xxsmall(context)
                                    .copyWith(
                                    color:
                                    customColors.primary60),
                              ),
                            ))
                                .toList(),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                formatPostDate(post.createdAt),
                                style: body_xxsmall(context)
                                    .copyWith(color: customColors.neutral60),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.title,
                        style: body_small_semi(context),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          post.content,
                          style: body_xxsmall(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Spacer(),
                      Row(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                NetworkImage(post.profileImage),
                                radius: 12,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                post.nickname,
                                style: body_xsmall_semi(context)
                                    .copyWith(
                                    color: customColors.neutral30),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.favorite,
                                          size: 16,
                                          color: customColors.neutral60),
                                      const SizedBox(width: 4),
                                      Text(
                                        post.likes.toString(),
                                        style: body_xxsmall_semi(context)
                                            .copyWith(
                                            color: customColors
                                                .neutral60),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.remove_red_eye,
                                          size: 16,
                                          color: customColors.neutral60),
                                      const SizedBox(width: 4),
                                      Text(
                                        post.views.toString(),
                                        style: body_xxsmall_semi(context)
                                            .copyWith(
                                            color: customColors
                                                .neutral60),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
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

  Widget RankingPreview(BuildContext context, CustomColors customColors) {
    return Column(
      children: [
        rankingnavigation(context, customColors),
        Container(
          decoration: BoxDecoration(
            color: customColors.neutral100,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              buildTopThree(context, customColors),
              buildPodium(context, customColors),
            ],
          ),
        ),
      ],
    );
  }

  Widget postnavigation(BuildContext context, CustomColors customColors) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        '게시판',
        style: body_small_semi(context),
      ),
      trailing: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Cm2depthBoardmain()),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '더보기',
              style: body_xxsmall_semi(context),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: customColors.neutral0,
            ),
          ],
        ),
      ),
    );
  }

  Widget rankingnavigation(BuildContext context, CustomColors customColors) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        '랭킹',
        style: body_small_semi(context),
      ),
      trailing: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RankingPage()),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '더보기',
              style: body_xxsmall_semi(context),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: customColors.neutral0,
            ),
          ],
        ),
      ),
    );
  }

  String formatPostDate(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return "방금 전";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}분 전";
    } else if (difference.inHours < 24) {
      return "${(difference.inMinutes / 60).ceil()}시간 전"; // 79분이면 2시간 전
    } else {
      return "${difference.inDays}일 전";
    }
  }

}
