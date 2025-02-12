import 'package:cloud_firestore/cloud_firestore.dart';
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
  const SettingsFAQ({Key? key}) : super(key: key);

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

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '자주 묻는 질문'.tr(),
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
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final faqDocs = snapshot.data!.docs;

          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("$userName님,\n무엇을 도와드릴까요?",
                      style: heading_large(context)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: faqDocs.length,
                  itemBuilder: (context, index) {
                    final data = faqDocs[index].data() as Map<String, dynamic>;
                    final question = data['question'] ?? '';
                    final answer = data['answer'] ?? '';
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
            const SizedBox(height: 20),
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
