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
];

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

  const WorldCupMatch({
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals,
    this.awayGoals,
    this.isPlayed = false,
    this.winner,
  });

  WorldCupMatch play({int? homeScore, int? awayScore}) {
    final random = Random();
    var home = homeScore ?? random.nextInt(4);
    var away = awayScore ?? random.nextInt(4);

    if (home == away) {
      if (random.nextBool()) {
        home++;
      } else {
        away++;
      }
    }

    return WorldCupMatch(
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeGoals: home,
      awayGoals: away,
      isPlayed: true,
      winner: home > away ? homeTeam : awayTeam,
    );
  }

  Map<String, dynamic> toJson() => {
    'homeTeam': homeTeam,
    'awayTeam': awayTeam,
    'homeGoals': homeGoals,
    'awayGoals': awayGoals,
    'isPlayed': isPlayed,
    'winner': winner,
  };

  factory WorldCupMatch.fromJson(Map<String, dynamic> json) => WorldCupMatch(
    homeTeam: json['homeTeam'] as String? ?? '',
    awayTeam: json['awayTeam'] as String? ?? '',
    homeGoals: (json['homeGoals'] as num?)?.toInt(),
    awayGoals: (json['awayGoals'] as num?)?.toInt(),
    isPlayed: json['isPlayed'] as bool? ?? false,
    winner: json['winner'] as String?,
  );
}

class WorldCup {
  final int season;
  final List<String> participants;
  final List<WorldCupMatch> matches;
  final WorldCupStage stage;
  final String? champion;
  final String playerCallUpStatus;

  const WorldCup({
    required this.season,
    required this.participants,
    required this.matches,
    required this.stage,
    this.champion,
    required this.playerCallUpStatus,
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

    final formScore = (goals + assists) * 0.35 +
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
      matches.add(WorldCupMatch(
        homeTeam: shuffled[i],
        awayTeam: shuffled[i + 1],
      ));
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
      nextMatches.add(WorldCupMatch(
        homeTeam: winners[i],
        awayTeam: winners[i + 1],
      ));
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
  }) => WorldCup(
    season: season,
    participants: participants ?? this.participants,
    matches: matches ?? this.matches,
    stage: stage ?? this.stage,
    champion: champion ?? this.champion,
    playerCallUpStatus: playerCallUpStatus ?? this.playerCallUpStatus,
  );

  Map<String, dynamic> toJson() => {
    'season': season,
    'participants': participants,
    'matches': matches.map((match) => match.toJson()).toList(),
    'stage': stage.name,
    'champion': champion,
    'playerCallUpStatus': playerCallUpStatus,
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
          ? rawMatches.whereType<Map>().map((item) =>
              WorldCupMatch.fromJson(Map<String, dynamic>.from(item))).toList()
          : const [],
      stage: WorldCupStage.values.firstWhere(
        (value) => value.name == stageName,
        orElse: () => WorldCupStage.roundOf32,
      ),
      champion: json['champion'] as String?,
      playerCallUpStatus: json['playerCallUpStatus'] as String? ?? 'not_called',
    );
  }
}
