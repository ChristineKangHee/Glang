import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../viewmodel/user_service.dart';
import '../../components/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsFAQ extends ConsumerWidget {
  const SettingsFAQ({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider); // 사용자 이름 상태 구독
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String? userId = _auth.currentUser?.uid;

    // userName이 null이고, userId가 있을 때만 fetch
    if (userId != null && userName == null) {
      ref.read(userNameProvider.notifier).fetchUserName();
    }

    final customColors = ref.watch(customColorsProvider);

    // FAQ data with both question and detailed answer
    final List<Map<String, String>> faqItems = [
      {
        'question': '글랑은 무엇인가요?',
        'answer': '글랑은 읽기를 더 효율적으로 만들기 위한 앱입니다. 사용자는 텍스트를 드래그하여 번역, 노트 작성, 하이라이팅 등 다양한 기능을 활용할 수 있으며, 미션 활동을 통해 더 나은 이해도를 얻을 수 있습니다.'
      },
      {
        'question': '글랑의 주요 기능은 무엇인가요?',
        'answer': '글랑은 드래그하여 텍스트와 상호작용하는 읽기 활동, 챗봇을 통한 질의응답, AI 분석을 통한 학습 피드백 등을 제공합니다. 또한, 읽은 콘텐츠에 대해 노트를 작성하고, 하이라이트 및 정의를 추가하여 읽기 활동을 돕습니다.'
      },
      {
        'question': '앱을 어떻게 다운로드하나요?',
        'answer': '글랑은 iOS와 Android에서 사용할 수 있습니다. 각 플랫폼의 앱스토어에서 \'글랑\'을 검색하여 다운로드할 수 있습니다.'
      },
      {
        'question': '사용자 데이터는 어떻게 보호되나요?',
        'answer': '글랑은 Firebase를 기반으로 한 안전한 데이터 저장 방식을 사용합니다. 모든 사용자 데이터는 암호화되어 저장되며, 개인정보 보호를 위해 최고 수준의 보안 프로토콜을 따릅니다.'
      },
      {
        'question': '앱에서 제공하는 학습 자료는 어떻게 업데이트되나요?',
        'answer': '글랑은 지속적으로 학습 자료를 업데이트하고 있으며, 사용자에게 최신 콘텐츠를 제공하기 위해 주기적인 업데이트를 실시합니다.'
      },
      {
        'question': '문제를 겪고 있을 때 어떻게 도움을 받을 수 있나요?',
        'answer': '앱 내 고객 지원 센터 또는 이메일을 통해 문제를 신고하고, 도움을 받을 수 있습니다.'
      },
    ];

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '자주 묻는 질문'.tr(),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft, // 텍스트를 좌측 정렬
            child: Padding(
              padding: const EdgeInsets.all(16.0), // 여백 추가
              child: Text("$userName님,\n무엇을 도와드릴까요?", style: heading_large(context)),
            ),
          ),
          Expanded( // ListView가 크기를 가지도록 Expanded 위젯으로 감쌈
            child: ListView.builder(
              itemCount: faqItems.length, // 목록의 개수만큼 반복
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        faqItems[index]['question']!,
                        style: body_small_semi(context).copyWith(color: customColors.neutral0),
                      ),
                      onTap: () {
                        // Navigate to the detailed page for each FAQ item, passing the answer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FAQDetailPage(
                              faqQuestion: faqItems[index]['question']!,
                              faqAnswer: faqItems[index]['answer']!,
                            ),
                          ),
                        );
                      },
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
                    ),
                    Divider(color: customColors.neutral80),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FAQDetailPage extends StatelessWidget {
  final String faqQuestion;
  final String faqAnswer;

  const FAQDetailPage({super.key, required this.faqQuestion, required this.faqAnswer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '자주 묻는 질문',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              faqQuestion,
              style: heading_large(context),
            ),
            SizedBox(height: 20),
            // Display the detailed answer
            Text(
              faqAnswer,
              style: body_small(context),
            ),
          ],
        ),
      ),
    );
  }
}
