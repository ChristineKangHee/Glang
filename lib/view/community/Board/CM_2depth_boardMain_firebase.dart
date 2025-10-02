/// File: CM_2depth_boardMain_firebase.dart
/// Purpose: 커뮤니티 게시판 화면 (L10N + 다국어 안전 카테고리 필터 + 단일 스트림 구독)
/// Author: 강희
/// Last Modified: 2025-10-03 by ChatGPT
///
/// 변경 요약
/// - 무한 로딩 원인 제거: 동일 스트림 다중 구독을 피하기 위해 상위에서 단 1회만 구독
/// - _postsStream 에 asBroadcastStream() 적용(추가 안전장치)
/// - 각 탭은 받은 리스트를 필터링만 하도록 단순화(_PostListStatic)
/// - 중복 import 정리

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

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

class Cm2depthBoardmain extends ConsumerStatefulWidget {
  const Cm2depthBoardmain({Key? key}) : super(key: key);

  @override
  _Cm2depthBoardmainState createState() => _Cm2depthBoardmainState();
}

enum CategoryFilter { all, essay, free }

class _Cm2depthBoardmainState extends ConsumerState<Cm2depthBoardmain>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final Map<int, ScrollController> _scrollControllers = {};
  final CommunityService _communityService = CommunityService();
  late final Stream<List<Post>> _postsStream;

  @override
  void initState() {
    super.initState();

    _tabController =
    TabController(length: 3, vsync: this)..addListener(() => setState(() {}));

    for (var i = 0; i < 3; i++) {
      _scrollControllers[i] = ScrollController();
    }

    // ✅ 여러 위젯이 동시에 listen해도 안전하도록 broadcast 전환 (추가 안전장치)
    _postsStream = _communityService.getPosts().asBroadcastStream();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _scrollControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    final isDialOpen = ValueNotifier(false);

    return Scaffold(
      appBar: CustomAppBar_2depth_5(
        title: 'community.board'.tr(), // '게시판'
        onIconPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage()));
        },
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelStyle: body_small_semi(context),
            indicatorColor: customColors.primary,
            dividerColor: customColors.neutral80,
            tabs: [
              Tab(text: 'community.all'.tr()),
              Tab(text: 'community.essay'.tr()),
              Tab(text: 'community.free'.tr()),
            ],
          ),

          // ✅ 단 1회만 스트림을 구독하고, 하위 탭은 필터링만 수행
          Expanded(
            child: StreamBuilder<List<Post>>(
              stream: _postsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Text(
                      'posts_load_failed'.tr(), // "게시글을 불러올 수 없습니다."
                      style:
                      body_small(context).copyWith(color: customColors.neutral60),
                    ),
                  );
                }

                final posts = snapshot.data!;

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _PostListStatic(
                      posts: posts,
                      filter: CategoryFilter.all,
                      scrollController: _scrollControllers[0]!,
                    ),
                    _PostListStatic(
                      posts: posts,
                      filter: CategoryFilter.essay,
                      scrollController: _scrollControllers[1]!,
                    ),
                    _PostListStatic(
                      posts: posts,
                      filter: CategoryFilter.free,
                      scrollController: _scrollControllers[2]!,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSpeedDial(context, isDialOpen, customColors),
    );
  }

  Widget _buildSpeedDial(
      BuildContext context, ValueNotifier<bool> isDialOpen, CustomColors customColors) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDialOpen,
      builder: (context, isOpen, _) {
        return SpeedDial(
          icon: isOpen ? Icons.close : Icons.create,
          backgroundColor: customColors.primary,
          overlayColor: customColors.neutral0,
          overlayOpacity: 0.5,
          onOpen: () => isDialOpen.value = true,
          onClose: () => isDialOpen.value = false,
          children: [
            SpeedDialChild(
              child: Icon(Icons.article, color: customColors.neutral30),
              label: 'community.free'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FreeWritingPage()),
                );
              },
              shape: const CircleBorder(),
              labelShadow: const [],
              labelStyle: body_small_semi(context)
                  .copyWith(color: customColors.neutral100),
              labelBackgroundColor: Colors.transparent,
              backgroundColor: customColors.primary20,
            ),
            SpeedDialChild(
              child: Icon(Icons.lightbulb, color: customColors.neutral30),
              label: 'community.essay'.tr(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EssayPostPage()),
                );
              },
              shape: const CircleBorder(),
              labelStyle: body_small_semi(context)
                  .copyWith(color: customColors.neutral100),
              labelBackgroundColor: Colors.transparent,
              labelShadow: const [],
              backgroundColor: customColors.primary20,
            ),
          ],
        );
      },
    );
  }
}

/// 탭별 리스트(필터링만 수행)
class _PostListStatic extends ConsumerWidget {
  final List<Post> posts;
  final CategoryFilter filter;
  final ScrollController scrollController;

  const _PostListStatic({
    required this.posts,
    required this.filter,
    required this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    final filtered = posts.where((p) => _matchFilter(p, filter)).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'no_posts_in_category'.tr(), // "해당 카테고리에 게시글이 없습니다."
          style: body_small(context).copyWith(color: customColors.neutral60),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      itemCount: filtered.length,
      separatorBuilder: (context, _) => const BigDivider(),
      itemBuilder: (context, index) {
        final post = filtered[index];
        return PostItemContainer(
          post: post,
          customColors: customColors,
          parentContext: context,
        );
      },
    );
  }
}

/// ✅ 다국어 안전 필터: DB가 '에세이/자유글' 또는 'essay/free'여도 매칭
bool _matchFilter(Post post, CategoryFilter filter) {
  if (filter == CategoryFilter.all) return true;

  final raw = (post.category ?? '').toString().trim().toLowerCase();
  if (raw.isEmpty) return false;

  const essaySet = {'에세이', 'essay'};
  const freeSet = {'자유글', 'free'};

  switch (filter) {
    case CategoryFilter.essay:
      return essaySet.contains(raw);
    case CategoryFilter.free:
      return freeSet.contains(raw);
    case CategoryFilter.all:
      return true;
  }
}
