import 'package:flutter_football/models/league_player_season_stats.dart';
import 'package:flutter_football/models/league_table.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/season_award.dart';
import 'package:flutter_football/models/season_stats.dart';
import 'package:flutter_football/models/position_rival.dart';

class SeasonAwardService {
  static List<SeasonAward> create({
    required int season,
    required Player player,
    required SeasonStats seasonStats,
    required List<LeaguePlayerSeasonStats> leaguePlayerStats,
    required List<LeagueTableEntry> leagueTable,
    required List<PositionRival> rivals,
  }) {
    final candidates = <_Candidate>[];

    for (final item in leaguePlayerStats) {
      if (item.matches == 0) continue;
      if (item.club == player.club && item.playerName == player.name) continue;
      candidates.add(_Candidate(
        name: item.playerName,
        club: item.club,
        position: item.position,
        age: item.age,
        matches: item.matches,
        goals: item.goals,
        assists: item.assists,
        rating: item.averageRating,
        isCareerPlayer: false,
      ));
    }

    // Конкуренты за позицию входят в общий список наград с той же
    // статистикой, которая отображается на экране команды.
    for (final rival in rivals) {
      if (rival.matches == 0) continue;
      candidates.add(_Candidate(
        name: rival.name,
        club: player.club,
        position: rival.position,
        age: rival.age,
        matches: rival.matches,
        goals: rival.goals,
        assists: rival.assists,
        rating: rival.averageRating,
        isCareerPlayer: false,
      ));
    }

    // Игрок карьеры участвует на тех же условиях, но его статистика берётся
    // из реальных матчей карьеры, а не из искусственно смоделированного состава.
    if (seasonStats.matches >= 10 && (seasonStats.averageRating ?? 0) >= 6.0) {
      candidates.add(_Candidate(
        name: player.name,
        club: player.club,
        position: player.position,
        age: player.age,
        matches: seasonStats.matches,
        goals: seasonStats.goals,
        assists: seasonStats.assists,
        rating: seasonStats.averageRating ?? 0,
        isCareerPlayer: true,
      ));
    }

    final eligible = candidates
        .where((item) => item.matches >= 10 && item.rating >= 6.0)
        .toList();
    if (eligible.isEmpty) return [];

    final sortedTable = [...leagueTable]
      ..sort((a, b) => b.points != a.points
          ? b.points.compareTo(a.points)
          : b.goalDifference.compareTo(a.goalDifference));
    final positions = <String, int>{
      for (var i = 0; i < sortedTable.length; i++)
        sortedTable[i].club: i + 1,
    };

    // Индивидуальная результативность и оценка имеют основной вес.
    // Позиция клуба даёт небольшой контекстный бонус, как в реальных премиях.
    double performanceScore(_Candidate item, {bool includeTeamSuccess = false}) {
      final contributionsPerMatch =
          (item.goals + item.assists) / item.matches;
      final teamPosition = positions[item.club];
      final teamBonus = !includeTeamSuccess || teamPosition == null
          ? 0.0
          : teamPosition == 1
              ? 0.8
              : teamPosition <= 4
                  ? 0.45
                  : teamPosition <= (sortedTable.length / 2).ceil()
                      ? 0.2
                      : 0.0;
      return item.rating * 8 +
          item.goals * 0.30 +
          item.assists * 0.22 +
          item.matches * 0.035 +
          contributionsPerMatch * 3 +
          teamBonus;
    }

    SeasonAward convert(_Candidate item, String category, double score) =>
        SeasonAward(
          season: season,
          category: category,
          playerName: item.name,
          club: item.club,
          position: item.position,
          age: item.age,
          matches: item.matches,
          goals: item.goals,
          assists: item.assists,
          averageRating: double.parse(item.rating.toStringAsFixed(2)),
          score: double.parse(score.toStringAsFixed(2)),
          isCareerPlayer: item.isCareerPlayer,
        );

    final result = <SeasonAward>[];

    final playerOfSeason = [...eligible]
      ..sort((a, b) {
        final scoreCompare = performanceScore(
          b,
          includeTeamSuccess: true,
        ).compareTo(performanceScore(a, includeTeamSuccess: true));
        if (scoreCompare != 0) return scoreCompare;
        final ratingCompare = b.rating.compareTo(a.rating);
        if (ratingCompare != 0) return ratingCompare;
        return (b.goals + b.assists).compareTo(a.goals + a.assists);
      });
    final seasonWinner = playerOfSeason.first;
    result.add(convert(
      seasonWinner,
      'Игрок сезона',
      performanceScore(seasonWinner, includeTeamSuccess: true),
    ));

    final youngPlayers = eligible.where((item) => item.age <= 21).toList()
      ..sort((a, b) => performanceScore(b).compareTo(performanceScore(a)));
    if (youngPlayers.isNotEmpty) {
      result.add(convert(
        youngPlayers.first,
        'Лучший молодой игрок',
        performanceScore(youngPlayers.first),
      ));
    }

    // Лидер ассистов определяется только количеством голевых передач.
    final goalLeaders = eligible.where((item) => item.goals > 0).toList()
      ..sort((a, b) {
        final compare = b.goals.compareTo(a.goals);
        if (compare != 0) return compare;
        final ratingCompare = b.rating.compareTo(a.rating);
        if (ratingCompare != 0) return ratingCompare;
        return b.assists.compareTo(a.assists);
      });
    if (goalLeaders.isNotEmpty) {
      result.add(convert(
        goalLeaders.first,
        'Лучший бомбардир',
        goalLeaders.first.goals.toDouble(),
      ));
    }

    final assistLeaders = eligible.where((item) => item.assists > 0).toList()
      ..sort((a, b) {
        final compare = b.assists.compareTo(a.assists);
        if (compare != 0) return compare;
        final ratingCompare = b.rating.compareTo(a.rating);
        if (ratingCompare != 0) return ratingCompare;
        return b.goals.compareTo(a.goals);
      });
    if (assistLeaders.isNotEmpty) {
      result.add(convert(
        assistLeaders.first,
        'Лучший ассистент',
        assistLeaders.first.assists.toDouble(),
      ));
    }

    // Сборная сезона: 1 вратарь, 4 защитника, 3 полузащитника, 3 нападающих.
    const formation = <PlayerPosition, int>{
      PlayerPosition.goalkeeper: 1,
      PlayerPosition.defender: 4,
      PlayerPosition.midfielder: 3,
      PlayerPosition.forward: 3,
    };
    final selected = <String>{};
    for (final entry in formation.entries) {
      final positionCandidates = eligible
          .where((item) => item.position == entry.key)
          .toList()
        ..sort((a, b) => performanceScore(b).compareTo(performanceScore(a)));
      for (final item in positionCandidates.take(entry.value)) {
        final key = '${item.name}|${item.club}';
        if (selected.add(key)) {
          result.add(convert(item, 'Команда года', performanceScore(item)));
        }
      }
    }

    final remaining = [...eligible]
      ..sort((a, b) => performanceScore(b).compareTo(performanceScore(a)));
    for (final item in remaining) {
      if (result.where((award) => award.category == 'Команда года').length >= 11) {
        break;
      }
      final key = '${item.name}|${item.club}';
      if (!selected.add(key)) continue;
      result.add(convert(item, 'Команда года', performanceScore(item)));
    }

    return result;
  }
}

class _Candidate {
  final String name;
  final String club;
  final PlayerPosition position;
  final int age;
  final int matches;
  final int goals;
  final int assists;
  final double rating;
  final bool isCareerPlayer;

  const _Candidate({
    required this.name,
    required this.club,
    required this.position,
    required this.age,
    required this.matches,
    required this.goals,
    required this.assists,
    required this.rating,
    required this.isCareerPlayer,
  });
}
