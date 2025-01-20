import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import 'alert_section_button.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({super.key});

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
                  "학습 결과",
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
                        "단어 선택이 매우 정확해요! 핵심 단어 2가지를 모두 포함시켰어요. 하지만 단어의 순서가 달라요. 그래도 잘 하셨어요!",
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
                        "다른 유저의 글",
                        style: body_small_semi(context)
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "다람쥐는 작은 토끼를 보고 미소 지으며 말했어요. ‘내가 집까지 데려다줄게!’ 작은 토끼는 다람쥐의 도움으로 무사히 집으로 돌아왔어요.",
                        style: body_small(context)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 버튼 섹션
                AlertSectionButton(customColors: customColors),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
