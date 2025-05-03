import 'package:flutter/material.dart';
import 'package:readventure/view/community/Board/Component/report_dialog.dart';

import '../../../../theme/font.dart';
import '../../../../theme/theme.dart';
import '../community_data_firebase.dart';
import 'block_dialog.dart';

class ReportOrBlockBottomSheet extends StatelessWidget {
  final Post post;
  final CustomColors customColors;

  const ReportOrBlockBottomSheet({
    Key? key,
    required this.post,
    required this.customColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔴 신고하기 버튼
            ListTile(
              title: Center(
                child: Text('신고', style: body_large(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                showReportDialog(context, post.id);
              },
            ),
            const SizedBox(height: 10),
            // 🔴 차단하기 버튼
            ListTile(
              title: Center(
                child: Text('차단', style: body_large(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                showBlockDialog(context, post.authorId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
