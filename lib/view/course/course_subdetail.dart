/// 파일: course_detail.dart
/// 목적: 특정 코스의 상세 정보를 표시
/// 작성자: 강희
/// 생성일: 2025-01-03

import 'package:flutter/material.dart';
import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../components/custom_app_bar.dart';

class CourseDetailPage extends StatelessWidget {
  final String title; // 섹션 제목 전달

  const CourseDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_1(title: '코스 상세',),
      body: Center(
        child: Text(
          '$title 상세 페이지입니다!',
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
