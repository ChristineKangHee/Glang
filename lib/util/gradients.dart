import 'package:flutter/material.dart';
import 'package:readventure/theme/theme.dart'; // CustomColors가 정의된 파일

/*
*
  사용법
  child: Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(gradient: AppGradients.whiteToGrey(customColors)),
*
*/

class AppGradients {
  // 흰색에서 회색 그라데이션
  static LinearGradient whiteToGrey(CustomColors customColors) {
    return LinearGradient(
      colors: [
        customColors.neutral100 ?? Colors.white, // 흰색
        customColors.neutral90 ?? Colors.grey,   // 회색
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  // 다른 그라데이션 예시
  static LinearGradient primaryToAccent(CustomColors customColors) {
    return LinearGradient(
      colors: [
        customColors.primary ?? Colors.blue,    // Primary 색상
        customColors.accent ?? Colors.orange,   // Accent 색상
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
