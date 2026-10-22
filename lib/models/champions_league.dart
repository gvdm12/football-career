import 'dart:math';

enum ChampionsLeagueStage {
  roundOf32,
  roundOf16,
  quarterFinal,
  semiFinal,
  finalMatch,
  completed,
}

extension ChampionsLeagueStageInfo on ChampionsLeagueStage {
  String get title {
    switch (this) {
      case ChampionsLeagueStage.roundOf32:
        return '1/16 финала';
      case ChampionsLeagueStage.roundOf16:
        return '1/8 финала';
      case ChampionsLeagueStage.quarterFinal:
        return '1/4 финала';
      case ChampionsLeagueStage.semiFinal:
        return '1/2 финала';
      case ChampionsLeagueStage.finalMatch:
        return 'Финал';
      case ChampionsLeagueStage.completed:
        return 'Завершён';
    }
  }

  int get teamCount {
    switch (this) {
      case ChampionsLeagueStage.roundOf32:
        return 32;
      case ChampionsLeagueStage.roundOf16:
        return 16;
      case ChampionsLeagueStage.quarterFinal:
        return 8;
      case ChampionsLeagueStage.semiFinal:
        return 4;
      case ChampionsLeagueStage.finalMatch:
        return 2;
      case ChampionsLeagueStage.completed:
        return 0;
    }
  }

  ChampionsLeagueStage get next {
    switch (this) {
      case ChampionsLeagueStage.roundOf32:
        return ChampionsLeagueStage.roundOf16;
      case ChampionsLeagueStage.roundOf16:
        return ChampionsLeagueStage.quarterFinal;
      case ChampionsLeagueStage.quarterFinal:
        return ChampionsLeagueStage.semiFinal;
      case ChampionsLeagueStage.semiFinal:
        return ChampionsLeagueStage.finalMatch;
      case ChampionsLeagueStage.finalMatch:
      case ChampionsLeagueStage.completed:
        return ChampionsLeagueStage.completed;
    }
  }

  bool get isTwoLegged =>
      this != ChampionsLeagueStage.finalMatch &&
      this != ChampionsLeagueStage.completed;
}

/// Результат отдельного матча Лиги чемпионов.
class ChampionsLeagueMatchHistory {
  final ChampionsLeagueStage stage;
  final int leg;
  final String homeTeam;
  final String awayTeam;
  final int homeGoals;
  final int awayGoals;
  final int? homePenalties;
  final int? awayPenalties;
  final String? winner;

  const ChampionsLeagueMatchHistory({
    required this.stage,
    required this.leg,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeGoals,
    required this.awayGoals,
    this.homePenalties,
    this.awayPenalties,
    this.winner,
  });

  Map<String, dynamic> toJson() => {
    'stage': stage.name,
    'leg': leg,
    'homeTeam': homeTeam,
    'awayTeam': awayTeam,
    'homeGoals': homeGoals,
    'awayGoals': awayGoals,
    'homePenalties': homePenalties,
    'awayPenalties': awayPenalties,
    'winner': winner,
  };

  factory ChampionsLeagueMatchHistory.fromJson(Map<String, dynamic> json) {
    final stageName = json['stage'] as String?;

    return ChampionsLeagueMatchHistory(
      stage: ChampionsLeagueStage.values.firstWhere(
        (value) => value.name == stageName,
        orElse: () => ChampionsLeagueStage.roundOf32,
      ),
      leg: (json['leg'] as num?)?.toInt() ?? 1,
      homeTeam: json['homeTeam'] as String? ?? '',
      awayTeam: json['awayTeam'] as String? ?? '',
      homeGoals: (json['homeGoals'] as num?)?.toInt() ?? 0,
      awayGoals: (json['awayGoals'] as num?)?.toInt() ?? 0,
      homePenalties: (json['homePenalties'] as num?)?.toInt(),
      awayPenalties: (json['awayPenalties'] as num?)?.toInt(),
      winner: json['winner'] as String?,
    );
  }
}

class ChampionsLeagueTie {
  final String homeTeam;
  final String awayTeam;

  final int? firstLegHomeGoals;
  final int? firstLegAwayGoals;
  final int? secondLegHomeGoals;
  final int? secondLegAwayGoals;

  final int? finalHomeGoals;
  final int? finalAwayGoals;

  final String? winner;

  /// true, если победитель определился по пенальти.
  final bool decidedByPenalties;

  const ChampionsLeagueTie({
    required this.homeTeam,
    required this.awayTeam,
    this.firstLegHomeGoals,
    this.firstLegAwayGoals,
    this.secondLegHomeGoals,
    this.secondLegAwayGoals,
    this.finalHomeGoals,
    this.finalAwayGoals,
    this.winner,
    this.decidedByPenalties = false,
  });

  bool get isFirstLegPlayed =>
      firstLegHomeGoals != null && firstLegAwayGoals != null;

  bool get isSecondLegPlayed =>
      secondLegHomeGoals != null && secondLegAwayGoals != null;

  bool get isFinalPlayed => finalHomeGoals != null && finalAwayGoals != null;

  bool get isCompleted => winner != null;

  ChampionsLeagueTie copyWith({
    int? firstLegHomeGoals,
    int? firstLegAwayGoals,
    int? secondLegHomeGoals,
    int? secondLegAwayGoals,
    int? finalHomeGoals,
    int? finalAwayGoals,
    String? winner,
    bool? decidedByPenalties,
  }) {
    return ChampionsLeagueTie(
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      firstLegHomeGoals: firstLegHomeGoals ?? this.firstLegHomeGoals,
      firstLegAwayGoals: firstLegAwayGoals ?? this.firstLegAwayGoals,
      secondLegHomeGoals: secondLegHomeGoals ?? this.secondLegHomeGoals,
      secondLegAwayGoals: secondLegAwayGoals ?? this.secondLegAwayGoals,
      finalHomeGoals: finalHomeGoals ?? this.finalHomeGoals,
      finalAwayGoals: finalAwayGoals ?? this.finalAwayGoals,
      winner: winner ?? this.winner,
      decidedByPenalties: decidedByPenalties ?? this.decidedByPenalties,
    );
  }

  Map<String, dynamic> toJson() => {
    'homeTeam': homeTeam,
    'awayTeam': awayTeam,
    'firstLegHomeGoals': firstLegHomeGoals,
    'firstLegAwayGoals': firstLegAwayGoals,
    'secondLegHomeGoals': secondLegHomeGoals,
    'secondLegAwayGoals': secondLegAwayGoals,
    'finalHomeGoals': finalHomeGoals,
    'finalAwayGoals': finalAwayGoals,
    'winner': winner,
    'decidedByPenalties': decidedByPenalties,
  };

  factory ChampionsLeagueTie.fromJson(Map<String, dynamic> json) {
    int? readInt(String key) {
      final value = json[key];
      return value is num ? value.toInt() : null;
    }

    return ChampionsLeagueTie(
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      firstLegHomeGoals: readInt('firstLegHomeGoals'),
      firstLegAwayGoals: readInt('firstLegAwayGoals'),
      secondLegHomeGoals: readInt('secondLegHomeGoals'),
      secondLegAwayGoals: readInt('secondLegAwayGoals'),
      finalHomeGoals: readInt('finalHomeGoals'),
      finalAwayGoals: readInt('finalAwayGoals'),
      winner: json['winner'] as String?,
      decidedByPenalties: json['decidedByPenalties'] as bool? ?? false,
    );
  }
}

class ChampionsLeague {
  final int season;
  final List<String> participants;
  final ChampionsLeagueStage stage;
  final List<ChampionsLeagueTie> ties;
  final String? champion;

  /// История всех сыгранных матчей турнира за текущий сезон.
  final List<ChampionsLeagueMatchHistory> matchHistory;

  const ChampionsLeague({
    required this.season,
    required this.participants,
    required this.stage,
    required this.ties,
    this.champion,
    this.matchHistory = const [],
  });

  factory ChampionsLeague.create({
    required int season,
    required List<String> participants,
  }) {
    if (participants.length != 32 || participants.toSet().length != 32) {
      throw ArgumentError('Для Лиги чемпионов нужны 32 уникальных клуба.');
    }

    final shuffled = List<String>.from(participants)..shuffle(Random(season));

    final ties = <ChampionsLeagueTie>[];

    for (var i = 0; i < shuffled.length; i += 2) {
      ties.add(
        ChampionsLeagueTie(homeTeam: shuffled[i], awayTeam: shuffled[i + 1]),
      );
    }

    return ChampionsLeague(
      season: season,
      participants: List.unmodifiable(participants),
      stage: ChampionsLeagueStage.roundOf32,
      ties: List.unmodifiable(ties),
    );
  }

  Map<String, dynamic> toJson() => {
    'season': season,
    'participants': participants,
    'stage': stage.name,
    'ties': ties.map((tie) => tie.toJson()).toList(),
    'champion': champion,
    'matchHistory': matchHistory.map((match) => match.toJson()).toList(),
  };

  factory ChampionsLeague.fromJson(Map<String, dynamic> json) {
    final stageName = json['stage'] as String?;

    final stage = ChampionsLeagueStage.values.firstWhere(
      (value) => value.name == stageName,
      orElse: () => ChampionsLeagueStage.roundOf32,
    );

    return ChampionsLeague(
      season: (json['season'] as num?)?.toInt() ?? 1,
      participants: (json['participants'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      stage: stage,
      ties: (json['ties'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (tie) =>
                ChampionsLeagueTie.fromJson(Map<String, dynamic>.from(tie)),
          )
          .toList(),
      champion: json['champion'] as String?,
      matchHistory: (json['matchHistory'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (match) => ChampionsLeagueMatchHistory.fromJson(
              Map<String, dynamic>.from(match),
            ),
          )
          .toList(),
    );
  }

  (int, int) _generatePenaltyScore(Random random) {
    final home = 3 + random.nextInt(3);
    var away = 3 + random.nextInt(3);

    while (away == home) {
      away = 3 + random.nextInt(3);
    }

    return (home, away);
  }

  ChampionsLeague playFinal({
    required int homeGoals,
    required int awayGoals,
    int? homePenalties,
    int? awayPenalties,
  }) {
    if (stage != ChampionsLeagueStage.finalMatch) {
      throw StateError('Сейчас не стадия финала.');
    }

    if (ties.isEmpty) {
      throw StateError('Финал не создан.');
    }

    if (homeGoals < 0 || awayGoals < 0) {
      throw ArgumentError('Количество голов не может быть отрицательным.');
    }

    final finalTie = ties.first;

    if (finalTie.isFinalPlayed) {
      throw StateError('Финал уже сыгран.');
    }

    final decidedByPenalties = homeGoals == awayGoals;

    final random = Random(season * 1000 + homeGoals * 10 + awayGoals);

    String winner;

    if (homeGoals > awayGoals) {
      winner = finalTie.homeTeam;
    } else if (awayGoals > homeGoals) {
      winner = finalTie.awayTeam;
    } else {
      if (homePenalties == null || awayPenalties == null) {
        final penaltyScore = _generatePenaltyScore(random);
        homePenalties = penaltyScore.$1;
        awayPenalties = penaltyScore.$2;
      }

      if (homePenalties == awayPenalties) {
        throw ArgumentError('Счёт серии пенальти не может быть равным.');
      }

      winner = homePenalties > awayPenalties
          ? finalTie.homeTeam
          : finalTie.awayTeam;
    }

    final updatedTie = finalTie.copyWith(
      finalHomeGoals: homeGoals,
      finalAwayGoals: awayGoals,
      winner: winner,
      decidedByPenalties: decidedByPenalties,
    );

    final updatedHistory = [
      ...matchHistory,
      ChampionsLeagueMatchHistory(
        stage: ChampionsLeagueStage.finalMatch,
        leg: 1,
        homeTeam: finalTie.homeTeam,
        awayTeam: finalTie.awayTeam,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        homePenalties: homePenalties,
        awayPenalties: awayPenalties,
        winner: winner,
      ),
    ];

    return copyWith(
      ties: [updatedTie],
      champion: winner,
      stage: ChampionsLeagueStage.completed,
      matchHistory: updatedHistory,
    );
  }

  ChampionsLeague advanceStage() {
    if (stage == ChampionsLeagueStage.finalMatch ||
        stage == ChampionsLeagueStage.completed) {
      throw StateError('Дальше перейти нельзя.');
    }

    if (ties.isEmpty || ties.any((tie) => !tie.isCompleted)) {
      throw StateError('Сначала нужно завершить все матчи стадии.');
    }

    final winners = ties.map((tie) => tie.winner!).toList();
    final nextStage = stage.next;
    final nextTies = <ChampionsLeagueTie>[];

    for (var i = 0; i < winners.length; i += 2) {
      nextTies.add(
        ChampionsLeagueTie(homeTeam: winners[i], awayTeam: winners[i + 1]),
      );
    }

    // История сохраняется при переходе на следующую стадию.
    return copyWith(stage: nextStage, ties: nextTies, champion: null);
  }

  ChampionsLeague playLeg({
    required int tieIndex,
    required bool isFirstLeg,
    int? homeGoals,
    int? awayGoals,
    int? homePenalties,
    int? awayPenalties,
  }) {
    if (stage == ChampionsLeagueStage.finalMatch ||
        stage == ChampionsLeagueStage.completed) {
      throw StateError('На этой стадии нельзя сыграть этот матч.');
    }

    if (tieIndex < 0 || tieIndex >= ties.length) {
      throw RangeError.index(tieIndex, ties, 'tieIndex');
    }

    final tie = ties[tieIndex];

    if (tie.isCompleted) {
      throw StateError('Это противостояние уже завершено.');
    }

    if (isFirstLeg && tie.isFirstLegPlayed) {
      throw StateError('Первый матч уже сыгран.');
    }

    if (!isFirstLeg && !tie.isFirstLegPlayed) {
      throw StateError('Сначала нужно сыграть первый матч.');
    }

    if (!isFirstLeg && tie.isSecondLegPlayed) {
      throw StateError('Ответный матч уже сыгран.');
    }

    final random = Random(
      season * 100000 +
          stage.index * 1000 +
          tieIndex * 10 +
          (isFirstLeg ? 1 : 2),
    );

    final goalsHome = homeGoals ?? random.nextInt(4);
    final goalsAway = awayGoals ?? random.nextInt(4);

    if (goalsHome < 0 || goalsAway < 0) {
      throw ArgumentError('Количество голов не может быть отрицательным.');
    }

    var updatedTie = isFirstLeg
        ? tie.copyWith(
            firstLegHomeGoals: goalsHome,
            firstLegAwayGoals: goalsAway,
          )
        : tie.copyWith(
            secondLegHomeGoals: goalsHome,
            secondLegAwayGoals: goalsAway,
          );

    int? penaltiesHome;
    int? penaltiesAway;
    String? matchWinner;

    if (!isFirstLeg) {
      // Общий счёт после двух матчей.
      final homeTeamAggregate = tie.firstLegHomeGoals! + goalsAway;

      final awayTeamAggregate = tie.firstLegAwayGoals! + goalsHome;

      if (homeTeamAggregate > awayTeamAggregate) {
        matchWinner = tie.homeTeam;
      } else if (awayTeamAggregate > homeTeamAggregate) {
        matchWinner = tie.awayTeam;
      } else {
        // Общий счёт равный — определяем победителя по пенальти.
        if (homePenalties != null &&
            awayPenalties != null &&
            homePenalties == awayPenalties) {
          throw ArgumentError('Счёт серии пенальти не может быть равным.');
        }

        if (homePenalties == null || awayPenalties == null) {
          final penaltyScore = _generatePenaltyScore(random);
          penaltiesHome = penaltyScore.$1;
          penaltiesAway = penaltyScore.$2;
        } else {
          penaltiesHome = homePenalties;
          penaltiesAway = awayPenalties;
        }

        // Во втором матче хозяева — awayTeam из пары.
        // Поэтому счёт пенальти относится к командам ответного матча.
        matchWinner = penaltiesHome > penaltiesAway
            ? tie.awayTeam
            : tie.homeTeam;
      }

      updatedTie = updatedTie.copyWith(
        winner: matchWinner,
        decidedByPenalties: penaltiesHome != null,
      );
    }

    final updatedTies = List<ChampionsLeagueTie>.from(ties);
    updatedTies[tieIndex] = updatedTie;

    final historyMatch = ChampionsLeagueMatchHistory(
      stage: stage,
      leg: isFirstLeg ? 1 : 2,
      homeTeam: isFirstLeg ? tie.homeTeam : tie.awayTeam,
      awayTeam: isFirstLeg ? tie.awayTeam : tie.homeTeam,
      homeGoals: goalsHome,
      awayGoals: goalsAway,
      homePenalties: penaltiesHome,
      awayPenalties: penaltiesAway,
      winner: matchWinner,
    );

    return copyWith(
      ties: updatedTies,
      matchHistory: [...matchHistory, historyMatch],
    );
  }

  ChampionsLeague copyWith({
    int? season,
    List<String>? participants,
    ChampionsLeagueStage? stage,
    List<ChampionsLeagueTie>? ties,
    String? champion,
    List<ChampionsLeagueMatchHistory>? matchHistory,
  }) {
    return ChampionsLeague(
      season: season ?? this.season,
      participants: participants ?? this.participants,
      stage: stage ?? this.stage,
      ties: ties ?? this.ties,
      champion: champion ?? this.champion,
      matchHistory: matchHistory ?? this.matchHistory,
    );
  }
}
