import 'dart:math';

import 'club.dart';
import 'cup_match.dart';
import 'league_division_service.dart';

class DomesticCup {
  final League league;
  final int season;
  final List<String> teams;
  final List<CupMatch> matches;

  const DomesticCup({
    required this.league,
    required this.season,
    required this.teams,
    required this.matches,
  });

  /// Создаёт кубок из 16 клубов одной лиги.
  /// Клуб игрока обязательно участвует в турнире.
  factory DomesticCup.create({
    required League league,
    required int season,
    required String playerClub,
    Map<String, List<String>>? leagueDivisions,
    int? seed,
  }) {
    final divisions = leagueDivisions ??
        LeagueDivisionService.createInitialDivisions();
    final playerDivision =
        LeagueDivisionService.divisionForClub(playerClub, divisions);
    if (playerDivision == null ||
        Clubs.leagueOf(playerClub) != league ||
        !divisions.values.any((clubs) => clubs.contains(playerClub))) {
      throw ArgumentError('Клуб $playerClub не найден в выбранной лиге.');
    }

    final allCountryClubs = <String>{
      ...LeagueDivisionService.clubsFor(league, 1, divisions)
          .map((club) => club.name),
      if (LeagueDivisionService.hasSecondDivision(league))
        ...LeagueDivisionService.clubsFor(league, 2, divisions)
            .map((club) => club.name),
    };
    final participantCount =
        LeagueDivisionService.hasSecondDivision(league) ? 32 : 16;
    if (allCountryClubs.length < participantCount) {
      throw StateError(
        'Для кубка необходимо минимум $participantCount клубов.',
      );
    }

    final random = Random(seed);
    final availableClubs = allCountryClubs
        .where((name) => name != playerClub)
        .toList()
      ..shuffle(random);
    final selectedTeams = <String>[
      playerClub,
      ...availableClubs.take(participantCount - 1),
    ]..shuffle(random);

    final firstRoundMatches = <CupMatch>[];
    for (int i = 0; i < selectedTeams.length; i += 2) {
      firstRoundMatches.add(
        CupMatch(
          id: 100 + i ~/ 2,
          round: 1,
          homeTeam: selectedTeams[i],
          awayTeam: selectedTeams[i + 1],
        ),
      );
    }

    return DomesticCup(
      league: league,
      season: season,
      teams: selectedTeams,
      matches: firstRoundMatches,
    );
  }

  int get totalRounds => teams.length >= 32 ? 5 : 4;

  /// Название текущей стадии турнира.
  String get roundName {
    switch (currentRound) {
      case 1:
        return totalRounds == 5 ? '1/16 финала' : '1/8 финала';
      case 2:
        return totalRounds == 5 ? '1/8 финала' : 'Четвертьфинал';
      case 3:
        return totalRounds == 5 ? 'Четвертьфинал' : 'Полуфинал';
      case 4:
        return totalRounds == 5 ? 'Полуфинал' : 'Финал';
      case 5:
        return 'Финал';
      default:
        return 'Турнир завершён';
    }
  }

  /// Первая стадия, в которой остались несыгранные матчи.
  /// Если все матчи завершены, возвращает последнюю стадию.
  int get currentRound {
    for (int round = 1; round <= totalRounds; round++) {
      final roundMatches = matches
          .where((match) => match.round == round)
          .toList();

      if (roundMatches.isNotEmpty &&
          roundMatches.any((match) => !match.isPlayed)) {
        return round;
      }
    }

    if (matches.isEmpty) return 1;

    return matches.map((match) => match.round).reduce(max);
  }

  List<CupMatch> get currentRoundMatches {
    return matches.where((match) => match.round == currentRound).toList();
  }

  bool get isFinished {
    final finalMatches = matches.where((match) => match.round == totalRounds);

    return finalMatches.length == 1 &&
        finalMatches.first.isPlayed &&
        finalMatches.first.winner != null;
  }

  String? get champion {
    if (!isFinished) return null;

    return matches.firstWhere((match) => match.round == totalRounds).winner;
  }

  /// Проверяет, продолжает ли клуб участвовать в кубке.
  /// Проверяет, продолжает ли клуб участвовать в кубке.
  bool isTeamStillInCup(String clubName) {
    if (!teams.contains(clubName)) return false;

    // Победитель финала — чемпион кубка.
    if (isFinished) {
      return champion == clubName;
    }

    final teamMatches = matches.where(
      (match) => match.homeTeam == clubName || match.awayTeam == clubName,
    );

    if (teamMatches.isEmpty) return false;

    // Если клуб проиграл хотя бы один завершённый матч,
    // он выбывает из турнира.
    for (final match in teamMatches) {
      if (match.isPlayed && match.winner != clubName) {
        return false;
      }
    }

    // Клуб продолжает участвовать, если его следующий матч
    // ещё не сыгран или он выиграл предыдущий раунд.
    return teamMatches.any((match) => !match.isPlayed) ||
        teamMatches.any((match) => match.isPlayed && match.winner == clubName);
  }

  /// Записывает результат матча.
  /// При ничьей обязательны пенальти с разным количеством голов.
  DomesticCup recordResult({
    required int matchId,
    required int homeGoals,
    required int awayGoals,
    int? homePenalties,
    int? awayPenalties,
  }) {
    if (homeGoals < 0 || awayGoals < 0) {
      throw ArgumentError('Количество голов не может быть отрицательным.');
    }

    final index = matches.indexWhere((match) => match.id == matchId);

    if (index == -1) {
      throw ArgumentError('Кубковый матч не найден.');
    }

    final match = matches[index];

    if (match.isPlayed) {
      throw StateError('Этот матч уже завершён.');
    }

    String winner;

    if (homeGoals > awayGoals) {
      winner = match.homeTeam;
    } else if (awayGoals > homeGoals) {
      winner = match.awayTeam;
    } else {
      if (homePenalties == null ||
          awayPenalties == null ||
          homePenalties < 0 ||
          awayPenalties < 0 ||
          homePenalties == awayPenalties) {
        throw ArgumentError('При ничьей укажи корректный результат пенальти.');
      }

      winner = homePenalties > awayPenalties ? match.homeTeam : match.awayTeam;
    }

    final updatedMatches = List<CupMatch>.from(matches);

    updatedMatches[index] = CupMatch(
      id: match.id,
      round: match.round,
      homeTeam: match.homeTeam,
      awayTeam: match.awayTeam,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      winner: winner,
      homePenalties: homePenalties,
      awayPenalties: awayPenalties,
    );

    return copyWith(matches: updatedMatches);
  }

  /// Создаёт следующую стадию после завершения всех матчей текущей.
  /// Победители предыдущего раунда формируют новые пары.
  DomesticCup advanceRound({int? seed}) {
    if (isFinished) return this;

    final round = currentRound;
    final roundMatches = matches
        .where((match) => match.round == round)
        .toList();

    if (roundMatches.isEmpty ||
        roundMatches.any((match) => !match.isPlayed || match.winner == null)) {
      throw StateError(
        'Сначала необходимо завершить все матчи стадии «$roundName».',
      );
    }

    if (round >= totalRounds) return this;

    // Защита от повторного создания следующего раунда.
    final nextRound = round + 1;

    if (matches.any((match) => match.round == nextRound)) {
      throw StateError('Следующая стадия кубка уже создана.');
    }

    final winners = roundMatches.map((match) => match.winner!).toList();

    winners.shuffle(Random(seed));

    final nextMatches = <CupMatch>[];

    for (int i = 0; i < winners.length; i += 2) {
      nextMatches.add(
        CupMatch(
          id: nextRound * 100 + i ~/ 2,
          round: nextRound,
          homeTeam: winners[i],
          awayTeam: winners[i + 1],
        ),
      );
    }

    return copyWith(matches: [...matches, ...nextMatches]);
  }

  DomesticCup copyWith({
    League? league,
    int? season,
    List<String>? teams,
    List<CupMatch>? matches,
  }) {
    return DomesticCup(
      league: league ?? this.league,
      season: season ?? this.season,
      teams: teams ?? this.teams,
      matches: matches ?? this.matches,
    );
  }

  Map<String, dynamic> toJson() => {
    'league': league.name,
    'season': season,
    'teams': teams,
    'matches': matches.map((match) => match.toJson()).toList(),
  };

  factory DomesticCup.fromJson(Map<String, dynamic> json) {
    final leagueName = json['league'] as String?;

    final league = League.values.firstWhere(
      (value) => value.name == leagueName,
      orElse: () => League.england,
    );

    return DomesticCup(
      league: league,
      season: (json['season'] as num?)?.toInt() ?? 1,
      teams:
          (json['teams'] as List<dynamic>?)?.whereType<String>().toList() ??
          const [],
      matches:
          (json['matches'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((item) => CupMatch.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          const [],
    );
  }
}
