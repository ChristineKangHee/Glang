// lib/model/i18n.dart
typedef LocalizedString = Map<String, String>;
typedef LocalizedStringList = Map<String, List<String>>;

/// locale 코드로 문자열을 뽑아오되, 없으면 ko→en 순으로 폴백
String trStr(LocalizedString m, {String locale = 'ko'}) {
  return m[locale] ?? m['ko'] ?? m['en'] ?? '';
}

List<String> trList(LocalizedStringList m, {String locale = 'ko'}) {
  return m[locale] ?? m['ko'] ?? m['en'] ?? const [];
}
