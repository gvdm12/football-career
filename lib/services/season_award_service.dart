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

    for (final award in monthlyAwards) {
      final key = '${award.playerName}|${award.club}|${award.position.name}';
      grouped.putIfAbsent(key, () => []).add(award);
    }

    for (final entry in grouped.entries) {
      final items = entry.value;
      final matches = items.fold<int>(0, (sum, item) => sum + item.matches);
      if (matches == 0) continue;
      final goals = items.fold<int>(0, (sum, item) => sum + item.goals);
      final assists = items.fold<int>(0, (sum, item) => sum + item.assists);
      final rating = items.fold<double>(
        0, (sum, item) => sum + item.averageRating * item.matches,
      ) / matches;
      final first = items.first;
      final age = first.age;
      candidates.add(_Candidate(
        name: first.playerName,
        club: first.club,
        position: first.position,
        age: age,
        matches: matches,
        goals: goals,
        assists: assists,
        rating: rating,
        overall: first.overall,
        isCareerPlayer: false,
      ));
    }

    candidates.removeWhere((item) => item.club == player.club && item.name == player.name);
    candidates.add(_Candidate(
      name: player.name,
      club: player.club,
      position: player.position,
      age: player.age,
      matches: seasonStats.matches,
      goals: seasonStats.goals,
      assists: seasonStats.assists,
      rating: seasonStats.averageRating ?? 0,
      overall: player.overall,
      isCareerPlayer: true,
    ));

    final eligible = candidates.where((item) => item.matches >= 10).toList();
    if (eligible.isEmpty) return [];

    double overallScore(_Candidate item) =>
        item.rating * 5 + (item.goals + item.assists) * 0.42 +
        item.matches * 0.08 + item.overall * 0.06;

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
      ..sort((a, b) => overallScore(b).compareTo(overallScore(a)));
    result.add(convert(playerOfSeason.first, 'Игрок сезона', overallScore(playerOfSeason.first)));

    final youngPlayers = eligible.where((item) => item.age <= 21).toList()
      ..sort((a, b) => overallScore(b).compareTo(overallScore(a)));
    if (youngPlayers.isNotEmpty) {
      result.add(convert(youngPlayers.first, 'Лучший молодой игрок', overallScore(youngPlayers.first)));
    }

    final assistLeaders = eligible.where((item) => item.assists > 0).toList()
      ..sort((a, b) {
        final compare = b.assists.compareTo(a.assists);
        return compare != 0 ? compare : overallScore(b).compareTo(overallScore(a));
      });
    if (assistLeaders.isNotEmpty) {
      result.add(convert(assistLeaders.first, 'Лучший ассистент', assistLeaders.first.assists.toDouble()));
    }

    // Схема команды года: 1 вратарь, 4 защитника, 3 полузащитника, 3 нападающих.
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
        ..sort((a, b) => overallScore(b).compareTo(overallScore(a)));
      for (final item in positionCandidates.take(entry.value)) {
        selected.add('${item.name}|${item.club}');
        result.add(convert(item, 'Команда года', overallScore(item)));
      }
    }

    // Если для позиции не хватает кандидатов, добираем лучших по общей оценке.
    final remaining = [...eligible]
      ..sort((a, b) => overallScore(b).compareTo(overallScore(a)));
    for (final item in remaining) {
      if (result.where((a) => a.category == 'Команда года').length >= 11) break;
      if (!selected.add('${item.name}|${item.club}')) continue;
      result.add(convert(item, 'Команда года', overallScore(item)));
    }
    return result;
  }

  static int _stableHash(String value) {
    var hash = 17;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
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
  final int overall;
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
    required this.overall,
    required this.isCareerPlayer,
  });
}
