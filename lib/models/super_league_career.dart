import 'dart:math';

import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/models/super_league_division.dart';

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

class SuperLeagueSeasonSummary {
  final int season;
  final String club;
  final int matches;
  final int goals;
  final int assists;
  final double averageRating;
  final bool champion;

  const SuperLeagueSeasonSummary({
    required this.season,
    required this.club,
    required this.matches,
    required this.goals,
    required this.assists,
    required this.averageRating,
    required this.champion,
  });

  Map<String, dynamic> toJson() => {
    'season': season,
    'club': club,
    'matches': matches,
    'goals': goals,
    'assists': assists,
    'averageRating': averageRating,
    'champion': champion,
  };

  factory SuperLeagueSeasonSummary.fromJson(Map<String, dynamic> json) =>
      SuperLeagueSeasonSummary(
        season: (json['season'] as num?)?.toInt() ?? 1,
        club: json['club'] as String? ?? '',
        matches: (json['matches'] as num?)?.toInt() ?? 0,
        goals: (json['goals'] as num?)?.toInt() ?? 0,
        assists: (json['assists'] as num?)?.toInt() ?? 0,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
        champion: json['champion'] as bool? ?? false,
      );
}

class SuperLeagueCareer {
  final Player player;
  final int season;
  final List<SuperLeagueFixture> fixtures;
  final int developmentPoints;
  final int developmentPointsAwardedSeason;
  final List<int> championSeasons;
  final List<int> secondDivisionChampionSeasons;
  final List<SuperLeagueSeasonSummary> history;
  final List<String> firstDivision;
  final List<String> secondDivision;

  const SuperLeagueCareer({
    required this.player,
    required this.season,
    required this.fixtures,
    this.developmentPoints = 0,
    this.developmentPointsAwardedSeason = 0,
    this.championSeasons = const [],
    this.secondDivisionChampionSeasons = const [],
    this.history = const [],
    this.firstDivision = SuperLeagueDivisionConfig.firstDivisionClubs,
    this.secondDivision = SuperLeagueDivisionConfig.secondDivisionClubs,
  });

  /// Legacy alias kept for older screens; use [currentDivisionClubNames] for the active league.
  static const List<String> clubNames = SuperLeagueDivisionConfig.firstDivisionClubs;

  SuperLeagueDivision get playerDivision => secondDivision.contains(player.club)
      ? SuperLeagueDivision.second
      : SuperLeagueDivision.first;

  List<String> get currentDivisionClubNames =>
      playerDivision == SuperLeagueDivision.second ? secondDivision : firstDivision;

  factory SuperLeagueCareer.newCareer(
    Player player, {
    List<String> firstDivisionClubs = SuperLeagueDivisionConfig.firstDivisionClubs,
    List<String> secondDivisionClubs = SuperLeagueDivisionConfig.secondDivisionClubs,
  }) {
    List<SuperLeagueFixture> buildCalendar(List<String> clubNames) {
      final teams = List<String>.from(clubNames);
      final firstLeg = <SuperLeagueFixture>[];
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
      return <SuperLeagueFixture>[
        ...firstLeg,
        ...firstLeg.map((fixture) => SuperLeagueFixture(
          round: fixture.round + clubNames.length - 1,
          homeTeam: fixture.awayTeam,
          awayTeam: fixture.homeTeam,
        )),
      ];
    }

    final fixtures = <SuperLeagueFixture>[
      ...buildCalendar(firstDivisionClubs),
      ...buildCalendar(secondDivisionClubs),
    ];
    return SuperLeagueCareer(
      player: player,
      season: 1,
      fixtures: fixtures,
      developmentPoints: 0,
      firstDivision: List<String>.from(firstDivisionClubs),
      secondDivision: List<String>.from(secondDivisionClubs),
    );
  }

  int get playedMatches => fixtures.where((fixture) => fixture.isPlayed && (fixture.homeTeam == player.club || fixture.awayTeam == player.club)).length;
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

  List<SuperLeagueStanding> get standings => standingsFor(playerDivision);

  List<SuperLeagueStanding> standingsFor(SuperLeagueDivision division) {
    final divisionClubs = division == SuperLeagueDivision.first
        ? firstDivision
        : secondDivision;
    final clubSet = divisionClubs.toSet();
    final stats = {
      for (final club in divisionClubs)
        club: <String, int>{
          'played': 0, 'wins': 0, 'draws': 0, 'losses': 0,
          'gf': 0, 'ga': 0,
        },
    };
    for (final fixture in fixtures.where((f) =>
        f.isPlayed && clubSet.contains(f.homeTeam) && clubSet.contains(f.awayTeam))) {
      final home = stats[fixture.homeTeam];
      final away = stats[fixture.awayTeam];
      if (home == null || away == null) continue;
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

  SuperLeagueCareer copyWith({
    Player? player,
    int? season,
    List<SuperLeagueFixture>? fixtures,
    int? developmentPoints,
    int? developmentPointsAwardedSeason,
    List<int>? championSeasons,
    List<int>? secondDivisionChampionSeasons,
    List<SuperLeagueSeasonSummary>? history,
    List<String>? firstDivision,
    List<String>? secondDivision,
  }) => SuperLeagueCareer(
    player: player ?? this.player,
    season: season ?? this.season,
    fixtures: fixtures ?? this.fixtures,
    developmentPoints: developmentPoints ?? this.developmentPoints,
    developmentPointsAwardedSeason: developmentPointsAwardedSeason ?? this.developmentPointsAwardedSeason,
    championSeasons: championSeasons ?? this.championSeasons,
    secondDivisionChampionSeasons: secondDivisionChampionSeasons ?? this.secondDivisionChampionSeasons,
    history: history ?? this.history,
    firstDivision: firstDivision ?? this.firstDivision,
    secondDivision: secondDivision ?? this.secondDivision,
  );

  int get developmentPointsForSeason {
    if (playedMatches < 5) return 2;
    if (playedMatches >= 30) return 8;
    if (playedMatches >= 20) return 6;
    return 4;
  }

  SuperLeagueCareer playNextMatch() {
    final playerFixture = nextFixture;
    if (playerFixture == null) return this;
    final random = Random();
    final updatedFixtures = fixtures.map((fixture) {
      if (fixture.round != playerFixture.round || fixture.isPlayed) return fixture;

      final playerInFixture = fixture.homeTeam == player.club || fixture.awayTeam == player.club;
      if (playerInFixture) {
        final isHome = fixture.homeTeam == player.club;
        final opponent = isHome ? fixture.awayTeam : fixture.homeTeam;
        final match = Match.generate(player: player, opponent: opponent, isHome: isHome);
        return fixture.copyWith(
          homeGoals: match.homeGoals,
          awayGoals: match.awayGoals,
          playerGoals: match.playerGoals,
          playerAssists: match.playerAssists,
          playerRating: match.playerRating,
          playerPlayed: match.playerPlayed,
        );
      }

      final homeClub = Clubs.getByName(fixture.homeTeam);
      final awayClub = Clubs.getByName(fixture.awayTeam);
      final difference = homeClub.strength - awayClub.strength;
      final homeGoals = _goalsFor(1.35 + difference * 0.035 + 0.18, random);
      final awayGoals = _goalsFor(1.10 - difference * 0.035, random);
      return fixture.copyWith(homeGoals: homeGoals, awayGoals: awayGoals);
    }).toList();

    return SuperLeagueCareer(
      player: player.copyWith(season: season),
      season: season,
      fixtures: updatedFixtures,
      developmentPoints: developmentPoints,
      developmentPointsAwardedSeason: developmentPointsAwardedSeason,
      championSeasons: championSeasons,
      secondDivisionChampionSeasons: secondDivisionChampionSeasons,
      history: history,
      firstDivision: firstDivision,
      secondDivision: secondDivision,
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

  SuperLeagueCareer completeRemainingFixtures() {
    final random = Random();
    final completedFixtures = fixtures.map((fixture) {
      if (fixture.isPlayed) return fixture;
      final isPlayerFixture = fixture.homeTeam == player.club ||
          fixture.awayTeam == player.club;
      if (isPlayerFixture) {
        final isHome = fixture.homeTeam == player.club;
        final opponent = isHome ? fixture.awayTeam : fixture.homeTeam;
        final match = Match.generate(
          player: player,
          opponent: opponent,
          isHome: isHome,
        );
        return fixture.copyWith(
          homeGoals: match.homeGoals,
          awayGoals: match.awayGoals,
          playerGoals: match.playerGoals,
          playerAssists: match.playerAssists,
          playerRating: match.playerRating,
          playerPlayed: match.playerPlayed,
        );
      }
      final homeClub = Clubs.getByName(fixture.homeTeam);
      final awayClub = Clubs.getByName(fixture.awayTeam);
      final difference = homeClub.strength - awayClub.strength;
      return fixture.copyWith(
        homeGoals: _goalsFor(1.35 + difference * 0.035 + 0.18, random),
        awayGoals: _goalsFor(1.10 - difference * 0.035, random),
      );
    }).toList();
    return copyWith(fixtures: completedFixtures);
  }

  SuperLeagueCareer nextSeason({String? newClub}) {
    final nextSeasonNumber = season + 1;
    final nextPlayer = player.copyWith(
      age: player.age + 1,
      season: nextSeasonNumber,
      club: newClub ?? player.club,
    );

    // Complete the remaining second-division rounds before calculating promotions.
    final completedSeason = completeRemainingFixtures();
    final firstStandings = completedSeason.standingsFor(SuperLeagueDivision.first);
    final secondStandings = completedSeason.standingsFor(SuperLeagueDivision.second);
    final relegated = firstStandings.skip(15).take(5).map((entry) => entry.club).toList();
    final promoted = secondStandings.take(5).map((entry) => entry.club).toList();
    final nextFirst = <String>[
      ...firstDivision.where((club) => !relegated.contains(club)),
      ...promoted,
    ];
    final nextSecond = <String>[
      ...secondDivision.where((club) => !promoted.contains(club)),
      ...relegated,
    ];
    final freshSeason = SuperLeagueCareer.newCareer(
      nextPlayer,
      firstDivisionClubs: nextFirst,
      secondDivisionClubs: nextSecond,
    );
    return SuperLeagueCareer(
      player: nextPlayer,
      season: nextSeasonNumber,
      fixtures: freshSeason.fixtures,
      developmentPoints: developmentPoints,
      developmentPointsAwardedSeason: developmentPointsAwardedSeason,
      championSeasons: championSeasons,
      secondDivisionChampionSeasons: secondDivisionChampionSeasons,
      history: history,
      firstDivision: nextFirst,
      secondDivision: nextSecond,
    );
  }

  Map<String, dynamic> toJson() => {
    'player': player.toJson(),
    'season': season,
    'fixtures': fixtures.map((fixture) => fixture.toJson()).toList(),
    'developmentPoints': developmentPoints,
    'developmentPointsAwardedSeason': developmentPointsAwardedSeason,
    'championSeasons': championSeasons,
    'secondDivisionChampionSeasons': secondDivisionChampionSeasons,
    'history': history.map((item) => item.toJson()).toList(),
    'firstDivision': firstDivision,
    'secondDivision': secondDivision,
  };

  factory SuperLeagueCareer.fromJson(Map<String, dynamic> json) {
    final player = Player.fromJson(
      Map<String, dynamic>.from(json['player'] as Map),
    );
    final firstDivision = (json['firstDivision'] as List?)
            ?.map((value) => value as String)
            .toList() ??
        SuperLeagueDivisionConfig.firstDivisionClubs;
    final secondDivision = (json['secondDivision'] as List?)
            ?.map((value) => value as String)
            .toList() ??
        SuperLeagueDivisionConfig.secondDivisionClubs;
    final rawFixtures = json['fixtures'];
    final fixtures = rawFixtures is List
        ? rawFixtures
            .map((item) => SuperLeagueFixture.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList()
        : <SuperLeagueFixture>[];

    // Migrate old saves that only stored the original 20-club calendar.
    final hasSecondDivisionFixtures = fixtures.any((fixture) =>
        secondDivision.contains(fixture.homeTeam) &&
        secondDivision.contains(fixture.awayTeam));
    if (!hasSecondDivisionFixtures && json['secondDivision'] == null) {
      final generated = SuperLeagueCareer.newCareer(
        player,
        firstDivisionClubs: firstDivision,
        secondDivisionClubs: secondDivision,
      ).fixtures.where((fixture) =>
          secondDivision.contains(fixture.homeTeam) &&
          secondDivision.contains(fixture.awayTeam));
      fixtures.addAll(generated);
    }

    return SuperLeagueCareer(
      player: player,
      season: (json['season'] as num?)?.toInt() ?? 1,
      fixtures: fixtures,
      developmentPoints: (json['developmentPoints'] as num?)?.toInt() ?? 0,
      developmentPointsAwardedSeason:
          (json['developmentPointsAwardedSeason'] as num?)?.toInt() ?? 0,
      championSeasons: (json['championSeasons'] as List?)
              ?.map((value) => (value as num).toInt())
              .toList() ??
          const [],
      secondDivisionChampionSeasons: (json['secondDivisionChampionSeasons'] as List?)
              ?.map((value) => (value as num).toInt())
              .toList() ??
          const [],
      history: (json['history'] as List?)
              ?.map((item) => SuperLeagueSeasonSummary.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const [],
      firstDivision: firstDivision,
      secondDivision: secondDivision,
    );
  }
}
