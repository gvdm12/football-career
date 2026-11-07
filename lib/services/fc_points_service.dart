import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_football/models/career.dart';

/// Постоянная игровая валюта профиля. Не связана с деньгами внутри карьеры
/// и не сбрасывается при удалении или создании сохранения.
class FCPointsService {
  static const String _storageKey = 'fc_points_profile_v1';

  static Future<Map<String, dynamic>> _readState() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null) {
      return {'balance': 0, 'claimedRewards': <String>[]};
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
      };
    } catch (_) {
      return {'balance': 0, 'claimedRewards': <String>[]};
    }
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
    final rewardId = 'undefined:season:undefined';
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
