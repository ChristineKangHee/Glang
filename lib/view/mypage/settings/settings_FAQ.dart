/// File: settings_FAQ.dart
/// Purpose: FAQ 페이지를 구성하는 화면 (L10N 보강: 타이틀/인사/에러/빈상태)
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2025-08-26 by ChatGPT (L10N)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';

import '../../../viewmodel/user_service.dart';
import '../../components/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsFAQ extends ConsumerWidget {
  const SettingsFAQ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final FirebaseAuth auth = FirebaseAuth.instance;
    final String? userId = auth.currentUser?.uid;

    // userName이 없으면 로드 시도
    if (userId != null && userName == null) {
      ref.read(userNameProvider.notifier).fetchUserName();
    }

    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'faq'.tr(), // ✅ "자주 묻는 질문"
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc('faqs')
            .collection('faqs')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('error_with_message'.tr(args: [snapshot.error.toString()])));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final faqDocs = snapshot.data!.docs;
          if (faqDocs.isEmpty) {
            return Center(child: Text('no_faqs'.tr())); // ✅ 빈 상태
          }

          final nameToShow = userName ?? '';
          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'faq_greeting'.tr(args: [nameToShow]), // ✅ "{name}님,\n무엇을 도와드릴까요?"
                    style: heading_large(context),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: faqDocs.length,
                  itemBuilder: (context, index) {
                    final data = faqDocs[index].data() as Map<String, dynamic>;
                    final question = (data['question'] ?? '') as String;
                    final answer = (data['answer'] ?? '') as String;

                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            question,
                            style: body_small_semi(context)
                                .copyWith(color: customColors.neutral0),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FAQDetailPage(
                                  faqQuestion: question,
                                  faqAnswer: answer,
                                ),
                              ),
                            );
                          },
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 16, color: customColors.neutral30),
                        ),
                        Divider(color: customColors.neutral80),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// FAQ 상세 페이지 위젯
class FAQDetailPage extends StatelessWidget {
  final String faqQuestion;
  final String faqAnswer;

  const FAQDetailPage({
    Key? key,
    required this.faqQuestion,
    required this.faqAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'faq'.tr(), // ✅ 타이틀 키 통일
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(faqQuestion, style: heading_large(context)),
            const SizedBox(height: 20),
            Text(faqAnswer, style: body_small(context)),
          ],
        ),
      ),
    );
  }
}
