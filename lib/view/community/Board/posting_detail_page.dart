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

// 게시글 상세 페이지
class PostDetailPage extends ConsumerStatefulWidget {
  final Post post;
  const PostDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final CommunityService _communityService = CommunityService();
  bool isLiked = false; // 좋아요 상태
  int likeCount = 0; // 좋아요 수

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likes; // 초기 좋아요 수 설정
    _checkIfLiked(); // 현재 사용자가 좋아요를 눌렀는지 확인
    _incrementViewCount(); // 페이지 로드 시 조회수 증가
  }

  // 사용자가 해당 게시글을 좋아요했는지 확인
  Future<void> _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // 로그인하지 않은 경우 처리

    final postDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .get();

    if (postDoc.exists) {
      final likedBy = postDoc.data()?['likedBy'] ?? [];
      setState(() {
        isLiked = likedBy.contains(user.uid); // 좋아요 여부 상태 업데이트
      });
    }
  }

  // 좋아요/좋아요 취소 토글 기능
  Future<void> _toggleLike() async {
    await _communityService.toggleLike(widget.post.id); // 좋아요/좋아요 취소 API 호출
    setState(() {
      isLiked = !isLiked; // 좋아요 상태 반전
      likeCount += isLiked ? 1 : -1; // 좋아요 수 업데이트
    });
  }

  // 조회수 증가 함수
  Future<void> _incrementViewCount() async {
    await _communityService.increasePostViews(widget.post.id); // 조회수 증가 API 호출
    setState(() {
      widget.post.views += 1; // UI에서 조회수 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider); // 사용자 지정 색상
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAuthor = currentUser != null && widget.post.authorId == currentUser.uid; // 작성자 여부 확인

    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: '게시판'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailTag(context, customColors), // 태그 및 작성일 표시
              const SizedBox(height: 16),
              DetailHeader(context, isAuthor, customColors), // 게시글 제목 및 작성자 버튼
              const SizedBox(height: 10),
              Text(widget.post.content, style: reading_exercise(context)), // 게시글 내용
              const SizedBox(height: 20),

              // 🔹 좋아요 & 조회수 UI
              DetailAndLikeView(customColors, context), // 좋아요 및 조회수 UI
            ],
          ),
        ),
      ),
    );
  }

  // 게시글 제목 및 작성자 메뉴
  Widget DetailHeader(BuildContext context, bool isAuthor, CustomColors customColors) {
    return Row(
      children: [
        Expanded(
          child: Text(widget.post.title, style: heading_medium(context)),
        ),
        if (isAuthor) // 작성자인 경우만 메뉴 버튼 표시
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: customColors.neutral80),
            onPressed: () {
              showPostActionBottomSheet(context, widget.post, customColors, context); // 게시글 액션 메뉴 호출
            },
          ),
      ],
    );
  }

  // 게시글 태그 및 작성일 표시
  Widget DetailTag(BuildContext context, CustomColors customColors) {
    return Row(
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
              formatPostDate(widget.post.createdAt), // 게시글 작성일 포맷팅
              style: body_xxsmall(context).copyWith(color: customColors.neutral60),
            ),
          ),
        ),
      ],
    );
  }

  // 좋아요 및 조회수 UI
  Widget DetailAndLikeView(CustomColors customColors, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 작성자 프로필 정보: FutureBuilder를 통해 동적 조회
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.post.authorId)
              .get(),
          builder: (context, snapshot) {
            String imageUrl = 'assets/images/default_avatar.png'; // 기본 이미지 설정
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
              imageUrl = 'assets/images/default_avatar.png'; // 에러 발생 시 기본 이미지
            } else if (snapshot.hasData) {
              final userData =
              snapshot.data!.data() as Map<String, dynamic>?;
              if (userData != null &&
                  userData['photoURL'] != null &&
                  userData['photoURL'].toString().isNotEmpty) {
                imageUrl = userData['photoURL']; // 프로필 이미지 URL
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
        DetailLikeandView(customColors, context),
      ],
    );
  }

  // 좋아요 및 조회수 표시 UI
  Widget DetailLikeandView(CustomColors customColors, BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? customColors.primary : customColors.neutral60,
          ),
          onPressed: _toggleLike, // 좋아요 토글 기능
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
    );
  }

  // 게시글 액션 메뉴 표시
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
