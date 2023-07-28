import 'package:flutter/cupertino.dart';

const List<Locale> SUPPORTED_LOCALES = [Locale('vi'), Locale('en')];

const Map<String, String> LANGUAGE_MAP = {
  'vi': 'Tiếng Việt',
  'en': 'English',
};


class Language {
  final String code;
  final String name;

  Language(this.code, this.name);

  factory Language.fromLocale(Locale locale) {
    final code = locale.languageCode;
    final name = LANGUAGE_MAP[code] ?? '';
    return Language(code, name);
  }
}
