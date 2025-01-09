/// File: statistics.dart
/// Purpose: 날짜별 학습한 통계를 확인할 수 있다.
/// Author: 윤은서
/// Created: 2025-01-08
/// Last Modified: 2025-01-09 by 윤은서

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../components/custom_app_bar.dart';

class InfoStatistics extends ConsumerWidget {
  const InfoStatistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: "학습 통계",
      ),
      body: Column(
        children: [
          Text("학습 통계"),
        ],
      ),
    );
  }
}