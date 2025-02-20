/// File: settings_FAQ.dart
/// Purpose: FAQ 페이지를 구성하는 화면
/// Author: 강희
/// Created: 2024-12-28
/// Last Modified: 2024-12-28 by 강희
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../viewmodel/user_service.dart';
import '../../components/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsFAQ extends ConsumerWidget {
  const SettingsFAQ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider); // 사용자 이름 상태를 구독하여 가져옴
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String? userId = _auth.currentUser?.uid; // 현재 로그인된 사용자의 UID 가져오기

    // userName이 null이고, userId가 존재할 경우 사용자 이름을 가져오는 함수 실행
    if (userId != null && userName == null) {
      ref.read(userNameProvider.notifier).fetchUserName();
    }

    final customColors = ref.watch(customColorsProvider); // 커스텀 색상 상태 구독

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '자주 묻는 질문'.tr(), // 다국어 지원을 위한 번역 적용
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore에서 FAQ 데이터를 실시간으로 가져오는 스트림 설정
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
            return const Center(child: CircularProgressIndicator()); // 데이터 로딩 중 표시
          }
          final faqDocs = snapshot.data!.docs; // 가져온 FAQ 문서 리스트

          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("$userName님,\n무엇을 도와드릴까요?",
                      style: heading_large(context)), // 사용자 환영 메시지
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: faqDocs.length, // FAQ 개수 만큼 리스트 생성
                  itemBuilder: (context, index) {
                    final data = faqDocs[index].data() as Map<String, dynamic>;
                    final question = data['question'] ?? ''; // 질문 데이터
                    final answer = data['answer'] ?? ''; // 답변 데이터
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            question,
                            style: body_small_semi(context)
                                .copyWith(color: customColors.neutral0),
                          ),
                          onTap: () {
                            // 리스트 아이템 클릭 시 상세 페이지로 이동
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
                        Divider(color: customColors.neutral80), // 항목 구분선
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
  final String faqQuestion; // FAQ 질문
  final String faqAnswer; // FAQ 답변

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
              style: heading_large(context), // 질문 텍스트 스타일 적용
            ),
            const SizedBox(height: 20),
            Text(
              faqAnswer,
              style: body_small(context), // 답변 텍스트 스타일 적용
            ),
          ],
        ),
      ),
    );
  }
}