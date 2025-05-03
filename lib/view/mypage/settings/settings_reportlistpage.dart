import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        appBar: AppBar(title: const Text('신고 내역')),
        body: const Center(
          child: Text('접근 권한이 없습니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '신고 내역', // 다국어 지원을 위한 번역 적용
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return const Center(child: Text('신고 내역이 없습니다.'));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final reportDoc = reports[index];
              final data = reportDoc.data() as Map<String, dynamic>;

              final isProcessed = (data['status'] ?? '대기중') == '처리완료';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    '[${data['reason'] ?? '사유 없음'}]',
                    style: body_medium_semi(context),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('신고자 ID: ${data['reporterUserId'] ?? '알 수 없음'}', style: body_small(context)),
                      Text('피신고자 ID: ${data['reportedUserId'] ?? '알 수 없음'}', style: body_small(context)),
                      if (data['reportedPostId'] != null)
                        Text('신고된 게시글 ID: ${data['reportedPostId']}', style: body_small(context)),
                      if (data['reportedCommentId'] != null)
                        Text('신고된 댓글 ID: ${data['reportedCommentId']}', style: body_small(context)),
                      Text('상태: ${data['status'] ?? '대기중'}', style: body_small(context)),
                      Text('신고일: ${_formatTimestamp(data['createdAt'])}', style: body_small(context)),
                      const SizedBox(height: 8),
                      if (!isProcessed)
                        ElevatedButton(
                          onPressed: () => _markAsProcessed(context, reportDoc.id),
                          child: const Text('처리 완료로 변경'),
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

  /// 🔹 Timestamp -> 문자열 변환
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '알 수 없음';
    final date = timestamp.toDate();
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  /// 🔹 신고 상태 처리 완료로 변경
  Future<void> _markAsProcessed(BuildContext context, String reportId) async {
    try {
      await FirebaseFirestore.instance.collection('reports').doc(reportId).update({
        'status': '처리완료',
        'adminResponse': '운영자 처리 완료',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('처리 완료로 변경했습니다.')),
      );
    } catch (e) {
      print('❌ 처리 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('처리 실패')),
      );
    }
  }
}
