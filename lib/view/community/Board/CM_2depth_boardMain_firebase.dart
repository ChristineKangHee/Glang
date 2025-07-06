/// File: CM_2depth_boardMain_firebase.dart
/// Purpose: 커뮤니티 게시판 화면 (Cm2depthBoardmain) + 스크롤 유지 최적화
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2025-05-01 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:easy_localization/easy_localization.dart';

class Cm2depthBoardmain extends ConsumerStatefulWidget {
  const Cm2depthBoardmain({Key? key}) : super(key: key);

  @override
  _Cm2depthBoardmainState createState() => _Cm2depthBoardmainState();
}

class _Cm2depthBoardmainState extends ConsumerState<Cm2depthBoardmain> with TickerProviderStateMixin {
  late final TabController _tabController;
  final CommunityService _communityService = CommunityService();
  final Map<int, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        setState(() {}); // 탭 변경 시 리빌드
      });

    for (var i = 0; i < 3; i++) {
      _scrollControllers[i] = ScrollController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostList(context, customColors, 0, category: null),
                _buildPostList(context, customColors, 1, category: '에세이'),
                _buildPostList(context, customColors, 2, category: '자유글'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSpeedDial(context, isDialOpen, customColors),
    );
  }

  Widget _buildPostList(BuildContext context, CustomColors customColors, int tabIndex, {String? category}) {
    return StreamBuilder<List<Post>>(
      stream: _communityService.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
              'community.load_error'.tr(),
              style: body_small(context).copyWith(color: customColors.neutral60),
            ),
          );
        }

        List<Post> posts = snapshot.data!.where((post) {
          if (category == null) return true;
          return post.category == category;
        }).toList();

        if (posts.isEmpty) {
          return Center(
            child: Text(
              'community.no_posts_in_category'.tr(),
              style: body_small(context).copyWith(color: customColors.neutral60),
            ),
          );
        }

        return ListView.separated(
          controller: _scrollControllers[tabIndex],
          itemCount: posts.length,
          separatorBuilder: (context, index) => const BigDivider(),
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostItemContainer(
              post: post,
              customColors: customColors,
              parentContext: context,
            );
          },
        );
      },
    );
  }

  Widget _buildSpeedDial(BuildContext context, ValueNotifier<bool> isDialOpen, CustomColors customColors) {
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
              labelShadow: [],
              labelStyle: body_small_semi(context).copyWith(color: customColors.neutral100),
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
              labelStyle: body_small_semi(context).copyWith(color: customColors.neutral100),
              labelBackgroundColor: Colors.transparent,
              labelShadow: [],
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
