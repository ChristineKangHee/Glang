import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import '../../components/my_divider.dart';
import 'CM_2depth_board.dart';
import 'community_data.dart';
import 'essay_posting.dart';
import 'free_posting.dart';
import 'mission_posting.dart';

class Cm2depthBoardmain extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    // ValueNotifier to track the state of the SpeedDial
    final isDialOpen = ValueNotifier(false);

    return Scaffold(
      appBar: CustomAppBar_2depth_5(title: '게시판'),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
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
                  BoardPostList(posts, context, customColors), // 전체
                  BoardPostList(posts.where((post) => post.category == '코스').toList(), context, customColors), // 코스
                  BoardPostList(posts.where((post) => post.category == '인사이트' || post.category == '에세이').toList(), context, customColors), // 주제
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: isDialOpen,
        builder: (context, isOpen, _) {
          return SpeedDial(
            icon: isOpen ? Icons.close : Icons.create, // Toggle between create and close icon
            backgroundColor: customColors.primary,
            overlayColor: customColors.neutral0,
            overlayOpacity: 0.5,
            onOpen: () => isDialOpen.value = true,
            onClose: () => isDialOpen.value = false,
            children: [
              SpeedDialChild(
                child: Icon(Icons.article, color: customColors.neutral30,),
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
                child: Icon(Icons.lightbulb, color: customColors.neutral30,),
                label: '에세이',
                backgroundColor: customColors.primary20,
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
                shape: CircleBorder(),
                labelShadow: [],
                labelStyle: body_small_semi(context).copyWith(color: customColors.neutral100),
                labelBackgroundColor: Colors.transparent,
                backgroundColor: customColors.primary20,
              ),

            ],
          );
        },
      ),
    );
  }

  Widget BoardPostList(List<Post> posts, BuildContext context, CustomColors customColors) {
    if (posts.isEmpty) {
      return Center(
        child: Text(
          '게시글이 없습니다.',
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
              padding: EdgeInsets.all(16),
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
                            style: body_xxsmall(context).copyWith(color: customColors.primary60),
                          ),
                        ))
                            .toList(),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            formatPostDate(post.createdAt),
                            style: body_xxsmall(context).copyWith(color: customColors.neutral60),
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
                  Text(
                    post.content,
                    style: body_xxsmall(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
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
                            style: body_xsmall_semi(context).copyWith(color: customColors.neutral30),
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
                                    style: body_xxsmall_semi(context).copyWith(color: customColors.neutral60),
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
                                    style: body_xxsmall_semi(context).copyWith(color: customColors.neutral60),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  String formatPostDate(DateTime? postDate) {
    if (postDate == null) {
      return '알 수 없음';
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
