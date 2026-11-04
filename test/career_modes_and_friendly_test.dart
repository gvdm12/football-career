import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/career_settings.dart';
import 'package:flutter_football/models/friendly_match.dart';
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
      expect(career.copyWith(season: 6).canChangeClub, isTrue);
    });

    test('no-injury mode clears an existing injury and prevents new ones', () {
      final career = createTestCareer(
        settings: const CareerSettings(playWithoutInjuries: true),
      ).copyWith(
        injuryName: 'Test injury',
        injuryMatchesRemaining: 4,
      );

      expect(career.isInjured, isFalse);
      final updated = career.advanceAfterCompetitionMatch(
        playerParticipated: true,
      );

      expect(updated.injuryMatchesRemaining, 0);
      expect(updated.injuryName, isNull);
      expect(updated.isInjured, isFalse);
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
