import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_navigation_bar.dart';
import 'Board/CM_2depth_board.dart';
import 'Board/CM_2depth_boardMain.dart';
import 'Board/CM_2depth_boardMain_firebase.dart';
import 'Board/community_searchpage.dart';
import 'Board/posting_detail_page.dart';
import 'Ranking/CM_2depth_ranking.dart';
import 'Ranking/ranking_component.dart';
import 'Board/community_data.dart';
import 'community_service.dart';

class CommunityMainPage extends ConsumerWidget {
  final CommunityService _communityService = CommunityService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      backgroundColor: customColors.neutral90,
      appBar: CustomAppBar_Community(
        onSearchPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _communityService.getPosts(), // Firestore에서 게시글 가져오기
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("게시글이 없습니다."));
                }

                final posts = snapshot.data!;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];

                    return ListTile(
                      title: Text(post['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(post['content'], maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite, size: 16, color: Colors.red),
                          SizedBox(width: 4),
                          Text(post['likes'].toString()),
                          SizedBox(width: 16),
                          Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(post['views'].toString()),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailPage(postId: post['id']),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
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
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                tag,
                                style: body_xxsmall(context)
                                    .copyWith(color: customColors.primary60),
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
                                backgroundImage: NetworkImage(post.profileImage),
                                radius: 12,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                post.authorName,
                                style: body_xsmall_semi(context)
                                    .copyWith(color: customColors.neutral30),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.favorite, size: 16, color: customColors.neutral60),
                                      const SizedBox(width: 4),
                                      Text(
                                        post.likes.toString(),
                                        style: body_xxsmall_semi(context)
                                            .copyWith(color: customColors.neutral60),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.remove_red_eye, size: 16, color: customColors.neutral60),
                                      const SizedBox(width: 4),
                                      Text(
                                        post.views.toString(),
                                        style: body_xxsmall_semi(context)
                                            .copyWith(color: customColors.neutral60),
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
            MaterialPageRoute(builder: (context) => Cm2depthBoardmain()), // 게시판 페이지로 이동, 첫 번째 게시글을 전달
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
            MaterialPageRoute(builder: (context) => RankingPage()), // 랭킹 페이지로 이동
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

  String formatPostDate(DateTime? postDate) {
    if (postDate == null) {
      return '알 수 없음'; // Handle the case when the postDate is null
    }

    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inDays > 1) {
      return '${postDate.month}/${postDate.day}/${postDate.year}';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inHours > 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
