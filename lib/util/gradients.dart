import 'package:flutter/material.dart';
import 'package:readventure/theme/theme.dart'; // CustomColors가 정의된 파일

/*
* **AppGradients 클래스 사용 예시**
*
* child: Container(
*   padding: const EdgeInsets.all(16.0),
*   decoration: BoxDecoration(
*     gradient: AppGradients.whiteToGrey(customColors), // 흰색 → 회색 그라데이션 적용
*   ),
* ),
*
*/

/// **AppGradients 클래스**
/// - 앱에서 공통적으로 사용할 그라데이션을 정의하는 헬퍼 클래스.
/// - `CustomColors` 객체를 사용하여 동적인 색상 테마를 지원.
/// - 예제: `AppGradients.whiteToGrey(customColors)` → 흰색에서 회색으로의 그라데이션.
class AppGradients {
  /// **whiteToGrey**: 흰색에서 회색으로 변하는 수직 그라데이션
  ///
  /// - `customColors`: `CustomColors` 객체를 받아 색상을 동적으로 설정.
  /// - `neutral100`(기본값: 흰색)에서 `neutral90`(기본값: 회색)으로 변경.
  /// - `begin`: 상단(Top)에서 시작 → `Alignment.topCenter`
  /// - `end`: 하단(Bottom)에서 끝 → `Alignment.bottomCenter`
  static LinearGradient whiteToGrey(CustomColors customColors) {
    return LinearGradient(
      colors: [
        customColors.neutral100 ?? Colors.white, // 기본값: 흰색
        customColors.neutral90 ?? Colors.grey,   // 기본값: 회색
      ],
      begin: Alignment.topCenter, // 시작점 (위쪽)
      end: Alignment.bottomCenter, // 끝점 (아래쪽)
    );
  }

  /// **primaryToAccent**: 기본(primary) 색상에서 보조(accent) 색상으로 변하는 대각선 그라데이션
  ///
  /// - `customColors.primary`(기본값: 파란색)에서 `customColors.secondary`(기본값: 주황색)으로 변경.
  /// - `begin`: 왼쪽 상단에서 시작 → `Alignment.topLeft`
  /// - `end`: 오른쪽 하단에서 끝 → `Alignment.bottomRight`
  static LinearGradient primaryToAccent(CustomColors customColors) {
    return LinearGradient(
      colors: [
        customColors.primary ?? Colors.blue,    // 기본값: 파란색
        customColors.secondary ?? Colors.orange, // 기본값: 주황색
      ],
      begin: Alignment.topLeft, // 시작점 (왼쪽 상단)
      end: Alignment.bottomRight, // 끝점 (오른쪽 하단)
    );
  }   
}
