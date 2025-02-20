/// File: statistics.dart
/// Purpose: 날짜별 학습한 통계를 확인할 수 있다.
/// Author: 윤은서
/// Created: 2025-01-08
/// Last Modified: 2025-01-24 by 윤은서

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:readventure/view/mypage/info/word_cloud_data.dart';
import '../../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:word_cloud/word_cloud_data.dart';
import 'package:word_cloud/word_cloud_view.dart';

import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';

class InfoStatistics extends ConsumerWidget {
  const InfoStatistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: CustomAppBar_2depth_2(
        title: "통계",
        onIconPressed: () => _showDatePicker(context), // 람다 함수로 감싸기
      ),
      backgroundColor: customColors.neutral90,
      body: const StatisticsWidget(),
    );
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드가 올라와도 화면이 자동으로 조정됨
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView( // 스크롤 가능하게 변경
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "날짜 선택",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250, // CalendarDatePicker의 크기를 명시적으로 설정
                  child: CalendarDatePicker(
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (selectedDate) {
                      Navigator.pop(context);
                      // 선택한 날짜 처리 로직 추가
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class StatisticsWidget extends StatelessWidget {
  const StatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeBox(context, customColors),
            const SizedBox(height: 24),
            _buildAnalysisBox(context, customColors),
            const SizedBox(height: 24),
            Text('성과', style: body_medium_semi(context)),
            const SizedBox(height: 4),
            Text('1월 23일은 총 3회의 읽기를 진행했어요', style: body_small(context)),
            const SizedBox(height: 8),
            _buildGoalBox(context, customColors),
            const SizedBox(height: 24),
            Text('자주 쓰는 단어', style: body_medium_semi(context)),
            const SizedBox(height: 8),
            buildWordCloudBox(context, customColors), // 추가된 부분
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(BuildContext context, CustomColors customColors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customColors.neutral100,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '시간',
            style: body_medium_semi(context),
          ),
          const SizedBox(height: 8),
          _buildStatisticRow(context, '오늘', '34분'),
          const SizedBox(height: 8),
          _buildStatisticRow(context, '이번달 누적', '24시간 20분'),
        ],
      ),
    );
  }

  Widget _buildAnalysisBox(BuildContext context, CustomColors customColors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: customColors.neutral100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '분석',
            style: body_medium_semi(context),
          ),
          const SizedBox(height: 8),
          Text(
            'AI가 하나둘셋제로님의 읽기 능력을 분석했어요',
            style: body_small(context),
          ),
          const SizedBox(height: 16),
          _buildAnalysisRow(
            context,
            '강점',
            '문법 이해도가 높고 어휘력이 풍부해요',
            customColors.primary20!,
          ),
          const SizedBox(height: 8),
          _buildAnalysisRow(
            context,
            '개선',
            '말하기 연습이 더 필요해요',
            customColors.secondary60!,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalBox(BuildContext context, CustomColors customColors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: customColors.neutral100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '학습 상황',
            style: body_small_semi(context).copyWith(
              color: customColors.neutral30,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 10.0,
                animation: true,
                //percent: completedCount / activities.length,
                center: Text(
                  //'${(completedCount / activities.length * 100).toStringAsFixed(0)}',
                  '30%',
                  style: body_xsmall_semi(context).copyWith(
                    color: customColors.neutral30,
                  ),
                ),
                progressColor: customColors.primary,
                backgroundColor: customColors.neutral80 ?? Colors.grey,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '단어 맞추기',
                    style: heading_medium(context).copyWith(
                      color: customColors.neutral30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '시도: 25회 / 평균 85점',
                    style: body_xsmall(context).copyWith(
                      color: customColors.neutral60,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticRow(BuildContext context, String title, String value) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: body_small(context).copyWith(color: customColors.neutral30),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: body_small(context).copyWith(color: customColors.neutral0),
        ),
      ],
    );
  }

  Widget _buildAnalysisRow(
      BuildContext context,
      String title,
      String content,
      Color backgroundColor,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: body_small_semi(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: body_small(context),
            ),
          ),
        ],
      ),
    );
  }
}