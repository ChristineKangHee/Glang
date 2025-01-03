/// File: settings_profile.dart
/// Purpose: 프로필 설정을 할 수 있게 한다.
/// Author: 박민준
/// Created: 2025-01-03
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodel/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsProfile extends ConsumerWidget {
  const SettingsProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar:
      AppBar(
        title: const Text('app_title').tr(),
      ),
      body: Column(
        children: [
          Text("프로필 설정"),
        ],
      ),
    );
  }
}

