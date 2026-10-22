import 'dart:math';

import 'club.dart';

class LeagueTableEntry {
  final String club;

  final int played;
  final int wins;
  final int draws;
  final int losses;

  final int goalsFor;
  final int goalsAgainst;

  const LeagueTableEntry({
    required this.club,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  int get goalDifference => goalsFor - goalsAgainst;

  int get points => wins * 3 + draws;

  LeagueTableEntry copyWith({
    String? club,
    int? played,
    int? wins,
    int? draws,
    int? losses,
    int? goalsFor,
    int? goalsAgainst,
  }) {
    return LeagueTableEntry(
      club: club ?? this.club,
      played: played ?? this.played,
      wins: wins ?? this.wins,
      draws: draws ?? this.draws,
      losses: losses ?? this.losses,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'club': club,
      'played': played,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
    };
  }

  factory LeagueTableEntry.fromJson(Map<String, dynamic> json) {
    return LeagueTableEntry(
      club: json['club'] as String? ?? 'Без клуба',
      played: (json['played'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      draws: (json['draws'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      goalsFor: (json['goalsFor'] as num?)?.toInt() ?? 0,
      goalsAgainst: (json['goalsAgainst'] as num?)?.toInt() ?? 0,
    );
  }
}

class LeagueTable {
  static List<LeagueTableEntry> create(
    String playerClub,
    List<String> opponents,
  ) {
    final clubs = [
      playerClub,
      ...opponents.where((club) => club != playerClub),
    ];

    return clubs
        .toSet()
        .map(
          (club) => LeagueTableEntry(
            club: club,
            played: 0,
            wins: 0,
            draws: 0,
            losses: 0,
            goalsFor: 0,
            goalsAgainst: 0,
          ),
        )
        .toList();
  }

  static List<LeagueTableEntry> applyMatch({
    required List<LeagueTableEntry> table,
    required String homeTeam,
    required String awayTeam,
    required int homeGoals,
    required int awayGoals,
  }) {
    final updated = table.map((entry) {
      if (entry.club == homeTeam) {
        return _updateEntry(
          entry,
          goalsFor: homeGoals,
          goalsAgainst: awayGoals,
          won: homeGoals > awayGoals,
          draw: homeGoals == awayGoals,
          lost: homeGoals < awayGoals,
        );
      }

      if (entry.club == awayTeam) {
        return _updateEntry(
          entry,
          goalsFor: awayGoals,
          goalsAgainst: homeGoals,
          won: awayGoals > homeGoals,
          draw: homeGoals == awayGoals,
          lost: awayGoals < homeGoals,
        );
      }

      return entry;
    }).toList();

    return _sort(updated);
  }

  static LeagueTableEntry _updateEntry(
    LeagueTableEntry entry, {
    required int goalsFor,
    required int goalsAgainst,
    required bool won,
    required bool draw,
    required bool lost,
  }) {
    return entry.copyWith(
      played: entry.played + 1,
      wins: entry.wins + (won ? 1 : 0),
      draws: entry.draws + (draw ? 1 : 0),
      losses: entry.losses + (lost ? 1 : 0),
      goalsFor: entry.goalsFor + goalsFor,
      goalsAgainst: entry.goalsAgainst + goalsAgainst,
    );
  }

  static List<LeagueTableEntry> _sort(List<LeagueTableEntry> table) {
    table.sort((a, b) {
      final pointsCompare = b.points.compareTo(a.points);

      if (pointsCompare != 0) {
        return pointsCompare;
      }

      final goalDifferenceCompare = b.goalDifference.compareTo(
        a.goalDifference,
      );

      if (goalDifferenceCompare != 0) {
        return goalDifferenceCompare;
      }

      return b.goalsFor.compareTo(a.goalsFor);
    });

    return table;
  }

  static List<LeagueTableEntry> simulateBackgroundMatches({
    required List<LeagueTableEntry> table,
    required String playerClub,
    required String currentOpponent,
    required int season,
    required int round,
  }) {
    final random = Random(season * 1000 + round * 97);

    final teams = table
        .map((entry) => entry.club)
        .where((club) => club != playerClub && club != currentOpponent)
        .toList();

    teams.shuffle(random);

    var updatedTable = [...table];

    for (int i = 0; i + 1 < teams.length; i += 2) {
      final homeTeam = teams[i];
      final awayTeam = teams[i + 1];

      final homeStrength = Clubs.getByName(homeTeam).strength;

      final awayStrength = Clubs.getByName(awayTeam).strength;

      final homeGoals = _generateGoals(random, homeStrength, awayStrength);

      final awayGoals = _generateGoals(random, awayStrength, homeStrength);

      updatedTable = applyMatch(
        table: updatedTable,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
      );
    }

    return updatedTable;
  }

  static int _generateGoals(Random random, int attack, int opponentStrength) {
    final difference = (attack - opponentStrength) / 20;

    final chance = 0.30 + difference.clamp(-0.15, 0.20);

    int goals = 0;

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
