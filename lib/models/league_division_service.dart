import 'dart:math';

import 'club.dart';
import 'league_match.dart';
import 'league_table.dart';

/// Состояние двухдивизионных национальных чемпионатов.
class LeagueDivisionService {
  static const Set<League> twoTierLeagues = {
    League.england,
    League.spain,
    League.germany,
    League.italy,
    League.france,
    League.russia,
  };

  static String key(League league, int division) =>
      '${league.name}_${division}';

  static bool hasSecondDivision(League league) =>
      twoTierLeagues.contains(league);

  static Map<String, List<String>> createInitialDivisions() {
    final result = <String, List<String>>{};
    for (final league in League.values) {
      result[key(league, 1)] = Clubs.byLeagueDivision(league, 1)
          .map((club) => club.name)
          .toList();
      if (hasSecondDivision(league)) {
        result[key(league, 2)] = Clubs.byLeagueDivision(league, 2)
            .map((club) => club.name)
            .toList();
      }
    }
    return result;
  }

  static Map<String, List<String>> restoreDivisions(Object? raw) {
    if (raw is! Map) return createInitialDivisions();
    final restored = <String, List<String>>{
      for (final entry in raw.entries)
        if (entry.value is List)
          entry.key.toString(): (entry.value as List)
              .whereType<String>()
              .toList(),
    };
    final initial = createInitialDivisions();
    for (final entry in initial.entries) {
      restored.putIfAbsent(entry.key, () => List<String>.from(entry.value));
    }
    return restored;
  }

  static int? divisionForClub(
    String clubName,
    Map<String, List<String>> divisions,
  ) {
    for (final entry in divisions.entries) {
      if (entry.value.contains(clubName)) {
        final separator = entry.key.lastIndexOf('_');
        if (separator >= 0) {
          return int.tryParse(entry.key.substring(separator + 1));
        }
      }
    }
    return Clubs.divisionOf(clubName);
  }

  static List<Club> clubsFor(
    League league,
    int division,
    Map<String, List<String>> divisions,
  ) {
    final names = divisions[key(league, division)] ??
        Clubs.byLeagueDivision(league, division).map((club) => club.name).toList();
    return names.map(Clubs.getByName).toList();
  }

  static Map<String, List<LeagueTableEntry>> simulateAllDivisions({
    required Map<String, List<String>> divisions,
    required int season,
  }) {
    final result = <String, List<LeagueTableEntry>>{};
    for (final league in League.values) {
      final divisionCount = hasSecondDivision(league) ? 2 : 1;
      for (var division = 1; division <= divisionCount; division++) {
        final clubs = clubsFor(league, division, divisions);
        if (clubs.length < 2 || clubs.length.isOdd) continue;
        final fixtures = LeagueCalendar.generate(clubs);
        final table = LeagueTable.create(
          clubs.first.name,
          clubs.skip(1).map((club) => club.name).toList(),
        );
        final random = Random(
          season * 100000 + league.index * 7919 + division * 104729,
        );
        var updated = table;
        for (final match in fixtures) {
          final homeStrength = Clubs.getByName(match.homeTeam).strength;
          final awayStrength = Clubs.getByName(match.awayTeam).strength;
          final homeGoals = _generateGoals(random, homeStrength, awayStrength);
          final awayGoals = _generateGoals(random, awayStrength, homeStrength);
          updated = LeagueTable.applyMatch(
            table: updated,
            homeTeam: match.homeTeam,
            awayTeam: match.awayTeam,
            homeGoals: homeGoals,
            awayGoals: awayGoals,
          );
        }
        result[key(league, division)] =
            List<LeagueTableEntry>.unmodifiable(updated);
      }
    }
    return result;
  }

  /// Повышает две лучшие команды второго дивизиона и вылетает две
  /// последние команды высшего дивизиона. Все остальные клубы сохраняют уровень.
  static Map<String, List<String>> advanceSeason({
    required Map<String, List<String>> divisions,
    required Map<String, List<LeagueTableEntry>> finalTables,
  }) {
    final next = <String, List<String>>{
      for (final entry in divisions.entries)
        entry.key: List<String>.from(entry.value),
    };

    for (final league in twoTierLeagues) {
      final topKey = key(league, 1);
      final secondKey = key(league, 2);
      final topTable = finalTables[topKey];
      final secondTable = finalTables[secondKey];
      if (topTable == null || secondTable == null ||
          topTable.length < 2 || secondTable.length < 2) {
        continue;
      }

      final promoted = secondTable.take(2).map((entry) => entry.club).toList();
      final relegated = topTable.skip(topTable.length - 2)
          .map((entry) => entry.club)
          .toList();

      final topClubs = next[topKey] ?? <String>[];
      final secondClubs = next[secondKey] ?? <String>[];
      next[topKey] = [
        ...topClubs.where((club) => !relegated.contains(club)),
        ...promoted,
      ];
      next[secondKey] = [
        ...secondClubs.where((club) => !promoted.contains(club)),
        ...relegated,
      ];
    }
    return next;
  }

  static int _generateGoals(Random random, int attack, int opponentStrength) {
    final difference = (attack - opponentStrength) / 20;
    final chance = 0.30 + difference.clamp(-0.15, 0.20);
    var goals = 0;
    if (random.nextDouble() < chance) goals++;
    if (random.nextDouble() < chance * 0.65) goals++;
    if (random.nextDouble() < chance * 0.30) goals++;
    return min(goals, 4);
  }
}
