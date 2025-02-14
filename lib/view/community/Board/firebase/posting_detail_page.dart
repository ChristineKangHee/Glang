import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/font.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import '../../../components/custom_app_bar.dart';
import 'CM_2depth_boardMain_firebase.dart';
import 'community_data_firebase.dart';
import 'community_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
              Text(widget.post.title, style: heading_medium(context)),
              const SizedBox(height: 10),
              Text(widget.post.content, style: reading_exercise(context)),
              const SizedBox(height: 20),

              // 🔹 좋아요 & 조회수 UI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(widget.post.profileImage),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(widget.post.nickname,
                          style: body_xsmall_semi(context)
                              .copyWith(color: customColors.neutral30)),
                    ],
                  ),
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
                      Icon(Icons.remove_red_eye, size: 20, color: customColors.neutral60),
                      const SizedBox(width: 6),
                      Text(
                        widget.post.views.toString(),
                        style: body_small_semi(context)
                            .copyWith(color: customColors.neutral60),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
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

