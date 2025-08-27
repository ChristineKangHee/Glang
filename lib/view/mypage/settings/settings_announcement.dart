/// File: settings_announcement.dart
/// Purpose: 공지사항 설정 화면 위젯 (L10N 보강: 에러/빈상태/날짜 로캘)
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2025-08-26 by ChatGPT (L10N)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/theme_controller.dart';
import '../../components/custom_app_bar.dart';

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
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('error_with_message'.tr(args: [snapshot.error.toString()])), // ✅ 에러 L10N
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(child: Text('no_announcements'.tr())); // ✅ 빈 상태 L10N
          }

          final announcements = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Announcement(
              title: data['title'] ?? '',
              date: (data['date'] as Timestamp).toDate(),
              detail: data['detail'] ?? '',
            );
          }).toList();

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AnnouncementDetailPage(announcement: announcement),
                    ),
                  );
                },
                child: Column(
                  children: [
                    AnnouncementCard(
                      title: announcement.title,
                      date: announcement.date,
                    ),
                    Divider(color: customColors.neutral80),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AnnouncementCard extends ConsumerWidget {
  final String title;
  final DateTime date;

  const AnnouncementCard({
    Key? key,
    required this.title,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final localeStr = context.locale.toString(); // ✅ 날짜 로캘 적용

    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: body_small_semi(context)),
          const SizedBox(height: 10),
          Text(
            DateFormat('yyyy-MM-dd', localeStr).format(date), // ✅ 로캘 기반 포맷
            style: body_xsmall(context).copyWith(color: customColors.neutral60),
          ),
        ],
      ),
    );
  }
}

class Announcement {
  final String title;
  final DateTime date;
  final String detail;

  Announcement({
    required this.title,
    required this.date,
    required this.detail,
  });
}

class AnnouncementDetailPage extends ConsumerWidget {
  final Announcement announcement;

  const AnnouncementDetailPage({Key? key, required this.announcement})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final localeStr = context.locale.toString(); // ✅ 날짜 로캘 적용

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'announcements'.tr(), // ✅ 공지사항
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
                Text(
                  DateFormat('yyyy-MM-dd', localeStr).format(announcement.date), // ✅ 로캘 기반
                  style: body_xsmall(context).copyWith(color: customColors.neutral60),
                ),
                Divider(color: customColors.neutral80),
                const SizedBox(height: 20),
                Text(
                  announcement.detail.replaceAll(r'\n', '\n'),
                  style: body_small(context),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
