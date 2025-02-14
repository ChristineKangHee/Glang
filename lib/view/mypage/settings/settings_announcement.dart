import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../components/custom_app_bar.dart';

class SettingsAnnouncement extends ConsumerWidget {
  const SettingsAnnouncement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '공지사항'.tr(),
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
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final announcements = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Announcement(
              title: data['title'] ?? '',
              date: (data['date'] as Timestamp).toDate(), // Timestamp → DateTime 변환
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

    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: body_small_semi(context),
          ),
          const SizedBox(height: 10),
          Text(
            DateFormat('yyyy-MM-dd').format(date),
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

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '공지사항'.tr(),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: customColors.neutral90,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: body_small_semi(context),
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormat('yyyy-MM-dd').format(announcement.date),
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
