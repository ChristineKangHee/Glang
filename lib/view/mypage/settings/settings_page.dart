import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import '../../../viewmodel/app_state_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../viewmodel/custom_colors_provider.dart';
import '../../components/custom_app_bar.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase 인증 상태 초기화
      ref.read(appStateProvider.notifier).clearUser(); // 전역 상태 초기화
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // 로그인 화면으로 이동
    } catch (e) {
      print('로그아웃 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 중 문제가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider); // 사용자 상태
    final customColors = ref.watch(customColorsProvider);

    bool isNotificationEnabled = false; // 알림 설정 여부
    bool isMarketingAgreement = false; // 마케팅 동의 여부

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: '설정',
      ),
      body: ListView(
        children: [
          ListTile(title: Text('알림 설정', style: body_xsmall(context).copyWith(color: customColors.neutral30),),),
          ListTile(
            title: Text('알림 설정', style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
            trailing: Switch(
              value: isNotificationEnabled,
              onChanged: (bool value) {
                // TODO: 알림 설정 값 변경
                isNotificationEnabled = value;
              },
              activeColor: customColors.primary,
            ),
          ),
          ListTile(
            title: Text('마케팅 수신 동의', style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
            trailing: Switch(
              value: isMarketingAgreement,
              onChanged: (bool value) {
                // TODO: 마케팅 동의 값 변경
                isMarketingAgreement = value;
              },
              activeColor: customColors.primary,
            ),
          ),
          Divider(color: customColors.neutral80,),
          ListTile(title: Text('도움 및 지원', style: body_xsmall(context).copyWith(color: customColors.neutral30),),),
          ListTile(
            title: Text(
              '공지사항',
              style: body_medium_semi(context).copyWith(color: customColors.neutral0),
            ),
            onTap: () {
              // TODO: 프로필 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/announcement');
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text(
              '자주 묻는 질문 (FAQ)',
              style: body_medium_semi(context).copyWith(color: customColors.neutral0),
            ),
            onTap: () {
              // TODO: 프로필 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/FAQ');
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('언어 설정', style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
            onTap: () {
              // TODO: 언어 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/language');
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('테마 설정', style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
            onTap: () {
              // TODO: 테마 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/theme');
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text(
              '약관 및 정책',
              style: body_medium_semi(context).copyWith(color: customColors.neutral0),
            ),
            onTap: () {
              // TODO: 프로필 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/politics');
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text(
              '문의 및 개선 사항 요청',
              style: body_medium_semi(context).copyWith(color: customColors.neutral0),
            ),
            onTap: () {
              // TODO: 프로필 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/requests');
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('최신 버전 업데이트',
              style: body_medium_semi(context).copyWith(color: customColors.neutral0),
            ),
            onTap: () {
              // TODO: 프로필 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/profile');
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          Divider(color: customColors.neutral80,),
          ListTile(
            title: Text('로그아웃', style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
            onTap: () {
              // TODO: 로그아웃 기능 구현
              _logout(context, ref);
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('탈퇴하기', style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
            onTap: () {
              // TODO: 프로필 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/secession');
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
        ],
      ),
    );
  }
}
