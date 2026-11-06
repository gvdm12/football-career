import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/career_settings.dart';
import 'package:flutter_football/models/friendly_match.dart';
import 'package:flutter_football/models/league_player_season_stats.dart';
import 'package:flutter_football/models/league_table.dart';
import 'package:flutter_football/models/position_rival.dart';
import 'package:flutter_football/models/season_stats.dart';
import 'package:flutter_football/services/season_award_service.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/services/pre_season_service.dart';

Career createTestCareer({CareerSettings settings = const CareerSettings(), int season = 1}) {
  final player = Player.create(
    name: 'Test Player',
    nationality: 'Россия',
    position: PlayerPosition.forward,
    club: 'Real Madrid',
  );
  return Career.create(player, settings: settings).copyWith(
    season: season,
    contractYears: 3,
  );
}

const unplayedTeamMatch = Match(
  homeTeam: 'Real Madrid',
  awayTeam: 'Barcelona',
  homeGoals: 1,
  awayGoals: 0,
  playerGoals: 0,
  playerAssists: 0,
  yellowCards: 0,
  redCards: 0,
  playerRating: 0,
  playerPlayed: false,
);

void main() {
  group('Negotiation cooldowns', () {
    test('counts a club fixture even when the player did not play', () {
      final career = createTestCareer();
      final updated = career.afterMatch(unplayedTeamMatch);

      expect(updated.teamMatches, 1);
      expect(updated.matches, 0);
    });

    test('staff purchase cooldown advances after a team match even when the player does not play', () {
      final career = createTestCareer().copyWith(
        temporarySkillBoosts: const {'shooting': 5},
        temporarySkillBoostMatches: const {
          'shooting': 2,
          'psychologist': 10,
          'personalTrainer': 10,
        },
      );

      final updated = career.afterMatch(unplayedTeamMatch);

      expect(updated.temporarySkillBoostMatches['psychologist'], 9);
      expect(updated.temporarySkillBoostMatches['personalTrainer'], 9);
      expect(updated.temporarySkillBoostMatches['shooting'], 2);
      expect(updated.temporarySkillBoosts['shooting'], 5);
    });

    test('coach and agent cooldowns are independent', () {
      final career = createTestCareer().copyWith(
        teamMatches: 12,
        lastCoachNegotiationTeamMatch: 12,
      );

      expect(
        career.teamMatches - career.lastCoachNegotiationTeamMatch < 7,
        isTrue,
      );
      expect(
        career.teamMatches - career.lastAgentNegotiationTeamMatch >= 7,
        isTrue,
      );
    });

    test('the same negotiation becomes available after seven team matches', () {
      final career = createTestCareer().copyWith(
        teamMatches: 20,
        lastCoachNegotiationTeamMatch: 13,
        lastAgentNegotiationTeamMatch: 20,
      );

      expect(career.teamMatches - career.lastCoachNegotiationTeamMatch, 7);
      expect(career.teamMatches - career.lastAgentNegotiationTeamMatch, 0);
    });
  });

  group('Career modes', () {
    test('five-season transfer limit blocks early club changes', () {
      final career = createTestCareer(
        settings: const CareerSettings(limitTransfersToFiveYears: true),
        season: 4,
      ).copyWith(lastClubChangeSeason: 1);

      expect(career.canChangeClub, isFalse);
      expect(career.seasonsUntilClubChange, 2);
      expect(career.copyWith(contractYears: 0).canChangeClub, isFalse);
      expect(career.copyWith(season: 6).canChangeClub, isTrue);
    });

    test('five-season transfer cooldown survives starting the next season', () {
      final career = createTestCareer(
        settings: const CareerSettings(limitTransfersToFiveYears: true),
        season: 5,
      ).copyWith(lastClubChangeSeason: 5);

      final nextSeason = career.startNextSeason();

      expect(nextSeason.season, 6);
      expect(nextSeason.lastClubChangeSeason, 5);
      expect(nextSeason.canChangeClub, isFalse);
      expect(nextSeason.seasonsUntilClubChange, 4);
      expect(nextSeason.copyWith(season: 10).canChangeClub, isTrue);
    });

    test('no-injury mode clears an existing injury and prevents new ones', () {
      final career = createTestCareer(
        settings: const CareerSettings(playWithoutInjuries: true),
      ).copyWith(
        injuryName: 'Test injury',
        injuryMatchesRemaining: 4,
        temporarySkillBoosts: const {'shooting': 1},
        temporarySkillBoostMatches: const {'shooting': 2},
      );

      expect(career.isInjured, isFalse);
      final updated = career.advanceAfterCompetitionMatch(
        playerParticipated: true,
      );

      expect(updated.injuryMatchesRemaining, 0);
      expect(updated.injuryName, isNull);
      expect(updated.isInjured, isFalse);
      expect(updated.temporarySkillBoostMatches['shooting'], 1);
    });

    test('new career settings survive JSON serialization', () {
      const settings = CareerSettings(
        allowAnyStartingClub: true,
        difficulty: CareerDifficulty.hard,
        limitTransfersToFiveYears: true,
        playWithoutInjuries: true,
      );

      final restored = CareerSettings.fromJson(settings.toJson());

      expect(restored.allowAnyStartingClub, isTrue);
      expect(restored.difficulty, CareerDifficulty.hard);
      expect(restored.limitTransfersToFiveYears, isTrue);
      expect(restored.playWithoutInjuries, isTrue);
    });
  });


  group('Season leader awards', () {
    test('awards the top scorer and assist leader among current league candidates', () {
      final player = Player.create(
        name: 'Career Player',
        nationality: 'Россия',
        position: PlayerPosition.forward,
        club: 'Real Madrid',
      );
      final awards = SeasonAwardService.create(
        season: 1,
        player: player,
        seasonStats: const SeasonStats(
          season: 1,
          club: 'Real Madrid',
          matches: 0,
          goals: 0,
          assists: 0,
          yellowCards: 0,
          redCards: 0,
          averageRating: null,
        ),
        leaguePlayerStats: const [
          LeaguePlayerSeasonStats(
            playerName: 'Top Scorer',
            club: 'Real Madrid',
            position: PlayerPosition.forward,
            age: 26,
            overall: 86,
            matches: 30,
            goals: 35,
            assists: 2,
            ratingSum: 210,
          ),
          LeaguePlayerSeasonStats(
            playerName: 'Top Assister',
            club: 'Barcelona',
            position: PlayerPosition.midfielder,
            age: 25,
            overall: 85,
            matches: 30,
            goals: 3,
            assists: 100,
            ratingSum: 210,
          ),
        ],
        leagueTable: const <LeagueTableEntry>[],
        rivals: const <PositionRival>[],
        worldLeagueStandings: const <League, List<LeagueTableEntry>>{},
      );

      expect(
        awards.any(
          (award) =>
              award.category == 'Лучший бомбардир' &&
              award.playerName == 'Top Scorer',
        ),
        isTrue,
      );
      expect(
        awards.any(
          (award) =>
              award.category == 'Лучший ассистент' &&
              award.playerName == 'Top Assister',
        ),
        isTrue,
      );
    });

    test('awards the league Golden Boot to the actual top scorer below the achievement threshold', () {
      final player = Player.create(
        name: 'Career Player',
        nationality: 'Россия',
        position: PlayerPosition.forward,
        club: 'Real Madrid',
      );
      final awards = SeasonAwardService.create(
        season: 2,
        player: player,
        seasonStats: const SeasonStats(
          season: 2,
          club: 'Real Madrid',
          matches: 30,
          goals: 16,
          assists: 4,
          yellowCards: 0,
          redCards: 0,
          averageRating: 8.0,
        ),
        leaguePlayerStats: const [],
        leagueTable: const <LeagueTableEntry>[
          LeagueTableEntry(
            club: 'Real Madrid',
            played: 38,
            wins: 20,
            draws: 8,
            losses: 10,
            goalsFor: 60,
            goalsAgainst: 40,
          ),
        ],
        rivals: const <PositionRival>[],
        worldLeagueStandings: const <League, List<LeagueTableEntry>>{},
      );

      final goldenBoot = awards.where(
        (award) => award.category == 'Лучший бомбардир',
      ).toList();
      expect(goldenBoot, isNotEmpty);
      expect(goldenBoot.every((award) => !award.isCareerPlayer), isTrue);
      expect(goldenBoot.first.goals, greaterThan(16));
    });
  });

  group('Preseason friendlies', () {
    test('generates no more than two friendly matches', () {
      final friendlies = PreSeasonService.create(
        playerClub: 'Real Madrid',
        season: 1,
      );

      expect(friendlies.length, lessThanOrEqualTo(2));
    });

    test('skipped friendly state survives JSON serialization', () {
      final skipped = const FriendlyMatch(
        number: 1,
        opponent: 'Barcelona',
        isHome: true,
      ).copyWith(isSkipped: true);

      final restored = FriendlyMatch.fromJson(skipped.toJson());

      expect(restored.isSkipped, isTrue);
      expect(restored.isResolved, isTrue);
    });
  });
}
