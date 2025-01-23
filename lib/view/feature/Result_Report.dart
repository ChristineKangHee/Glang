import 'package:flutter/material.dart';

import '../../theme/font.dart';

class ResultReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      '학습 완료!',
                      style: body_small_semi(context),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      '대단해요 ! 오늘도 열심히 공부하셨어요!',
                      style: TextStyle(
                        color: Color(0xFF434343),
                        fontSize: 16,
                        fontFamily: 'Pretendard Variable',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
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
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '학습 시간',
                        style: TextStyle(
                          color: Color(0xFF0A0A0A),
                          fontSize: 16,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                      Text(
                        '34분',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFF0A0A0A),
                          fontSize: 16,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '얻은 경험치',
                        style: TextStyle(
                          color: Color(0xFF0A0A0A),
                          fontSize: 16,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                      Text(
                        '120xp',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFF0A0A0A),
                          fontSize: 16,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 199,
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '학습 분석',
                    style: TextStyle(
                      color: Color(0xFF0A0A0A),
                      fontSize: 18,
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w600,
                      height: 1.50,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI가 하나둘셋제로님의 학습을 분석했어요',
                    style: TextStyle(
                      color: Color(0xFF0A0A0A),
                      fontSize: 16,
                      fontFamily: 'Pretendard Variable',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: ShapeDecoration(
                      color: Color(0xFFD6D5FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '강점',
                          style: TextStyle(
                            color: Color(0xFF0A0A0A),
                            fontSize: 16,
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w600,
                            height: 1.50,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '문법 이해도가 높고 어휘력이 풍부해요',
                            style: TextStyle(
                              color: Color(0xFF0A0A0A),
                              fontSize: 16,
                              fontFamily: 'Pretendard Variable',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: ShapeDecoration(
                      color: Color(0xFFFDE185),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '개선',
                          style: TextStyle(
                            color: Color(0xFF0A0A0A),
                            fontSize: 16,
                            fontFamily: 'Pretendard Variable',
                            fontWeight: FontWeight.w600,
                            height: 1.50,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '말하기 연습이 더 필요해요',
                            style: TextStyle(
                              color: Color(0xFF0A0A0A),
                              fontSize: 16,
                              fontFamily: 'Pretendard Variable',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
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
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, size: 24),
                      const SizedBox(width: 9),
                      Text(
                        '세부 학습 리포트 보기',
                        style: TextStyle(
                          color: Color(0xFF0A0A0A),
                          fontSize: 18,
                          fontFamily: 'Pretendard Variable',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, size: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}