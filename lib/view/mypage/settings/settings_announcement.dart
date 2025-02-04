import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../components/custom_app_bar.dart';

class SettingsAnnouncement extends ConsumerWidget {
  const SettingsAnnouncement({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    // Sample data for announcements, now including detailed content
    final announcements = [
      Announcement(
          title: '[공지] 해당 글은 예시 문장입니다. 문장이 하나의 라인을 넘어갈 경우 넓이에 맞게 내려갑니다.',
          date: '2024.07.11',
          detail: '이 공지사항은 예시 문장을 다루고 있으며, 여러 라인으로 작성될 수 있습니다. 이 공지의 세부 내용은 여기에 포함됩니다.'
      ),
      Announcement(
          title: '[공지] 두 번째 예시 공지입니다. 여기에도 동일한 형식으로 작성됩니다.',
          date: '2024.07.12',
          detail: '두 번째 예시 공지의 내용은 이곳에 표시됩니다. 각 공지사항은 필요한 정보를 제공합니다.'
      ),
      // Add more announcements here
    ];

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '공지사항'.tr(),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: announcements.length, // The number of items in the list
          itemBuilder: (context, index) {
            // For each item in the list, create an AnnouncementCard
            final announcement = announcements[index];
            return GestureDetector(
              onTap: () {
                // Navigate to the detail page when an item is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnnouncementDetailPage(announcement: announcement),
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
        ),
      ),
    );
  }
}

class AnnouncementCard extends ConsumerWidget {
  final String title;
  final String date;

  const AnnouncementCard({
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: body_small_semi(context),
          ),
          const SizedBox(height: 20),
          Text(
            date,
            style: body_xsmall(context).copyWith(color: customColors.neutral60),
          ),
        ],
      ),
    );
  }
}

class Announcement {
  final String title;
  final String date;
  final String detail;  // Added detail field for content

  Announcement({
    required this.title,
    required this.date,
    required this.detail,  // Initializing the detail field
  });
}

class AnnouncementDetailPage extends ConsumerWidget {
  final Announcement announcement;

  const AnnouncementDetailPage({super.key, required this.announcement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '공지사항'.tr(),
      ),
      body: Container(
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
                announcement.date,
                style: body_xsmall(context).copyWith(color: customColors.neutral60),
              ),
              Divider(color: customColors.neutral80,),
              const SizedBox(height: 20),
              Text(
                announcement.detail,  // Displaying the detailed content
                style: body_small(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
