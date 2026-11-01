import 'dart:math';

import 'package:flutter_football/models/league_match.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/real_club_squads.dart';

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
  });

  double get averageRating => matches == 0 ? 0 : ratingSum / matches;

  LeaguePlayerSeasonStats addMatch({
    required int goals,
    required int assists,
    required double rating,
  }) {
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
  };

  factory LeaguePlayerSeasonStats.fromJson(Map<String, dynamic> json) {
    return LeaguePlayerSeasonStats(
      playerName: json['playerName'] as String? ?? 'Player',
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
    );
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

    const targetCounts = <PlayerPosition, int>{
      PlayerPosition.goalkeeper: 2,
      PlayerPosition.defender: 6,
      PlayerPosition.midfielder: 6,
      PlayerPosition.forward: 5,
    };
    final clubStrength = _clubStrength(club);
    for (final entry in targetCounts.entries) {
      final existing = result.where((item) => item.position == entry.key).length;
      for (var index = existing; index < entry.value; index++) {
        final nameIndex = random.nextInt(_names.length);
        final name = '${_names[nameIndex]} ${_suffix(club, index, season)}';
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
    return result;
  }

  static String _suffix(String club, int index, int season) {
    final value = _seed('$club|$index|$season') % 90 + 10;
    return value.toString();
  }

  static int _clubStrength(String club) {
    // Сила клуба передаётся через рейтинг реального состава, если он есть.
    final squad = RealClubSquads.squads[club];
    if (squad == null) return 68;
    final values = squad.values.expand((items) => items).map((item) => item.overall).toList();
    if (values.isEmpty) return 68;
    return (values.reduce((a, b) => a + b) / values.length).round();
  }

  static LeaguePlayerStatsUpdate update({
    required int season,
    required List<LeaguePlayerSeasonStats> current,
    required List<String> processedMatchKeys,
    required List<LeagueMatch> fixtures,
  }) {
    final players = List<LeaguePlayerSeasonStats>.from(current);
    final processed = List<String>.from(processedMatchKeys);
    final clubs = fixtures
        .expand((fixture) => [fixture.homeTeam, fixture.awayTeam])
        .toSet();

    if (players.isEmpty) {
      for (final club in clubs) {
        players.addAll(_createRoster(club, season));
      }
    }

    for (final fixture in fixtures.where((item) => item.isPlayed)) {
      final key = '$season:${fixture.id}';
      if (processed.contains(key)) continue;
      final random = Random(_seed(key));
      _applyTeamMatch(
        players,
        club: fixture.homeTeam,
        goalsFor: fixture.homeGoals!,
        goalsAgainst: fixture.awayGoals!,
        random: random,
      );
      _applyTeamMatch(
        players,
        club: fixture.awayTeam,
        goalsFor: fixture.awayGoals!,
        goalsAgainst: fixture.homeGoals!,
        random: random,
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

    for (final player in selected) {
      var playerGoals = 0;
      var playerAssists = 0;
      final goalWeight = switch (player.position) {
        PlayerPosition.goalkeeper => 0.0,
        PlayerPosition.defender => 0.08,
        PlayerPosition.midfielder => 0.28,
        PlayerPosition.forward => 0.64,
      };
      for (var i = 0; i < goalsFor; i++) {
        if (random.nextDouble() < goalWeight / 3) playerGoals++;
      }
      final assistWeight = switch (player.position) {
        PlayerPosition.goalkeeper => 0.0,
        PlayerPosition.defender => 0.10,
        PlayerPosition.midfielder => 0.48,
        PlayerPosition.forward => 0.38,
      };
      for (var i = 0; i < goalsFor; i++) {
        if (random.nextDouble() < assistWeight / 2) playerAssists++;
      }

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
        );
      }
    }
  }
}
