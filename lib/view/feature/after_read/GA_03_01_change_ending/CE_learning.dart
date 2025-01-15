import 'package:flutter/material.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/my_divider.dart';

import '../../../../theme/theme.dart';

class CELearning extends StatelessWidget {
  const CELearning({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar_2depth_8(title: "결말바꾸기"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타이머와 제목 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "글을 읽고 나만의 결말을 작성해보세요!",
                        style: body_small_semi(context).copyWith(
                          color: customColors.primary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "<토끼 가족 이야기>",
                            style: body_small(context)
                                .copyWith(color: customColors.neutral60),
                          ),
                          Text(
                            " | 김댕댕",
                            style: body_small(context)
                                .copyWith(color: customColors.neutral60),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon_Section(customColors: customColors),
                ],
              ),
              const SizedBox(height: 16),
              // 본문 텍스트
              Text(
                "결국 주인공은 친구들과 힘을 합쳐 어려움을 극복했습니다. "
                    "용기와 지혜를 발휘한 덕분에 모두가 함께 웃으며 행복한 결말을 맞이했습니다. "
                    "그날 이후로 마을에는 평화와 기쁨이 가득했고, 주인공은 소중한 가르침을 "
                    "마음에 새기며 새로운 모험을 준비했습니다.",
                style: reading_exercise(context),
              ),
              const SizedBox(height: 16),
              BigDivider(),
              BigDivider(),
              const SizedBox(height: 16),
              // 사용자 입력 영역
              Text("나의 답변", style: body_small(context)),
              const SizedBox(height: 16),
              TextField(
                maxLines: 5,
                maxLength: 50,
                style: body_medium(context),
                decoration: InputDecoration(
                  hintText: "글을 작성해주세요.",
                  hintStyle:
                  body_medium(context).copyWith(color: customColors.neutral60),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  counterText: "0/50",
                ),
              ),

              const SizedBox(height: 16),
              // 제출 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 제출 버튼 액션
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade100,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text("제출하기", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Icon_Section extends StatelessWidget {
  const Icon_Section({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const ShapeDecoration(
        color: Color(0xFF514FFF),
        shape: OvalBorder(),
      ),
      child: Icon(
        Icons.import_contacts,
        color: customColors.neutral100,
        size: 24,
      ),
    );
  }
}