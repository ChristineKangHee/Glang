import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'alert_section_button_br.dart';

class AlertDialogBR extends StatelessWidget {
  const AlertDialogBR({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // 최대 높이 제한
        ),
        child: SingleChildScrollView( // 스크롤 가능하도록 설정
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 타이틀
                Text(
                  "결과",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // 레이더 차트 (플레이스홀더)
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey.shade200, // 실제 레이더 차트 라이브러리 사용 가능
                  child: Center(
                    child: Text(
                        "Radar Chart",
                        style: body_small(context)
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // AI 피드백
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "AI 피드백",
                          style: body_small_semi(context)
                      ),
                      const SizedBox(height: 8),
                      Text(
                          "단어 선택이 매우 정확해요! 핵심 단어 2가지를 모두 포함시켰어요.",
                          style: body_small(context)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 다른 유저의 글
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "다른 유저의 답",
                          style: body_small_semi(context)
                      ),
                      const SizedBox(height: 8),
                      Text(
                          "읽기의 기술: 맞춤형 도구와 피드백으로 성장하기",
                          style: body_small(context)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 버튼 섹션
                AlertSectionButtonBr(customColors: customColors),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
