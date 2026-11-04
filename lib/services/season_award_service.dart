import 'dart:math';

import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_player_season_stats.dart';
import 'package:flutter_football/models/league_table.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/season_award.dart';
import 'package:flutter_football/models/season_stats.dart';
import 'package:flutter_football/models/position_rival.dart';
import 'package:flutter_football/models/real_club_squads.dart';

class SeasonAwardService {
  static List<SeasonAward> create({
    required int season,
    required Player player,
    required SeasonStats seasonStats,
    required List<LeaguePlayerSeasonStats> leaguePlayerStats,
    required List<LeagueTableEntry> leagueTable,
    required List<PositionRival> rivals,
    List<String> additionalTrophyWinningClubs = const [],
    required Map<League, List<LeagueTableEntry>> worldLeagueStandings,
    SeasonStats? overallSeasonStats,
  }) {
    final playerLeague = Clubs.leagueOf(player.club);
    final goldenBootThreshold =
        playerLeague?.goldenBootGoalThreshold ?? 0;
    final bestAssisterThreshold =
        playerLeague?.bestAssisterThreshold ?? 0;
    final sortedTable = [...leagueTable]
      ..sort(
        (a, b) => b.points != a.points
            ? b.points.compareTo(a.points)
            : b.goalDifference.compareTo(a.goalDifference),
      );
    final worldChampions = <String>{};
    for (final entry in worldLeagueStandings.entries) {
      final standings = [...entry.value]
        ..sort(
          (a, b) => b.points != a.points
              ? b.points.compareTo(a.points)
              : b.goalDifference.compareTo(a.goalDifference),
        );
      if (standings.isNotEmpty) worldChampions.add(standings.first.club);
    }
    final trophyWinningClubs = <String>{
      ...additionalTrophyWinningClubs,
      ...worldChampions,
      if (sortedTable.isNotEmpty) sortedTable.first.club,
    };
    final candidates = <_Candidate>[];

    int seedFor(String value) {
      var seed = 17;
      for (final unit in value.codeUnits) {
        seed = (seed * 31 + unit) & 0x7fffffff;
      }
      return seed;
    }

    for (final item in leaguePlayerStats) {
      if (item.matches == 0) continue;
      if (item.club == player.club &&
          (item.playerName == player.name ||
              rivals.any((rival) => rival.name == item.playerName))) {
        continue;
      }
      candidates.add(
        _Candidate(
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
        ),
      );
    }

    // Конкуренты за позицию входят в общий список наград с той же
    // статистикой, которая отображается на экране команды.
    for (final rival in rivals) {
      if (rival.matches == 0) continue;
      candidates.add(
        _Candidate(
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
        ),
      );
    }

    // Сохраняем исходный пул текущей лиги отдельно: бомбардир и ассистент
    // должны определяться только среди игроков этого чемпионата.
    final leagueCandidates = [...candidates];

    // Игроки всех реальных составов участвуют во всех общих сезонных наградах,
    // а не только в гонке за «Золотой мяч».
    final knownCandidateKeys = candidates
        .map((item) => '${item.name}|${item.club}')
        .toSet();
    for (final clubEntry in RealClubSquads.squads.entries) {
      final clubLeague = Clubs.leagueOf(clubEntry.key);
      final seasonMatches = clubLeague?.matchesPerSeason ?? 34;
      for (final group in clubEntry.value.entries) {
        final position = switch (group.key) {
          'goalkeeper' => PlayerPosition.goalkeeper,
          'defender' => PlayerPosition.defender,
          'midfielder' => PlayerPosition.midfielder,
          _ => PlayerPosition.forward,
        };
        for (final realPlayer in group.value) {
          final key = '${realPlayer.name}|${clubEntry.key}';
          if (!knownCandidateKeys.add(key)) continue;
          final random = Random(seedFor('$season|$key'));
          final matches = (seasonMatches - random.nextInt(12))
              .clamp(20, seasonMatches)
              .toInt();
          final rating = (6.4 +
                  (realPlayer.overall - 70) * 0.06 +
                  random.nextDouble() * 0.45)
              .clamp(6.2, 8.95)
              .toDouble();
          final goals = switch (position) {
            PlayerPosition.forward =>
              ((realPlayer.overall - 65) * 0.75 + random.nextInt(12))
                  .round().clamp(0, 45).toInt(),
            PlayerPosition.midfielder =>
              ((realPlayer.overall - 65) * 0.34 + random.nextInt(8))
                  .round().clamp(0, 28).toInt(),
            PlayerPosition.defender => random.nextInt(6),
            PlayerPosition.goalkeeper => 0,
          };
          final assists = switch (position) {
            PlayerPosition.forward =>
              ((realPlayer.overall - 65) * 0.30 + random.nextInt(10))
                  .round().clamp(0, 25).toInt(),
            PlayerPosition.midfielder =>
              ((realPlayer.overall - 65) * 0.60 + random.nextInt(12))
                  .round().clamp(0, 32).toInt(),
            PlayerPosition.defender => random.nextInt(10),
            PlayerPosition.goalkeeper => 0,
          };
          candidates.add(
            _Candidate(
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
            ),
          );
        }
      }
    }

    // Игрок карьеры участвует на тех же условиях, но его статистика берётся
    // из реальных матчей карьеры, а не из искусственно смоделированного состава.
    if (seasonStats.matches > 0) {
      // Игрок карьеры участвует в гонке бомбардиров даже при малом числе
      // матчей; минимальный порог применяется отдельно к другим наградам.
      final careerCandidate = _Candidate(
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
      );
      candidates.add(careerCandidate);
      leagueCandidates.add(careerCandidate);
    }

    final eligible = candidates
        .where((item) => item.matches >= 10 && item.rating >= 6.0)
        .toList();

    final positions = <String, int>{
      for (var i = 0; i < sortedTable.length; i++) sortedTable[i].club: i + 1,
    };
    for (final entry in worldLeagueStandings.entries) {
      final standings = [...entry.value]
        ..sort(
          (a, b) => b.points != a.points
              ? b.points.compareTo(a.points)
              : b.goalDifference.compareTo(a.goalDifference),
        );
      for (var index = 0; index < standings.length; index++) {
        positions[standings[index].club] = index + 1;
      }
    }

    // Индивидуальная результативность и оценка имеют основной вес.
    // Позиция клуба даёт небольшой контекстный бонус, как в реальных премиях.
    double performanceScore(
      _Candidate item, {
      bool includeTeamSuccess = false,
    }) {
      final contributionsPerMatch = (item.goals + item.assists) / item.matches;
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
    final playerOfSeason =
        eligible
            .where(
              (item) =>
                  item.matches >= 20 &&
                  item.rating >= 7.8 &&
                  item.goals + item.assists >= 40 &&
                  item.wonTrophy,
            )
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
      result.add(
        convert(
          seasonWinner,
          'Игрок сезона',
          performanceScore(seasonWinner, includeTeamSuccess: true),
        ),
      );
    }

    final youngPlayers =
        eligible
            .where(
              (item) =>
                  item.age <= 21 && item.matches >= 15 && item.rating >= 7.0,
            )
            .toList()
          ..sort((a, b) => performanceScore(b).compareTo(performanceScore(a)));
    if (youngPlayers.isNotEmpty) {
      result.add(
        convert(
          youngPlayers.first,
          'Лучший молодой игрок',
          performanceScore(youngPlayers.first),
        ),
      );
    }

    // Награды бомбардиру и ассистенту выдаются только при выполнении
    // порога конкретной лиги. Лидер с 16 голами не получает приз,
    // если для его чемпионата требуется 21/23/27/35 голов.
    final goalLeaders = leagueCandidates
        .where(
          (item) =>
              goldenBootThreshold > 0 &&
              item.matches >= 10 &&
              item.goals >= goldenBootThreshold,
        )
        .toList()
      ..sort((a, b) {
        final compare = b.goals.compareTo(a.goals);
        if (compare != 0) return compare;
        final ratingCompare = b.rating.compareTo(a.rating);
        if (ratingCompare != 0) return ratingCompare;
        return b.assists.compareTo(a.assists);
      });
    if (goalLeaders.isNotEmpty) {
      final topGoals = goalLeaders.first.goals;
      for (final winner in goalLeaders.where((item) => item.goals == topGoals)) {
        result.add(
          convert(winner, 'Лучший бомбардир', winner.goals.toDouble()),
        );
      }
    }

    final assistLeaders = leagueCandidates
        .where(
          (item) =>
              bestAssisterThreshold > 0 &&
              item.matches >= 10 &&
              item.assists >= bestAssisterThreshold,
        )
        .toList()
      ..sort((a, b) {
        final compare = b.assists.compareTo(a.assists);
        if (compare != 0) return compare;
        final ratingCompare = b.rating.compareTo(a.rating);
        if (ratingCompare != 0) return ratingCompare;
        return b.goals.compareTo(a.goals);
      });
    if (assistLeaders.isNotEmpty) {
      final topAssists = assistLeaders.first.assists;
      for (final winner in assistLeaders.where(
        (item) => item.assists == topAssists,
      )) {
        result.add(
          convert(winner, 'Лучший ассистент', winner.assists.toDouble()),
        );
      }
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
      final positionCandidates =
          eligible.where((item) => item.position == entry.key).toList()..sort(
            (a, b) => performanceScore(b).compareTo(performanceScore(a)),
          );
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
      if (result.where((award) => award.category == 'Команда года').length >=
          11) {
        break;
      }
      final key = '${item.name}|${item.club}';
      if (!selected.add(key)) continue;
      result.add(convert(item, 'Команда года', performanceScore(item)));
    }

    // «Золотой мяч» — общая мировая гонка. У каждого кандидата
    // одинаковые критерии: игровое время, средняя оценка и вклад в голы.
    // Победы команды дают бонус, но не являются обязательным условием.
    final ballonStats = overallSeasonStats ?? seasonStats;
    final ballonCandidates = <_Candidate>[
      ...candidates.where((item) => !item.isCareerPlayer),
    ];
    if (ballonStats.matches > 0) {
      ballonCandidates.add(
        _Candidate(
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
        ),
      );
    }

    final ballonTeamPositions = <String, int>{...positions};
    for (final entry in worldLeagueStandings.entries) {
      final standings = [...entry.value]
        ..sort(
          (a, b) => b.points != a.points
              ? b.points.compareTo(a.points)
              : b.goalDifference.compareTo(a.goalDifference),
        );
      for (var index = 0; index < standings.length; index++) {
        ballonTeamPositions[standings[index].club] = index + 1;
      }
    }

    final knownPlayers = ballonCandidates
        .map((item) => '${item.name}|${item.club}')
        .toSet();

    for (final clubEntry in RealClubSquads.squads.entries) {
      final clubLeague = Clubs.leagueOf(clubEntry.key);
      final seasonMatches = clubLeague?.matchesPerSeason ?? 34;
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
          final matches = (seasonMatches - random.nextInt(12))
              .clamp(20, seasonMatches)
              .toInt();
          final rating = (6.4 +
                  (realPlayer.overall - 70) * 0.06 +
                  random.nextDouble() * 0.45)
              .clamp(6.2, 8.95)
              .toDouble();

          final goals = switch (position) {
            PlayerPosition.forward =>
              ((realPlayer.overall - 65) * 0.75 + random.nextInt(12))
                  .round()
                  .clamp(0, 45)
                  .toInt(),
            PlayerPosition.midfielder =>
              ((realPlayer.overall - 65) * 0.34 + random.nextInt(8))
                  .round()
                  .clamp(0, 28)
                  .toInt(),
            PlayerPosition.defender => random.nextInt(6),
            PlayerPosition.goalkeeper => 0,
          };
          final assists = switch (position) {
            PlayerPosition.forward =>
              ((realPlayer.overall - 65) * 0.30 + random.nextInt(10))
                  .round()
                  .clamp(0, 25)
                  .toInt(),
            PlayerPosition.midfielder =>
              ((realPlayer.overall - 65) * 0.60 + random.nextInt(12))
                  .round()
                  .clamp(0, 32)
                  .toInt(),
            PlayerPosition.defender => random.nextInt(10),
            PlayerPosition.goalkeeper => 0,
          };

          ballonCandidates.add(
            _Candidate(
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
            ),
          );
        }
      }
    }

    final ballonEligible = ballonCandidates
        .where(
          (item) =>
              item.matches >= 25 &&
              item.rating >= 7.4 &&
              item.goals + item.assists >= 22,
        )
        .toList();

    double ballonScore(_Candidate item) {
      final teamPosition = ballonTeamPositions[item.club];
      final teamBonus = item.wonTrophy
          ? 4.0
          : teamPosition == 1
          ? 3.0
          : teamPosition != null && teamPosition <= 4
          ? 1.5
          : 0.0;
      return item.rating * 12 +
          item.goals * 0.8 +
          item.assists * 0.65 +
          teamBonus;
    }

    ballonEligible.sort((a, b) {
      final scoreCompare = ballonScore(b).compareTo(ballonScore(a));
      if (scoreCompare != 0) return scoreCompare;
      final ratingCompare = b.rating.compareTo(a.rating);
      if (ratingCompare != 0) return ratingCompare;
      final contributionsCompare = (b.goals + b.assists).compareTo(
        a.goals + a.assists,
      );
      if (contributionsCompare != 0) return contributionsCompare;
      return a.name.compareTo(b.name);
    });
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
