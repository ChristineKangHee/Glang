import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/feature/after_read/GA_03_08_paragraph_analysis/paragraph_analysis.dart';
import '../../../../theme/font.dart';
import '../../../../viewmodel/custom_colors_provider.dart';
import 'dart:math'; // For the pi constant

class ResultScreen extends ConsumerStatefulWidget {
  final int totalQuestions;
  final int correctAnswers;
  final List<int> userAnswers;

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
    final customColors = ref.watch(customColorsProvider);  // Fetch the custom colors

    double percentage = widget.correctAnswers / widget.totalQuestions;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section - Centered
            Align(
              alignment: Alignment.center,
              child: Text(
                '학습 결과',
                style: body_small_semi(context).copyWith(
                  color: customColors.neutral30,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Custom half-circle progress graphic
            Align(
              alignment: Alignment.center,
              child: CustomPaint(
                size: Size(150, 75), // Custom size for the graphic
                painter: HalfCirclePainter(percentage: percentage * 100), // Convert to percentage
              ),
            ),
            const SizedBox(height: 16),
            // Result Summary Section - Centered
            Align(
              alignment: Alignment.center,
              child: Text(
                '총 ${widget.totalQuestions}문제 중 ${widget.correctAnswers}개 정답을 맞혔습니다.',
                style: body_xxsmall(context).copyWith(
                  color: customColors.neutral60,
                  decoration: TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 20),

            // Correct Answer Summary Section - Left aligned
            Text(
              '정답 요약',
              style: body_small_semi(context).copyWith(
                color: customColors.neutral30,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: widget.userAnswers.length,
                itemBuilder: (context, index) {
                  final isCorrect = widget.userAnswers[index] == questions[index].correctAnswerIndex;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: customColors.neutral90,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '문제 ${index + 1}',
                          style: body_xxsmall(context).copyWith(
                            color: customColors.neutral30,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 7),

                        Text(
                          '${questions[index].options[questions[index].correctAnswerIndex]}',
                          style: body_small(context).copyWith(
                            color: isCorrect ? customColors.success : customColors.error,
                            decoration: TextDecoration.none,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons (Retry incorrect answers / Finish)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Add your action for retrying incorrect answers
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: customColors.neutral90,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '오답만 다시 풀기',
                          style: body_small_semi(context).copyWith(
                            color: customColors.neutral60,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Add your action for finishing the test
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: customColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '완료',
                          style: body_small_semi(context).copyWith(
                            color: customColors.neutral100,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class HalfCirclePainter extends CustomPainter {
  final double percentage;

  HalfCirclePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final Paint progressPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round; // Ensures the ends are rounded

    // Draw half-circle background
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      pi, // Start angle (180 degrees)
      pi, // End angle (180 degrees)
      false,
      backgroundPaint,
    );

    // Draw progress based on the percentage
    final double sweepAngle = (percentage / 100) * pi;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      pi, // Start angle (180 degrees)
      sweepAngle, // Sweep angle based on the percentage
      false,
      progressPaint,
    );

    // Add percentage text
    final textPainter = TextPainter(
      text: TextSpan(
        text: "${percentage.toInt()}점",
        style: TextStyle(fontSize: 20, color: Colors.black),
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
    return true;
  }
}
