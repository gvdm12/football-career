import 'dart:math';

import 'package:flutter_football/models/league_match.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/player_of_month_award.dart';
import 'package:flutter_football/models/season_match.dart';

class PlayerOfMonthService {
  static const _names = [
    'Александр Волков', 'Даниэль Коста', 'Марк Фишер',
    'Лукас Мартин', 'Матео Ромеро', 'Давид Гарсия',
    'Юсуф Диалло', 'Рафаэль Силва', 'Оливер Кларк',
    'Федерико Росси', 'Томас Берг', 'Никита Смирнов',
  ];

  static int _seed(String value) {
    var result = 23;
    for (final code in value.codeUnits) {
      result = (result * 37 + code) & 0x7fffffff;
    }
    return result;
  }

  static PlayerOfMonthAward? create({
    required int season,
    required int month,
    required Player player,
    required List<SeasonMatch> playerMatches,
    required List<LeagueMatch> leagueMatches,
    required List<PlayerOfMonthAward> previousAwards,
  }) {
    if (previousAwards.any((award) =>
        award.season == season && award.month == month)) {
      return null;
    }

    final totalRounds = playerMatches.length;
    if (totalRounds == 0) return null;
    final firstRound = (((month - 1) * totalRounds) ~/ 12) + 1;
    final lastRound = (month * totalRounds / 12).ceil();
    if (lastRound < firstRound) return null;

    final monthPlayerMatches = playerMatches.where((item) =>
        item.number >= firstRound &&
        item.number <= lastRound &&
        item.result != null &&
        item.result!.playerPlayed).toList();

    final playerGoals = monthPlayerMatches.fold<int>(
        0, (sum, item) => sum + item.result!.playerGoals);
    final playerAssists = monthPlayerMatches.fold<int>(
        0, (sum, item) => sum + item.result!.playerAssists);
    final playerRatingSum = monthPlayerMatches.fold<double>(
        0, (sum, item) => sum + item.result!.playerRating);
    final playerRating = monthPlayerMatches.isEmpty
        ? 0.0
        : playerRatingSum / monthPlayerMatches.length;

    final candidates = <PlayerOfMonthAward>[];
    if (monthPlayerMatches.isNotEmpty) {
      candidates.add(_candidate(
        season: season,
        month: month,
        name: player.name,
        club: player.club,
        position: player.position,
        overall: player.overall,
        matches: monthPlayerMatches.length,
        goals: playerGoals,
        assists: playerAssists,
        averageRating: playerRating,
        isCareerPlayer: true,
      ));
    }

    final monthFixtures = leagueMatches.where((match) =>
        match.round >= firstRound &&
        match.round <= lastRound &&
        match.isPlayed).toList();
    final clubs = <String>{
      for (final fixture in monthFixtures) fixture.homeTeam,
      for (final fixture in monthFixtures) fixture.awayTeam,
    };

    for (final clubName in clubs) {
      final fixtures = monthFixtures.where((match) =>
          match.homeTeam == clubName || match.awayTeam == clubName).toList();
      if (fixtures.isEmpty) continue;

      final scored = fixtures.fold<int>(0, (sum, match) =>
          sum + (match.homeTeam == clubName ? match.homeGoals! : match.awayGoals!));
      final conceded = fixtures.fold<int>(0, (sum, match) =>
          sum + (match.homeTeam == clubName ? match.awayGoals! : match.homeGoals!));
      final points = fixtures.fold<int>(0, (sum, match) {
        final home = match.homeTeam == clubName;
        final own = home ? match.homeGoals! : match.awayGoals!;
        final other = home ? match.awayGoals! : match.homeGoals!;
        return sum + (own > other ? 3 : own == other ? 1 : 0);
      });

      final random = Random(_seed('$season|$month|$clubName'));
      final position = scored >= fixtures.length * 1.5
          ? PlayerPosition.forward
          : points >= fixtures.length * 2
              ? PlayerPosition.midfielder
              : PlayerPosition.defender;
      final overall = (68 + random.nextInt(22)).clamp(60, 90).toInt();
      final goals = scored == 0 ? 0 : min(scored, (scored * (0.35 + random.nextDouble() * 0.3)).round()).toInt();
      final assists = max(0, min(scored - goals, (scored * 0.22).round())).toInt();
      final rating = (6.15 +
          (points / (fixtures.length * 3)) * 1.1 +
          (goals + assists) * 0.12 -
          (conceded / max(1, fixtures.length)) * 0.06)
          .clamp(5.8, 9.4).toDouble();

      candidates.add(_candidate(
        season: season,
        month: month,
        name: _names[random.nextInt(_names.length)],
        club: clubName,
        position: position,
        overall: overall,
        matches: fixtures.length,
        goals: goals,
        assists: assists,
        averageRating: rating,
      ));
    }

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => b.score.compareTo(a.score));
    return candidates.first;
  }

  static PlayerOfMonthAward _candidate({
    required int season,
    required int month,
    required String name,
    required String club,
    required PlayerPosition position,
    required int overall,
    required int matches,
    required int goals,
    required int assists,
    required double averageRating,
    bool isCareerPlayer = false,
  }) {
    final score = matches < 2
        ? 0.0
        : goals * 3.2 +
            assists * 2.2 +
            averageRating * 2.4 +
            matches * 0.35 +
            overall * 0.025;
    return PlayerOfMonthAward(
      season: season,
      month: month,
      playerName: name,
      club: club,
      position: position,
      overall: overall,
      matches: matches,
      goals: goals,
      assists: assists,
      averageRating: double.parse(averageRating.toStringAsFixed(2)),
      score: double.parse(score.toStringAsFixed(2)),
      isCareerPlayer: isCareerPlayer,
    );
  }
}
