import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ L10N
import '../../../constants.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/custom_app_bar.dart';

class ReportListPage extends ConsumerWidget {
  const ReportListPage({Key? key}) : super(key: key);

  bool _isAdmin(User? user) {
    if (user == null) return false;
    return adminEmails.contains(user.email);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final user = FirebaseAuth.instance.currentUser;

    if (!_isAdmin(user)) {
      return Scaffold(
        appBar: CustomAppBar_2depth_4(title: 'admin_reports'.tr()),
        body: Center(child: Text('no_permission'.tr())),
      );
    }

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'admin_reports'.tr(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('error_with_message'.tr(args: [snapshot.error.toString()])),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;
          if (reports.isEmpty) {
            return Center(child: Text('no_reports'.tr()));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final reportDoc = reports[index];
              final data = reportDoc.data() as Map<String, dynamic>;

              final reasonRaw = (data['reason'] ?? '') as String;
              final reason = reasonRaw.trim().isEmpty ? 'reason_none'.tr() : reasonRaw;

              final reporterId = (data['reporterUserId'] ?? '') as String;
              final reportedUserId = (data['reportedUserId'] ?? '') as String;
              final reportedPostId = data['reportedPostId'];
              final reportedCommentId = data['reportedCommentId'];

              final statusRaw = (data['status'] ?? '') as String;
              final statusLocalized = _localizedStatus(statusRaw);

              final createdAt = data['createdAt'] as Timestamp?;

              final isProcessed = statusLocalized == 'status_processed'.tr();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    '[$reason]',
                    style: body_medium_semi(context),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'reporter_id_label'.tr(args: [reporterId.isEmpty ? 'unknown'.tr() : reporterId]),
                        style: body_small(context),
                      ),
                      Text(
                        'reported_user_id_label'
                            .tr(args: [reportedUserId.isEmpty ? 'unknown'.tr() : reportedUserId]),
                        style: body_small(context),
                      ),
                      if (reportedPostId != null)
                        Text(
                          'reported_post_id_label'.tr(args: ['$reportedPostId']),
                          style: body_small(context),
                        ),
                      if (reportedCommentId != null)
                        Text(
                          'reported_comment_id_label'.tr(args: ['$reportedCommentId']),
                          style: body_small(context),
                        ),
                      Text(
                        'status_label'.tr(args: [statusLocalized]),
                        style: body_small(context),
                      ),
                      Text(
                        'report_date_label'.tr(args: [_formatTimestamp(context, createdAt)]),
                        style: body_small(context),
                      ),
                      const SizedBox(height: 8),
                      if (!isProcessed)
                        ElevatedButton(
                          onPressed: () => _markAsProcessed(context, reportDoc.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: customColors.primary,
                            foregroundColor: customColors.neutral100,
                          ),
                          child: Text('mark_as_processed'.tr()),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// ✅ Timestamp → 로케일 기반 날짜 문자열
  String _formatTimestamp(BuildContext context, Timestamp? timestamp) {
    if (timestamp == null) return 'unknown'.tr();
    final date = timestamp.toDate();
    final localeStr = context.locale.toString();
    return DateFormat('yyyy.MM.dd', localeStr).format(date);
  }

  /// ✅ 상태 현지화(한/영 값 모두 대응)
  String _localizedStatus(String raw) {
    final s = raw.trim().toLowerCase();
    if (s == '처리완료' || s == 'processed') return 'status_processed'.tr();
    if (s == '대기중' || s == 'pending' || s.isEmpty) return 'status_pending'.tr();
    // 알 수 없는 커스텀 상태는 원문 노출
    return raw;
  }

  /// ✅ 신고 상태 → 처리완료
  Future<void> _markAsProcessed(BuildContext context, String reportId) async {
    try {
      await FirebaseFirestore.instance.collection('reports').doc(reportId).update({
        'status': '처리완료',           // 스키마 호환: 기존 값 유지
        'adminResponse': '운영자 처리 완료',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('mark_processed_success'.tr())),
      );
    } catch (e) {
      debugPrint('❌ 처리 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('mark_processed_failed'.tr())),
      );
    }
  }
}
