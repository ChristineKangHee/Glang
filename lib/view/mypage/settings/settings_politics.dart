import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/font.dart';
import '../../../viewmodel/custom_colors_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPolitics extends ConsumerWidget {
  const SettingsPolitics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '약관 및 정책'.tr(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc('terms')
            .collection('terms')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('약관 정보가 없습니다.'));
          }

          final terms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: terms.length,
            itemBuilder: (context, index) {
              final term = terms[index];
              final title = term['title'];

              return Column(
                children: [
                  ListTile(
                    title: Text(
                      title,
                      style: body_medium_semi(context).copyWith(color: customColors.neutral0),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PolicyDetailScreen(
                            title: title,
                            content: term['content'],
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
          );
        },
      ),
    );
  }
}

class PolicyDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const PolicyDetailScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: title.tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            content.replaceAll(r'\n', '\n'),
            style: body_small(context),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}