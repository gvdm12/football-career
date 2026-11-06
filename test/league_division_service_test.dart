import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/cup_match.dart';
import 'package:flutter_football/models/domestic_cup.dart';
import 'package:flutter_football/models/league_division_service.dart';
import 'package:flutter_football/models/league_table.dart';
import 'package:flutter_football/models/league_season_simulator.dart';
import 'package:flutter_football/services/app_strings.dart';

void main() {
  group('Career club state', () {
    test('new career reset restores base club strengths', () {
      final baseStrength = Clubs.all
          .firstWhere((club) => club.name == 'Arsenal')
          .baseStrength;
      Clubs.applyStrengthOverrides({'Arsenal': baseStrength + 8});

      expect(Clubs.getByName('Arsenal').strength, baseStrength + 8);

      Clubs.resetCareerState();

      expect(Clubs.strengthOverrides, isEmpty);
      expect(Clubs.getByName('Arsenal').strength, baseStrength);
    });
  });

  group('National cup stage labels', () {
    test('32-team cup labels all five rounds correctly', () {
      expect(AppStrings.cupStageName(1, hasRoundOf32: true), '1/16 финала');
      expect(AppStrings.cupStageName(2, hasRoundOf32: true), '1/8 финала');
      expect(AppStrings.cupStageName(3, hasRoundOf32: true), 'Четвертьфинал');
      expect(AppStrings.cupStageName(4, hasRoundOf32: true), 'Полуфинал');
      expect(AppStrings.cupStageName(5, hasRoundOf32: true), 'Финал');
    });

    test('16-team cup keeps its original four-round labels', () {
      expect(AppStrings.cupStageName(1), '1/8 финала');
      expect(AppStrings.cupStageName(4), 'Финал');
    });
  });

  group('League divisions', () {
    test('initial divisions contain the expected club counts', () {
      final divisions = LeagueDivisionService.createInitialDivisions();
      const expected = <League, (int, int)>{
        League.england: (20, 24),
        League.spain: (20, 22),
        League.germany: (18, 18),
        League.italy: (20, 20),
        League.france: (18, 18),
        League.russia: (16, 18),
      };

      for (final entry in expected.entries) {
        expect(
          divisions[LeagueDivisionService.key(entry.key, 1)]!.length,
          entry.value.$1,
          reason: '${entry.key.name} first division',
        );
        expect(
          divisions[LeagueDivisionService.key(entry.key, 2)]!.length,
          entry.value.$2,
          reason: '${entry.key.name} second division',
        );
      }
      expect(Clubs.all.map((club) => club.name).toSet().length, Clubs.all.length);
    });

    test('second-division results do not qualify a promoted club for Europe', () {
      final divisions = LeagueDivisionService.createInitialDivisions();
      final firstDivision = divisions[LeagueDivisionService.key(League.england, 1)]!;
      final secondDivision = divisions[LeagueDivisionService.key(League.england, 2)]!;
      final simulatedTopTable = [
        for (var i = 0; i < firstDivision.length; i++)
          LeagueTableEntry(
            club: firstDivision[i],
            played: 38,
            wins: 20 - i,
            draws: 0,
            losses: 18 + i,
            goalsFor: 40,
            goalsAgainst: 20,
          ),
      ];
      final secondDivisionTable = [
        for (var i = 0; i < secondDivision.length; i++)
          LeagueTableEntry(
            club: secondDivision[i],
            played: 46,
            wins: 40 - i,
            draws: 0,
            losses: 6 + i,
            goalsFor: 80,
            goalsAgainst: 20,
          ),
      ];

      final standings = LeagueSeasonSimulator.standingsForQualification(
        simulatedStandings: {League.england: simulatedTopTable},
        playerClub: secondDivision.first,
        playerLeagueStandings: secondDivisionTable,
        leagueDivisions: divisions,
      );

      expect(standings[League.england]!.first.club, simulatedTopTable.first.club);
      expect(
        standings[League.england]!.map((entry) => entry.club),
        isNot(contains(secondDivision.first)),
      );
    });

    test('first-division results are used for European qualification', () {
      final divisions = LeagueDivisionService.createInitialDivisions();
      final firstDivision = divisions[LeagueDivisionService.key(League.england, 1)]!;
      final playerTable = [
        for (var i = 0; i < firstDivision.length; i++)
          LeagueTableEntry(
            club: firstDivision[i],
            played: 38,
            wins: 20 - i,
            draws: 0,
            losses: 18 + i,
            goalsFor: 40,
            goalsAgainst: 20,
          ),
      ];

      final standings = LeagueSeasonSimulator.standingsForQualification(
        simulatedStandings: {League.england: const []},
        playerClub: firstDivision.last,
        playerLeagueStandings: playerTable,
        leagueDivisions: divisions,
      );

      expect(standings[League.england], playerTable);
    });

    test('two clubs move in each direction after the season', () {
      final divisions = LeagueDivisionService.createInitialDivisions();
      final top = divisions[LeagueDivisionService.key(League.england, 1)]!;
      final second = divisions[LeagueDivisionService.key(League.england, 2)]!;
      final tables = <String, List<LeagueTableEntry>>{
        LeagueDivisionService.key(League.england, 1): [
          for (final club in top)
            LeagueTableEntry(
              club: club,
              played: 38,
              wins: club == top[0] ? 30 : club == top[1] ? 28 : 10,
              draws: 0,
              losses: 0,
              goalsFor: 50,
              goalsAgainst: 20,
            ),
        ],
        LeagueDivisionService.key(League.england, 2): [
          for (final club in second)
            LeagueTableEntry(
              club: club,
              played: 46,
              wins: club == second[0] ? 35 : club == second[1] ? 33 : club == second[2] ? 31 : 10,
              draws: 0,
              losses: 0,
              goalsFor: 60,
              goalsAgainst: 20,
            ),
        ],
      };

      final next = LeagueDivisionService.advanceSeason(
        divisions: divisions,
        finalTables: tables,
      );
      final nextTop = next[LeagueDivisionService.key(League.england, 1)]!;
      final nextSecond = next[LeagueDivisionService.key(League.england, 2)]!;

      expect(nextTop, containsAll(second.take(3)));
      expect(nextTop, isNot(contains(top[top.length - 1])));
      expect(nextTop, isNot(contains(top[top.length - 2])));
      expect(nextSecond, containsAll(top.skip(top.length - 3)));
      expect(nextTop.length, top.length);
      expect(nextSecond.length, second.length);
    });

    test('national cups for all two-tier leagues start at 1/16 final', () {
      final divisions = LeagueDivisionService.createInitialDivisions();
      const expectedStages = [
        '1/16 финала',
        '1/8 финала',
        'Четвертьфинал',
        'Полуфинал',
        'Финал',
      ];

      for (final league in LeagueDivisionService.twoTierLeagues) {
        final firstDivision =
            divisions[LeagueDivisionService.key(league, 1)]!;
        final secondDivision =
            divisions[LeagueDivisionService.key(league, 2)]!;
        var cup = DomesticCup.create(
          league: league,
          season: 1,
          playerClub: secondDivision.first,
          leagueDivisions: divisions,
          seed: 42,
        );

        expect(cup.teams.length, 32, reason: league.name);
        expect(cup.teams.toSet().length, 32, reason: league.name);
        expect(cup.teams, containsAll(firstDivision), reason: league.name);
        expect(
          cup.teams.where(secondDivision.contains).length,
          32 - firstDivision.length,
          reason: league.name,
        );
        expect(cup.currentRoundMatches.length, 16, reason: league.name);

        for (final stage in expectedStages) {
          expect(cup.roundName, stage, reason: '${league.name}: $stage');
          final stageMatches = List<CupMatch>.from(cup.currentRoundMatches);
          for (final match in stageMatches) {
            cup = cup.recordResult(
              matchId: match.id,
              homeGoals: 1,
              awayGoals: 0,
            );
          }
          if (stage != expectedStages.last) {
            cup = cup.advanceRound(seed: 42);
          }
        }
        expect(cup.isFinished, isTrue, reason: league.name);
      }
    });

    test('national cup format remains unchanged outside the six leagues', () {
      final divisions = LeagueDivisionService.createInitialDivisions();
      final playerClub = Clubs.byLeague(League.turkey).first.name;
      final cup = DomesticCup.create(
        league: League.turkey,
        season: 1,
        playerClub: playerClub,
        leagueDivisions: divisions,
        seed: 42,
      );

      expect(cup.teams.length, 16);
      expect(cup.roundName, '1/8 финала');
    });
  });
}
