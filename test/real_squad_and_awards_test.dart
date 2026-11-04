import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career_world_transfer.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_match.dart';
import 'package:flutter_football/models/league_player_season_stats.dart';
import 'package:flutter_football/models/league_table.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/position_rival.dart';
import 'package:flutter_football/models/real_club_squads.dart';
import 'package:flutter_football/models/season_stats.dart';
import 'package:flutter_football/services/season_award_service.dart';

void main() {
  group('Real club squads', () {
    setUp(() => RealClubSquads.applyCareerTransfers(const []));

    test('does not add generated players to clubs with real squads', () {
      const fixtures = [
        LeagueMatch(
          id: 1,
          round: 1,
          homeTeam: 'Real Madrid',
          awayTeam: 'Barcelona',
        ),
      ];

      final update = LeaguePlayerStatsService.update(
        season: 1,
        current: const [],
        processedMatchKeys: const [],
        fixtures: fixtures,
      );

      for (final club in ['Real Madrid', 'Barcelona']) {
        final expected = RealClubSquads.squads[club]!
            .values
            .expand((players) => players)
            .map((player) => player.name)
            .toSet();
        final actual = update.players
            .where((player) => player.club == club)
            .map((player) => player.playerName)
            .toSet();

        expect(actual, expected);
      }
    });

    test('does not add generated players to a club receiving a real transfer', () {
      final transferredPlayer =
          RealClubSquads.squads['Real Madrid']!['forward']!.first;
      RealClubSquads.applyCareerTransfers([
        CareerWorldTransfer(
          playerName: transferredPlayer.name,
          fromClub: 'Real Madrid',
          toClub: 'Newly Promoted FC',
          position: 'forward',
          age: transferredPlayer.age,
          overall: transferredPlayer.overall,
          jerseyNumber: transferredPlayer.jerseyNumber,
          season: 2,
        ),
      ]);

      final update = LeaguePlayerStatsService.update(
        season: 2,
        current: const [],
        processedMatchKeys: const [],
        fixtures: const [
          LeagueMatch(
            id: 1,
            round: 1,
            homeTeam: 'Newly Promoted FC',
            awayTeam: 'Real Madrid',
          ),
        ],
      );

      final destinationPlayers = update.players
          .where((player) => player.club == 'Newly Promoted FC')
          .map((player) => player.playerName)
          .toList();
      expect(destinationPlayers, [transferredPlayer.name]);
    });

    test('keeps monthly history for real rosters smaller than eleven players', () {
      final firstRealPlayer =
          RealClubSquads.squads['Real Madrid']!['goalkeeper']!.first;
      final update = LeaguePlayerStatsService.update(
        season: 1,
        current: [
          LeaguePlayerSeasonStats(
            playerName: firstRealPlayer.name,
            club: 'Real Madrid',
            position: PlayerPosition.goalkeeper,
            age: firstRealPlayer.age,
            overall: firstRealPlayer.overall,
            matches: 1,
            goals: 1,
            ratingSum: 7.5,
            monthlyStats: const {
              1: LeaguePlayerMonthStats(
                matches: 1,
                goals: 1,
                ratingSum: 7.5,
              ),
            },
          ),
        ],
        processedMatchKeys: const ['1:1'],
        fixtures: const [
          LeagueMatch(
            id: 1,
            round: 1,
            homeTeam: 'Real Madrid',
            awayTeam: 'Barcelona',
            homeGoals: 1,
            awayGoals: 0,
          ),
        ],
      );

      final restoredPlayer = update.players.firstWhere(
        (player) =>
            player.club == 'Real Madrid' &&
            player.playerName == firstRealPlayer.name,
      );
      expect(restoredPlayer.matches, 1);
      expect(restoredPlayer.goals, 1);
      expect(restoredPlayer.monthlyStats[1]?.matches, 1);
    });

    test('removes generated players from old saved rosters', () {
      final update = LeaguePlayerStatsService.update(
        season: 2,
        current: const [
          LeaguePlayerSeasonStats(
            playerName: 'Random Generated Player',
            club: 'Real Madrid',
            position: PlayerPosition.forward,
            age: 24,
            overall: 75,
          ),
        ],
        processedMatchKeys: const [],
        fixtures: const [
          LeagueMatch(
            id: 1,
            round: 1,
            homeTeam: 'Real Madrid',
            awayTeam: 'Barcelona',
          ),
        ],
      );

      expect(
        update.players.any(
          (player) =>
              player.club == 'Real Madrid' &&
              player.playerName == 'Random Generated Player',
        ),
        isFalse,
      );
      expect(
        update.players.where((player) => player.club == 'Real Madrid').length,
        RealClubSquads.squads['Real Madrid']!
            .values
            .fold<int>(0, (sum, group) => sum + group.length),
      );
    });
  });

  group('Ballon d\'Or', () {
    test('uses overall season stats and requires the career-player thresholds', () {
      const skills = PlayerSkills(
        pace: 90,
        physical: 90,
        passing: 90,
        shooting: 90,
        defending: 70,
        dribbling: 90,
        heading: 85,
        vision: 90,
      );
      const player = Player(
        name: 'Career Star',
        nationality: 'Россия',
        position: PlayerPosition.forward,
        age: 24,
        season: 4,
        club: 'Real Madrid',
        overall: 90,
        skills: skills,
      );
      const table = [
        LeagueTableEntry(
          club: 'Real Madrid',
          played: 38,
          wins: 30,
          draws: 5,
          losses: 3,
          goalsFor: 90,
          goalsAgainst: 25,
        ),
      ];
      const overallStats = SeasonStats(
        season: 4,
        club: 'Real Madrid',
        matches: 32,
        goals: 50,
        assists: 20,
        yellowCards: 1,
        redCards: 0,
        averageRating: 9.0,
      );

      final awards = SeasonAwardService.create(
        season: 4,
        player: player,
        seasonStats: overallStats,
        overallSeasonStats: overallStats,
        leaguePlayerStats: const [],
        leagueTable: table,
        rivals: const <PositionRival>[],
        worldLeagueStandings: const <League, List<LeagueTableEntry>>{},
      );

      final ballonDor = awards.firstWhere(
        (award) => award.category == 'Золотой мяч',
      );
      expect(ballonDor.playerName, 'Career Star');
      expect(ballonDor.isCareerPlayer, isTrue);
      expect(ballonDor.matches, 32);
      expect(ballonDor.goals + ballonDor.assists, 70);
    });

    test('does not award the Ballon d\'Or to a career player with 34 contributions and no team trophy', () {
      const skills = PlayerSkills(
        pace: 90,
        physical: 90,
        passing: 90,
        shooting: 90,
        defending: 70,
        dribbling: 90,
        heading: 85,
        vision: 90,
      );
      const player = Player(
        name: 'Career Star',
        nationality: 'Россия',
        position: PlayerPosition.forward,
        age: 24,
        season: 4,
        club: 'Real Madrid',
        overall: 90,
        skills: skills,
      );
      const stats = SeasonStats(
        season: 4,
        club: 'Real Madrid',
        matches: 32,
        goals: 30,
        assists: 4,
        yellowCards: 1,
        redCards: 0,
        averageRating: 9.8,
      );
      const table = [
        LeagueTableEntry(
          club: 'Barcelona',
          played: 38,
          wins: 30,
          draws: 5,
          losses: 3,
          goalsFor: 90,
          goalsAgainst: 25,
        ),
      ];

      final awards = SeasonAwardService.create(
        season: 4,
        player: player,
        seasonStats: stats,
        overallSeasonStats: stats,
        leaguePlayerStats: const [],
        leagueTable: table,
        rivals: const <PositionRival>[],
        worldLeagueStandings: const <League, List<LeagueTableEntry>>{},
      );

      final ballonDor = awards.firstWhere(
        (award) => award.category == 'Золотой мяч',
      );
      expect(ballonDor.playerName, 'Career Star');
      expect(ballonDor.isCareerPlayer, isTrue);
      expect(ballonDor.goals + ballonDor.assists, 34);
      expect(ballonDor.wonTrophy, isFalse);
    });
  });
}
