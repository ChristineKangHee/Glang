// lib/localization/tr.dart
// CHANGED: 런타임 로케일 선택 유틸 함수 제공.
// - tr: LocalizedText → String
// - trList: LocalizedList → List<String>
// - 존재하지 않거나 빈 값이면 ko/en 간 안전 폴백.

import 'package:flutter/widgets.dart';
import '../model/localized_types.dart';

String tr(LocalizedText v, Locale locale, {String fallbackLang = 'en'}) {
  final lang = locale.languageCode;
  final primary = (lang == 'ko') ? v.ko : v.en;
  if (primary.trim().isNotEmpty) return primary;

  final fb = (fallbackLang == 'ko') ? v.ko : v.en;
  if (fb.trim().isNotEmpty) return fb;

  // 양쪽이 모두 비었을 때 반대 언어라도 반환
  return (lang == 'ko') ? v.en : v.ko;
}

List<String> trList(LocalizedList v, Locale locale, {String fallbackLang = 'en'}) {
  final lang = locale.languageCode;
  final primary = (lang == 'ko') ? v.ko : v.en;
  if (primary.isNotEmpty) return primary;

  final fb = (fallbackLang == 'ko') ? v.ko : v.en;
  if (fb.isNotEmpty) return fb;

  return (lang == 'ko') ? v.en : v.ko;
}

// (선택) BuildContext 확장: locale 접근 단축
extension GlangLocaleX on BuildContext {
  Locale get glangLocale => Localizations.localeOf(this);
}
