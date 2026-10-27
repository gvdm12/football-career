import 'dart:math';

enum EuropaLeagueStage {
  roundOf32,
  roundOf16,
  quarterFinal,
  semiFinal,
  finalMatch,
  completed,
}

extension EuropaLeagueStageInfo on EuropaLeagueStage {
  String get title {
    switch (this) {
      case EuropaLeagueStage.roundOf32:
        return '1/16 финала';
      case EuropaLeagueStage.roundOf16:
        return '1/8 финала';
      case EuropaLeagueStage.quarterFinal:
        return '1/4 финала';
      case EuropaLeagueStage.semiFinal:
        return '1/2 финала';
      case EuropaLeagueStage.finalMatch:
        return 'Финал';
      case EuropaLeagueStage.completed:
        return 'Завершён';
    }
  }

  int get teamCount {
    switch (this) {
      case EuropaLeagueStage.roundOf32:
        return 32;
      case EuropaLeagueStage.roundOf16:
        return 16;
      case EuropaLeagueStage.quarterFinal:
        return 8;
      case EuropaLeagueStage.semiFinal:
        return 4;
      case EuropaLeagueStage.finalMatch:
        return 2;
      case EuropaLeagueStage.completed:
        return 0;
    }
  }

  EuropaLeagueStage get next {
    switch (this) {
      case EuropaLeagueStage.roundOf32:
        return EuropaLeagueStage.roundOf16;
      case EuropaLeagueStage.roundOf16:
        return EuropaLeagueStage.quarterFinal;
      case EuropaLeagueStage.quarterFinal:
        return EuropaLeagueStage.semiFinal;
      case EuropaLeagueStage.semiFinal:
        return EuropaLeagueStage.finalMatch;
      case EuropaLeagueStage.finalMatch:
      case EuropaLeagueStage.completed:
        return EuropaLeagueStage.completed;
    }
  }

  bool get isTwoLegged =>
      this != EuropaLeagueStage.finalMatch &&
      this != EuropaLeagueStage.completed;
}

/// Результат отдельного матча Лиги Европы.
class EuropaLeagueMatchHistory {
  final EuropaLeagueStage stage;
  final int leg;
  final String homeTeam;
  final String awayTeam;
  final int homeGoals;
  final int awayGoals;
  final int? homePenalties;
  final int? awayPenalties;
  final String? winner;

  const EuropaLeagueMatchHistory({
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

  factory EuropaLeagueMatchHistory.fromJson(Map<String, dynamic> json) {
    final stageName = json['stage'] as String?;

    return EuropaLeagueMatchHistory(
      stage: EuropaLeagueStage.values.firstWhere(
        (value) => value.name == stageName,
        orElse: () => EuropaLeagueStage.roundOf32,
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

class EuropaLeagueTie {
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

  const EuropaLeagueTie({
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

  EuropaLeagueTie copyWith({
    int? firstLegHomeGoals,
    int? firstLegAwayGoals,
    int? secondLegHomeGoals,
    int? secondLegAwayGoals,
    int? finalHomeGoals,
    int? finalAwayGoals,
    String? winner,
    bool? decidedByPenalties,
  }) {
    return EuropaLeagueTie(
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

  factory EuropaLeagueTie.fromJson(Map<String, dynamic> json) {
    int? readInt(String key) {
      final value = json[key];
      return value is num ? value.toInt() : null;
    }

    return EuropaLeagueTie(
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

class EuropaLeague {
  final int season;
  final List<String> participants;
  final EuropaLeagueStage stage;
  final List<EuropaLeagueTie> ties;
  final String? champion;

  /// История всех сыгранных матчей турнира за текущий сезон.
  final List<EuropaLeagueMatchHistory> matchHistory;

  const EuropaLeague({
    required this.season,
    required this.participants,
    required this.stage,
    required this.ties,
    this.champion,
    this.matchHistory = const [],
  });

  factory EuropaLeague.create({
    required int season,
    required List<String> participants,
  }) {
    if (participants.length != 32 || participants.toSet().length != 32) {
      throw ArgumentError('Для Лиги Европы нужны 32 уникальных клуба.');
    }

    final shuffled = List<String>.from(participants)..shuffle(Random(season));

    final ties = <EuropaLeagueTie>[];

    for (var i = 0; i < shuffled.length; i += 2) {
      ties.add(
        EuropaLeagueTie(homeTeam: shuffled[i], awayTeam: shuffled[i + 1]),
      );
    }

    return EuropaLeague(
      season: season,
      participants: List.unmodifiable(participants),
      stage: EuropaLeagueStage.roundOf32,
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

  factory EuropaLeague.fromJson(Map<String, dynamic> json) {
    final stageName = json['stage'] as String?;

    final stage = EuropaLeagueStage.values.firstWhere(
      (value) => value.name == stageName,
      orElse: () => EuropaLeagueStage.roundOf32,
    );

    return EuropaLeague(
      season: (json['season'] as num?)?.toInt() ?? 1,
      participants: (json['participants'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      stage: stage,
      ties: (json['ties'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (tie) =>
                EuropaLeagueTie.fromJson(Map<String, dynamic>.from(tie)),
          )
          .toList(),
      champion: json['champion'] as String?,
      matchHistory: (json['matchHistory'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (match) => EuropaLeagueMatchHistory.fromJson(
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

  EuropaLeague playFinal({
    required int homeGoals,
    required int awayGoals,
    int? homePenalties,
    int? awayPenalties,
  }) {
    if (stage != EuropaLeagueStage.finalMatch) {
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
      EuropaLeagueMatchHistory(
        stage: EuropaLeagueStage.finalMatch,
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
      stage: EuropaLeagueStage.completed,
      matchHistory: updatedHistory,
    );
  }

  EuropaLeague advanceStage() {
    if (stage == EuropaLeagueStage.finalMatch ||
        stage == EuropaLeagueStage.completed) {
      throw StateError('Дальше перейти нельзя.');
    }

    if (ties.isEmpty || ties.any((tie) => !tie.isCompleted)) {
      throw StateError('Сначала нужно завершить все матчи стадии.');
    }

    final winners = ties.map((tie) => tie.winner!).toList();
    final nextStage = stage.next;
    final nextTies = <EuropaLeagueTie>[];

    for (var i = 0; i < winners.length; i += 2) {
      nextTies.add(
        EuropaLeagueTie(homeTeam: winners[i], awayTeam: winners[i + 1]),
      );
    }

    // История сохраняется при переходе на следующую стадию.
    return copyWith(stage: nextStage, ties: nextTies, champion: null);
  }

  EuropaLeague playLeg({
    required int tieIndex,
    required bool isFirstLeg,
    int? homeGoals,
    int? awayGoals,
    int? homePenalties,
    int? awayPenalties,
  }) {
    if (stage == EuropaLeagueStage.finalMatch ||
        stage == EuropaLeagueStage.completed) {
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

    final updatedTies = List<EuropaLeagueTie>.from(ties);
    updatedTies[tieIndex] = updatedTie;

    final historyMatch = EuropaLeagueMatchHistory(
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

  EuropaLeague copyWith({
    int? season,
    List<String>? participants,
    EuropaLeagueStage? stage,
    List<EuropaLeagueTie>? ties,
    String? champion,
    List<EuropaLeagueMatchHistory>? matchHistory,
  }) {
    return EuropaLeague(
      season: season ?? this.season,
      participants: participants ?? this.participants,
      stage: stage ?? this.stage,
      ties: ties ?? this.ties,
      champion: champion ?? this.champion,
      matchHistory: matchHistory ?? this.matchHistory,
    );
  }
}
