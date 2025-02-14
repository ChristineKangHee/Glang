import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../components/my_divider.dart';
import '../community_service.dart';
import 'Component/component_communitypostlist.dart';
import 'community_searchpage.dart';
import 'essay_posting.dart';
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
                Tab(text: '코스'),
                Tab(text: '주제'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPostList(context, customColors, category: null), // 전체
                  _buildPostList(context, customColors, category: '미션 글'), // 코스
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
  Widget _buildPostList(BuildContext context, CustomColors customColors, {String? category}) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _communityService.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('데이터 로딩 실패'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              '게시글이 없습니다.',
              style: body_small(context).copyWith(color: customColors.neutral60),
            ),
          );
        }

        // Firestore에서 가져온 데이터를 Post 모델로 변환
        List<Post> posts = snapshot.data!
            .map((data) => Post.fromMap(data))
            .where((post) => category == null || post.category == category)
            .toList();

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
                context: context,
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
              backgroundColor: customColors.primary20,
            ),
            SpeedDialChild(
              child: Icon(Icons.upload_rounded, color: customColors.neutral30),
              label: '미션 글 업로드',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MissionPostPage()),
                );
              },
              backgroundColor: customColors.primary20,
            ),
          ],
        );
      },
    );
  }
}

/// 🔹 Firestore 데이터를 다룰 Post 모델
class Post {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String profileImage;
  final List<String> tags;
  final int likes;
  final int views;
  final DateTime createdAt;
  final String category;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.profileImage,
    required this.tags,
    required this.likes,
    required this.views,
    required this.createdAt,
    required this.category,
  });

  factory Post.fromMap(Map<String, dynamic> data) {
    return Post(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '익명',
      profileImage: data['profileImage'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      likes: data['likes'] ?? 0,
      views: data['views'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? '기타',
    );
  }
}
