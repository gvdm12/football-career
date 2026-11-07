import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';

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
  static const String _storageKey = 'fc_points_profile_v1';

  /// Каждый режим покупается отдельно за FC Points.
  static const List<FCPointsShopItem> shopItems = [
    FCPointsShopItem(
      id: 'any_starting_club',
      titleRu: 'Выбор любого клуба',
      titleEn: 'Choose any club',
      descriptionRu: 'Выбирай любую команду из доступных лиг и дивизионов.',
      descriptionEn: 'Choose any team from available leagues and divisions.',
      price: 600,
      icon: Icons.shield_outlined,
    ),
    FCPointsShopItem(
      id: 'career_without_injuries',
      titleRu: 'Карьера без травм',
      titleEn: 'Career without injuries',
      descriptionRu: 'Твой игрок не будет получать травмы на протяжении карьеры.',
      descriptionEn: 'Your player will not receive injuries during the career.',
      price: 450,
      icon: Icons.health_and_safety_outlined,
    ),
    FCPointsShopItem(
      id: 'five_year_transfers',
      titleRu: 'Трансферы раз в 5 лет',
      titleEn: 'Transfers every 5 years',
      descriptionRu: 'Менять клуб можно будет только в сезонах 5, 10, 15 и далее.',
      descriptionEn: 'Change clubs only in seasons 5, 10, 15 and so on.',
      price: 500,
      icon: Icons.swap_horiz_rounded,
    ),
  ];

  static Future<Map<String, dynamic>> _readState() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null) {
      return {'balance': 0, 'claimedRewards': <String>[], 'ownedModes': <String>[]};
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return {'balance': 0, 'claimedRewards': <String>[]};
      }
      return {
        'balance': ((decoded['balance'] as num?)?.toInt() ?? 0)
            .clamp(0, 1 << 31)
            .toInt(),
        'claimedRewards': (decoded['claimedRewards'] as List?)
                ?.whereType<String>()
                .toList() ??
            <String>[],
        'ownedModes': (decoded['ownedModes'] as List?)
                ?.whereType<String>()
                .toList() ??
            <String>[],
      };
    } catch (_) {
      return {'balance': 0, 'claimedRewards': <String>[]};
    }
  }

  static Future<Set<String>> ownedModes() async {
    final state = await _readState();
    return (state['ownedModes'] as List<String>).toSet();
  }

  static Future<bool> isModeOwned(String modeId) async {
    return (await ownedModes()).contains(modeId);
  }

  /// Списывает валюту и открывает только выбранный режим.
  /// Баланс и покупка записываются одним обновлением профиля.
  static Future<FCPointsPurchaseResult> purchaseMode(String modeId) async {
    FCPointsShopItem? item;
    for (final candidate in shopItems) {
      if (candidate.id == modeId) {
        item = candidate;
        break;
      }
    }
    if (item == null) return FCPointsPurchaseResult.unknownItem;

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
    };
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(updatedState),
    );
    if (!saved) throw Exception('Не удалось сохранить покупку FC Points');
    return FCPointsPurchaseResult.purchased;
  }

  static Future<int> balance() async {
    final state = await _readState();
    return state['balance'] as int;
  }

  /// Начисляет награду за завершённый сезон один раз на конкретную карьеру.
  /// Повторный вызов безопасен, в том числе после повторного открытия экрана.
  static Future<int> awardSeason(Career career) async {
    final seasonStats = career.history.where(
      (item) => item.season == career.season,
    );
    if (seasonStats.isEmpty) return 0;

    final stats = seasonStats.last;
    final rewardId = '${career.careerId}:season:${career.season}';
    final state = await _readState();
    final claimed = (state['claimedRewards'] as List<String>).toSet();
    if (claimed.contains(rewardId)) return 0;

    var reward = 80; // Базовая награда за завершение сезона.
    const achievementRewards = <String, int>{
      'Чемпион страны': 150,
      'Обладатель кубка страны': 100,
      'Победитель Лиги Европы': 200,
      'Победитель Лиги чемпионов': 300,
      'Чемпион мира': 400,
    };
    for (final achievement in stats.achievements.toSet()) {
      reward += achievementRewards[achievement] ?? 0;
    }
    // Дополнительная награда за завершение полной 20-сезонной карьеры.
    if (career.season >= 20) reward += 300;

    const awardRewards = <String, int>{
      'Лучший бомбардир': 80,
      'Лучший ассистент': 60,
      'Золотой мяч': 200,
      'Лучший молодой игрок': 50,
      'Команда года': 25,
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
    final updatedState = {
      'balance': (state['balance'] as int) + reward,
      'claimedRewards': claimed.toList()..sort(),
    };
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(updatedState),
    );
    if (!saved) throw Exception('Не удалось сохранить FC Points');
    return reward;
  }
}
