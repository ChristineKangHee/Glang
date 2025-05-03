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



/// 커뮤니티 메인 페이지
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
    bool acceptedLocal = prefs.getBool('eulaAccepted_community') ?? false;

    bool acceptedServer = false;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      acceptedServer = userDoc.data()?['communityEulaAccepted'] ?? false;
    } catch (e) {
      print('❌ Firestore에서 EULA 정보 가져오기 실패: $e');
    }

    // 로컬 또는 서버 둘 중 하나라도 false면 약관 띄우기
    if (!acceptedLocal || !acceptedServer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEulaBottomSheet();
      });
    }
  }


  void _showEulaBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // 🔥 바깥 터치로 닫기 금지
      enableDrag: false,    // 🔥 스와이프 닫기 금지
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 제목
                Text(
                  '커뮤니티 이용 약관',
                  style: body_large(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // 약관 내용 스크롤
                SizedBox(
                  child: SingleChildScrollView(
                    child: Text(
                      '• 타인에게 불쾌감을 주는 발언을 금지합니다.\n'
                          '• 허위 정보, 광고, 욕설, 비방 금지\n'
                          '• 운영 정책을 위반할 경우 게시글이 삭제될 수 있습니다.\n'
                          '• 모든 게시글은 관리자가 모니터링할 수 있습니다.\n\n'
                          '※ 상세한 약관 내용은 "설정 > 이용약관"에서 확인할 수 있습니다.',
                      style: body_small(context),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 약관 동의 버튼
                ButtonPrimary_noPadding(
                  title: '약관에 동의하고 커뮤니티 이용하기',
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

                    Navigator.pop(context); // ✅ 동의 후 BottomSheet 닫기
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
