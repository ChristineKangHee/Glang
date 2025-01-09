/// File: badge.dart
/// Purpose: 획득한 배지를 확인할 수 있다.
/// Author: 윤은서
/// Created: 2025-01-08
/// Last Modified: 2025-01-08 by 윤은서

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../components/custom_app_bar.dart';

class InfoBadge extends ConsumerWidget {
  const InfoBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: "획득한 배지",
      ),
      body: Column(
        children: [
          Text("획득한 배지"),
        ],
      ),
    );
  }
}