import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';

  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('ru'));

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'ru';

    locale.value = Locale(languageCode == 'en' ? 'en' : 'ru');
  }

  static Future<void> setLanguage(String languageCode) async {
    final code = languageCode == 'en' ? 'en' : 'ru';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);

    locale.value = Locale(code);
  }

  static bool get isEnglish => locale.value.languageCode == 'en';
}
