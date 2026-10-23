import 'dart:convert';

import 'package:flutter_football/models/super_league_career.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Separate save slot for Super League; never touches the regular career.
class SuperLeagueStorage {
  static const String _saveKey = 'super_league_career_v2';

  static Future<void> saveCareer(SuperLeagueCareer career) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_saveKey, jsonEncode(career.toJson()));
    if (!saved) throw Exception('Не удалось сохранить карьеру Суперлиги');
  }

  static Future<SuperLeagueCareer?> loadCareer() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_saveKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Некорректное сохранение Суперлиги');
    }
    return SuperLeagueCareer.fromJson(Map<String, dynamic>.from(decoded));
  }

  static Future<bool> hasSavedCareer() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey(_saveKey);
  }

  static Future<void> delete() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_saveKey);
  }
}
