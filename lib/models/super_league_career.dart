import 'dart:math';

import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/player.dart';

class SuperLeagueFixture {
  final int round;
  final String homeTeam;
  final String awayTeam;
  final int? homeGoals;
  final int? awayGoals;
  final int playerGoals;
  final int playerAssists;
  final double playerRating;
  final bool playerPlayed;

  const SuperLeagueFixture({
    required this.round,
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals,
    this.awayGoals,
    this.playerGoals = 0,
    this.playerAssists = 0,
    this.playerRating = 0,
    this.playerPlayed = false,
  });

  bool get isPlayed => homeGoals != null && awayGoals != null;

  SuperLeagueFixture copyWith({
    int? homeGoals,
    int? awayGoals,
    int? playerGoals,
    int? playerAssists,
    double? playerRating,
    bool? playerPlayed,
  }) => SuperLeagueFixture(
    round: round,
    homeTeam: homeTeam,
    awayTeam: awayTeam,
    homeGoals: homeGoals ?? this.homeGoals,
    awayGoals: awayGoals ?? this.awayGoals,
    playerGoals: playerGoals ?? this.playerGoals,
    playerAssists: playerAssists ?? this.playerAssists,
    playerRating: playerRating ?? this.playerRating,
    playerPlayed: playerPlayed ?? this.playerPlayed,
  );

  Map<String, dynamic> toJson() => {
    'round': round,
    'homeTeam': homeTeam,
    'awayTeam': awayTeam,
    'homeGoals': homeGoals,
    'awayGoals': awayGoals,
    'playerGoals': playerGoals,
    'playerAssists': playerAssists,
    'playerRating': playerRating,
    'playerPlayed': playerPlayed,
  };

  factory SuperLeagueFixture.fromJson(Map<String, dynamic> json) =>
      SuperLeagueFixture(
        round: (json['round'] as num?)?.toInt() ?? 1,
        homeTeam: json['homeTeam'] as String? ?? '',
        awayTeam: json['awayTeam'] as String? ?? '',
        homeGoals: (json['homeGoals'] as num?)?.toInt(),
        awayGoals: (json['awayGoals'] as num?)?.toInt(),
        playerGoals: (json['playerGoals'] as num?)?.toInt() ?? 0,
        playerAssists: (json['playerAssists'] as num?)?.toInt() ?? 0,
        playerRating: (json['playerRating'] as num?)?.toDouble() ?? 0,
        playerPlayed: json['playerPlayed'] as bool? ?? false,
      );
}

class SuperLeagueStanding {
  final String club;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;

  const SuperLeagueStanding({
    required this.club,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  int get points => wins * 3 + draws;
  int get goalDifference => goalsFor - goalsAgainst;
}

class SuperLeagueCareer {
  final Player player;
  final int season;
  final List<SuperLeagueFixture> fixtures;

  const SuperLeagueCareer({
    required this.player,
    required this.season,
    required this.fixtures,
  });

  static const List<String> clubNames = [
    'Barcelona', 'Real Madrid', 'Atletico Madrid', 'Inter', 'Napoli',
    'AC Milan', 'Juventus', 'Roma', 'Liverpool', 'Manchester City',
    'Arsenal', 'Chelsea', 'Manchester United', 'Tottenham',
    'Bayern Munich', 'Bayer Leverkusen', 'Borussia Dortmund', 'PSG',
    'Monaco', 'Marseille',
  ];

  factory SuperLeagueCareer.newCareer(Player player) {
    final firstLeg = <SuperLeagueFixture>[];
    final teams = List<String>.from(clubNames);
    // Round-robin circle method: every club plays once per round.
    for (var round = 1; round <= teams.length - 1; round++) {
      for (var i = 0; i < teams.length ~/ 2; i++) {
        final first = teams[i];
        final second = teams[teams.length - 1 - i];
        final home = round.isEven ? second : first;
        final away = round.isEven ? first : second;
        firstLeg.add(SuperLeagueFixture(
          round: round,
          homeTeam: home,
          awayTeam: away,
        ));
      }
      final fixed = teams.first;
      final rotating = teams.sublist(1);
      rotating.insert(0, rotating.removeLast());
      teams
        ..clear()
        ..add(fixed)
        ..addAll(rotating);
    }
    final fixtures = <SuperLeagueFixture>[
      ...firstLeg,
      ...firstLeg.map((fixture) => SuperLeagueFixture(
        round: fixture.round + 19,
        homeTeam: fixture.awayTeam,
        awayTeam: fixture.homeTeam,
      )),
    ];
    return SuperLeagueCareer(player: player, season: 1, fixtures: fixtures);
  }

  int get playedMatches => fixtures.where((fixture) => fixture.isPlayed).length;
  int get goals => fixtures.fold(0, (sum, f) => sum + f.playerGoals);
  int get assists => fixtures.fold(0, (sum, f) => sum + f.playerAssists);
  double get averageRating {
    final rated = fixtures.where((f) => f.isPlayed && f.playerPlayed).toList();
    if (rated.isEmpty) return 0;
    return rated.fold<double>(0, (sum, f) => sum + f.playerRating) / rated.length;
  }

  SuperLeagueFixture? get nextFixture {
    for (final fixture in fixtures) {
      if (!fixture.isPlayed &&
          (fixture.homeTeam == player.club || fixture.awayTeam == player.club)) {
        return fixture;
      }
    }
    return null;
  }

  List<SuperLeagueStanding> get standings {
    final stats = {
      for (final club in clubNames)
        club: <String, int>{
          'played': 0, 'wins': 0, 'draws': 0, 'losses': 0,
          'gf': 0, 'ga': 0,
        },
    };
    for (final fixture in fixtures.where((f) => f.isPlayed)) {
      final home = stats[fixture.homeTeam]!;
      final away = stats[fixture.awayTeam]!;
      final hg = fixture.homeGoals!;
      final ag = fixture.awayGoals!;
      home['played'] = home['played']! + 1;
      away['played'] = away['played']! + 1;
      home['gf'] = home['gf']! + hg;
      home['ga'] = home['ga']! + ag;
      away['gf'] = away['gf']! + ag;
      away['ga'] = away['ga']! + hg;
      if (hg > ag) {
        home['wins'] = home['wins']! + 1;
        away['losses'] = away['losses']! + 1;
      } else if (hg < ag) {
        away['wins'] = away['wins']! + 1;
        home['losses'] = home['losses']! + 1;
      } else {
        home['draws'] = home['draws']! + 1;
        away['draws'] = away['draws']! + 1;
      }
    }
    final result = stats.entries.map((entry) {
      final s = entry.value;
      return SuperLeagueStanding(
        club: entry.key,
        played: s['played']!,
        wins: s['wins']!,
        draws: s['draws']!,
        losses: s['losses']!,
        goalsFor: s['gf']!,
        goalsAgainst: s['ga']!,
      );
    }).toList();
    result.sort((a, b) {
      final points = b.points.compareTo(a.points);
      if (points != 0) return points;
      final gd = b.goalDifference.compareTo(a.goalDifference);
      if (gd != 0) return gd;
      return b.goalsFor.compareTo(a.goalsFor);
    });
    return result;
  }

  SuperLeagueCareer playNextMatch() {
    final playerFixture = nextFixture;
    if (playerFixture == null) return this;
    final random = Random();
    final updatedFixtures = fixtures.map((fixture) {
      if (fixture.round != playerFixture.round || fixture.isPlayed) return fixture;

      final homeClub = Clubs.getByName(fixture.homeTeam);
      final awayClub = Clubs.getByName(fixture.awayTeam);
      final difference = homeClub.strength - awayClub.strength;
      final homeGoals = _goalsFor(1.35 + difference * 0.035 + 0.18, random);
      final awayGoals = _goalsFor(1.10 - difference * 0.035, random);
      final playerInFixture = fixture.homeTeam == player.club || fixture.awayTeam == player.club;
      if (!playerInFixture) {
        return fixture.copyWith(homeGoals: homeGoals, awayGoals: awayGoals);
      }

      final playerClubGoals = fixture.homeTeam == player.club ? homeGoals : awayGoals;
      final played = random.nextDouble() < 0.96;
      var playerGoals = 0;
      var playerAssists = 0;
      var rating = 0.0;
      if (played) {
        final positionGoalChance = player.position == PlayerPosition.forward
            ? 0.48
            : player.position == PlayerPosition.midfielder
                ? 0.25
                : player.position == PlayerPosition.defender
                    ? 0.10
                    : 0.02;
        for (var i = 0; i < playerClubGoals; i++) {
          if (random.nextDouble() < positionGoalChance) {
            playerGoals++;
          } else if (random.nextDouble() < 0.58) {
            playerAssists++;
          }
        }
        playerAssists = min(playerAssists, playerClubGoals - playerGoals);
        rating = (6.2 + random.nextDouble() * 1.5 + playerGoals * 0.55 + playerAssists * 0.25)
            .clamp(5.5, 10.0).toDouble();
      }
      return fixture.copyWith(
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        playerGoals: playerGoals,
        playerAssists: playerAssists,
        playerRating: rating,
        playerPlayed: played,
      );
    }).toList();

    return SuperLeagueCareer(
      player: player.copyWith(season: season),
      season: season,
      fixtures: updatedFixtures,
    );
  }

  static int _goalsFor(double expected, Random random) {
    final chance = expected.clamp(0.25, 3.0);
    var goals = 0;
    var cumulative = exp(-chance);
    var threshold = random.nextDouble();
    while (threshold > cumulative && goals < 5) {
      goals++;
      cumulative += cumulative * chance / goals;
    }
    return goals;
  }

  SuperLeagueCareer nextSeason() {
    final nextPlayer = player.copyWith(age: player.age + 1, season: season + 1);
    return SuperLeagueCareer.newCareer(nextPlayer);
  }

  Map<String, dynamic> toJson() => {
    'player': player.toJson(),
    'season': season,
    'fixtures': fixtures.map((fixture) => fixture.toJson()).toList(),
  };

  factory SuperLeagueCareer.fromJson(Map<String, dynamic> json) {
    final rawFixtures = json['fixtures'];
    return SuperLeagueCareer(
      player: Player.fromJson(Map<String, dynamic>.from(json['player'] as Map)),
      season: (json['season'] as num?)?.toInt() ?? 1,
      fixtures: rawFixtures is List
          ? rawFixtures.map((item) => SuperLeagueFixture.fromJson(
              Map<String, dynamic>.from(item as Map),
            )).toList()
          : [],
    );
  }
}
