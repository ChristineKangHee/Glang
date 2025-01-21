/*

IconSection(
  customColors: customColors,       // 필수: CustomColors 전달
  icon: Icons.edit,                 // 선택: 아이콘 변경 (기본값: Icons.import_contacts)
  size: 100.0,                      // 선택: 아이콘 크기 변경 (기본값: 80.0)
),

 */
import 'package:flutter/material.dart';
import 'package:readventure/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconSection extends StatelessWidget {
  const IconSection({
    super.key,
    required this.customColors,
    this.icon = Icons.import_contacts, // 기본 아이콘
    this.size = 80.0,                  // 기본 아이콘 크기
  });

  final CustomColors customColors;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.875, // 배경 크기는 아이콘 크기 기준으로 설정
      height: size * 1.875,
      decoration: ShapeDecoration(
        color: customColors.primary,
        shape: const OvalBorder(),
      ),
      child: Icon(
        icon,
        color: customColors.neutral100,
        size: size,
      ),
    );
  }
}

class SVGSection extends StatelessWidget {
  const SVGSection({
    super.key,
    required this.customColors,
    this.assetPath = 'assets/icons/debate.svg', // 기본 SVG 경로
    this.size = 80.0,                                // 기본 아이콘 크기
  });

  final CustomColors customColors;
  final String assetPath; // SVG 파일 경로
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.875, // 배경 크기는 아이콘 크기 기준으로 설정
      height: size * 1.875,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        placeholderBuilder: (context) => Center(
          child: CircularProgressIndicator(), // SVG 로드 중 표시할 위젯
        ),
      ),
    );
  }
}
