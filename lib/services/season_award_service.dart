import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_player_season_stats.dart';
import 'package:flutter_football/models/league_table.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/season_award.dart';
import 'package:flutter_football/models/season_stats.dart';
import 'package:flutter_football/models/position_rival.dart';
import 'package:flutter_football/models/real_club_squads.dart';
import 'dart:math';

class SeasonAwardService {
  static List<SeasonAward> create({
    required int season,
    required Player player,
    required SeasonStats seasonStats,
    required List<LeaguePlayerSeasonStats> leaguePlayerStats,
    required List<LeagueTableEntry> leagueTable,
    required List<PositionRival> rivals,
    List<String> additionalTrophyWinningClubs = const [],
    Map<League, List<LeagueTableEntry>>? worldLeagueStandings,
    SeasonStats? overallSeasonStats,
  }) {
    final sortedTable = [...leagueTable]
      ..sort((a, b) => b.points != a.points
          ? b.points.compareTo(a.points)
          : b.goalDifference.compareTo(a.goalDifference));
    final worldChampions = <String>{};
    for (final entry in worldLeagueStandings?.entries ??
        const <MapEntry<League, List<LeagueTableEntry>>>[]) {
      final standings = [...entry.value]
        ..sort((a, b) => b.points != a.points
            ? b.points.compareTo(a.points)
            : b.goalDifference.compareTo(a.goalDifference));
      if (standings.isNotEmpty) worldChampions.add(standings.first.club);
    }
    final trophyWinningClubs = <String>{
      ...additionalTrophyWinningClubs,
      ...worldChampions,
      if (sortedTable.isNotEmpty) sortedTable.first.club,
    };
    final candidates = <_Candidate>[];

    for (final item in leaguePlayerStats) {
      if (item.matches == 0) continue;
      if (item.club == player.club &&
          (item.playerName == player.name ||
              rivals.any((rival) => rival.name == item.playerName))) {
        continue;
      }
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
        wonTrophy: trophyWinningClubs.contains(item.club),
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
        wonTrophy: trophyWinningClubs.contains(player.club),
      ));
    }

    // Игрок карьеры участвует на тех же условиях, но его статистика берётся
    // из реальных матчей карьеры, а не из искусственно смоделированного состава.
    if (seasonStats.matches > 0) {
      // Игрок карьеры участвует в гонке бомбардиров даже при малом числе
      // матчей; минимальный порог применяется отдельно к другим наградам.
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
        wonTrophy: trophyWinningClubs.contains(player.club),
      ));
    }

    final eligible = candidates
        .where((item) => item.matches >= 10 && item.rating >= 6.0)
        .toList();
    if (eligible.isEmpty) return [];

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
      return item.rating * 7.5 +
          item.goals * 0.75 +
          item.assists * 0.55 +
          item.matches * 0.035 +
          contributionsPerMatch * 2 +
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
          wonTrophy: item.wonTrophy,
        );

    final result = <SeasonAward>[];

    // Награда «Игрок сезона» выдаётся только при действительно сильном сезоне.
    // Условия совпадают с критериями достижения в архиве карьеры.
    final playerOfSeason = eligible
        .where((item) =>
            item.matches >= 20 &&
            item.rating >= 7.8 &&
            item.goals + item.assists >= 30 &&
            item.wonTrophy)
        .toList()
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
    if (playerOfSeason.isNotEmpty) {
      final seasonWinner = playerOfSeason.first;
      result.add(convert(
        seasonWinner,
        'Игрок сезона',
        performanceScore(seasonWinner, includeTeamSuccess: true),
      ));
    }

    final youngPlayers = eligible
        .where((item) => item.age <= 21 && item.matches >= 15 && item.rating >= 7.0)
        .toList()
      ..sort((a, b) => performanceScore(b).compareTo(performanceScore(a)));
    if (youngPlayers.isNotEmpty) {
      result.add(convert(
        youngPlayers.first,
        'Лучший молодой игрок',
        performanceScore(youngPlayers.first),
      ));
    }

    // «Золотая бутса» появляется только при достижении порога конкретной лиги.
    final league = Clubs.leagueOf(player.club);
    final goldenBootThreshold = league?.goldenBootGoalThreshold ?? 21;
    final goalLeaders = candidates
        .where((item) =>
            item.matches >= 10 &&
            item.goals > 0 &&
            item.goals >= goldenBootThreshold)
        .toList()
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

    // Не выдаём награду ассистента за несколько случайных передач.
    final assistLeaders = candidates
        .where((item) {
          if (item.matches < 20) return false;
          final league = Clubs.leagueOf(item.club);
          if (league == null) return false;
          if (item.assists >= league.bestAssisterThreshold) return true;
          final isTopLeague =
              league == League.england || league == League.spain;
          return isTopLeague && item.assists >= 18 && item.rating >= 8.0;
        })
        .toList()
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

    // Золотой мяч: единая гонка между игроком карьеры и футболистами
    // из ростеров всех лиг. Статистика остальных игроков моделируется
    // детерминированно на сезон, поэтому результаты не меняются при перезагрузке.
    final ballonCandidates = candidates
        .where((item) => !item.isCareerPlayer)
        .toList();
    final ballonStats = overallSeasonStats ?? seasonStats;
    if (ballonStats.matches > 0) {
      ballonCandidates.add(_Candidate(
        name: player.name,
        club: player.club,
        position: player.position,
        age: player.age,
        matches: ballonStats.matches,
        goals: ballonStats.goals,
        assists: ballonStats.assists,
        rating: ballonStats.averageRating ?? 0,
        isCareerPlayer: true,
        wonTrophy: trophyWinningClubs.contains(player.club),
      ));
    }
    final knownPlayers = ballonCandidates
        .map((item) => '${item.name}|${item.club}')
        .toSet();

    int seedFor(String value) {
      var seed = 17;
      for (final unit in value.codeUnits) {
        seed = (seed * 31 + unit) & 0x7fffffff;
      }
      return seed;
    }

    for (final clubEntry in RealClubSquads.squads.entries) {
      for (final group in clubEntry.value.entries) {
        final position = switch (group.key) {
          'goalkeeper' => PlayerPosition.goalkeeper,
          'defender' => PlayerPosition.defender,
          'midfielder' => PlayerPosition.midfielder,
          _ => PlayerPosition.forward,
        };
        for (final realPlayer in group.value) {
          final key = '${realPlayer.name}|${clubEntry.key}';
          if (!knownPlayers.add(key)) continue;
          final random = Random(seedFor('$season|$key'));
          final matches = 28 + random.nextInt(11);
          final rating = (6.55 +
                  (realPlayer.overall - 70) * 0.05 +
                  random.nextDouble() * 0.35)
              .clamp(6.2, 8.9)
              .toDouble();
          final goals = switch (position) {
            PlayerPosition.forward =>
              ((realPlayer.overall - 65) * 0.72 + random.nextInt(9))
                  .round()
                  .clamp(0, 45)
                  .toInt(),
            PlayerPosition.midfielder =>
              ((realPlayer.overall - 65) * 0.27 + random.nextInt(6))
                  .round()
                  .clamp(0, 25)
                  .toInt(),
            PlayerPosition.defender => random.nextInt(5),
            PlayerPosition.goalkeeper => 0,
          };
          final assists = switch (position) {
            PlayerPosition.forward =>
              ((realPlayer.overall - 65) * 0.25 + random.nextInt(8))
                  .round()
                  .clamp(0, 25)
                  .toInt(),
            PlayerPosition.midfielder =>
              ((realPlayer.overall - 65) * 0.43 + random.nextInt(9))
                  .round()
                  .clamp(0, 30)
                  .toInt(),
            PlayerPosition.defender => random.nextInt(6),
            PlayerPosition.goalkeeper => 0,
          };
          ballonCandidates.add(_Candidate(
            name: realPlayer.name,
            club: clubEntry.key,
            position: position,
            age: realPlayer.age,
            matches: matches,
            goals: goals,
            assists: assists,
            rating: rating,
            isCareerPlayer: false,
            wonTrophy: trophyWinningClubs.contains(clubEntry.key),
          ));
        }
      }
    }

    final ballonEligible = ballonCandidates.where((item) {
      final contributions = item.goals + item.assists;
      if (item.matches < 25 || item.rating < 7.7 || contributions < 28) {
        return false;
      }
      // Игрок карьеры должен провести по-настоящему элитный сезон и выиграть трофей.
      if (item.isCareerPlayer) {
        return item.wonTrophy && item.rating >= 7.9 && contributions >= 35;
      }
      return true;
    }).toList();

    double ballonScore(_Candidate item) =>
        item.rating * 12 +
        item.goals * 0.72 +
        item.assists * 0.48 +
        (item.wonTrophy ? 4.0 : 0.0);

    ballonEligible.sort((a, b) => ballonScore(b).compareTo(ballonScore(a)));
    if (ballonEligible.isNotEmpty) {
      final winner = ballonEligible.first;
      result.add(convert(winner, 'Золотой мяч', ballonScore(winner)));
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
  final bool wonTrophy;

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
    required this.wonTrophy,
  });
}
