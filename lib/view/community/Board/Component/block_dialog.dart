import 'package:flutter/material.dart';
import 'package:readventure/view/community/Board/community_service.dart';

/// 사용자를 차단하는 다이얼로그 컴포넌트
class BlockDialog extends StatelessWidget {
  final String blockedUserId;

  const BlockDialog({Key? key, required this.blockedUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("사용자 차단"),
      content: const Text("이 사용자를 차단하시겠습니까? 차단하면 이 사용자의 글이 더 이상 보이지 않습니다."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("취소"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await CommunityService().blockUser(blockedUserId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("사용자를 차단했습니다.")),
            );
          },
          child: const Text("차단"),
        ),
      ],
    );
  }
}

/// 사용 방법
void showBlockDialog(BuildContext context, String blockedUserId) {
  showDialog(
    context: context,
    builder: (context) => BlockDialog(blockedUserId: blockedUserId),
  );
}
