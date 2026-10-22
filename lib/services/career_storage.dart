import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_football/models/career.dart';

class CareerStorage {
  static const String _careerKey = 'saved_career_v1';

  /// Сохраняет карьеру на устройстве.
  static Future<void> save(Career career) async {
    final preferences = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(career.toJson());

    final success = await preferences.setString(_careerKey, jsonString);

    if (!success) {
      throw Exception('Не удалось сохранить карьеру');
    }
  }

  /// Загружает сохранённую карьеру.
  /// Возвращает null, если сохранения нет.
  static Future<Career?> load() async {
    final preferences = await SharedPreferences.getInstance();

    final jsonString = preferences.getString(_careerKey);

    if (jsonString == null) {
      return null;
    }

    final decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      throw const FormatException('Некорректное сохранение карьеры');
    }

    return Career.fromJson(Map<String, dynamic>.from(decoded));
  }

  /// Проверяет, существует ли сохранение.
  static Future<bool> hasSavedCareer() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.containsKey(_careerKey);
  }

  /// Удаляет сохранённую карьеру.
  static Future<void> delete() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_careerKey);
  }
}
