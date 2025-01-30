import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/font.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_button.dart';

class ResultReportPage extends ConsumerStatefulWidget {
  @override
  _ResultReportPageState createState() => _ResultReportPageState();
}

class _ResultReportPageState extends ConsumerState<ResultReportPage> {
  @override
  Widget build(BuildContext context) {
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: CustomAppBar_2depth_6(
        title: '결과 리포트',
        automaticallyImplyLeading: false, // 뒤로가기 화살표 비활성화
        onIconPressed: () {
          Navigator.pushNamed(context, '/'); // '/'로 이동
        },
      ),
      backgroundColor: customColors.neutral90,
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      '읽기 완료!',
                      style: body_large_semi(context)
                          .copyWith(color: customColors.primary),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      '대단해요 ! 오늘도 열심히 읽으셨네요!',
                      style: body_small(context)
                          .copyWith(color: customColors.neutral30),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '읽은 시간',
                        style: body_small_semi(context),
                      ),
                      Text(
                        '34분',
                        textAlign: TextAlign.right,
                        style: body_small(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '얻은 경험치',
                        style: body_small_semi(context),
                      ),
                      Text(
                        '120xp',
                        textAlign: TextAlign.right,
                        style: body_small(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 수정된 부분
                children: [
                  Text(
                    '분석',
                    style: body_medium_semi(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI가 하나둘셋제로님의 읽기 능력을 분석했어요',
                    style: body_small(context),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: ShapeDecoration(
                      color: customColors.primary20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '강점',
                          style: body_small_semi(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '문법 이해도가 높고 어휘력이 풍부해요',
                            style: body_small(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFDE185),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '개선',
                          style: body_small_semi(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '말하기 연습이 더 필요해요',
                            style: body_small(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: ShapeDecoration(
                color: customColors.neutral100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 24,
                        color: customColors.primary,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        '세부 리포트 보기',
                        style: body_medium_semi(context),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 24,
                    color: customColors.neutral30,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
