import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ L10N
import '../../../constants.dart';
import '../../../restart_widget.dart';
import '../../../viewmodel/app_state_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../viewmodel/custom_colors_provider.dart';
import '../../../viewmodel/theme_controller.dart';
import '../../components/alarm_dialog.dart';
import '../../components/custom_app_bar.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await FirebaseAuth.instance.signOut();
      ref.read(appStateProvider.notifier).clearUser();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      RestartWidget.restartApp(context);
    } catch (e) {
      // 로그 + 토스트 모두 L10N
      debugPrint('logout_error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('logout_failed_retry'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final customColors = ref.watch(customColorsProvider);
    final themeController = ref.read(themeProvider.notifier);
    final isLightTheme = ref.watch(themeProvider);

    bool isNotificationEnabled = false;
    bool isMarketingAgreement = false;

    return Scaffold(
      appBar: CustomAppBar_2depth_4(
        title: 'settings_title'.tr(), // ✅ 설정
      ),
      body: ListView(
        children: [
          // 섹션 라벨
          ListTile(
            title: Text(
              'help_and_support'.tr(),
              style: body_xsmall(context).copyWith(color: customColors.neutral30),
            ),
          ),
          ListTile(
            title: Text('announcements'.tr(),
                style: body_medium_semi(context).copyWith(color: customColors.neutral0)),
            onTap: () => Navigator.pushNamed(context, '/mypage/settings/announcement'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('faq'.tr(),
                style: body_medium_semi(context).copyWith(color: customColors.neutral0)),
            onTap: () => Navigator.pushNamed(context, '/mypage/settings/FAQ'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('language_settings'.tr(),
                style: body_medium_semi(context).copyWith(color: customColors.neutral0)),
            onTap: () => Navigator.pushNamed(context, '/mypage/settings/language'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('terms_policies'.tr(),
                style: body_medium_semi(context).copyWith(color: customColors.neutral0)),
            onTap: () => Navigator.pushNamed(context, '/mypage/settings/politics'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('feedback_requests'.tr(),
                style: body_medium_semi(context).copyWith(color: customColors.neutral0)),
            onTap: () => Navigator.pushNamed(context, '/mypage/settings/requests'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('update_latest_version'.tr(),
                style: body_medium_semi(context).copyWith(color: customColors.neutral0)),
            trailing: FutureBuilder<String>(
              future: _fetchLatestVersion(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (snapshot.hasError) {
                  return Text('error_short'.tr(),
                      style: body_small_semi(context).copyWith(color: customColors.neutral0));
                }
                return Text(
                  'v${snapshot.data}',
                  style: body_small_semi(context).copyWith(color: customColors.neutral0),
                );
              },
            ),
          ),
          FutureBuilder<bool>(
            future: isAdminUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox.shrink();
              }
              if (!(snapshot.data ?? false)) return const SizedBox.shrink();
              return Column(
                children: [
                  Divider(color: customColors.neutral80),
                  ListTile(
                    title: Text('admin_reports'.tr(),
                        style: body_medium_semi(context).copyWith(color: customColors.neutral0)),
                    onTap: () => Navigator.pushNamed(context, '/mypage/settings/reports'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
                  ),
                ],
              );
            },
          ),

          Divider(color: customColors.neutral80),
          ListTile(
            title: Text('logout'.tr(),
                style: body_medium_semi(context).copyWith(color: customColors.neutral0)),
            onTap: () {
              showResultSaveDialog(
                context,
                customColors,
                'logout_confirm_prompt'.tr(), // ✅ "로그아웃하시겠습니까?"
                'cancel'.tr(),
                'logout'.tr(),
                    (ctx) => _logout(context, ref),
              );
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('delete_account'.tr(),
                style: body_medium_semi(context).copyWith(color: customColors.neutral0)),
            onTap: () => Navigator.pushNamed(context, '/mypage/settings/secession'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
        ],
      ),
    );
  }
}

Future<String> _fetchLatestVersion() async {
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    return remoteConfig.getString('latest_version');
  } catch (e) {
    debugPrint('Firebase Remote Config error: $e');
    return '0.0.0';
  }
}
