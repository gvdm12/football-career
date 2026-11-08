import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_football/models/super_league_career.dart';
import 'package:flutter_football/services/account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Separate Super League save, isolated by Firebase UID.
class SuperLeagueStorage {
  static const String _legacySaveKey = 'super_league_career_v2';
  static const String _oldLegacySaveKey = 'super_league_career_v1';

  static String? get _uid => AccountService.currentUser?.uid;
  static String get _saveKey =>
      _uid == null ? _legacySaveKey : 'super_league_career_v2_${_uid}';

  static DocumentReference<Map<String, dynamic>>? get _cloudSave {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('gameData')
        .doc('superLeague');
  }

  static Future<void> saveCareer(SuperLeagueCareer career) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = jsonEncode(career.toJson());
    final saved = await preferences.setString(_saveKey, raw);
    if (!saved) throw Exception('Не удалось сохранить карьеру Суперлиги');

    final cloud = _cloudSave;
    if (cloud != null) {
      try {
        await cloud.set({
          'careerJson': raw,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // Локальная копия сохраняется, даже если сеть временно недоступна.
      }
    }
  }

  static Future<SuperLeagueCareer?> loadCareer() async {
    final preferences = await SharedPreferences.getInstance();
    final cloud = _cloudSave;
    if (cloud != null) {
      try {
        final snapshot = await cloud.get();
        final cloudRaw = snapshot.data()?['careerJson'];
        if (cloudRaw is String) {
          await preferences.setString(_saveKey, cloudRaw);
          return _decodeCareer(cloudRaw);
        }
      } catch (_) {
        // Используем локальный кэш, если облако недоступно.
      }
    }

    var raw = preferences.getString(_saveKey);
    if (raw == null && _uid == null) {
      raw = preferences.getString(_oldLegacySaveKey);
      if (raw != null) await preferences.setString(_saveKey, raw);
    }
    if (raw == null && _uid != null && await AccountService.isDeveloper()) {
      // Перенос старого общего сохранения только в аккаунт разработчика.
      raw = preferences.getString(_legacySaveKey) ??
          preferences.getString(_oldLegacySaveKey);
      if (raw != null) {
        await preferences.setString(_saveKey, raw);
        if (cloud != null) {
          try {
            await cloud.set({
              'careerJson': raw,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } catch (_) {}
        }
      }
    }

    if (raw == null) return null;
    if (cloud != null) {
      try {
        final snapshot = await cloud.get();
        if (!snapshot.exists) {
          await cloud.set({
            'careerJson': raw,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {}
    }
    return _decodeCareer(raw);
  }

  static SuperLeagueCareer _decodeCareer(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Некорректное сохранение Суперлиги');
    }
    return SuperLeagueCareer.fromJson(Map<String, dynamic>.from(decoded));
  }

  static Future<bool> hasSavedCareer() async {
    final cloud = _cloudSave;
    if (cloud != null) {
      try {
        final snapshot = await cloud.get();
        if (snapshot.exists && snapshot.data()?['careerJson'] is String) {
          return true;
        }
      } catch (_) {}
    }
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey(_saveKey) ||
        (_uid == null &&
            (preferences.containsKey(_legacySaveKey) ||
                preferences.containsKey(_oldLegacySaveKey)));
  }

  static Future<void> delete() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_saveKey);
    if (_uid == null) {
      await preferences.remove(_oldLegacySaveKey);
    }
    final cloud = _cloudSave;
    if (cloud != null) {
      await cloud.delete();
    }
  }
}
