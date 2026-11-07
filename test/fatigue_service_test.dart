import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/season_match.dart';
import 'package:flutter_football/services/fatigue_service.dart';

Match _match({
  required String home,
  required String away,
  bool playerPlayed = true,
}) {
  return Match(
    homeTeam: home,
    awayTeam: away,
    homeGoals: 1,
    awayGoals: 0,
    playerGoals: 0,
    playerAssists: 0,
    yellowCards: 0,
    redCards: 0,
    playerRating: 6.8,
    playerPlayed: playerPlayed,
  );
}

Career _career() {
  const skills = PlayerSkills(
    pace: 80,
    physical: 80,
    passing: 70,
    shooting: 75,
    defending: 40,
    dribbling: 72,
    heading: 60,
    vision: 66,
  );
  final player = Player(
    name: 'Test Player',
    nationality: 'Россия',
    position: PlayerPosition.forward,
    age: 22,
    season: 1,
    club: Clubs.all.first.name,
    overall: calculateOverall(skills: skills, position: PlayerPosition.forward),
    skills: skills,
  );
  return Career.create(player);
}

void main() {
  group('FatigueService.afterMatch', () {
    test('a played non-league match adds the full load', () {
      expect(
        FatigueService.afterMatch(
          current: 20,
          playerPlayed: true,
          isLeagueFixture: false,
        ),
        20 + FatigueService.matchLoad,
      );
    });

    test('a played league match nets load minus weekly recovery', () {
      expect(
        FatigueService.afterMatch(
          current: 20,
          playerPlayed: true,
          isLeagueFixture: true,
        ),
        20 + FatigueService.matchLoad - FatigueService.weeklyRecovery,
      );
    });

    test('a benched league match only recovers', () {
      expect(
        FatigueService.afterMatch(
          current: 30,
          playerPlayed: false,
          isLeagueFixture: true,
        ),
        30 - FatigueService.weeklyRecovery,
      );
    });

    test('a benched cup match changes nothing', () {
      expect(
        FatigueService.afterMatch(
          current: 30,
          playerPlayed: false,
          isLeagueFixture: false,
        ),
        30,
      );
    });

    test('stays within 0..100', () {
      expect(
        FatigueService.afterMatch(
          current: 0,
          playerPlayed: false,
          isLeagueFixture: true,
        ),
        0,
      );
      expect(
        FatigueService.afterMatch(
          current: 98,
          playerPlayed: true,
          isLeagueFixture: false,
        ),
        FatigueService.max,
      );
    });
  });

  group('FatigueService.isLeagueFixture', () {
    const club = 'Мой клуб';
    final seasonMatches = [
      const SeasonMatch(number: 1, opponent: 'Соперник А', isHome: true),
      const SeasonMatch(number: 2, opponent: 'Соперник Б', isHome: false),
    ];

    test('matches the next unplayed league fixture', () {
      expect(
        FatigueService.isLeagueFixture(
          match: _match(home: club, away: 'Соперник А'),
          playerClub: club,
          seasonMatches: seasonMatches,
        ),
        isTrue,
      );
    });

    test('a cup match against someone else is not a league fixture', () {
      expect(
        FatigueService.isLeagueFixture(
          match: _match(home: club, away: 'Соперник Б'),
          playerClub: club,
          seasonMatches: seasonMatches,
        ),
        isFalse,
      );
    });

    test('venue must match as well', () {
      expect(
        FatigueService.isLeagueFixture(
          match: _match(home: 'Соперник А', away: club),
          playerClub: club,
          seasonMatches: seasonMatches,
        ),
        isFalse,
      );
    });

    test('false when the whole calendar is already played', () {
      final played = [
        SeasonMatch(
          number: 1,
          opponent: 'Соперник А',
          isHome: true,
          result: _match(home: club, away: 'Соперник А'),
        ),
      ];
      expect(
        FatigueService.isLeagueFixture(
          match: _match(home: club, away: 'Соперник А'),
          playerClub: club,
          seasonMatches: played,
        ),
        isFalse,
      );
    });
  });

  group('FatigueService effects', () {
    test('no penalties up to the thresholds', () {
      expect(FatigueService.physicalSkillPenalty(0), 0);
      expect(
        FatigueService.physicalSkillPenalty(FatigueService.skillPenaltyThreshold),
        0,
      );
      expect(FatigueService.selectionPenalty(0), 0);
      expect(
        FatigueService.selectionPenalty(FatigueService.selectionThreshold),
        0,
      );
    });

    test('penalties grow with fatigue and are capped', () {
      var previousSkill = 0;
      var previousSelection = 0.0;
      for (var fatigue = 0; fatigue <= 100; fatigue += 5) {
        final skill = FatigueService.physicalSkillPenalty(fatigue);
        final selection = FatigueService.selectionPenalty(fatigue);
        expect(skill, greaterThanOrEqualTo(previousSkill));
        expect(selection, greaterThanOrEqualTo(previousSelection));
        previousSkill = skill;
        previousSelection = selection;
      }
      expect(FatigueService.physicalSkillPenalty(100), 3);
      expect(FatigueService.technicalSkillPenalty(100), 1);
      expect(FatigueService.selectionPenalty(100), closeTo(0.16, 1e-9));
    });

    test('labels cover the whole scale in both languages', () {
      expect(FatigueService.label(0, english: true), 'Fresh');
      expect(FatigueService.label(30, english: true), 'Normal');
      expect(FatigueService.label(60, english: true), 'Tired');
      expect(FatigueService.label(90, english: true), 'Exhausted');
      expect(FatigueService.label(0, english: false), 'Свеж');
      expect(FatigueService.label(90, english: false), 'Измотан');
    });
  });

  group('Career fatigue', () {
    test('new career starts fresh', () {
      expect(_career().fatigue, 0);
    });

    test('survives a JSON round trip and defaults for old saves', () {
      final tired = _career().copyWith(fatigue: 37);
      final json = jsonDecode(jsonEncode(tired.toJson())) as Map<String, dynamic>;

      expect(Career.fromJson(json).fatigue, 37);

      json.remove('fatigue');
      expect(Career.fromJson(json).fatigue, 0);
    });

    test('playerForMatch lowers skills only for the match', () {
      final fresh = _career();
      final exhausted = fresh.copyWith(fatigue: 100);

      final matchPlayer = exhausted.playerForMatch;

      expect(matchPlayer.skills.pace, fresh.player.skills.pace - 3);
      expect(matchPlayer.skills.physical, fresh.player.skills.physical - 3);
      expect(matchPlayer.skills.shooting, fresh.player.skills.shooting - 1);
      expect(exhausted.player.skills.pace, fresh.player.skills.pace);
      expect(fresh.playerForMatch.skills.pace, fresh.player.skills.pace);
    });

    test('afterMatch adds load for a cup match and recovers in the league', () {
      final career = _career();
      final fixture = career.seasonMatches.first;
      final club = career.player.club;

      final leagueMatch = _match(
        home: fixture.isHome ? club : fixture.opponent,
        away: fixture.isHome ? fixture.opponent : club,
      );
      final afterLeague = career.copyWith(fatigue: 30).afterMatch(leagueMatch);
      expect(
        afterLeague.fatigue,
        30 + FatigueService.matchLoad - FatigueService.weeklyRecovery,
      );

      final cupMatch = _match(home: club, away: 'Совсем другой клуб');
      final afterCup = career.copyWith(fatigue: 30).afterMatch(cupMatch);
      expect(afterCup.fatigue, 30 + FatigueService.matchLoad);
    });

    test('a tired player is selected less often than a fresh one', () {
      final fresh = _career();
      final exhausted = fresh.copyWith(fatigue: 100);
      final opponents = Clubs.all.map((club) => club.name).take(40).toList();

      int starts(Career career) {
        var count = 0;
        for (final opponent in opponents) {
          for (final isHome in [true, false]) {
            if (Match.willPlayerPlay(
              player: career.player,
              career: career,
              opponent: opponent,
              isHome: isHome,
            )) {
              count++;
            }
          }
        }
        return count;
      }

      expect(starts(exhausted), lessThanOrEqualTo(starts(fresh)));
    });
  });
}
