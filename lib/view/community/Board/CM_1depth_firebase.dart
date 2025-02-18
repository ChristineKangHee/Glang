import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/community/Board/posting_detail_page.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_navigation_bar.dart';
import 'Component/postHeader.dart';
import 'Component/postfooter.dart';
import 'CM_2depth_boardMain_firebase.dart';
import 'community_data_firebase.dart';
import 'community_searchpage_firebase.dart';
import '../Ranking/CM_2depth_ranking.dart';
import '../Ranking/ranking_component.dart';
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
              buildTopThreeWithPodium(context, customColors),
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
          height: 190,
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
                        // 헤더: 태그와 날짜 표시
                        PostHeader(post: post, customColors: widget.customColors),
                        const SizedBox(height: 8),
                        Text(
                          post.title,
                          style: body_small_semi(context),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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
                        // 풋터: 작성자, 좋아요, 조회수 표시
                        PostFooter(post: post, customColors: widget.customColors),
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
