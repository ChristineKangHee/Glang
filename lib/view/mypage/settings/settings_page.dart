import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ L10N
import '../../../constants.dart';
import '../../../restart_widget.dart';
import '../../../viewmodel/app_state_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
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
        title: 'settings.title'.tr(), // "설정"
      ),
      body: ListView(
        children: [
          // ListTile(title: Text('알림 설정', style: body_xsmall(context).copyWith(color: customColors.neutral30),),),
          // ListTile(
          //   title: Text('알림 설정', style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
          //   trailing: Switch(
          //     value: isNotificationEnabled,
          //     onChanged: (bool value) {
          //       // TODO: 알림 설정 값 변경
          //       isNotificationEnabled = value;
          //     },
          //     activeColor: customColors.neutral100,
          //     activeTrackColor: customColors.primary,
          //     inactiveThumbColor: customColors.neutral100,
          //     inactiveTrackColor: customColors.neutral80,
          //   ),
          // ),
          // ListTile(
          //   title: Text('마케팅 수신 동의', style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
          //   trailing: Switch(
          //     value: isMarketingAgreement,
          //     onChanged: (bool value) {
          //       // TODO: 마케팅 동의 값 변경
          //       isMarketingAgreement = value;
          //     },
          //     activeColor: customColors.neutral100,
          //     activeTrackColor: customColors.primary,
          //     inactiveThumbColor: customColors.neutral100,
          //     inactiveTrackColor: customColors.neutral80,
          //   ),
          // ),
          // Divider(color: customColors.neutral80,),
          ListTile(title: Text('settings.help_support'.tr(), style: body_xsmall(context).copyWith(color: customColors.neutral30),),),
          ListTile(
            title: Text('announcements'.tr(),
                style: body_medium_semi(context).copyWith(color: customColors.neutral0)),
            onTap: () => Navigator.pushNamed(context, '/mypage/settings/announcement'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text(
              'settings.faq'.tr(),
              style: body_medium_semi(context).copyWith(color: customColors.neutral0),
            ),
            onTap: () {
              // TODO: 프로필 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/FAQ');
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('settings.language'.tr(), style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
            onTap: () {
              // TODO: 언어 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/language');
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          // ListTile(
          //   title: Text('테마 설정', style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
          //   trailing: IconButton(
          //     icon: Icon(isLightTheme ? Icons.dark_mode : Icons.light_mode),
          //     onPressed: () {
          //       themeController.toggleTheme(); // 테마 변경
          //     },
          //   ),
          // ),
          ListTile(
            title: Text(
              'settings.policy'.tr(),
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
              'settings.feedback'.tr(),
              style: body_medium_semi(context).copyWith(color: customColors.neutral0),
            ),
            onTap: () {
              // TODO: 프로필 설정 페이지로 이동
              Navigator.pushNamed(context, '/mypage/settings/requests');
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text(
              'settings.update'.tr(),
              style: body_medium_semi(context).copyWith(color: customColors.neutral0),
            ),
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
                    title: Text('🚨 admin_report'.tr(), style: body_medium_semi(context).copyWith(color: customColors.neutral0)),
                    onTap: () {
                      Navigator.pushNamed(context, '/mypage/settings/reports');
                    },
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
                  ),
                ],
              );
            },
          ),

          Divider(color: customColors.neutral80),
          ListTile(
            title: Text('settings.logout'.tr(), style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
            onTap: () {
              showResultSaveDialog(
                context,
                customColors,
                'settings.logout_confirm'.tr(),  // "로그아웃하시겠습니까?"
                'settings.cancel'.tr(),          // "취소"
                'settings.logout'.tr(),          // "로그아웃"
                    (ctx) {
                      _logout(context, ref);
                },
              );
            },
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: customColors.neutral30),
          ),
          ListTile(
            title: Text('settings.withdraw'.tr(), style: body_medium_semi(context).copyWith(color: customColors.neutral0),),
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
