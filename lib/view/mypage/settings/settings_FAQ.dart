import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../components/custom_app_bar.dart';
import '../../home/user_service.dart';
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
      ref.read(userNameProvider.notifier).fetchUserName(userId);
    }

    final customColors = ref.watch(customColorsProvider);

    // FAQ data with both question and detailed answer
    final List<Map<String, String>> faqItems = [
      {
        'question': '이 내용은 자주 묻는 세부 질문의 예시입니다.',
        'answer': '이것은 FAQ의 세부 내용입니다. 사용자가 이 질문을 클릭하면 상세 내용이 표시됩니다.'
      },
      {
        'question': '계정 설정을 어떻게 변경하나요?',
        'answer': '계정 설정을 변경하려면 설정 메뉴로 이동하여 계정 섹션에서 변경을 할 수 있습니다.'
      },
      {
        'question': '비밀번호를 잊어버렸습니다. 어떻게 해야 하나요?',
        'answer': '비밀번호를 잊어버린 경우, 로그인 화면에서 "비밀번호 찾기" 옵션을 선택하여 새 비밀번호를 설정할 수 있습니다.'
      },
      {
        'question': '앱의 주요 기능은 무엇인가요?',
        'answer': '앱은 다양한 기능을 제공하며, 주요 기능에는 사용자 맞춤형 피드, 알림 서비스, 설정 관리 등이 있습니다.'
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
