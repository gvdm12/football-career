import 'dart:math';

import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_match.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/real_club_squads.dart';

class LeaguePlayerMonthStats {
  final int matches;
  final int goals;
  final int assists;
  final double ratingSum;

  const LeaguePlayerMonthStats({
    this.matches = 0,
    this.goals = 0,
    this.assists = 0,
    this.ratingSum = 0,
  });

  double get averageRating => matches == 0 ? 0 : ratingSum / matches;

  LeaguePlayerMonthStats addMatch({
    required int goals,
    required int assists,
    required double rating,
  }) {
    return LeaguePlayerMonthStats(
      matches: matches + 1,
      goals: this.goals + goals,
      assists: this.assists + assists,
      ratingSum: ratingSum + rating,
    );
  }

  Map<String, dynamic> toJson() => {
    'matches': matches,
    'goals': goals,
    'assists': assists,
    'ratingSum': ratingSum,
  };

  factory LeaguePlayerMonthStats.fromJson(Map<String, dynamic> json) {
    return LeaguePlayerMonthStats(
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      ratingSum: (json['ratingSum'] as num?)?.toDouble() ?? 0,
    );
  }
}

class LeaguePlayerSeasonStats {
  final String playerName;
  final String club;
  final PlayerPosition position;
  final int age;
  final int overall;
  final int matches;
  final int goals;
  final int assists;
  final double ratingSum;
  final Map<int, LeaguePlayerMonthStats> monthlyStats;

  const LeaguePlayerSeasonStats({
    required this.playerName,
    required this.club,
    required this.position,
    required this.age,
    required this.overall,
    this.matches = 0,
    this.goals = 0,
    this.assists = 0,
    this.ratingSum = 0,
    this.monthlyStats = const {},
  });

  double get averageRating => matches == 0 ? 0 : ratingSum / matches;

  LeaguePlayerSeasonStats addMatch({
    required int goals,
    required int assists,
    required double rating,
    int? month,
  }) {
    final updatedMonthlyStats =
        Map<int, LeaguePlayerMonthStats>.from(monthlyStats);
    if (month != null && month >= 1 && month <= 12) {
      updatedMonthlyStats[month] =
          (updatedMonthlyStats[month] ?? const LeaguePlayerMonthStats())
              .addMatch(goals: goals, assists: assists, rating: rating);
    }
    return LeaguePlayerSeasonStats(
      playerName: playerName,
      club: club,
      position: position,
      age: age,
      overall: overall,
      matches: matches + 1,
      goals: this.goals + goals,
      assists: this.assists + assists,
      ratingSum: ratingSum + rating,
      monthlyStats: updatedMonthlyStats,
    );
  }

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'club': club,
    'position': position.name,
    'age': age,
    'overall': overall,
    'matches': matches,
    'goals': goals,
    'assists': assists,
    'ratingSum': ratingSum,
    'monthlyStats': {
      for (final entry in monthlyStats.entries)
        entry.key.toString(): entry.value.toJson(),
    },
  };

  factory LeaguePlayerSeasonStats.fromJson(Map<String, dynamic> json) {
    return LeaguePlayerSeasonStats(
      playerName: _cleanGeneratedPlayerName(json['playerName'] as String? ?? 'Player'),
      club: json['club'] as String? ?? '',
      position: PlayerPosition.values.firstWhere(
        (value) => value.name == json['position'],
        orElse: () => PlayerPosition.forward,
      ),
      age: (json['age'] as num?)?.toInt() ?? 25,
      overall: (json['overall'] as num?)?.toInt() ?? 65,
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      ratingSum: (json['ratingSum'] as num?)?.toDouble() ?? 0,
      monthlyStats:
          (json['monthlyStats'] as Map?)?.entries
              .fold<Map<int, LeaguePlayerMonthStats>>(
                {},
                (result, entry) {
                  final month = int.tryParse(entry.key.toString());
                  if (month != null && entry.value is Map) {
                    result[month] = LeaguePlayerMonthStats.fromJson(
                      Map<String, dynamic>.from(entry.value as Map),
                    );
                  }
                  return result;
                },
              ) ??
          const {},
    );
  }
static String _cleanGeneratedPlayerName(String name) {
  final trimmed = name.trim();
  final separator = trimmed.lastIndexOf(' ');
  if (separator < 0) return trimmed;

  final suffix = trimmed.substring(separator + 1);
  if (suffix.length == 2 && int.tryParse(suffix) != null) {
    return trimmed.substring(0, separator);
  }
  return trimmed;
}

}

class LeaguePlayerStatsUpdate {
  final List<LeaguePlayerSeasonStats> players;
  final List<String> processedMatchKeys;

  const LeaguePlayerStatsUpdate({
    required this.players,
    required this.processedMatchKeys,
  });
}

class LeaguePlayerStatsService {
  static const _names = [
    'James Wilson', 'Oliver Bennett', 'Lucas Mitchell', 'Ethan Parker',
    'Daniel Foster', 'Alexander Brooks', 'Noah Carter', 'Leo Anderson',
    'Mateo Rivera', 'Gabriel Santos', 'Ryan Cooper', 'Thomas Reed',
    'William Turner', 'Nathan Collins', 'Adrian Morris', 'Samuel Hayes',
    'Jack Robinson', 'David Morgan', 'Benjamin Scott', 'Oscar Hughes',
    'Felix Wagner', 'Marco Romano', 'Hugo Laurent', 'Victor Almeida',
    'Milan Petrovic', 'Erik Johansson', 'Adam Kowalski', 'Luca Moretti',
    'Dylan Murphy', 'Kai Nakamura', 'Amir Haddad', 'Carlos Herrera',
  ];

  static int _seed(String value) {
    var hash = 29;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  static List<LeaguePlayerSeasonStats> _createRoster(
    String club,
    int season,
  ) {
    final random = Random(_seed('$club|$season'));
    final real = RealClubSquads.squads[club];
    final result = <LeaguePlayerSeasonStats>[];

    for (final position in PlayerPosition.values) {
      final key = position.name;
      final realPlayers = real?[key] ?? const <RealClubPlayer>[];
      for (final item in realPlayers) {
        result.add(LeaguePlayerSeasonStats(
          playerName: item.name,
          club: club,
          position: position,
          age: item.age,
          overall: item.overall,
        ));
      }
    }

    // Если для клуба уже задан реальный состав, не добавляем к нему
    // вымышленных футболистов. Генерация применяется только к клубам
    // без базы реальных игроков.
    if (real == null || real.values.every((players) => players.isEmpty)) {
      const targetCounts = <PlayerPosition, int>{
        PlayerPosition.goalkeeper: 2,
        PlayerPosition.defender: 6,
        PlayerPosition.midfielder: 6,
        PlayerPosition.forward: 5,
      };
      final clubStrength = _clubStrength(club);
      final usedNames = result.map((item) => item.playerName).toSet();
      final generatedNames = List<String>.from(_names)..shuffle(random);

      for (final entry in targetCounts.entries) {
        final existing =
            result.where((item) => item.position == entry.key).length;
        for (var index = existing; index < entry.value; index++) {
          final name = generatedNames.firstWhere(
            (candidate) => !usedNames.contains(candidate),
          );
          usedNames.add(name);
          final delta = random.nextInt(15) - 7;
          result.add(LeaguePlayerSeasonStats(
            playerName: name,
            club: club,
            position: entry.key,
            age: 18 + random.nextInt(17),
            overall: (clubStrength + delta).clamp(48, 92).toInt(),
          ));
        }
      }
    }
    return result;
  }

  /// Синхронизирует сохранённый список со всеми реальными игроками клуба.
  /// Также очищает случайных футболистов из старых сохранений.
  static void _syncRealRosters(
    List<LeaguePlayerSeasonStats> players,
    Iterable<String> clubs,
  ) {
    for (final club in clubs) {
      final realSquad = RealClubSquads.squads[club];
      if (realSquad == null ||
          realSquad.values.every((items) => items.isEmpty)) {
        continue;
      }

      final realPlayers = <String, ({RealClubPlayer player, PlayerPosition position})>{};
      for (final group in realSquad.entries) {
        final position = PlayerPosition.values.firstWhere(
          (value) => value.name == group.key,
          orElse: () => PlayerPosition.forward,
        );
        for (final realPlayer in group.value) {
          realPlayers['${realPlayer.name}|$club'] =
              (player: realPlayer, position: position);
        }
      }

      players.removeWhere(
        (item) =>
            item.club == club &&
            !realPlayers.containsKey('${item.playerName}|$club'),
      );

      for (final entry in realPlayers.entries) {
        final key = entry.key;
        final data = entry.value;
        final exists = players.any(
          (item) => '${item.playerName}|${item.club}' == key,
        );
        if (exists) continue;
        players.add(LeaguePlayerSeasonStats(
          playerName: data.player.name,
          club: club,
          position: data.position,
          age: data.player.age,
          overall: data.player.overall,
        ));
      }
    }
  }

  static int _clubStrength(String club) {
    // Сила клуба передаётся через рейтинг реального состава, если он есть.
    final squad = RealClubSquads.squads[club];
    if (squad == null) return Clubs.getByName(club).strength;
    final values = squad.values.expand((items) => items).map((item) => item.overall).toList();
    if (values.isEmpty) return Clubs.getByName(club).strength;
    return (values.reduce((a, b) => a + b) / values.length).round();
  }

  static LeaguePlayerStatsUpdate update({
    required int season,
    required List<LeaguePlayerSeasonStats> current,
    required List<String> processedMatchKeys,
    required List<LeagueMatch> fixtures,
  }) {
    final playedFixtureCount = fixtures.where((item) => item.isPlayed).length;
    final storedMonthlyAppearances = current.fold<int>(
      0,
      (sum, player) => sum +
          player.monthlyStats.values.fold<int>(
            0,
            (month, stats) => month + stats.matches,
          ),
    );
    // Старые сохранения не содержат помесячной разбивки. Пересобираем
    // детерминированную статистику из календаря, чтобы не смешивать месяцы.
    final hasLegacySeasonStats = current.any((player) => player.matches > 0);
    final expectedProcessedAppearances = processedMatchKeys.length * 22;
    final needsMonthlyRebuild = current.isNotEmpty &&
        playedFixtureCount > 0 &&
        (processedMatchKeys.isNotEmpty
            ? storedMonthlyAppearances < expectedProcessedAppearances
            : hasLegacySeasonStats && storedMonthlyAppearances == 0);
    final players = needsMonthlyRebuild
        ? <LeaguePlayerSeasonStats>[]
        : List<LeaguePlayerSeasonStats>.from(current);
    final processed = needsMonthlyRebuild
        ? <String>[]
        : List<String>.from(processedMatchKeys);
    final clubs = fixtures
        .expand((fixture) => [fixture.homeTeam, fixture.awayTeam])
        .toSet();

    if (players.isEmpty) {
      for (final club in clubs) {
        players.addAll(_createRoster(club, season));
      }
    }

    // Обновляем реальные составы даже в уже существующих сохранениях:
    // старые случайно сгенерированные имена удаляются, реальные добавляются.
    _syncRealRosters(players, clubs);

    final totalRounds = fixtures.fold<int>(
      0,
      (maximum, fixture) => max(maximum, fixture.round),
    );
    for (final fixture in fixtures.where((item) => item.isPlayed)) {
      final key = '$season:${fixture.id}';
      if (processed.contains(key)) continue;
      final random = Random(_seed(key));
      final month = totalRounds == 0
          ? 1
          : (((fixture.round * 12) - 1) ~/ totalRounds) + 1;
      _applyTeamMatch(
        players,
        club: fixture.homeTeam,
        goalsFor: fixture.homeGoals!,
        goalsAgainst: fixture.awayGoals!,
        random: random,
        month: month,
      );
      _applyTeamMatch(
        players,
        club: fixture.awayTeam,
        goalsFor: fixture.awayGoals!,
        goalsAgainst: fixture.homeGoals!,
        random: random,
        month: month,
      );
      processed.add(key);
    }

    return LeaguePlayerStatsUpdate(
      players: players,
      processedMatchKeys: processed,
    );
  }

  static void _applyTeamMatch(
    List<LeaguePlayerSeasonStats> players, {
    required String club,
    required int goalsFor,
    required int goalsAgainst,
    required Random random,
    required int month,
  }) {
    final squad = players.where((item) => item.club == club).toList();
    final selected = <LeaguePlayerSeasonStats>[];
    for (final position in PlayerPosition.values) {
      final group = squad.where((item) => item.position == position).toList()
        ..shuffle(random);
      final count = switch (position) {
        PlayerPosition.goalkeeper => 1,
        PlayerPosition.defender => 4,
        PlayerPosition.midfielder => 3,
        PlayerPosition.forward => 3,
      };
      selected.addAll(group.take(count));
    }

    final goalsByPlayer = <String, int>{};
    final assistsByPlayer = <String, int>{};

    for (var goal = 0; goal < goalsFor; goal++) {
      final scorer = _weightedPick(selected, random, (item) {
        return switch (item.position) {
          PlayerPosition.goalkeeper => 0.01,
          PlayerPosition.defender => 0.08,
          PlayerPosition.midfielder => 0.28,
          PlayerPosition.forward => 0.63,
        };
      });
      goalsByPlayer[scorer.playerName] =
          (goalsByPlayer[scorer.playerName] ?? 0) + 1;

      if (random.nextDouble() < 0.76) {
        final possibleAssisters = selected
            .where((item) => item.playerName != scorer.playerName)
            .toList();
        if (possibleAssisters.isNotEmpty) {
          final assister = _weightedPick(possibleAssisters, random, (item) {
            return switch (item.position) {
              PlayerPosition.goalkeeper => 0.02,
              PlayerPosition.defender => 0.10,
              PlayerPosition.midfielder => 0.50,
              PlayerPosition.forward => 0.38,
            };
          });
          assistsByPlayer[assister.playerName] =
              (assistsByPlayer[assister.playerName] ?? 0) + 1;
        }
      }
    }

    for (final player in selected) {
      final playerGoals = goalsByPlayer[player.playerName] ?? 0;
      final playerAssists = assistsByPlayer[player.playerName] ?? 0;

      var rating = 6.25 + random.nextDouble() * 1.15;
      rating += (player.overall - 70) * 0.012;
      rating += playerGoals * 0.65 + playerAssists * 0.35;
      if (goalsAgainst == 0 &&
          (player.position == PlayerPosition.goalkeeper ||
              player.position == PlayerPosition.defender)) {
        rating += 0.25;
      }
      if (goalsAgainst >= 3 &&
          (player.position == PlayerPosition.goalkeeper ||
              player.position == PlayerPosition.defender)) {
        rating -= 0.35;
      }
      rating = rating.clamp(5.0, 9.8).toDouble();

      final index = players.indexWhere(
        (item) => item.club == club && item.playerName == player.playerName,
      );
      if (index >= 0) {
        players[index] = players[index].addMatch(
          goals: playerGoals,
          assists: playerAssists,
          rating: rating,
          month: month,
        );
      }
    }
  }

  static T _weightedPick<T>(
    List<T> items,
    Random random,
    double Function(T item) weightOf,
  ) {
    final total = items.fold<double>(0, (sum, item) => sum + weightOf(item));
    var target = random.nextDouble() * total;
    for (final item in items) {
      target -= weightOf(item);
      if (target <= 0) return item;
    }
    return items.last;
  }
}
