/// File: settings_politics.dart
/// Purpose: 약관 및 정책 화면을 표시하는 위젯 (L10N/로캘 폴백 강화)
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2025-08-26 by ChatGPT (L10N)

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../theme/theme.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPolitics extends ConsumerWidget {
  const SettingsPolitics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        // 기존 'settings.politics.title' 대신 공용 키 사용
        title: 'terms_policies'.tr(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc('terms')
            .collection('terms')
            .orderBy('order') // 단일 정렬 → 추가 인덱스 불필요
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('error_with_message'.tr(args: [snapshot.error.toString()])),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('no_terms'.tr()));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => Divider(color: customColors.neutral80),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>? ?? {};
              final title = _pickLocalized(context, data['title']);
              final content = _pickLocalized(context, data['content']);

              return ListTile(
                title: Text(
                  title,
                  style: body_medium_semi(context).copyWith(color: customColors.neutral0),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PolicyDetailScreen(title: title, content: content),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// 문자열 / {ko,en} 맵 안전 처리 (레거시 호환)
String _pickLocalized(BuildContext context, dynamic value) {
  if (value == null) return '';
  if (value is String) return value; // 레거시 단일 문자열
  if (value is Map) {
    final lang = context.locale.languageCode.toLowerCase();
    final ko = (value['ko'] ?? '').toString();
    final en = (value['en'] ?? '').toString();
    if (lang == 'ko') return ko.isNotEmpty ? ko : (en.isNotEmpty ? en : '');
    return en.isNotEmpty ? en : (ko.isNotEmpty ? ko : '');
  }
  return '';
}

/// 약관/정책 상세
class PolicyDetailScreen extends ConsumerWidget {
  final String title;   // Firestore 동적 제목
  final String content; // Firestore 동적 본문

  const PolicyDetailScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        // 동적 문자열 → .tr() 사용하지 않음
        title: title,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: customColors.neutral90,
          padding: const EdgeInsets.all(16),
          child: Text(
            content.replaceAll(r'\n', '\n'),
            style: body_small(context),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}
