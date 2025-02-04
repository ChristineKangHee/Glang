import 'package:flutter/material.dart';

import '../../theme/font.dart';
import '../../theme/theme.dart';

/*
사용방법
showResultDialog(
  context,
  customColors,
  "결과를 저장하고 이동할까요?",
  "아니오",
  "예",
  (ctx) {
    Navigator.pushReplacement(
      ctx,
      MaterialPageRoute(builder: (ctx) => HomePage()),
    );
  },
  continuationMessage: "다시 활동을 이어하시겠습니까?", // 추가 메시지
);
 */

class ResultDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final CustomColors customColors;
  final String message;
  final String cancelText;
  final String confirmText;
  final void Function(BuildContext) onConfirmNavigation;
  final String? continuationMessage; // continuationMessage는 옵션

  const ResultDialog({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
    required this.customColors,
    required this.message,
    required this.cancelText,
    required this.confirmText,
    required this.onConfirmNavigation,
    this.continuationMessage, // continuationMessage는 선택적으로 받아옴
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: customColors.neutral100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: heading_small(context).copyWith(color: customColors.neutral30),
              ),
            ),
            const SizedBox(height: 4),
            // continuationMessage가 있을 경우만 표시
            if (continuationMessage != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  continuationMessage!, // null이 아니면 메시지 표시
                  style: body_small(context).copyWith(color: customColors.neutral30),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildDialogButton(context, cancelText, customColors.neutral90!, customColors.neutral60!, onCancel),
                const SizedBox(width: 16),
                _buildDialogButton(context, confirmText, customColors.primary!, customColors.neutral100!, () {
                  Navigator.pop(context);
                  onConfirmNavigation(context);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(
      BuildContext context, String title, Color bgColor, Color textColor, VoidCallback onPressed) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: ShapeDecoration(
            color: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: body_small_semi(context).copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}

void showResultDialog(BuildContext context, CustomColors customColors, String message, String cancelText, String confirmText, void Function(BuildContext) onConfirmNavigation, {String? continuationMessage}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ResultDialog(
        customColors: customColors,
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);
          onConfirmNavigation(context);
        },
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirmNavigation: onConfirmNavigation,
        continuationMessage: continuationMessage, // optional continuationMessage
      );
    },
  );
}

class PauseDialog extends StatelessWidget {
  final VoidCallback onExit;
  final VoidCallback onResume;
  final CustomColors customColors;

  const PauseDialog({
    Key? key,
    required this.onExit,
    required this.onResume,
    required this.customColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: customColors.neutral100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "활동을 일시 중지했습니다. 계속하시겠습니까?",
              style: heading_small(context).copyWith(color: customColors.neutral30),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildDialogButton(
                  context,
                  "종료",
                  customColors.neutral90!,
                  customColors.neutral60!,
                  onExit,
                ),
                const SizedBox(width: 16),
                _buildDialogButton(
                  context,
                  "재개",
                  customColors.primary!,
                  customColors.neutral100!,
                  onResume,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(
      BuildContext context, String title, Color bgColor, Color textColor, VoidCallback onPressed) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: ShapeDecoration(
            color: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: body_small_semi(context).copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}

void showPauseDialog(BuildContext context, CustomColors customColors, VoidCallback onExit, VoidCallback onResume) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PauseDialog(
        customColors: customColors,
        onExit: () {
          Navigator.pop(context);
          onExit(); // Exit action
        },
        onResume: () {
          Navigator.pop(context);
          onResume(); // Resume action
        },
      );
    },
  );
}
