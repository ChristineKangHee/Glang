import 'package:flutter/material.dart';
import 'package:readventure/view/community/Board/community_service.dart';

/// 신고 다이얼로그를 보여주는 컴포넌트
class ReportDialog extends StatefulWidget {
  final String postId;

  const ReportDialog({Key? key, required this.postId}) : super(key: key);

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String selectedReason = "욕설 및 부적절한 표현"; // 기본 선택값

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("신고하기"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: selectedReason,
            items: [
              "욕설 및 부적절한 표현",
              "스팸 및 광고",
              "개인정보 노출",
              "기타 부적절한 내용"
            ].map((reason) => DropdownMenuItem(
              value: reason,
              child: Text(reason),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedReason = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("취소"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await CommunityService().reportPost(
              postId: widget.postId,
              reason: selectedReason,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("신고가 접수되었습니다.")),
            );
          },
          child: const Text("신고"),
        ),
      ],
    );
  }
}

/// 사용 방법
void showReportDialog(BuildContext context, String postId) {
  showDialog(
    context: context,
    builder: (context) => ReportDialog(postId: postId),
  );
}