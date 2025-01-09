/// File: edit_profile.dart
/// Purpose: 사용자의 정보를 수정할 수 있다.
/// Author: 윤은서
/// Created: 2025-01-08
/// Last Modified: 2025-01-09 by 윤은서

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';

final nicknameProvider = StateProvider<String>((ref) => '하나둘셋제로');

class EditProfile extends ConsumerWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: "내 정보 수정",
      ),
      backgroundColor: customColors.white,
      body: const EditInfo(),
    );
  }
}

class EditInfo extends StatelessWidget {
  const EditInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileImage(),
            const SizedBox(height: 40),
            const EditNick(),
            const SizedBox(height: 24),
            Divider(height: 16, color: Theme.of(context).extension<CustomColors>()?.neutral90, thickness: 16),
            const SizedBox(height: 24),
            const MyInfo(),
          ],
        ),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Center(
      child: Container(
        width: 124,
        height: 120,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 120,
                height: 120,
                decoration: ShapeDecoration(
                  image: const DecorationImage(
                    image: NetworkImage("https://via.placeholder.com/120x120"),
                    fit: BoxFit.fill,
                  ),
                  shape: OvalBorder(
                    side: BorderSide(
                      width: 3,
                      color: customColors.primary!,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 92,
              top: 85,
              child: Container(
                width: 32,
                height: 32,
                decoration: ShapeDecoration(
                  color: customColors.primary,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 3,
                      color: customColors.white!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 100,
              top: 93,
              child: Icon(
                Icons.camera_alt,
                size: 16,
                color: customColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditNick extends ConsumerStatefulWidget {
  const EditNick({super.key});

  @override
  ConsumerState<EditNick> createState() => _EditNickState();
}

class _EditNickState extends ConsumerState<EditNick> {
  @override
  Widget build(BuildContext context) {
    final nickname = ref.watch(nicknameProvider); // Read the nickname
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '별명',
          style: body_xsmall(context).copyWith(color: customColors.primary),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              nickname,
              style: body_large(context).copyWith(
                fontWeight: FontWeight.w600,
                color: customColors.black,
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, size: 24, color: customColors.neutral30),
              onPressed: () async {
                final newNickname = await Navigator.pushNamed(
                  context,
                  '/mypage/edit_nick_input',
                );

                if (newNickname is String) {
                  ref.read(nicknameProvider.notifier).state = newNickname;
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class MyInfo extends StatelessWidget {
  const MyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRow(title: '이름', value: '김민지'),
        const SizedBox(height: 24),
        InfoRow(title: '생년월일', value: '2000.01.01'),
        const SizedBox(height: 24),
        InfoRow(title: '이메일', value: '1230@kakao.com'),
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
          style: body_small(context).copyWith(
          color: customColors.neutral30,
          fontWeight: FontWeight.w400,
          height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: body_large(context).copyWith(
          fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}