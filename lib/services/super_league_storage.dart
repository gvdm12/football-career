import 'dart:convert';

import 'package:flutter_football/models/player.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Отдельное хранилище Суперлиги — не затрагивает обычную карьеру.
class SuperLeagueStorage {
  static const String _saveKey = 'super_league_career_v1';

  static Future<void> savePlayer(Player player) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _saveKey,
      jsonEncode({'player': player.toJson()}),
    );
    if (!saved) {
      throw Exception('Не удалось сохранить карьеру Суперлиги');
    }
  }

  static Future<Player?> loadPlayer() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_saveKey);
    if (raw == null) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['player'] is! Map) {
      throw const FormatException('Некорректное сохранение Суперлиги');
    }

    return Player.fromJson(
      Map<String, dynamic>.from(decoded['player'] as Map),
    );
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
