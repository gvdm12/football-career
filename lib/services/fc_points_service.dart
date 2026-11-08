import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/services/account_service.dart';

/// Постоянная игровая валюта профиля. Не связана с деньгами внутри карьеры
/// и не сбрасывается при удалении или создании сохранения.
class FCPointsShopItem {
  final String id;
  final String titleRu;
  final String titleEn;
  final String descriptionRu;
  final String descriptionEn;
  final int price;
  final IconData icon;

  const FCPointsShopItem({
    required this.id,
    required this.titleRu,
    required this.titleEn,
    required this.descriptionRu,
    required this.descriptionEn,
    required this.price,
    required this.icon,
  });
}

enum FCPointsPurchaseResult {
  purchased,
  alreadyOwned,
  insufficientFunds,
  unknownItem,
}

class FCPointsService {
  static const String _legacyStorageKey = 'fc_points_profile_v1';

  static String? get _uid => AccountService.currentUser?.uid;
  static String get _storageKey =>
      _uid == null ? _legacyStorageKey : 'fc_points_profile_v1_${_uid}';

  static DocumentReference<Map<String, dynamic>>? get _cloudProfile {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('gameData')
        .doc('fcPoints');
  }

  static Map<String, dynamic> _emptyState() => {
    'balance': 0,
    'claimedRewards': <String>[],
    'ownedModes': <String>[],
    'claimedDeveloperBonuses': <String>[],
  };

  static Future<void> _writeState(Map<String, dynamic> state) async {
    final raw = jsonEncode(state);
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_storageKey, raw);
    if (!saved) throw Exception('Не удалось сохранить профиль FC Points');

    final cloud = _cloudProfile;
    if (cloud == null) return;
    try {
      await cloud.set({
        'stateJson': raw,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Локальный профиль остаётся доступен офлайн; следующая запись
      // повторно отправит актуальное состояние в Firestore.
    }
  }
  static const int maxBalance = 99999;
  static const int _developerWelcomeBonus = 5000;

  static int _clampBalance(int value) => value.clamp(0, maxBalance).toInt();

  /// Каждый режим покупается отдельно за FC Points.
  static const List<FCPointsShopItem> shopItems = [
    FCPointsShopItem(
      id: 'any_starting_club',
      titleRu: 'Выбор любого клуба',
      titleEn: 'Choose any club',
      descriptionRu: 'Выбирай любую команду из доступных лиг и дивизионов.',
      descriptionEn: 'Choose any team from available leagues and divisions.',
      price: 4500,
      icon: Icons.shield_outlined,
    ),
    FCPointsShopItem(
      id: 'career_without_injuries',
      titleRu: 'Карьера без травм',
      titleEn: 'Career without injuries',
      descriptionRu: 'Твой игрок не будет получать травмы на протяжении карьеры.',
      descriptionEn: 'Your player will not receive injuries during the career.',
      price: 2300,
      icon: Icons.health_and_safety_outlined,
    ),
    FCPointsShopItem(
      id: 'five_year_transfers',
      titleRu: 'Трансферы раз в 5 лет',
      titleEn: 'Transfers every 5 years',
      descriptionRu: 'Менять клуб можно будет только в сезонах 5, 10, 15 и далее.',
      descriptionEn: 'Change clubs only in seasons 5, 10, 15 and so on.',
      price: 1950,
      icon: Icons.swap_horiz_rounded,
    ),
  ];

  static Future<Map<String, dynamic>> _readState() async {
    final preferences = await SharedPreferences.getInstance();
    final uid = _uid;
    final cloud = _cloudProfile;

    if (uid != null && cloud != null) {
      try {
        final snapshot = await cloud.get();
        final cloudRaw = snapshot.data()?['stateJson'];
        if (cloudRaw is String) {
          await preferences.setString(_storageKey, cloudRaw);
          return _decodeState(cloudRaw);
        }

        // Перенос прежнего общего профиля FC Points выполняется только
        // для аккаунта разработчика. Обычные аккаунты начинают отдельно.
        final localRaw = preferences.getString(_storageKey);
        if (localRaw != null) {
          final localState = _decodeState(localRaw);
          await _writeState(localState);
          return localState;
        }

        if (await AccountService.isDeveloper()) {
          final legacyRaw = preferences.getString(_legacyStorageKey);
          if (legacyRaw != null) {
            final legacyState = _decodeState(legacyRaw);
            await _writeState(legacyState);
            return legacyState;
          }
        }
      } catch (_) {
        // При отсутствии сети продолжаем с локальным кэшем.
      }
    }

    final raw = preferences.getString(_storageKey);
    return raw == null ? _emptyState() : _decodeState(raw);
  }

  static Map<String, dynamic> _decodeState(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return _emptyState();
      return {
        'balance': _clampBalance((decoded['balance'] as num?)?.toInt() ?? 0),
        'claimedRewards': (decoded['claimedRewards'] as List?)
                ?.whereType<String>()
                .toList() ??
            <String>[],
        'ownedModes': (decoded['ownedModes'] as List?)
                ?.whereType<String>()
                .toList() ??
            <String>[],
        'claimedDeveloperBonuses':
            (decoded['claimedDeveloperBonuses'] as List?)
                ?.whereType<String>()
                .toList() ??
            <String>[],
      };
    } catch (_) {
      return _emptyState();
    }
  }

  /// Однократно начисляет аккаунту разработчика стартовые 5000 FC Points.
  /// UID фиксируется в том же локальном профиле, поэтому повторные открытия
  /// магазина и перезапуски приложения не начисляют бонус повторно.
  static Future<void> _applyDeveloperWelcomeBonus() async {
    if (!await AccountService.isDeveloper()) return;
    final uid = AccountService.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    final state = await _readState();
    final claimed = (state['claimedDeveloperBonuses'] as List<String>).toSet();
    if (claimed.contains(uid)) return;

    claimed.add(uid);
    final updatedState = {
      'balance': _clampBalance(
        (state['balance'] as int) + _developerWelcomeBonus,
      ),
      'claimedRewards': state['claimedRewards'],
      'ownedModes': state['ownedModes'],
      'claimedDeveloperBonuses': claimed.toList()..sort(),
    };
    await _writeState(updatedState);
  }

  static Future<Set<String>> ownedModes() async {
    if (await AccountService.isDeveloper()) {
      return shopItems.map((item) => item.id).toSet();
    }
    final state = await _readState();
    return (state['ownedModes'] as List<String>).toSet();
  }

  static Future<bool> isModeOwned(String modeId) async {
    if (await AccountService.isDeveloper()) {
      return shopItems.any((item) => item.id == modeId);
    }
    return (await ownedModes()).contains(modeId);
  }

  /// Списывает валюту и открывает только выбранный режим.
  /// Баланс и покупка записываются одним обновлением профиля.
  static Future<FCPointsPurchaseResult> purchaseMode(String modeId) async {
    await _applyDeveloperWelcomeBonus();
    FCPointsShopItem? item;
    for (final candidate in shopItems) {
      if (candidate.id == modeId) {
        item = candidate;
        break;
      }
    }
    if (item == null) return FCPointsPurchaseResult.unknownItem;
    // Аккаунт разработчика получает доступ ко всем режимам без списания FCP.
    if (await AccountService.isDeveloper()) {
      return FCPointsPurchaseResult.alreadyOwned;
    }

    final state = await _readState();
    final owned = (state['ownedModes'] as List<String>).toSet();
    if (owned.contains(modeId)) return FCPointsPurchaseResult.alreadyOwned;

    final currentBalance = state['balance'] as int;
    if (currentBalance < item.price) {
      return FCPointsPurchaseResult.insufficientFunds;
    }

    owned.add(modeId);
    final updatedState = {
      'balance': currentBalance - item.price,
      'claimedRewards': state['claimedRewards'],
      'ownedModes': owned.toList()..sort(),
      'claimedDeveloperBonuses': state['claimedDeveloperBonuses'],
    };
    await _writeState(updatedState);
    return FCPointsPurchaseResult.purchased;
  }

  static Future<int> balance() async {
    await _applyDeveloperWelcomeBonus();
    final state = await _readState();
    return state['balance'] as int;
  }

  /// Начисляет награду за завершённый сезон один раз на конкретную карьеру.
  /// Повторный вызов безопасен, в том числе после повторного открытия экрана.
  static Future<int> awardSeason(Career career) async {
    await _applyDeveloperWelcomeBonus();
    final seasonStats = career.history.where(
      (item) => item.season == career.season,
    );
    if (seasonStats.isEmpty) return 0;

    final stats = seasonStats.last;
    final rewardId = '${career.careerId}:season:${career.season}';
    final state = await _readState();
    final claimed = (state['claimedRewards'] as List<String>).toSet();
    if (claimed.contains(rewardId)) return 0;

    var reward = 10; // Базовая награда за завершение сезона.
    const achievementRewards = <String, int>{
      'Чемпион страны': 80,
      'Обладатель кубка страны': 60,
      'Победитель Лиги Европы': 90,
      'Победитель Лиги чемпионов': 150,
    };
    for (final achievement in stats.achievements.toSet()) {
      reward += achievementRewards[achievement] ?? 0;
    }
    // Дополнительная награда за завершение полной 20-сезонной карьеры.
    if (career.season >= 20) reward += 50;

    const awardRewards = <String, int>{
      'Лучший бомбардир': 50,
      'Лучший ассистент': 40,
      'Золотой мяч': 100,
    };
    final earnedCategories = career.seasonAwards
        .where(
          (award) =>
              award.season == career.season &&
              award.isCareerPlayer &&
              award.playerName == career.player.name,
        )
        .map((award) => award.category)
        .toSet();
    for (final category in earnedCategories) {
      reward += awardRewards[category] ?? 0;
    }

    claimed.add(rewardId);
    final previousBalance = state['balance'] as int;
    final updatedBalance = _clampBalance(previousBalance + reward);
    final updatedState = {
      'balance': updatedBalance,
      'claimedRewards': claimed.toList()..sort(),
      'ownedModes': state['ownedModes'],
      'claimedDeveloperBonuses': state['claimedDeveloperBonuses'],
    };
    await _writeState(updatedState);
    return updatedBalance - previousBalance;
  }
}
