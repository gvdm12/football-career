import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/player_of_month_award.dart';
import 'package:flutter_football/models/season_award.dart';
import 'package:flutter_football/models/season_stats.dart';

class SeasonAwardService {
  static List<SeasonAward> create({
    required int season,
    required Player player,
    required SeasonStats seasonStats,
    required List<PlayerOfMonthAward> monthlyAwards,
  }) {
    final candidates = <_Candidate>[];
    final grouped = <String, List<PlayerOfMonthAward>>{};

    // В список соперников попадают только реальные победители награды месяца.
    // Их месячные показатели суммируются, чтобы не учитывать один месяц дважды.
    for (final award in monthlyAwards.where((item) => item.season == season)) {
      final key = '${award.playerName}|${award.club}|${award.position.name}';
      grouped.putIfAbsent(key, () => []).add(award);
    }

    for (final items in grouped.values) {
      final matches = items.fold<int>(0, (sum, item) => sum + item.matches);
      if (matches <= 0) continue;
      final goals = items.fold<int>(0, (sum, item) => sum + item.goals);
      final assists = items.fold<int>(0, (sum, item) => sum + item.assists);
      final rating = items.fold<double>(
            0,
            (sum, item) => sum + item.averageRating * item.matches,
          ) /
          matches;
      final first = items.first;
      candidates.add(_Candidate(
        name: first.playerName,
        club: first.club,
        position: first.position,
        age: first.age,
        matches: matches,
        goals: goals,
        assists: assists,
        rating: rating,
        isCareerPlayer: false,
      ));
    }

    // Не добавляем игрока карьеры автоматически: он участвует наравне
    // с остальными и только при достаточном количестве матчей.
    candidates.removeWhere(
      (item) => item.club == player.club && item.name == player.name,
    );
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

    final eligible = candidates.where((item) => item.matches >= 10).toList();
    if (eligible.isEmpty) return [];

    // Оцениваем именно сезонную игру: средняя оценка и результативность
    // важнее количества матчей. Overall не даёт бонуса за силу карточки.
    double performanceScore(_Candidate item) {
      final contributionsPerMatch =
          (item.goals + item.assists) / item.matches;
      return item.rating * 10 +
          contributionsPerMatch * 18 +
          (item.goals / item.matches) * 5 +
          (item.assists / item.matches) * 4;
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
        final scoreCompare =
            performanceScore(b).compareTo(performanceScore(a));
        if (scoreCompare != 0) return scoreCompare;
        final ratingCompare = b.rating.compareTo(a.rating);
        if (ratingCompare != 0) return ratingCompare;
        return (b.goals + b.assists).compareTo(a.goals + a.assists);
      });
    result.add(convert(
      playerOfSeason.first,
      'Игрок сезона',
      performanceScore(playerOfSeason.first),
    ));

    // Молодой игрок: до 21 года включительно, минимум 10 матчей.
    final youngPlayers = eligible.where((item) => item.age <= 21).toList()
      ..sort((a, b) => performanceScore(b).compareTo(performanceScore(a)));
    if (youngPlayers.isNotEmpty) {
      result.add(convert(
        youngPlayers.first,
        'Лучший молодой игрок',
        performanceScore(youngPlayers.first),
      ));
    }

    // Лучший ассистент определяется количеством передач, а не общей формулой.
    final assistLeaders = eligible.where((item) => item.assists > 0).toList()
      ..sort((a, b) {
        final assistsCompare = b.assists.compareTo(a.assists);
        if (assistsCompare != 0) return assistsCompare;
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

    // Если в какой-то линии не хватает игроков, добираем лучших из оставшихся.
    final remaining = [...eligible]
      ..sort((a, b) => performanceScore(b).compareTo(performanceScore(a)));
    for (final item in remaining) {
      if (result.where((award) => award.category == 'Команда года').length >=
          11) {
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
