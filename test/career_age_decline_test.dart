import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/player.dart';

void main() {
  group('Career age decline', () {
    final clubName = Clubs.all.first.name;

    Career careerFor(PlayerPosition position) {
      const skills = PlayerSkills(
        pace: 80,
        physical: 80,
        passing: 80,
        shooting: 80,
        defending: 80,
        dribbling: 80,
        heading: 80,
        vision: 80,
      );
      final player = Player(
        name: 'Test Player',
        nationality: 'Россия',
        position: position,
        age: 33,
        season: 15,
        club: clubName,
        overall: calculateOverall(skills: skills, position: position),
        skills: skills,
      );

      return Career.create(player).copyWith(season: 15).startNextSeason();
    }

    test('forward decline affects pace and dribbling, not shooting twice', () {
      final skills = careerFor(PlayerPosition.forward).player.skills;

      expect(skills.shooting, 77);
      expect(skills.pace, 77);
      expect(skills.dribbling, 76);
      expect(skills.passing, 78);
    });

    test('midfielder decline affects pace and dribbling correctly', () {
      final skills = careerFor(PlayerPosition.midfielder).player.skills;

      expect(skills.passing, 76);
      expect(skills.pace, 76);
      expect(skills.dribbling, 77);
      expect(skills.shooting, 78);
    });

    test('defender decline keeps other skills at the base decline', () {
      final skills = careerFor(PlayerPosition.defender).player.skills;

      expect(skills.defending, 77);
      expect(skills.pace, 78);
      expect(skills.shooting, 78);
    });

    test('goalkeeper decline keeps other skills at the base decline', () {
      final skills = careerFor(PlayerPosition.goalkeeper).player.skills;

      expect(skills.defending, 77);
      expect(skills.pace, 78);
      expect(skills.shooting, 78);
    });
  });

  group('Career progression systems', () {
    final clubName = Clubs.all.first.name;

    Player createTestPlayer() {
      const skills = PlayerSkills(
        pace: 70,
        physical: 70,
        passing: 70,
        shooting: 70,
        defending: 70,
        dribbling: 70,
        heading: 70,
        vision: 70,
      );
      return Player(
        name: 'Test Player',
        nationality: 'Россия',
        position: PlayerPosition.forward,
        age: 22,
        season: 1,
        club: clubName,
        overall: calculateOverall(
          skills: skills,
          position: PlayerPosition.forward,
        ),
        skills: skills,
      );
    }

    test('new career creates two position rivals', () {
      final career = Career.create(createTestPlayer());
      expect(career.rivals.length, 2);
    });

    test('rivals, trust and agent level survive save restoration', () {
      final career = Career.create(createTestPlayer()).copyWith(
        coachTrust: 82,
        agentLevel: 3,
        agentCredits: 234,
      );
      final restored = Career.fromJson(career.toJson());

      expect(restored.rivals.length, career.rivals.length);
      expect(restored.coachTrust, 82);
      expect(restored.agentLevel, 3);
      expect(restored.agentCredits, 234);
      expect(restored.coachName, career.coachName);
    });

    test('a player who did not play earns no match currency', () {
      final career = Career.create(createTestPlayer());
      const match = Match(
        homeTeam: 'Club',
        awayTeam: 'Opponent',
        homeGoals: 1,
        awayGoals: 0,
        playerGoals: 0,
        playerAssists: 0,
        yellowCards: 0,
        redCards: 0,
        playerRating: 0,
        playerPlayed: false,
      );

      expect(career.afterMatch(match).agentCredits, 0);
    });

    test('strong performance increases coach trust', () {
      final career = Career.create(createTestPlayer());
      const match = Match(
        homeTeam: 'Club',
        awayTeam: 'Opponent',
        homeGoals: 2,
        awayGoals: 1,
        playerGoals: 1,
        playerAssists: 0,
        yellowCards: 0,
        redCards: 0,
        playerRating: 8.5,
        playerPlayed: true,
      );

      final updated = career.afterMatch(match);
      expect(updated.coachTrust, 68);
      expect(updated.agentCredits, 23);
    });
  });
}
