import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/services/account_service.dart';

/// Краткая информация о слоте сохранения для экрана выбора.
class CareerSlotSummary {
  final int slot;
  final bool isEmpty;
  final bool isCorrupted;
  final String? playerName;
  final String? club;
  final int? season;
  final int? age;
  final int? overall;
  final bool isFinished;

  const CareerSlotSummary({
    required this.slot,
    this.isEmpty = false,
    this.isCorrupted = false,
    this.playerName,
    this.club,
    this.season,
    this.age,
    this.overall,
    this.isFinished = false,
  });

  bool get hasCareer => !isEmpty && !isCorrupted;
}

/// Локальный кэш + облачное сохранение отдельно для каждого Firebase UID.
/// Все игровые экраны продолжают использовать прежний API CareerStorage.
class CareerStorage {
  static const String _legacyCareerKey = 'saved_career_v1';
  static const String _legacyActiveSlotKey = 'active_career_slot';
  static const int slotCount = 3;

  static String? _uid => AccountService.currentUser?.uid;
  static bool _lastSyncSucceeded = true;
  static String? _lastSyncError;

  static bool get lastSyncSucceeded => _lastSyncSucceeded;
  static String? get lastSyncError => _lastSyncError;
  static bool get isCloudAccount => _uid != null;

  static CollectionReference<Map<String, dynamic>> _cloudSlots(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('careerSlots');

  static String _localKey(int slot) {
    _checkSlot(slot);
    final uid = _uid;
    if (uid == null) {
      return slot == 1 ? _legacyCareerKey : 'saved_career_slot_$slot';
    }
    return 'saved_career_${uid}_slot_$slot';
  }

  static String _activeKey() {
    final uid = _uid;
    return uid == null ? _legacyActiveSlotKey : 'active_career_slot_$uid';
  }

  static String _migrationKey(String uid) => 'career_cloud_migrated_$uid';

  static void _checkSlot(int slot) {
    if (slot < 1 || slot > slotCount) {
      throw RangeError.range(slot, 1, slotCount, 'slot');
    }
  }

  static Future<int> activeSlot() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getInt(_activeKey()) ?? 1;
    return value.clamp(1, slotCount).toInt();
  }

  static Future<void> setActiveSlot(int slot) async {
    _checkSlot(slot);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_activeKey(), slot);
  }

  /// Вызывается при открытии главного экрана и после входа в аккаунт.
  /// Облачные данные имеют приоритет над локальным кэшем.
  static Future<void> prepareAccount() async {
    final uid = _uid;
    if (uid == null) return;

    final preferences = await SharedPreferences.getInstance();
    final migrationKey = _migrationKey(uid);
    if (preferences.getBool(migrationKey) != true) {
      // Старое общее сохранение переносим только в аккаунт разработчика:
      // именно в нём создавалась прежняя карьера. Обычные аккаунты
      // никогда не получают чужое старое сохранение.
      if (await AccountService.isDeveloper()) {
        for (var slot = 1; slot <= slotCount; slot++) {
          final remote = await _cloudSlots(uid).doc('$slot').get();
          if (remote.exists) continue;
          final legacyKey = slot == 1
              ? _legacyCareerKey
              : 'saved_career_slot_$slot';
          final legacyJson = preferences.getString(legacyKey);
          if (legacyJson == null) continue;
          await _writeCloud(uid, slot, legacyJson);
          await preferences.setString('saved_career_${uid}_slot_$slot', legacyJson);
        }
      }
      await preferences.setBool(migrationKey, true);
    }

    // Восстанавливаем локальный кэш с облака. Если сети нет, оставляем
    // доступными ранее закэшированные данные.
    try {
      final snapshot = await _cloudSlots(uid).get();
      for (final document in snapshot.docs) {
        final slot = int.tryParse(document.id);
        final raw = document.data()['careerJson'];
        if (slot == null || slot < 1 || slot > slotCount || raw is! String) {
          continue;
        }
        await preferences.setString(_localKey(slot), raw);
      }
      _lastSyncSucceeded = true;
      _lastSyncError = null;
    } catch (error) {
      _markSyncError(error);
    }
  }

  static Future<void> save(Career career) async {
    final slot = await activeSlot();
    await saveToSlot(slot, career);
  }

  static Future<void> saveToSlot(int slot, Career career) async {
    _checkSlot(slot);
    final raw = jsonEncode(career.toJson());
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_localKey(slot), raw);
    if (!saved) throw Exception('Не удалось сохранить карьеру локально');

    final uid = _uid;
    if (uid == null) {
      _lastSyncSucceeded = true;
      _lastSyncError = null;
      return;
    }

    try {
      await _writeCloud(uid, slot, raw);
      _lastSyncSucceeded = true;
      _lastSyncError = null;
    } catch (error) {
      // Игра не теряет локальное сохранение из-за временного отсутствия сети.
      _markSyncError(error);
    }
  }

  static Future<void> _writeCloud(String uid, int slot, String raw) async {
    await _cloudSlots(uid).doc('$slot').set({
      'slot': slot,
      'careerJson': raw,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Career?> load() async {
    final slot = await activeSlot();
    return loadSlot(slot);
  }

  static Future<Career?> loadSlot(int slot) async {
    _checkSlot(slot);
    final preferences = await SharedPreferences.getInstance();
    final uid = _uid;

    if (uid != null) {
      try {
        final remote = await _cloudSlots(uid).doc('$slot').get();
        final raw = remote.data()?['careerJson'];
        if (raw is String) {
          await preferences.setString(_localKey(slot), raw);
          _lastSyncSucceeded = true;
          _lastSyncError = null;
          return _decodeCareer(raw);
        }
      } catch (error) {
        _markSyncError(error);
      }
    }

    final raw = preferences.getString(_localKey(slot));
    if (raw == null) return null;

    // Если это локальный кэш аккаунта, пробуем отправить его в облако,
    // когда документ ещё не создан (например, после офлайн-игры).
    if (uid != null) {
      try {
        final remote = await _cloudSlots(uid).doc('$slot').get();
        if (!remote.exists) await _writeCloud(uid, slot, raw);
      } catch (error) {
        _markSyncError(error);
      }
    }
    return _decodeCareer(raw);
  }

  static Career _decodeCareer(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Некорректное сохранение карьеры');
    }
    return Career.fromJson(Map<String, dynamic>.from(decoded));
  }

  static Future<bool> hasSavedCareer() async {
    final summaries = await slotSummaries();
    return summaries.any((item) => item.hasCareer);
  }

  static Future<void> delete() async {
    final slot = await activeSlot();
    await deleteSlot(slot);
  }

  static Future<void> deleteSlot(int slot) async {
    _checkSlot(slot);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_localKey(slot));

    final uid = _uid;
    if (uid != null) {
      try {
        await _cloudSlots(uid).doc('$slot').delete();
        _lastSyncSucceeded = true;
        _lastSyncError = null;
      } catch (error) {
        _markSyncError(error);
        rethrow;
      }
    }
  }

  static Future<List<CareerSlotSummary>> slotSummaries() async {
    final preferences = await SharedPreferences.getInstance();
    final raws = <int, String>{};

    for (var slot = 1; slot <= slotCount; slot++) {
      final raw = preferences.getString(_localKey(slot));
      if (raw != null) raws[slot] = raw;
    }

    final uid = _uid;
    if (uid != null) {
      try {
        final snapshot = await _cloudSlots(uid).get();
        for (final document in snapshot.docs) {
          final slot = int.tryParse(document.id);
          final raw = document.data()['careerJson'];
          if (slot == null || slot < 1 || slot > slotCount || raw is! String) {
            continue;
          }
          raws[slot] = raw;
          await preferences.setString(_localKey(slot), raw);
        }
        _lastSyncSucceeded = true;
        _lastSyncError = null;
      } catch (error) {
        _markSyncError(error);
      }
    }

    return [
      for (var slot = 1; slot <= slotCount; slot++)
        summarize(slot, raws[slot]),
    ];
  }

  static CareerSlotSummary summarize(int slot, String? raw) {
    if (raw == null) {
      return CareerSlotSummary(slot: slot, isEmpty: true);
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return CareerSlotSummary(slot: slot, isCorrupted: true);
      }

      final player = decoded['player'];
      if (player is! Map) {
        return CareerSlotSummary(slot: slot, isCorrupted: true);
      }

      return CareerSlotSummary(
        slot: slot,
        playerName: player['name'] as String?,
        club: player['club'] as String?,
        age: (player['age'] as num?)?.toInt(),
        overall: (player['overall'] as num?)?.toInt(),
        season: (decoded['season'] as num?)?.toInt(),
        isFinished: decoded['isCareerFinished'] as bool? ?? false,
      );
    } catch (_) {
      return CareerSlotSummary(slot: slot, isCorrupted: true);
    }
  }

  static void _markSyncError(Object error) {
    _lastSyncSucceeded = false;
    _lastSyncError = error.toString();
  }
}
