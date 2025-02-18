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

class Cm2depthBoardmain extends ConsumerWidget {
  final CommunityService _communityService = CommunityService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final isDialOpen = ValueNotifier(false);

    return Scaffold(
      appBar: CustomAppBar_2depth_5(
        title: '게시판',
        onIconPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
        },
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelStyle: body_small_semi(context),
              indicatorColor: customColors.primary,
              dividerColor: customColors.neutral80,
              tabs: const [
                Tab(text: '전체'),
                Tab(text: '에세이'),
                Tab(text: '자유글'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPostList(context, customColors, category: null), // 전체
                  _buildPostList(context, customColors, category: '에세이'), // 코스
                  _buildPostList(context, customColors, category: '자유글'), // 주제
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDial(context, isDialOpen, customColors),
    );
  }

  /// 🔹 Firestore에서 게시글을 가져와 표시하는 위젯
  Widget _buildPostList(BuildContext context, CustomColors customColors, {dynamic category}) {
    return StreamBuilder<List<Post>>(
      stream: _communityService.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
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

        if (posts.isEmpty) {
          return Center(
            child: Text(
              '해당 카테고리에 게시글이 없습니다.',
              style: body_small(context).copyWith(color: customColors.neutral60),
            ),
          );
        }

        return ListView.builder(
          itemCount: posts.length * 2 - 1,
          itemBuilder: (context, index) {
            if (index.isOdd) {
              return BigDivider();
            } else {
              var post = posts[index ~/ 2];
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
          icon: isOpen ? Icons.close : Icons.create,
          backgroundColor: customColors.primary,
          overlayColor: customColors.neutral0,
          overlayOpacity: 0.5,
          onOpen: () => isDialOpen.value = true,
          onClose: () => isDialOpen.value = false,
          children: [
            SpeedDialChild(
              child: Icon(Icons.article, color: customColors.neutral30),
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
              child: Icon(Icons.lightbulb, color: customColors.neutral30),
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