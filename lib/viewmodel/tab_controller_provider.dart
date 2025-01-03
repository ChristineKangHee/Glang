/// File: tab_controller_provider.dart
/// Purpose: TabController의 초기화, 상태 관리 및 해제를 처리하는 상태 관리 클래스
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-01-03 by 박민준

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tabControllerProvider = StateNotifierProvider<TabControllerNotifier, TabController?>((ref) {
  return TabControllerNotifier();
});

class TabControllerNotifier extends StateNotifier<TabController?> {
  TabControllerNotifier() : super(null);

  bool _isInitialized = false;

  void initialize(TickerProvider tickerProvider, int length) {
    if (!_isInitialized) {
      state = TabController(length: length, vsync: tickerProvider);
      _isInitialized = true;
    }
  }

  void dispose() {
    state?.dispose();
    state = null;
    _isInitialized = false;
  }
}
