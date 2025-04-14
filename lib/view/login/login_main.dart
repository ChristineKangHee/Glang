/// File: login_page.dart
/// Purpose: 사용자 로그인 화면, Google, Apple, Kakao 로그인 버튼 제공
/// Author: 박민준
/// Created: 2025-01-01
/// Last Modified: 2025-02-03 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/theme/font.dart';
import 'package:readventure/theme/theme.dart';
import '../../viewmodel/custom_colors_provider.dart';
import '../home/attendance/attendance_provider.dart';
import '../widgets/DoubleBackToExitWrapper.dart';
import 'auth_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider.notifier);
    final customColors = ref.watch(customColorsProvider); // CustomColors 가져오기

    return DoubleBackToExitWrapper(
      child: Scaffold(
        body: Stack(
          children: [
            // 1. 가장 아래: 그라데이션 배경
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    customColors.neutral100 ?? Colors.blue,  // 시작 색상
                    customColors.primary10 ?? Colors.green,    // 끝 색상
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // 2. 그 위에: login_background.svg (화면 너비 전체)
            Positioned(
              top: 0,  // 원하는 위치로 조정 가능 (예: 화면 상단)
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                "assets/images/login_background.svg",
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth, // 화면 너비에 맞게 조정
              ),
            ),
            // 3. 그 위에: 로그인 UI (로고, 로그인 버튼 등)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      authController.signInWithGoogle(
                        context: context,
                        onNicknameRequired: () {
                          Navigator.pushReplacementNamed(context, '/nickname');
                        },
                        onHome: () {
                          Navigator.pushReplacementNamed(context, '/');
                          ref.refresh(attendanceProvider);
                        },
                      );
                    },
                    child: GoogleLoginButton(customColors: customColors),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      authController.signInWithApple(
                        context: context,
                        onNicknameRequired: () {
                          Navigator.pushReplacementNamed(context, '/nickname');
                        },
                        onHome: () {
                          Navigator.pushReplacementNamed(context, '/');
                          ref.refresh(attendanceProvider);
                        },
                      );
                    },
                    child: AppleLoginButton(customColors: customColors),
                  ),
                  // SizedBox(height: 16),
                  // _AppleLoginButton1(),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      authController.signInWithKakao(
                        context: context,
                        onNicknameRequired: () {
                          Navigator.pushReplacementNamed(context, '/nickname');
                        },
                        onHome: () {
                          Navigator.pushReplacementNamed(context, '/');
                          ref.refresh(attendanceProvider);
                        },
                      );
                    },
                    child: KakaoLoginButton(customColors: customColors),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 64,
        padding: EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: customColors.neutral100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              child: Image.asset("assets/icons/google.png"),
            ),
            SizedBox(width: 16),
            Text("Google로 계속하기", style: body_medium_semi(context).copyWith(color: customColors.neutral30),)
          ],
        ),
      ),
    );
  }
}
class _AppleLoginButton_package_version extends StatelessWidget {
  const _AppleLoginButton_package_version();

  @override
  Widget build(BuildContext context) {
    return SignInWithAppleButton(
      onPressed: () async {
        final result = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        /// 사용자 이메일
        /// 사용자 설정에 따라서 비공개 이메일이 올 수 있음.
        /// 첫 로그인시에만 오고 그 후로는 null 반환.
        print(result.email ?? '');

        /// 사용자 이름 (성)
        /// 첫 로그인시에만 오고 그 후로는 null 반환.
        print(result.familyName ?? '');

        /// 사용자 이름 (이름)
        /// 첫 로그인시에만 오고 그 후로는 null 반환.
        print(result.givenName ?? '');

        /// Apple에서 발급하는 해당앱의 유저 고유 식별자.
        print(result.userIdentifier ?? '');

        /// Apple에서 발급하는 JWT 형식의 신원 확인 토큰.
        print(result.identityToken);

        /// 짧은 기간 유효한 인증 코드로, 서버에서 Apple과 통신해 사용자 인증을 확인할 때 사용됩니다.
        print(result.authorizationCode);
      },
    );
  }
}

class AppleLoginButton extends StatelessWidget {
  const AppleLoginButton({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 64,
        padding: EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: customColors.neutral0,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              child: Image.asset("assets/icons/apple_icon_white.png"),
            ),
            SizedBox(width: 16),
            Text("Apple로 계속하기", style: body_medium_semi(context).copyWith(color: customColors.neutral100),)
          ],
        ),
      ),
    );
  }
}

class KakaoLoginButton extends StatelessWidget {
  const KakaoLoginButton({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          color: Color(0xFFFAE100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              child: Image.asset("assets/icons/kakao_icon.png"),
            ),
            SizedBox(width: 16,),
            Text("카카오로 계속하기", style: body_medium_semi(context).copyWith(color: customColors.neutral30),)
          ],
        ),
      ),
    );
  }
}
