/// File: settings_announcement.dart
/// Purpose: 공지사항 설정 화면 위젯
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../components/custom_app_bar.dart';

// 공지사항 설정 화면 위젯
class SettingsAnnouncement extends ConsumerWidget {
  const SettingsAnnouncement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider); // 커스텀 색상 프로바이더 감시

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '공지사항'.tr(), // 다국어 지원을 위한 번역 적용
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore에서 공지사항 데이터를 실시간으로 가져오기
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc('announcements')
            .collection('announcements')
            .orderBy('date', descending: true) // 최신순 정렬
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}')); // 오류 발생 시 표시
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 데이터 로딩 중
          }

          // Firestore에서 가져온 데이터를 Announcement 객체 리스트로 변환
          final announcements = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Announcement(
              title: data['title'] ?? '',
              date: (data['date'] as Timestamp).toDate(), // Timestamp를 DateTime으로 변환
              detail: data['detail'] ?? '',
            );
          }).toList();

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return GestureDetector(
                onTap: () {
                  // 공지사항 상세 페이지로 이동
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

// 공지사항 목록에서 개별 공지사항을 표시하는 카드 위젯
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
    final customColors = ref.watch(customColorsProvider); // 커스텀 색상 가져오기

    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: body_small_semi(context), // 제목 스타일 적용
          ),
          const SizedBox(height: 10),
          Text(
            DateFormat('yyyy-MM-dd').format(date), // 날짜 형식 변환하여 표시
            style: body_xsmall(context).copyWith(color: customColors.neutral60),
          ),
        ],
      ),
    );
  }
}

// 공지사항 정보를 담는 데이터 모델 클래스
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

// 공지사항 상세 페이지 위젯
class AnnouncementDetailPage extends ConsumerWidget {
  final Announcement announcement;

  const AnnouncementDetailPage({Key? key, required this.announcement})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider); // 커스텀 색상 가져오기

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
                  style: body_small_semi(context), // 제목 스타일 적용
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormat('yyyy-MM-dd').format(announcement.date), // 날짜 표시
                  style: body_xsmall(context).copyWith(color: customColors.neutral60),
                ),
                Divider(color: customColors.neutral80),
                const SizedBox(height: 20),
                Text(
                  announcement.detail.replaceAll(r'\n', '\n'), // 줄 바꿈 적용
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