/// File: main.dart
/// Purpose: 안정적인 부트스트랩(플러그인 채널 준비 → Firebase 초기화 → UI 실행)
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'app.dart';
import 'restart_widget.dart';

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 세로 고정
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 전역 에러 로깅(릴리즈에서도 콘솔 출력)
  FlutterError.onError = (details) => FlutterError.dumpErrorToConsole(details);
  PlatformDispatcher.instance.onError = (error, stack) {
    // ignore: avoid_print
    print('UNCAUGHT (PlatformDispatcher): $error\n$stack');
    return true;
  };

  // env
  try {
    await dotenv.load(fileName: ".env");
    // ignore: avoid_print
    print("✅ .env file loaded successfully!");
  } catch (e) {
    // ignore: avoid_print
    print("⚠️ Failed to load .env file: $e");
  }

  // EasyLocalization는 위젯을 쓰기 전에 초기화 필요
  await EasyLocalization.ensureInitialized();

  // Kakao SDK 준비(채널 사용 안 하므로 여기서 OK)
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_KEY'] ?? '',
    javaScriptAppKey: dotenv.env['KAKAO_JS_KEY'] ?? '',
  );
}

// Firebase를 runApp 이후에 안전하게 초기화(플러그인 attach 지연 흡수용 재시도)
Future<void> _initFirebaseWithRetry({int retries = 3}) async {
  int attempt = 0;
  while (true) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // ignore: avoid_print
      print("🔥 Firebase initialized successfully!");
      return;
    } on PlatformException catch (e, s) {
      // 채널 에러일 때만 재시도
      if (e.code == 'channel-error' && attempt < retries) {
        attempt++;
        final delay = Duration(milliseconds: 300 * attempt);
        // ignore: avoid_print
        print("⏳ Firebase channel not ready (attempt $attempt), retrying in ${delay.inMilliseconds}ms...\n$e\n$s");
        await Future.delayed(delay);
        continue;
      } else {
        // ignore: avoid_print
        print("❌ Firebase initialization failed (PlatformException): $e\n$s");
        rethrow;
      }
    } catch (e, s) {
      // ignore: avoid_print
      print("❌ Firebase initialization failed: $e\n$s");
      rethrow;
    }
  }
}

void main() async {
  await _bootstrap();

  // runApp을 먼저 띄우고, 내부에서 Firebase init을 기다리는 구조로 변경
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ko'), Locale('en')],
      path: 'lib/localization/l10n',
      fallbackLocale: const Locale('ko'),
      child: const RestartWidget(
        child: ProviderScope(
          child: _BootstrapGate(),
        ),
      ),
    ),
  );
}

/// 첫 화면: Firebase/SharedPrefs 등 필수 초기화를 마친 뒤 실제 앱으로 진입
class _BootstrapGate extends StatefulWidget {
  const _BootstrapGate({super.key});
  @override
  State<_BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<_BootstrapGate> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _preload();
  }

  Future<void> _preload() async {
    // Firebase 먼저(가장 중요)
    await _initFirebaseWithRetry(retries: 3);

    // 그 다음에 SharedPreferences 등 나머지
    try {
      await SharedPreferences.getInstance();
      // ignore: avoid_print
      print("✅ SharedPreferences initialized successfully!");
    } catch (e, st) {
      // ignore: avoid_print
      print("❌ SharedPreferences failed: $e\n$st");
    }

    // (알림/딥링크 등 다른 초기화가 있으면 여기에 추가)
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          // 모든 준비 완료 → 실제 앱 진입
          return const MyApp();
        }
        if (snap.hasError) {
          // 초기화 실패 시 간단한 에러 화면(로그는 콘솔에 충분히 찍힘)
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  '초기화 실패: ${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        // 로딩 스플래시
        return const MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
