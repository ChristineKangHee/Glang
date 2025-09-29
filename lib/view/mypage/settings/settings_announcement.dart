/// File: settings_announcement.dart
/// Purpose: 공지사항 설정 화면 위젯 (L10N 보강: 에러/빈상태/날짜 로캘, published 필터, 안전 파싱)
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2025-09-10 by ChatGPT (L10N + schema)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:readventure/theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/theme_controller.dart';
import '../../components/custom_app_bar.dart';

/// Firestore에서 L10N 필드(단일 문자열 or {ko,en})를 안전하게 현재 로케일로 선택
String _pickLocalized(BuildContext context, dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value; // 레거시 단일 문자열
  if (value is Map) {
    final ko = (value['ko'] ?? '').toString();
    final en = (value['en'] ?? '').toString();
    final lang = context.locale.languageCode.toLowerCase();
    if (lang == 'ko') return ko.isNotEmpty ? ko : (en.isNotEmpty ? en : fallback);
    return en.isNotEmpty ? en : (ko.isNotEmpty ? ko : fallback);
  }
  return fallback;
}

/// Firestore의 date 타입을 안전하게 DateTime으로 변환
DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is String) {
    final d = DateTime.tryParse(v);
    if (d != null) return d;
  }
  return null;
}

class SettingsAnnouncement extends ConsumerWidget {
  const SettingsAnnouncement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'announcements'.tr(), // ✅ 공지사항
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc('announcements')
            .collection('announcements')
            .where('published', isEqualTo: true)
            .snapshots(),


        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'error_with_message'.tr(args: [snapshot.error.toString()]),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 빌더 내부에서 정렬
          final docs = [...(snapshot.data?.docs ?? [])];
          docs.sort((a, b) {
            final ad = (a['date'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bd = (b['date'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bd.compareTo(ad); // 최신순
          });

          if (docs.isEmpty) {
            return Center(child: Text('no_announcements'.tr())); // ✅ 빈 상태 L10N
          }

          final items = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return _AnnouncementRaw(
              id: doc.id,
              titleRaw: data['title'],
              detailRaw: data['detail'],
              date: _parseDate(data['date']),
            );
          }).toList();

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(color: customColors.neutral80),
            itemBuilder: (context, index) {
              final a = items[index];
              final title = _pickLocalized(context, a.titleRaw);
              final date = a.date;

              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: body_small_semi(context)),
                    const SizedBox(height: 10),
                    if (date != null)
                      Text(
                        DateFormat('yyyy-MM-dd', context.locale.toString()).format(date), // ✅ 로캘 기반 포맷
                        style: body_xsmall(context).copyWith(color: customColors.neutral60),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnnouncementDetailPage(
                        announcement: _AnnouncementResolved(
                          id: a.id,
                          title: title,
                          detail: _pickLocalized(context, a.detailRaw),
                          date: date,
                        ),
                      ),
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

/// 내부용: Firestore 원시 데이터 컨테이너
class _AnnouncementRaw {
  final String id;
  final dynamic titleRaw;  // String or {ko,en}
  final dynamic detailRaw; // String or {ko,en}
  final DateTime? date;

  _AnnouncementRaw({
    required this.id,
    required this.titleRaw,
    required this.detailRaw,
    required this.date,
  });
}

/// 화면 표시용: 로캘 적용이 끝난 모델
class _AnnouncementResolved {
  final String id;
  final String title;
  final String detail;
  final DateTime? date;

  _AnnouncementResolved({
    required this.id,
    required this.title,
    required this.detail,
    required this.date,
  });
}

class AnnouncementDetailPage extends ConsumerWidget {
  final _AnnouncementResolved announcement;

  const AnnouncementDetailPage({Key? key, required this.announcement})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final localeStr = context.locale.toString();

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'announcements'.tr(),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: customColors.neutral90,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(announcement.title, style: body_small_semi(context)),
                const SizedBox(height: 10),
                if (announcement.date != null)
                  Text(
                    DateFormat('yyyy-MM-dd', localeStr).format(announcement.date!),
                    style: body_xsmall(context).copyWith(color: customColors.neutral60),
                  ),
                Divider(color: customColors.neutral80),
                const SizedBox(height: 20),
                // Firestore 문자열은 실제 개행을 포함하고 있으므로 그대로 표시
                Text(
                  announcement.detail,
                  style: body_small(context),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
