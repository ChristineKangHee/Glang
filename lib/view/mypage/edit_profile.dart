/// File: edit_profile.dart
/// Purpose: 사용자의 정보를 수정할 수 있다.
/// Author: 윤은서
/// Created: 2025-01-08
/// Last Modified: 2025-01-29 by 윤은서

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../viewmodel/user_service.dart';
import 'edit_nick_input.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(
                  width: 3,
                  color: customColors.primary ?? Colors.deepPurpleAccent,
                ),
              ),
            ),
            child: ClipOval(
              child: SvgPicture.asset(
                'assets/images/character.svg',
                fit: BoxFit.fill,
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