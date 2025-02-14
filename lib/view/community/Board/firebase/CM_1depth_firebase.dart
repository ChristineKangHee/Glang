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
    final communityService = CommunityService();

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
      body: StreamBuilder<List<Post>>(
        stream: communityService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("게시글이 없습니다."));
          }

          final posts = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildRankingPreview(context, customColors),
                ),
                const SizedBox(height: 24),
                CommunityPreview(posts, context, customColors),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

  Widget _buildRankingPreview(BuildContext context, CustomColors customColors) {
    return Column(
      children: [
        _buildRankingNavigation(context, customColors),
        Container(
          decoration: BoxDecoration(
            color: customColors.neutral100,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
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

  Widget _buildRankingNavigation(BuildContext context, CustomColors customColors) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
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
            const SizedBox(width: 4),
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
}

class CommunityPreview extends StatefulWidget {
  final List<Post> posts;
  final BuildContext context;
  final CustomColors customColors;

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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 좋아요 수 기준 내림차순 정렬 후 상위 3개의 게시글 선택
    List<Post> sortedPosts = List.from(widget.posts)
      ..sort((a, b) => b.likes.compareTo(a.likes));
    final topPosts = sortedPosts.take(3).toList();

    return Column(
      children: [
        _buildPostNavigation(context, widget.customColors),
        SizedBox(
          height: 170,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: PageView.builder(
              padEnds: false,
              controller: _pageController,
              itemCount: topPosts.length,
              itemBuilder: (context, index) {
                final post = topPosts[index];
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
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: widget.customColors.neutral100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 태그와 날짜
                        Row(
                          children: [
                            Row(
                              children: post.tags
                                  .map<Widget>(
                                    (tag) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    '#$tag',
                                    style: body_xxsmall(context).copyWith(
                                      color: widget.customColors.primary60,
                                    ),
                                  ),
                                ),
                              )
                                  .toList(),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _formatPostDate(post.createdAt),
                                  style: body_xxsmall(context).copyWith(
                                    color: widget.customColors.neutral60,
                                  ),
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
                        const Spacer(),
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
                                  post.nickname,
                                  style: body_xsmall_semi(context).copyWith(
                                    color: widget.customColors.neutral30,
                                  ),
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
                                        Icon(
                                          Icons.favorite,
                                          size: 16,
                                          color: widget.customColors.neutral60,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          post.likes.toString(),
                                          style: body_xxsmall_semi(context).copyWith(
                                            color: widget.customColors.neutral60,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.remove_red_eye,
                                          size: 16,
                                          color: widget.customColors.neutral60,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          post.views.toString(),
                                          style: body_xxsmall_semi(context).copyWith(
                                            color: widget.customColors.neutral60,
                                          ),
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
        ),
      ],
    );
  }

  String _formatPostDate(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return "방금 전";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}분 전";
    } else if (difference.inHours < 24) {
      return "${(difference.inMinutes / 60).ceil()}시간 전";
    } else {
      return "${difference.inDays}일 전";
    }
  }

  Widget _buildPostNavigation(BuildContext context, CustomColors customColors) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        '게시판',
        style: body_small_semi(context),
      ),
      trailing: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Cm2depthBoardmain()),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '더보기',
              style: body_xxsmall_semi(context),
            ),
            const SizedBox(width: 4),
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
}
