/// File: RD_before.dart
/// Purpose: 읽기 중 시작 전 튜토리얼 구현 코드
/// Author: 강희
/// Created: 2024-1-19
/// Last Modified: 2024-6-28 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:readventure/theme/theme.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_button.dart';
import 'package:readventure/view/home/stage_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class RdBefore extends ConsumerWidget {
  const RdBefore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final currentStage = ref.watch(currentStageProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_6(
        title: currentStage?.subdetailTitle ?? '',
        automaticallyImplyLeading: false,
        onIconPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  color: customColors.neutral90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text("reading_greeting".tr(), style: body_medium_semi(context)),
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              color: Colors.transparent,
                              width: MediaQuery.of(context).size.width,
                              height: 450.h,
                              child: Image.asset("assets/images/cover.png"),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "selection_tip".tr(),
                            style: body_small(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 30.h),
                          SizedBox(height: 50.h),
                          ButtonPrimary_noPadding(
                            function: () {
                              Navigator.pushNamed(context, '/rdmain');
                            },
                            title: 'start_button'.tr(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}