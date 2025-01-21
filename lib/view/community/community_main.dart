/// File: community_main.dart
/// Purpose: 커뮤니티 메인 화면을 구현하여 ChatScreen 및 커스터마이즈된 네비게이션 바를 포함
/// Author: 박민준
/// Created: 2024-12-28
/// Last Modified: 2025-01-03 by 박민준


import 'package:flutter/material.dart';
import 'package:readventure/view/community/community_tmp.dart';
import '../chat/chat_screen.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_navigation_bar.dart';
import '../../viewmodel/custom_colors_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityMain extends ConsumerWidget {
  const CommunityMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider); // CustomColors 가져오기

    return const Scaffold(
      appBar: CustomAppBar_Community(),
      body: SafeArea(child: CommunityTmp()),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}
