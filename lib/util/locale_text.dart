import 'package:flutter/widgets.dart';
import 'package:readventure/model/localized_types.dart';

String _lang(BuildContext context) => Localizations.localeOf(context).languageCode;

/// LocalizedText → String (ko 우선, 비어있으면 en 폴백)
String lx(BuildContext context, LocalizedText t) {
  final code = _lang(context);
  if (code == 'ko') return t.ko.isNotEmpty ? t.ko : t.en;
  return t.en.isNotEmpty ? t.en : t.ko;
}

/// LocalizedList<String> → List<String> (ko/en 선택)
List<String> llx(BuildContext context, LocalizedList l) {
  final code = _lang(context);
  final list = code == 'ko' ? l.ko : l.en;
  if (list.isNotEmpty) return list.map((e) => e.toString()).toList();
  // 폴백
  final fb = code == 'ko' ? l.en : l.ko;
  return fb.map((e) => e.toString()).toList();
}
