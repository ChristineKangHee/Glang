/// File: paragraph_analysis_result.dart
/// Purpose: 주제 추출 미션 결과 팝업창
/// Author: 강희
/// Created: 2024-1-17
/// Last Modified: 2024-1-25 by 강희

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/feature/after_read/AR_main.dart';
import 'package:readventure/view/feature/after_read/GA_03_08_paragraph_analysis/paragraph_analysis.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import 'dart:math'; // pi 상수 사용을 위한 import

// 결과 화면을 나타내는 위젯 클래스
class ResultScreen extends ConsumerStatefulWidget {
  final int totalQuestions; // 총 문제 수
  final int correctAnswers; // 맞힌 문제 수
  final List<int> userAnswers; // 사용자가 선택한 답변 리스트

  ResultScreen({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.userAnswers,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider); // 커스텀 색상 정보 가져오기
    double percentage = widget.correctAnswers / widget.totalQuestions; // 정답 비율 계산

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: customColors.neutral100, // 배경 색상
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 테두리 둥글게 설정
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(customColors), // 제목 영역
            const SizedBox(height: 24),
            _buildProgressGraphic(percentage, customColors), // 진행률 그래픽
            const SizedBox(height: 16),
            _buildResultSummary(customColors), // 결과 요약
            const SizedBox(height: 20),
            _buildAnswerSummary(customColors), // 정답 요약
            const SizedBox(height: 20),
            _buildActionButtons(customColors), // 액션 버튼
          ],
        ),
      ),
    );
  }

  // 제목 영역 생성
  Align _buildTitle(CustomColors customColors) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        '학습 결과', // 제목 텍스트
        style: body_small_semi(context).copyWith(
          color: customColors.neutral30, // 텍스트 색상
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  // 진행률 그래픽 생성
  Align _buildProgressGraphic(double percentage, CustomColors customColors) {
    return Align(
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(150, 75),
        painter: HalfCirclePainter(
          percentage: percentage * 100, // 비율을 100으로 변환하여 전달
          customColors: customColors,
          context: context,
        ),
      ),
    );
  }

  // 결과 요약 텍스트 생성
  Align _buildResultSummary(CustomColors customColors) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        '총 ${widget.totalQuestions}문제 중 ${widget.correctAnswers}개 정답을 맞혔습니다.',
        style: body_xxsmall(context).copyWith(
          color: customColors.neutral60, // 색상 적용
          decoration: TextDecoration.none,
        ),
        overflow: TextOverflow.ellipsis, // 텍스트 오버플로우 처리
        maxLines: 2,
      ),
    );
  }

  // 정답 요약 리스트 생성
  Column _buildAnswerSummary(CustomColors customColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정답 요약', // 제목 텍스트
          style: body_small_semi(context).copyWith(
            color: customColors.neutral30,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200, // 리스트 높이 설정
          child: ListView.builder(
            itemCount: widget.userAnswers.length, // 문제 수만큼 반복
            itemBuilder: (context, index) {
              final isCorrect = widget.userAnswers[index] == questions[index].correctAnswerIndex; // 정답 여부 확인
              return _buildAnswerItem(index, isCorrect, customColors); // 정답 항목 생성
            },
          ),
        ),
      ],
    );
  }

  // 정답 항목을 표시하는 위젯
  Container _buildAnswerItem(int index, bool isCorrect, CustomColors customColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: customColors.neutral90, // 배경 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // 테두리 둥글게 설정
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '문제 ${index + 1}', // 문제 번호
            style: body_xxsmall(context).copyWith(
              color: customColors.neutral30,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${questions[index].options[questions[index].correctAnswerIndex]}', // 정답 보기 텍스트
            style: body_small(context).copyWith(
              color: isCorrect ? customColors.success : customColors.error, // 정답/오답 색상
              decoration: TextDecoration.none,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 액션 버튼들 생성
  Row _buildActionButtons(CustomColors customColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRetryButton(customColors), // 오답만 다시 풀기 버튼
        const SizedBox(width: 16),
        _buildFinishButton(customColors), // 완료 버튼
      ],
    );
  }

  // 오답만 다시 풀기 버튼
  Expanded _buildRetryButton(CustomColors customColors) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // 오답만 다시 풀기 액션 추가
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: customColors.neutral90,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // 테두리 둥글게 설정
            ),
          ),
          child: Center(
            child: Text(
              '오답만 다시 풀기', // 버튼 텍스트
              style: body_small_semi(context).copyWith(
                color: customColors.neutral60,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 완료 버튼
  Expanded _buildFinishButton(CustomColors customColors) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            Navigator.popUntil(
              context, (route) => route.settings.name == 'LearningActivitiesPage', // 특정 페이지로 돌아가기
            ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: customColors.primary, // 배경 색상
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // 테두리 둥글게 설정
            ),
          ),
          child: Center(
            child: Text(
              '완료', // 버튼 텍스트
              style: body_small_semi(context).copyWith(
                color: customColors.neutral100,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 반원 그래픽을 그리는 커스텀 페인터
class HalfCirclePainter extends CustomPainter {
  final double percentage; // 진행 비율
  final CustomColors customColors; // 색상 설정
  final BuildContext context;

  HalfCirclePainter({
    required this.percentage,
    required this.customColors,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = customColors.neutral80!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = customColors.primary!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // 배경 반원 그리기
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      pi,
      pi,
      false,
      backgroundPaint,
    );

    // 진행 비율에 맞춰 반원 그리기
    final double sweepAngle = (percentage / 100) * pi;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      pi,
      sweepAngle,
      false,
      progressPaint,
    );

    // 비율 텍스트 추가
    final textPainter = TextPainter(
      text: TextSpan(
        text: "${percentage.toInt()}점",
        style: body_large_semi(context).copyWith(
          color: customColors.neutral30,
          decoration: TextDecoration.none,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, size.height / 2 - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 화면이 갱신될 때마다 그리기
  }
}
