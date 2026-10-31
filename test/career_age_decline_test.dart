import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career.dart';
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
}
