import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import 'Component/postaction_bottomsheet.dart';
import 'CM_2depth_boardMain_firebase.dart';
import 'community_data_firebase.dart';
import 'community_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'component_community_post_firebase.dart';

class PostDetailPage extends ConsumerStatefulWidget {
  final Post post;
  const PostDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final CommunityService _communityService = CommunityService();
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likes;
    _checkIfLiked();
    _incrementViewCount(); // Increment the view count when the page is loaded
  }

  Future<void> _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final postDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .get();

    if (postDoc.exists) {
      final likedBy = postDoc.data()?['likedBy'] ?? [];
      setState(() {
        isLiked = likedBy.contains(user.uid);
      });
    }
  }

  Future<void> _toggleLike() async {
    await _communityService.toggleLike(widget.post.id);
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  // Function to increment view count
  Future<void> _incrementViewCount() async {
    await _communityService.increasePostViews(widget.post.id);
    setState(() {
      widget.post.views += 1; // Update the view count in the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAuthor = currentUser != null && widget.post.authorId == currentUser.uid;
    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: '게시판'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    children: widget.post.tags
                        .map<Widget>((tag) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '#'+tag,
                        style: body_xxsmall(context).copyWith(color: customColors.primary60),
                      ),
                    ))
                        .toList(),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        formatPostDate(widget.post.createdAt),
                        style: body_xxsmall(context).copyWith(color: customColors.neutral60),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(widget.post.title, style: heading_medium(context)),
                  ),
                  if (isAuthor)
                    IconButton(
                      icon: Icon(Icons.more_vert_rounded, color: customColors.neutral80,),
                      onPressed: () {
                        showPostActionBottomSheet(context, widget.post, customColors, context);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(widget.post.content, style: reading_exercise(context)),
              const SizedBox(height: 20),

              // 🔹 좋아요 & 조회수 UI
              // 🔹 좋아요 & 조회수 UI 부분의 수정 예시
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 작성자 프로필 정보: FutureBuilder를 통해 동적 조회
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.post.authorId)
                        .get(),
                    builder: (context, snapshot) {
                      String imageUrl = 'assets/images/default_avatar.png';
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: customColors.neutral90,
                              radius: 16,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.post.nickname,
                              style: body_xsmall_semi(context)
                                  .copyWith(color: customColors.neutral30),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        // 에러 발생 시 기본 이미지 사용
                        imageUrl = 'assets/images/default_avatar.png';
                      } else if (snapshot.hasData) {
                        final userData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                        if (userData != null &&
                            userData['photoURL'] != null &&
                            userData['photoURL'].toString().isNotEmpty) {
                          imageUrl = userData['photoURL'];
                        }
                      }
                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: customColors.neutral90,
                            backgroundImage: imageUrl.startsWith('http')
                                ? NetworkImage(imageUrl)
                                : AssetImage(imageUrl) as ImageProvider,
                            radius: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.post.nickname,
                            style: body_xsmall_semi(context)
                                .copyWith(color: customColors.neutral30),
                          ),
                        ],
                      );
                    },
                  ),
                  // 좋아요 및 조회수 표시
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? customColors.primary : customColors.neutral60,
                        ),
                        onPressed: _toggleLike,
                      ),
                      Text(
                        likeCount.toString(),
                        style: body_small_semi(context)
                            .copyWith(color: customColors.neutral60),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.remove_red_eye,
                          size: 20, color: customColors.neutral60),
                      const SizedBox(width: 6),
                      Text(
                        widget.post.views.toString(),
                        style: body_small_semi(context)
                            .copyWith(color: customColors.neutral60),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  void showPostActionBottomSheet(BuildContext context, Post post, CustomColors customColors, BuildContext parentContext) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PostActionBottomSheet(
        post: post,
        customColors: customColors,
        parentContext: parentContext,
      ),
    );
  }
}

