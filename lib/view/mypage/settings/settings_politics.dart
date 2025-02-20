/// File: settings_politics.dart
/// Purpose: 약관 및 정책 화면을 표시하는 위젯
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 약관 및 정책 화면을 표시하는 위젯
class SettingsPolitics extends ConsumerWidget {
  const SettingsPolitics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용자 지정 색상 테마를 가져옴
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '약관 및 정책'.tr(), // 다국어 지원
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('settings') // 'settings' 컬렉션 접근
            .doc('terms') // 'terms' 문서 접근
            .collection('terms') // 하위 컬렉션 'terms' 접근
            .orderBy('order') // 'order' 필드 기준으로 정렬
            .snapshots(), // 실시간 데이터 스트림 수신
        builder: (context, snapshot) {
          // 데이터를 불러오는 중일 때 로딩 인디케이터 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // 오류가 발생했을 때 오류 메시지 표시
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          }

          // 데이터가 없거나 비어있을 때 메시지 표시
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('약관 정보가 없습니다.'));
          }

          final terms = snapshot.data!.docs; // Firestore에서 가져온 약관 목록

          return ListView.builder(
            itemCount: terms.length, // 리스트 아이템 개수 설정
            itemBuilder: (context, index) {
              final term = terms[index]; // 개별 약관 문서
              final title = term['title']; // 약관 제목

              return Column(
                children: [
                  ListTile(
                    title: Text(
                      title,
                      style: body_medium_semi(context)
                          .copyWith(color: customColors.neutral0), // 사용자 지정 색상 적용
                    ),
                    onTap: () {
                      // 약관 상세 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PolicyDetailScreen(
                            title: title,
                            content: term['content'], // 약관 내용 전달
                          ),
                        ),
                      );
                    },
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: customColors.neutral30, // 아이콘 색상 적용
                    ),
                  ),
                  Divider(color: customColors.neutral80), // 구분선 추가
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// 약관 상세 내용을 표시하는 화면
class PolicyDetailScreen extends StatelessWidget {
  final String title; // 약관 제목
  final String content; // 약관 내용

  const PolicyDetailScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: title.tr(), // 다국어 지원
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            content.replaceAll(r'\n', '\n'), // 개행 문자 변환
            style: body_small(context), // 글꼴 스타일 적용
            softWrap: true, // 텍스트 자동 줄바꿈
            overflow: TextOverflow.visible, // 텍스트 넘칠 경우 표시
          ),
        ),
      ),
    );
  }
}
