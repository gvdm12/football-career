import 'dart:math';

const List<String> worldCupNationalTeams = [
  'Россия',
  'Бразилия',
  'Германия',
  'Франция',
  'Испания',
  'Англия',
  'Италия',
  'Португалия',
  'Нидерланды',
  'Бельгия',
  'Дания',
  'Аргентина',
  'Хорватия',
  'Швейцария',
  'Австрия',
  'Норвегия',
  'Польша',
  'Турция',
  'Украина',
  'Греция',
  'Шотландия',
  'Ирландия',
  'Колумбия',
  'Чили',
  'Уругвай',
  'Канада',
  'Мексика',
  'США',
  'Иран',
  'Южная Корея',
  'Япония',
  'Катар',
  'Саудовская Аравия',
  'Алжир',
  'Марокко',
  'Камерун',
  'Нигерия',
  'Сенегал',
  'Египет',
  'Тунис',
  'Швеция',
  'Венесуэла',
  'Палестина',
  'Венгрия',
  'Босния',
  'Албания',
  'Австралия',
];

/// Силы сборных для симуляции чемпионата мира.
/// Значения — игровые рейтинги, а не официальные рейтинги FIFA.
const Map<String, int> worldCupTeamStrength = {
  'Бразилия': 87,
  'Франция': 88,
  'Аргентина': 86,
  'Испания': 89,
  'Англия': 88,
  'Германия': 86,
  'Португалия': 86,
  'Нидерланды': 85,
  'Италия': 84,
  'Бельгия': 84,
  'Хорватия': 83,
  'Уругвай': 83,
  'Колумбия': 82,
  'Дания': 81,
  'Марокко': 85,
  'Швейцария': 82,
  'Мексика': 81,
  'Сенегал': 80,
  'США': 79,
  'Япония': 80,
  'Турция': 80,
  'Норвегия': 82,
  'Польша': 78,
  'Украина': 78,
  'Австрия': 79,
  'Нигерия': 78,
  'Россия': 75,
  'Алжир': 77,
  'Египет': 78,
  'Южная Корея': 79,
  'Иран': 76,
  'Чили': 76,
  'Канада': 79,
  'Камерун': 78,
  'Греция': 75,
  'Шотландия': 78,
  'Тунис': 74,
  'Ирландия': 77,
  'Саудовская Аравия': 74,
  'Катар': 73,
  'Швеция': 80,
  'Венесуэла': 77,
  'Палестина': 70,
  'Венгрия': 78,
  'Босния': 77,
  'Албания': 76,
  'Австралия': 78,
};

int worldCupStrengthOf(String team) => worldCupTeamStrength[team] ?? 70;

enum WorldCupStage {
  roundOf32,
  roundOf16,
  quarterFinal,
  semiFinal,
  finalMatch,
  completed,
}

extension WorldCupStageInfo on WorldCupStage {
  String get title {
    switch (this) {
      case WorldCupStage.roundOf32:
        return '1/16 финала';
      case WorldCupStage.roundOf16:
        return '1/8 финала';
      case WorldCupStage.quarterFinal:
        return 'Четвертьфинал';
      case WorldCupStage.semiFinal:
        return 'Полуфинал';
      case WorldCupStage.finalMatch:
        return 'Финал';
      case WorldCupStage.completed:
        return 'Турнир завершён';
    }
  }
}

class WorldCupMatch {
  final String homeTeam;
  final String awayTeam;
  final int? homeGoals;
  final int? awayGoals;
  final bool isPlayed;
  final String? winner;
  final int playerGoals;
  final int playerAssists;
  final double? playerRating;

  const WorldCupMatch({
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals,
    this.awayGoals,
    this.isPlayed = false,
    this.winner,
    this.playerGoals = 0,
    this.playerAssists = 0,
    this.playerRating,
  });

  WorldCupMatch play({
    int? homeScore,
    int? awayScore,
    String? playerTeam,
    int playerOverall = 70,
    String playerPosition = 'forward',
    int playerShooting = 60,
    int playerPassing = 60,
    int playerDribbling = 60,
  }) {
    final random = Random();
    var homeStrength = worldCupStrengthOf(homeTeam).toDouble();
    var awayStrength = worldCupStrengthOf(awayTeam).toDouble();

    // Игрок высокого уровня усиливает сборную, а слабый состав не получает
    // искусственный бонус. Максимальный бонус ограничен, чтобы один игрок
    // не гарантировал победу.
    final playerBoost = ((playerOverall - 70) * 0.12)
        .clamp(0.0, 3.5)
        .toDouble();
    if (playerTeam == homeTeam) homeStrength += playerBoost;
    if (playerTeam == awayTeam) awayStrength += playerBoost;
    final strengthDifference = homeStrength - awayStrength;

    // Сила влияет на среднее число голов, но не гарантирует победу.
    final homeExpectedGoals = (1.30 + strengthDifference * 0.035 + 0.12)
        .clamp(0.30, 2.65)
        .toDouble();
    final awayExpectedGoals = (1.30 - strengthDifference * 0.035)
        .clamp(0.30, 2.65)
        .toDouble();

    var home = homeScore ?? _randomGoals(homeExpectedGoals, random);
    var away = awayScore ?? _randomGoals(awayExpectedGoals, random);

    // В плей-офф ничья решается в дополнительное время/серии пенальти.
    if (home == away) {
      if (random.nextBool()) {
        home++;
      } else {
        away++;
      }
    }

    var scoredByPlayer = 0;
    var assistedByPlayer = 0;
    double? rating;

    if (playerTeam == homeTeam || playerTeam == awayTeam) {
      final playerTeamGoals = playerTeam == homeTeam ? home : away;
      final positionGoalFactor = switch (playerPosition) {
        'forward' => 0.30,
        'midfielder' => 0.16,
        'defender' => 0.055,
        'goalkeeper' => 0.005,
        _ => 0.15,
      };
      final goalChance =
          (positionGoalFactor +
                  (playerOverall - 70) * 0.006 +
                  (playerShooting - 60) * 0.003 +
                  (playerDribbling - 60) * 0.001)
              .clamp(0.02, 0.65);
      for (var i = 0; i < playerTeamGoals; i++) {
        if (random.nextDouble() < goalChance) scoredByPlayer++;
      }
      final assistChance = (0.10 + (playerPassing - 50) * 0.004).clamp(
        0.04,
        0.40,
      );
      for (var i = 0; i < playerTeamGoals - scoredByPlayer; i++) {
        if (random.nextDouble() < assistChance) assistedByPlayer++;
      }
      rating =
          (6.0 +
                  (playerOverall - 70) * 0.035 +
                  (playerTeamGoals - (playerTeam == homeTeam ? away : home)) *
                      0.35 +
                  scoredByPlayer * 0.65 +
                  assistedByPlayer * 0.35 +
                  (random.nextDouble() * 0.8 - 0.4))
              .clamp(4.5, 10.0)
              .toDouble();
      rating = double.parse(rating.toStringAsFixed(1));
    }

    return WorldCupMatch(
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeGoals: home,
      awayGoals: away,
      isPlayed: true,
      winner: home > away ? homeTeam : awayTeam,
      playerGoals: scoredByPlayer,
      playerAssists: assistedByPlayer,
      playerRating: rating,
    );
  }

  static int _randomGoals(double expectedGoals, Random random) {
    // Приближение распределения Пуассона.
    final limit = exp(-expectedGoals);
    var product = 1.0;
    var goals = 0;
    do {
      goals++;
      product *= random.nextDouble();
    } while (product > limit && goals < 8);
    return goals - 1;
  }

  Map<String, dynamic> toJson() => {
    'homeTeam': homeTeam,
    'awayTeam': awayTeam,
    'homeGoals': homeGoals,
    'awayGoals': awayGoals,
    'isPlayed': isPlayed,
    'winner': winner,
    'playerGoals': playerGoals,
    'playerAssists': playerAssists,
    'playerRating': playerRating,
  };

  factory WorldCupMatch.fromJson(Map<String, dynamic> json) => WorldCupMatch(
    homeTeam: json['homeTeam'] as String? ?? '',
    awayTeam: json['awayTeam'] as String? ?? '',
    homeGoals: (json['homeGoals'] as num?)?.toInt(),
    awayGoals: (json['awayGoals'] as num?)?.toInt(),
    isPlayed: json['isPlayed'] as bool? ?? false,
    winner: json['winner'] as String?,
    playerGoals: (json['playerGoals'] as num?)?.toInt() ?? 0,
    playerAssists: (json['playerAssists'] as num?)?.toInt() ?? 0,
    playerRating: (json['playerRating'] as num?)?.toDouble(),
  );
}

class WorldCup {
  final int season;
  final List<String> participants;
  final List<WorldCupMatch> matches;
  final WorldCupStage stage;
  final String? champion;
  final String playerCallUpStatus;
  final int playerMatches;
  final int playerGoals;
  final int playerAssists;
  final double? playerAverageRating;

  const WorldCup({
    required this.season,
    required this.participants,
    required this.matches,
    required this.stage,
    this.champion,
    required this.playerCallUpStatus,
    this.playerMatches = 0,
    this.playerGoals = 0,
    this.playerAssists = 0,
    this.playerAverageRating,
  });

  bool get isPlayerCalledUp => playerCallUpStatus == 'called';
  bool get isCompleted => stage == WorldCupStage.completed;

  static WorldCup create({
    required int season,
    required String nationality,
    required int overall,
    required int age,
    required int goals,
    required int assists,
    required double? averageRating,
  }) {
    final random = Random();
    final teams = [...worldCupNationalTeams]..shuffle(random);
    final participants = teams.take(32).toList()..sort();

    final formScore =
        (goals + assists) * 0.35 +
        (averageRating ?? 6.0) * 1.5 +
        overall * 0.35 +
        (age <= 21 ? 2 : 0);
    final callUpChance = ((formScore - 31) / 25).clamp(0.03, 0.95);
    final eligible = participants.contains(nationality);
    final called = eligible && random.nextDouble() < callUpChance;

    final status = !eligible
        ? 'country_not_qualified'
        : called
        ? 'called'
        : random.nextDouble() < 0.35
        ? 'reserve'
        : 'not_called';

    final shuffled = [...participants]..shuffle(random);
    final matches = <WorldCupMatch>[];
    for (var i = 0; i < shuffled.length; i += 2) {
      matches.add(
        WorldCupMatch(homeTeam: shuffled[i], awayTeam: shuffled[i + 1]),
      );
    }

    return WorldCup(
      season: season,
      participants: participants,
      matches: matches,
      stage: WorldCupStage.roundOf32,
      playerCallUpStatus: status,
    );
  }

  WorldCup playMatch(int index, {int? homeGoals, int? awayGoals}) {
    if (isCompleted || index < 0 || index >= matches.length) return this;
    final updated = [...matches];
    final match = updated[index];
    if (match.isPlayed) return this;
    updated[index] = match.play(homeScore: homeGoals, awayScore: awayGoals);
    final updatedCup = copyWith(matches: updated);
    return updatedCup.matches.every((item) => item.isPlayed)
        ? updatedCup._advanceRound()
        : updatedCup;
  }

  WorldCup _advanceRound() {
    if (!matches.every((match) => match.isPlayed)) return this;
    if (stage == WorldCupStage.finalMatch) {
      return copyWith(
        stage: WorldCupStage.completed,
        champion: matches.isEmpty ? null : matches.first.winner,
      );
    }

    final winners = matches.map((match) => match.winner!).toList();
    final nextMatches = <WorldCupMatch>[];
    for (var i = 0; i < winners.length; i += 2) {
      nextMatches.add(
        WorldCupMatch(homeTeam: winners[i], awayTeam: winners[i + 1]),
      );
    }

    final nextStage = switch (stage) {
      WorldCupStage.roundOf32 => WorldCupStage.roundOf16,
      WorldCupStage.roundOf16 => WorldCupStage.quarterFinal,
      WorldCupStage.quarterFinal => WorldCupStage.semiFinal,
      WorldCupStage.semiFinal => WorldCupStage.finalMatch,
      WorldCupStage.finalMatch || WorldCupStage.completed => stage,
    };
    return copyWith(matches: nextMatches, stage: nextStage);
  }

  WorldCup playCurrentRound({
    String? playerTeam,
    int playerOverall = 70,
    String playerPosition = 'forward',
    int playerShooting = 60,
    int playerPassing = 60,
    int playerDribbling = 60,
  }) {
    if (isCompleted) return this;
    var roundPlayerMatches = 0;
    var roundGoals = 0;
    var roundAssists = 0;
    var ratingTotal = 0.0;
    final currentRound = matches.map((match) {
      if (match.isPlayed) return match;
      final hasPlayer =
          playerTeam != null &&
          (match.homeTeam == playerTeam || match.awayTeam == playerTeam);
      final played = match.play(
        playerTeam: hasPlayer ? playerTeam : null,
        playerOverall: playerOverall,
        playerPosition: playerPosition,
        playerShooting: playerShooting,
        playerPassing: playerPassing,
        playerDribbling: playerDribbling,
      );
      if (hasPlayer && played.playerRating != null) {
        roundPlayerMatches++;
        roundGoals += played.playerGoals;
        roundAssists += played.playerAssists;
        ratingTotal += played.playerRating!;
      }
      return played;
    }).toList();

    final newPlayerMatches = playerMatches + roundPlayerMatches;
    final newPlayerGoals = playerGoals + roundGoals;
    final newPlayerAssists = playerAssists + roundAssists;
    final newAverage = roundPlayerMatches == 0
        ? playerAverageRating
        : playerAverageRating == null
        ? ratingTotal / roundPlayerMatches
        : ((playerAverageRating! * playerMatches) + ratingTotal) /
              newPlayerMatches;
    final updated = copyWith(
      matches: currentRound,
      playerMatches: newPlayerMatches,
      playerGoals: newPlayerGoals,
      playerAssists: newPlayerAssists,
      playerAverageRating: newAverage == null
          ? null
          : double.parse(newAverage.toStringAsFixed(2)),
    );
    return updated._advanceRound();
  }

  WorldCup simulateRemainingMatches() {
    var tournament = this;
    while (!tournament.isCompleted) {
      final playedMatches = tournament.matches
          .map((match) => match.isPlayed ? match : match.play())
          .toList();
      tournament = tournament.copyWith(matches: playedMatches)._advanceRound();
    }
    return tournament;
  }

  WorldCup copyWith({
    List<String>? participants,
    List<WorldCupMatch>? matches,
    WorldCupStage? stage,
    String? champion,
    String? playerCallUpStatus,
    int? playerMatches,
    int? playerGoals,
    int? playerAssists,
    double? playerAverageRating,
  }) => WorldCup(
    season: season,
    participants: participants ?? this.participants,
    matches: matches ?? this.matches,
    stage: stage ?? this.stage,
    champion: champion ?? this.champion,
    playerCallUpStatus: playerCallUpStatus ?? this.playerCallUpStatus,
    playerMatches: playerMatches ?? this.playerMatches,
    playerGoals: playerGoals ?? this.playerGoals,
    playerAssists: playerAssists ?? this.playerAssists,
    playerAverageRating: playerAverageRating ?? this.playerAverageRating,
  );

  Map<String, dynamic> toJson() => {
    'season': season,
    'participants': participants,
    'matches': matches.map((match) => match.toJson()).toList(),
    'stage': stage.name,
    'champion': champion,
    'playerCallUpStatus': playerCallUpStatus,
    'playerMatches': playerMatches,
    'playerGoals': playerGoals,
    'playerAssists': playerAssists,
    'playerAverageRating': playerAverageRating,
  };

  factory WorldCup.fromJson(Map<String, dynamic> json) {
    final rawMatches = json['matches'];
    final rawParticipants = json['participants'];
    final stageName = json['stage'] as String? ?? 'roundOf32';
    return WorldCup(
      season: (json['season'] as num?)?.toInt() ?? 4,
      participants: rawParticipants is List
          ? rawParticipants.whereType<String>().toList()
          : const [],
      matches: rawMatches is List
          ? rawMatches
                .whereType<Map>()
                .map(
                  (item) =>
                      WorldCupMatch.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
      stage: WorldCupStage.values.firstWhere(
        (value) => value.name == stageName,
        orElse: () => WorldCupStage.roundOf32,
      ),
      champion: json['champion'] as String?,
      playerCallUpStatus: json['playerCallUpStatus'] as String? ?? 'not_called',
      playerMatches: (json['playerMatches'] as num?)?.toInt() ?? 0,
      playerGoals: (json['playerGoals'] as num?)?.toInt() ?? 0,
      playerAssists: (json['playerAssists'] as num?)?.toInt() ?? 0,
      playerAverageRating: (json['playerAverageRating'] as num?)?.toDouble(),
    );
  }
}
