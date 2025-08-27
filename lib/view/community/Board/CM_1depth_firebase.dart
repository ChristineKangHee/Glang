/// File: CM_1depth_firebase.dart
/// Purpose: 커뮤니티 메인 페이지 (L10N 적용)
/// Author: 강희
/// Last Modified: 2025-08-26 by ChatGPT

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ L10N
import 'package:readventure/view/community/Board/posting_detail_page.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../components/custom_button.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityMainPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<CommunityMainPage> createState() => _CommunityMainPageState();
}

class _CommunityMainPageState extends ConsumerState<CommunityMainPage> {
  @override
  void initState() {
    super.initState();
    _checkEula();
  }

  Future<void> _checkEula() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final acceptedLocal = prefs.getBool('eulaAccepted_community') ?? false;

    var acceptedServer = false;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      acceptedServer = userDoc.data()?['communityEulaAccepted'] ?? false;
    } catch (e) {
      debugPrint('❌ Firestore EULA fetch failed: $e');
    }

    if (!acceptedLocal || !acceptedServer) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showEulaBottomSheet());
    }
  }

  void _showEulaBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final customColors = Theme.of(context).extension<CustomColors>()!;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'community.eula_title'.tr(),  // 커뮤니티 이용 약관
                  style: body_large(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      'community.eula_content'.tr(),  // 약관 본문
                      style: body_small(context),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ButtonPrimary_noPadding(
                  title: 'community.eula_agree_button'.tr(),
                  function: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('eulaAccepted_community', true);

                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
                      await userDoc.update({
                        'communityEulaAccepted': true,
                        'communityEulaAcceptedAt': FieldValue.serverTimestamp(),
                      });
                    }
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    final communityService = CommunityService();

    return DoubleBackToExitWrapper(
      child: Scaffold(
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
              return Center(child:Text('community.no_posts'.tr()));
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
      ),
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
        'community.ranking'.tr(), // '랭킹'
        style: body_small_semi(context),
      ),
      trailing: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RankingPage()));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'community.more'.tr(), // '더보기'
              style: body_xxsmall_semi(context),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: customColors.neutral0),
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

  const CommunityPreview(this.posts, this.context, this.customColors, {Key? key}) : super(key: key);

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
    final sortedPosts = List<Post>.from(widget.posts)..sort((a, b) => b.likes.compareTo(a.likes));
    final topPosts = sortedPosts.take(3).toList();

    return Column(
      children: [
        _buildPostNavigation(context, widget.customColors),
        SizedBox(
          height: 190,
          child: PageView.builder(
            padEnds: false,
            controller: _pageController,
            itemCount: topPosts.length,
            itemBuilder: (context, index) {
              final post = topPosts[index];
              final leftMargin = index == 0 ? 16.0 : 8.0;
              final rightMargin = index == topPosts.length - 1 ? 16.0 : 8.0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
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

  Widget _buildPostNavigation(BuildContext context, CustomColors customColors) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        'community.board'.tr(), // '게시판'
        style: body_small_semi(context),
      ),
      trailing: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Cm2depthBoardmain()));
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'community.more'.tr(), // '더보기'
              style: body_xxsmall_semi(context),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: customColors.neutral0),
          ],
        ),
      ),
    );
  }
}
