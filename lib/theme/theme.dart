import "package:flutter/material.dart";

/*
* 아래와 같이 사용
  class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
  이렇게 class 내에서 사전 선언 후

  color: customColors.primary,
  이런 식으로 사용.

  context가 없는 곳에서는

  color = ThemeManager.customColors.primary
  이런식으로 사용

*/

// CustomColors 클래스 정의
class CustomColors extends ThemeExtension<CustomColors> {
  final Color? primary;
  final Color? color01;
  final Color? color02;
  final Color? green03;
  final Color? green04;
  final Color? green05;
  final Color? green06;
  final Color? green07;
  final Color? secondary;
  final Color? yellow01;
  final Color? yellow02;
  final Color? yellow03;
  final Color? yellow04;
  final Color? yellow05;
  final Color? yellow06;
  final Color? yellow07;
  final Color? gray01;
  final Color? gray02;
  final Color? gray03;
  final Color? gray04;
  final Color? gray05;
  final Color? gray06;
  final Color? black;
  final Color? white;


  CustomColors({
    required this.primary,
    required this.color01,
    required this.color02,
    required this.green03,
    required this.green04,
    required this.green05,
    required this.green06,
    required this.green07,
    required this.secondary,
    required this.yellow01,
    required this.yellow02,
    required this.yellow03,
    required this.yellow04,
    required this.yellow05,
    required this.yellow06,
    required this.yellow07,
    required this.gray01,
    required this.gray02,
    required this.gray03,
    required this.gray04,
    required this.gray05,
    required this.gray06,
    required this.black,
    required this.white,
  });

  @override
  CustomColors copyWith({
    Color? primary,
    Color? color01,
    Color? color02,
    Color? green03,
    Color? green04,
    Color? green05,
    Color? green06,
    Color? green07,
    Color? secondary,
    Color? yellow01,
    Color? yellow02,
    Color? yellow03,
    Color? yellow04,
    Color? yellow05,
    Color? yellow06,
    Color? yellow07,
    Color? gray01,
    Color? gray02,
    Color? gray03,
    Color? gray04,
    Color? gray05,
    Color? gray06,
    Color? black,
    Color? white,
  }) {
    return CustomColors(
      primary: primary ?? this.primary,
      color01: color01 ?? this.color01,
      color02: color02 ?? this.color02,
      green03: green03 ?? this.green03,
      green04: green04 ?? this.green04,
      green05: green05 ?? this.green05,
      green06: green06 ?? this.green06,
      green07: green07 ?? this.green07,
      secondary: secondary ?? this.secondary,
      yellow01: yellow01 ?? this.yellow01,
      yellow02: yellow02 ?? this.yellow02,
      yellow03: yellow03 ?? this.yellow03,
      yellow04: yellow04 ?? this.yellow04,
      yellow05: yellow05 ?? this.yellow05,
      yellow06: yellow06 ?? this.yellow06,
      yellow07: yellow07 ?? this.yellow07,
      gray01: gray01 ?? this.gray01,
      gray02: gray02 ?? this.gray02,
      gray03: gray03 ?? this.gray03,
      gray04: gray04 ?? this.gray04,
      gray05: gray05 ?? this.gray05,
      gray06: gray06 ?? this.gray06,
      black: black ?? this.black,
      white: white ?? this.white,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      primary: Color.lerp(primary, other.primary, t),
      color01: Color.lerp(color01, other.color01, t),
      color02: Color.lerp(color02, other.color02, t),
      green03: Color.lerp(green03, other.green03, t),
      green04: Color.lerp(green04, other.green04, t),
      green05: Color.lerp(green05, other.green05, t),
      green06: Color.lerp(green06, other.green06, t),
      green07: Color.lerp(green07, other.green07, t),
      secondary: Color.lerp(secondary, other.secondary, t),
      yellow01: Color.lerp(yellow01, other.yellow01, t),
      yellow02: Color.lerp(yellow02, other.yellow02, t),
      yellow03: Color.lerp(yellow03, other.yellow03, t),
      yellow04: Color.lerp(yellow04, other.yellow04, t),
      yellow05: Color.lerp(yellow05, other.yellow05, t),
      yellow06: Color.lerp(yellow06, other.yellow06, t),
      yellow07: Color.lerp(yellow07, other.yellow07, t),
      gray01: Color.lerp(gray01, other.gray01, t),
      gray02: Color.lerp(gray02, other.gray02, t),
      gray03: Color.lerp(gray03, other.gray03, t),
      gray04: Color.lerp(gray04, other.gray04, t),
      gray05: Color.lerp(gray05, other.gray05, t),
      gray06: Color.lerp(gray06, other.gray06, t),
      black: Color.lerp(black, other.black, t),
      white: Color.lerp(white, other.white, t),
    );
  }
}

// CustomColors 클래스 및 기타 정의는 그대로 유지
// 화면 베이스 흰색으로 설정 할 겸... 테마 정의 부분

final ThemeData lightThemeGlobal = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white, // 바탕화면을 흰색으로 설정
  colorScheme: ColorScheme.light(
    primary: Color(0xFF58BA67), // 기본 Primary 색상
    secondary: Color(0xFFFFBF1C), // 기본 Secondary 색상
    background: Colors.white, // 배경 색상
    surface: Colors.white, // 서피스(카드 등) 색상
    onPrimary: Colors.white, // Primary 색상 위에 올려질 텍스트/아이콘 색상
    onSecondary: Colors.black, // Secondary 색상 위에 올려질 텍스트/아이콘 색상
    onBackground: Colors.black, // 배경색 위에 올려질 텍스트 색상
    onSurface: Colors.black, // 서피스 색상 위에 올려질 텍스트 색상
  ),
  extensions: <ThemeExtension>[
    CustomColors(
      primary: Color(0xFF3A94E7),
      color01: Color(0xFF0B3A64),
      color02: Color(0xFF2266A3),
      green03: Color(0xFF6CA6EA),
      green04: Color(0xFFAECCEF),
      green05: Color(0xFFCBDFF1),
      green06: Color(0xFFC3DFC2),
      green07: Color(0xFFD8EAD9),
      secondary: Color(0xFFFFBF1C),
      yellow01: Color(0xFF665A31),
      yellow02: Color(0xFF967C40),
      yellow03: Color(0xFFD0A547),
      yellow04: Color(0xFFF8CA66),
      yellow05: Color(0xFFFBDFA1),
      yellow06: Color(0xFFFCEBC2),
      yellow07: Color(0xFFFDF8E3),
      gray01: Color(0xFF464655),
      gray02: Color(0xFF626271),
      gray03: Color(0xFF90909F),
      gray04: Color(0xFFC6C6CF),
      gray05: Color(0xFFE9E9ED),
      gray06: Color(0xFFE9E9ED),
      white: Colors.white,
      black: Colors.black,
    ),
  ],
);

final ThemeData darkThemeGlobal = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF121212), // 다크 모드 배경 설정
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF4A8A3E), // 기본 Primary 색상
    secondary: Color(0xFFDDA60B), // 기본 Secondary 색상
    background: Color(0xFF121212), // 배경 색상
    surface: Color(0xFF1E1E1E), // 서피스(카드 등) 색상
    onPrimary: Colors.black, // Primary 색상 위에 올려질 텍스트/아이콘 색상
    onSecondary: Colors.white, // Secondary 색상 위에 올려질 텍스트/아이콘 색상
    onBackground: Colors.white, // 배경색 위에 올려질 텍스트 색상
    onSurface: Colors.white, // 서피스 색상 위에 올려질 텍스트 색상
  ),
  extensions: <ThemeExtension>[
    CustomColors(
      primary: Color(0xFF4A8A3E),
      color01: Color(0xFF264A2C),
      color02: Color(0xFF3A5F40),
      green03: Color(0xFF547A57),
      green04: Color(0xFF6D946D),
      green05: Color(0xFF8AAF8A),
      green06: Color(0xFFACC5A8),
      green07: Color(0xFFCDE5CD),
      secondary: Color(0xFFDDA60B),
      yellow01: Color(0xFF4E4325),
      yellow02: Color(0xFF705B33),
      yellow03: Color(0xFF9F7D38),
      yellow04: Color(0xFFD8A84B),
      yellow05: Color(0xFFEACF87),
      yellow06: Color(0xFFF0E0AA),
      yellow07: Color(0xFFF8F1CB),
      gray01: Color(0xFF303030),
      gray02: Color(0xFF484848),
      gray03: Color(0xFF6E6E6E),
      gray04: Color(0xFF9A9A9A),
      gray05: Color(0xFFBEBEBE),
      gray06: Color(0xFFE9E9ED),
      white: Colors.black, // 다크 모드에서는 흰색을 검은색으로
      black: Colors.white, // 다크 모드에서는 검은색을 흰색으로
    ),
  ],
);

