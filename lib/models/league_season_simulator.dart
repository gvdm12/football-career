import 'dart:math';

import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_match.dart';
import 'package:flutter_football/models/league_table.dart';

/// Автоматически симулирует национальные чемпионаты
/// для квалификации в Лигу чемпионов.
class LeagueSeasonSimulator {
  /// Страны и количество мест в Лиге чемпионов.
  static const Map<League, int> qualificationSlots = {
    League.england: 4,
    League.spain: 4,
    League.germany: 4,
    League.italy: 4,
    League.france: 4,
    League.russia: 3,
    League.turkey: 3,
    League.netherlands: 2,
    League.belgium: 2,
    League.portugal: 2,
  };

  /// Места в Лиге Европы по итогам национальных чемпионатов.
  static const Map<League, (int start, int count)> europaLeagueSlots = {
    League.england: (5, 2),
    League.spain: (5, 3),
    League.italy: (5, 3),
    League.germany: (5, 3),
    League.france: (5, 3),
    League.russia: (4, 3),
    League.turkey: (4, 3),
    League.portugal: (3, 4),
    League.netherlands: (3, 4),
    League.belgium: (3, 4),
  };

  /// Возвращает 32 клуба Лиги Европы по местам в таблицах.
  static List<String> getEuropaLeagueClubs(
    Map<League, List<LeagueTableEntry>> standings,
  ) {
    final qualified = <String>[];

    for (final entry in europaLeagueSlots.entries) {
      final table = standings[entry.key];
      final (start, count) = entry.value;

      if (table == null || table.length < start + count - 1) {
        throw StateError('Нет полной итоговой таблицы лиги ${entry.key.name}');
      }

      qualified.addAll(
        table.skip(start - 1).take(count).map((club) => club.club),
      );
    }

    if (qualified.length != 32 || qualified.toSet().length != 32) {
      throw StateError(
        'Ожидалось 32 уникальных участника Лиги Европы, '
        'получено: ${qualified.length}',
      );
    }

    return List<String>.unmodifiable(qualified);
  }

  /// Симулирует все чемпионаты.
  ///
  /// При одинаковом номере сезона результаты будут одинаковыми.
  /// Возвращает итоговые таблицы всех десяти стран.
  static Map<League, List<LeagueTableEntry>> simulateAll({
    required int season,
  }) {
    final result = <League, List<LeagueTableEntry>>{};

    for (final league in qualificationSlots.keys) {
      result[league] = simulateLeague(league: league, season: season);
    }

    return result;
  }

  /// Симулирует один национальный чемпионат.
  static List<LeagueTableEntry> simulateLeague({
    required League league,
    required int season,
  }) {
    final clubs = Clubs.byLeague(league);

    if (clubs.length < qualificationSlots[league]!) {
      throw StateError(
        'Недостаточно клубов в лиге ${league.name}: ${clubs.length}',
      );
    }

    final fixtures = LeagueCalendar.generate(clubs);

    final table = LeagueTable.create(
      clubs.first.name,
      clubs.skip(1).map((club) => club.name).toList(),
    );

    // Отдельная последовательность случайных чисел для каждой лиги.
    final random = Random(season * 100000 + league.index * 7919);

    var updatedTable = table;

    for (final match in fixtures) {
      final homeStrength = Clubs.getByName(match.homeTeam).strength;
      final awayStrength = Clubs.getByName(match.awayTeam).strength;

      final homeGoals = _generateGoals(random, homeStrength, awayStrength);

      final awayGoals = _generateGoals(random, awayStrength, homeStrength);

      updatedTable = LeagueTable.applyMatch(
        table: updatedTable,
        homeTeam: match.homeTeam,
        awayTeam: match.awayTeam,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
      );
    }

    return List<LeagueTableEntry>.unmodifiable(updatedTable);
  }

  /// Возвращает квалифицировавшиеся клубы в порядке стран.
  static List<String> getQualifiedClubs(
    Map<League, List<LeagueTableEntry>> standings,
  ) {
    final qualified = <String>[];

    for (final entry in qualificationSlots.entries) {
      final table = standings[entry.key];

      if (table == null || table.length < entry.value) {
        throw StateError('Нет полной итоговой таблицы лиги ${entry.key.name}');
      }

      qualified.addAll(table.take(entry.value).map((club) => club.club));
    }

    if (qualified.length != 32 || qualified.toSet().length != 32) {
      throw StateError(
        'Ожидалось 32 уникальных участника Лиги чемпионов, '
        'получено: ${qualified.length}',
      );
    }

    return List<String>.unmodifiable(qualified);
  }

  static int _generateGoals(Random random, int attack, int opponentStrength) {
    final difference = (attack - opponentStrength) / 20;
    final chance = 0.30 + difference.clamp(-0.15, 0.20);

    var goals = 0;

    if (random.nextDouble() < chance) {
      goals++;
    }

    if (random.nextDouble() < chance * 0.65) {
      goals++;
    }

    if (random.nextDouble() < chance * 0.30) {
      goals++;
    }

    return min(goals, 4);
  }
}
