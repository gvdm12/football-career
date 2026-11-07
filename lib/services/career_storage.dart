import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_football/models/career.dart';

/// Краткая информация о слоте сохранения для экрана выбора.
///
/// Собирается из «сырого» JSON, без `Career.fromJson`: загрузка карьеры
/// меняет глобальное состояние клубов, а просмотр списка слотов
/// не должен его трогать.
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

/// Хранилище карьеры с несколькими слотами.
///
/// Публичные методы `save`, `load`, `delete` работают с АКТИВНЫМ слотом,
/// поэтому остальной код игры (магазин, сезон, чемпионат мира) менять
/// не нужно: достаточно выбрать слот перед началом или продолжением карьеры.
///
/// Слот 1 использует прежний ключ `saved_career_v1`, так что уже
/// существующие сохранения остаются в слоте 1 без миграции.
class CareerStorage {
  static const String _legacyCareerKey = 'saved_career_v1';
  static const String _activeSlotKey = 'active_career_slot';

  /// Количество слотов сохранения.
  static const int slotCount = 3;

  static String _keyFor(int slot) {
    _checkSlot(slot);
    return slot == 1 ? _legacyCareerKey : 'saved_career_slot_$slot';
  }

  static void _checkSlot(int slot) {
    if (slot < 1 || slot > slotCount) {
      throw RangeError.range(slot, 1, slotCount, 'slot');
    }
  }

  /// Номер активного слота (по умолчанию 1).
  static Future<int> activeSlot() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getInt(_activeSlotKey) ?? 1;
    return value.clamp(1, slotCount).toInt();
  }

  /// Выбирает слот, с которым дальше работают `save`, `load` и `delete`.
  static Future<void> setActiveSlot(int slot) async {
    _checkSlot(slot);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_activeSlotKey, slot);
  }

  /// Сохраняет карьеру в активный слот.
  static Future<void> save(Career career) async {
    final slot = await activeSlot();
    await saveToSlot(slot, career);
  }

  static Future<void> saveToSlot(int slot, Career career) async {
    final preferences = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(career.toJson());

    final success = await preferences.setString(_keyFor(slot), jsonString);

    if (!success) {
      throw Exception('Не удалось сохранить карьеру');
    }
  }

  /// Загружает карьеру из активного слота.
  /// Возвращает null, если слот пуст.
  static Future<Career?> load() async {
    final slot = await activeSlot();
    return loadSlot(slot);
  }

  static Future<Career?> loadSlot(int slot) async {
    final preferences = await SharedPreferences.getInstance();

    final jsonString = preferences.getString(_keyFor(slot));

    if (jsonString == null) {
      return null;
    }

    final decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      throw const FormatException('Некорректное сохранение карьеры');
    }

    return Career.fromJson(Map<String, dynamic>.from(decoded));
  }

  /// Есть ли сохранение хотя бы в одном слоте.
  static Future<bool> hasSavedCareer() async {
    final preferences = await SharedPreferences.getInstance();

    for (var slot = 1; slot <= slotCount; slot++) {
      if (preferences.containsKey(_keyFor(slot))) return true;
    }
    return false;
  }

  /// Удаляет карьеру из активного слота.
  static Future<void> delete() async {
    final slot = await activeSlot();
    await deleteSlot(slot);
  }

  static Future<void> deleteSlot(int slot) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_keyFor(slot));
  }

  /// Описание всех слотов для экрана выбора.
  static Future<List<CareerSlotSummary>> slotSummaries() async {
    final preferences = await SharedPreferences.getInstance();

    return [
      for (var slot = 1; slot <= slotCount; slot++)
        summarize(slot, preferences.getString(_keyFor(slot))),
    ];
  }

  /// Разбирает JSON сохранения в краткое описание слота.
  /// Вынесено отдельно, чтобы его можно было проверить тестом.
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
}
