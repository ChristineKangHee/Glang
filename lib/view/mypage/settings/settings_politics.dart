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
    final locale = context.locale;

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'settings.politics.title'.tr(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc('terms')
            .collection('terms')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('error_with_message'.tr(args: [snapshot.error.toString()])),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('no_terms'.tr())); // ✅ 빈 상태
          }

          final docs = snapshot.data!.docs;

          final items = docs.map((d) {
            final data = d.data() as Map<String, dynamic>? ?? const {};
            final title = _localizedField(data, 'title', locale) ?? '';
            final content = _localizedField(data, 'content', locale) ?? '';
            return (title, content);
          }).toList();

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(color: customColors.neutral80),
            itemBuilder: (context, index) {
              final (title, content) = items[index];
              return ListTile(
                title: Text(
                  title,
                  style: body_medium_semi(context).copyWith(color: customColors.neutral0),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PolicyDetailScreen(title: title, content: content),
                    ),
                  );
                },
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
              );
            },
          );
        },
      ),
    );
  }

  /// 문서에서 baseKey_lang 로 우선 조회하고, 없으면 baseKey로 폴백
  String? _localizedField(Map<String, dynamic> data, String baseKey, Locale locale) {
    final lang = locale.languageCode;
    final withLang = data['${baseKey}_$lang'];
    if (withLang is String && withLang.trim().isNotEmpty) return withLang;
    final base = data[baseKey];
    return (base is String && base.trim().isNotEmpty) ? base : null;
  }
}

/// 약관 상세
class PolicyDetailScreen extends StatelessWidget {
  final String title;   // Firestore 동적 제목 (번역 키 아님)
  final String content; // Firestore 동적 본문

  const PolicyDetailScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        // 🔎 동적 제목이므로 .tr() 사용하지 않음
        title: title,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
