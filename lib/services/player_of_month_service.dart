import 'package:flutter_football/models/league_match.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/player_of_month_award.dart';
import 'package:flutter_football/models/season_match.dart';
import 'package:flutter_football/models/position_rival.dart';
import 'package:flutter_football/models/league_player_season_stats.dart';

class PlayerOfMonthService {
  static PlayerOfMonthAward? create({
    required int season,
    required int month,
    required Player player,
    required List<SeasonMatch> playerMatches,
    required List<LeagueMatch> leagueMatches,
    required List<LeaguePlayerSeasonStats> leaguePlayerStats,
    required List<PlayerOfMonthAward> previousAwards,
    required List<PositionRival> rivals,
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
        age: player.age,
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
    if (monthFixtures.isEmpty) return null;

    // Для остальных клубов берём помесячную статистику из той же модели,
    // которая накапливает сезонные голы, ассисты и оценки.
    for (final item in leaguePlayerStats) {
      if (item.matches == 0) continue;
      if (item.club == player.club &&
          (item.playerName == player.name ||
              rivals.any((rival) => rival.name == item.playerName))) {
        continue;
      }
      final monthStats = item.monthlyStats[month];
      if (monthStats == null || monthStats.matches == 0) continue;
      candidates.add(_candidate(
        season: season,
        month: month,
        name: item.playerName,
        club: item.club,
        age: item.age,
        position: item.position,
        overall: item.overall,
        matches: monthStats.matches,
        goals: monthStats.goals,
        assists: monthStats.assists,
        averageRating: monthStats.averageRating,
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
    required int age,
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
      age: age,
      matches: matches,
      goals: goals,
      assists: assists,
      averageRating: double.parse(averageRating.toStringAsFixed(2)),
      score: double.parse(score.toStringAsFixed(2)),
      isCareerPlayer: isCareerPlayer,
    );
  }
}
