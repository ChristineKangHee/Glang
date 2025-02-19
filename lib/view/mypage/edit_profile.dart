/// File: edit_profile.dart
/// Purpose: 사용자의 정보를 수정할 수 있다.
/// Author: 윤은서
/// Created: 2025-01-08
/// Last Modified: 2025-01-29 by 윤은서

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../../viewmodel/user_photo_url_provider.dart';
import '../components/custom_app_bar.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../viewmodel/user_service.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EditProfile extends ConsumerWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final userName = ref.watch(userNameProvider) ?? 'null';

    return Scaffold(
      appBar: CustomAppBar_2depth_4(title: "내 정보 수정"),
      backgroundColor: customColors.white,
      body: EditInfo(
        userName: userName,
      ),
    );
  }
}

class EditInfo extends StatelessWidget {
  final String userName;
  const EditInfo({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileImage(),
                const SizedBox(height: 40),
                EditNick(name: userName),
              ],
            ),
          ),
          Divider(
            height: 16,
            color: Theme.of(context).extension<CustomColors>()?.neutral90,
            thickness: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                SizedBox(height: 24),
                MyInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class ProfileImage extends ConsumerStatefulWidget {
  const ProfileImage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends ConsumerState<ProfileImage> {
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final file = File(pickedFile.path);

      try {
        // 1. 파일을 읽어 원본 이미지 바이트 가져오기
        final imageBytes = await file.readAsBytes();

        // 2. flutter_image_compress를 사용해 이미지 압축/리사이즈 (예: 가로세로 300px)
        final compressedImageBytes = await FlutterImageCompress.compressWithList(
          imageBytes,
          minWidth: 300,
          minHeight: 300,
          quality: 85, // 품질 조절 (0~100)
          format: CompressFormat.jpeg,
        );

        // 3. Firebase Storage에 압축된 이미지 업로드 (예: profile_images/{uid}.jpg)
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("profile_images")
            .child("${user.uid}.jpg");
        final uploadTask = storageRef.putData(compressedImageBytes);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // 4. FirebaseAuth의 photoURL과 Firestore 사용자 문서 업데이트
        await user.updatePhotoURL(downloadUrl);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'photoURL': downloadUrl});

        // 5. Provider 상태 업데이트
        ref.read(userPhotoUrlProvider.notifier).updatePhotoUrl(downloadUrl);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("프로필 사진 업데이트 오류: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final photoUrl = ref.watch(userPhotoUrlProvider);
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: ShapeDecoration(
              shape: const CircleBorder(side: BorderSide(width: 3)),
              color: customColors.neutral0,
              shadows: [
                BoxShadow(
                  color: customColors.primary!,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? Image.network(photoUrl, fit: BoxFit.cover)
                  : Image.asset('assets/images/default_avatar.png', fit: BoxFit.cover),
            ),
          ),
          // 오른쪽 하단의 수정 아이콘
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _pickAndUploadImage,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: customColors.primary ?? Colors.deepPurpleAccent,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// 닉네임 편집 섹션
class EditNick extends ConsumerStatefulWidget {
  final String name;
  const EditNick({super.key, required this.name});

  @override
  ConsumerState<EditNick> createState() => _EditNickState();
}

class _EditNickState extends ConsumerState<EditNick> {
  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '별명',
          style: body_xsmall(context).copyWith(
            color: customColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.name,
              style: heading_small(context),
            ),
            IconButton(
              icon: Icon(Icons.edit, size: 24, color: customColors.neutral30),
              onPressed: () async {
                final newNickname = await Navigator.pushNamed(
                  context,
                  '/mypage/edit_nick_input',
                );

                if (newNickname is String) {
                  ref.read(userNameProvider.notifier).updateUserName(newNickname);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// 추가 개인정보
class MyInfo extends ConsumerWidget {
  const MyInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailAsync = ref.watch(userEmailProvider);
    final nameAsync = ref.watch(userRealNameProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        nameAsync.when(
          data: (name) => InfoRow(title: '이름', value: name ?? '이름 없음'),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => InfoRow(title: '이름', value: '불러오기 실패'),
        ),
        const SizedBox(height: 24),
        emailAsync.when(
          data: (email) => InfoRow(title: '이메일', value: email ?? '이메일 없음'),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => InfoRow(title: '이메일', value: '불러오기 실패'),
        ),
      ],
    );
  }
}


class InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const InfoRow({
    required this.title,
    required this.value,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: body_xsmall(context).copyWith(
            color: customColors.neutral30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: body_large_semi(context),
        ),
      ],
    );
  }
}