import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/domestic_cup.dart';
import 'package:flutter_football/models/league_division_service.dart';
import 'package:flutter_football/models/league_table.dart';

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

    test('national cup for a two-tier league starts at 1/16 final', () {
      final divisions = LeagueDivisionService.createInitialDivisions();
      final playerClub =
          divisions[LeagueDivisionService.key(League.england, 2)]!.first;
      final cup = DomesticCup.create(
        league: League.england,
        season: 1,
        playerClub: playerClub,
        leagueDivisions: divisions,
        seed: 42,
      );

      expect(cup.teams.length, 32);
      expect(cup.teams.toSet().length, 32);
      expect(
        cup.teams,
        containsAll(divisions[LeagueDivisionService.key(League.england, 1)]!),
      );
      expect(
        cup.teams.where(
          divisions[LeagueDivisionService.key(League.england, 2)]!.contains,
        ).length,
        12,
      );
      expect(cup.currentRoundMatches.length, 16);
      expect(cup.roundName, '1/16 финала');
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
