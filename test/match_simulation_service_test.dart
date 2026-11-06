import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_division_service.dart';
import 'package:flutter_football/models/league_match.dart';
import 'package:flutter_football/models/league_table.dart';
import 'package:flutter_football/services/match_simulation_service.dart';

void main() {
  group('MatchSimulationService.simulateGoals', () {
    test('always returns a value in the 0..8 range', () {
      final random = Random(42);
      for (var i = 0; i < 3000; i++) {
        final goals = MatchSimulationService.simulateGoals(95, 40, random);
        expect(goals, inInclusiveRange(0, 8));
      }
    });

    test('is deterministic for the same seed', () {
      final first = Random(7);
      final second = Random(7);
      final a = List.generate(
        50,
        (_) => MatchSimulationService.simulateGoals(80, 70, first),
      );
      final b = List.generate(
        50,
        (_) => MatchSimulationService.simulateGoals(80, 70, second),
      );
      expect(a, b);
    });

    test('stronger team scores more on average than a weaker one', () {
      final random = Random(1);
      var strongTotal = 0;
      var weakTotal = 0;
      const samples = 4000;
      for (var i = 0; i < samples; i++) {
        strongTotal += MatchSimulationService.simulateGoals(85, 65, random);
        weakTotal += MatchSimulationService.simulateGoals(65, 85, random);
      }
      expect(strongTotal / samples, greaterThan(weakTotal / samples));
    });

    test('home advantage raises the average number of goals', () {
      final random = Random(3);
      var home = 0;
      var away = 0;
      const samples = 6000;
      for (var i = 0; i < samples; i++) {
        home += MatchSimulationService.simulateGoals(
          75,
          75,
          random,
          homeAdvantage: true,
        );
        away += MatchSimulationService.simulateGoals(75, 75, random);
      }
      expect(home / samples, greaterThan(away / samples));
    });
  });

  group('MatchSimulationService.simulateBackgroundRound', () {
    late List<String> names;

    setUp(() {
      final league = Clubs.all.first.league;
      names = Clubs.byLeague(league).take(4).map((c) => c.name).toList();
    });

    test('simulates only unplayed non-player matches of the given round', () {
      final player = names[0];
      final fixtures = [
        LeagueMatch(id: 1, round: 1, homeTeam: names[0], awayTeam: names[1]),
        LeagueMatch(id: 2, round: 1, homeTeam: names[2], awayTeam: names[3]),
        LeagueMatch(id: 3, round: 2, homeTeam: names[2], awayTeam: names[0]),
        LeagueMatch(id: 4, round: 2, homeTeam: names[3], awayTeam: names[1]),
      ];

      final result = MatchSimulationService.simulateBackgroundRound(
        fixtures: fixtures,
        round: 1,
        playerClub: player,
        playerOverall: 70,
        random: Random(5),
      );

      expect(result[0].isPlayed, isFalse, reason: 'player match untouched');
      expect(result[1].isPlayed, isTrue, reason: 'background match played');
      expect(result[1].homeGoals, inInclusiveRange(0, 8));
      expect(result[1].awayGoals, inInclusiveRange(0, 8));
      expect(result[2].isPlayed, isFalse, reason: 'other round untouched');
      expect(result[3].isPlayed, isFalse, reason: 'other round untouched');
    });

    test('does not overwrite an already played match', () {
      final fixtures = [
        LeagueMatch(
          id: 1,
          round: 1,
          homeTeam: names[2],
          awayTeam: names[3],
          homeGoals: 5,
          awayGoals: 0,
        ),
      ];

      final result = MatchSimulationService.simulateBackgroundRound(
        fixtures: fixtures,
        round: 1,
        playerClub: names[0],
        playerOverall: 70,
        random: Random(9),
      );

      expect(result.single.homeGoals, 5);
      expect(result.single.awayGoals, 0);
    });
  });

  group('MatchSimulationService.rebuildLeagueTable', () {
    test('counts only played fixtures and ignores input order', () {
      final league = Clubs.all.first.league;
      final clubs = Clubs.byLeague(league).map((c) => c.name).toList();
      final player = clubs[0];
      final x = clubs[1];
      final y = clubs[2];
      final z = clubs[3];

      final fixtures = [
        LeagueMatch(
          id: 1,
          round: 1,
          homeTeam: player,
          awayTeam: x,
          homeGoals: 2,
          awayGoals: 1,
        ),
        LeagueMatch(
          id: 2,
          round: 1,
          homeTeam: y,
          awayTeam: z,
          homeGoals: 0,
          awayGoals: 0,
        ),
        LeagueMatch(id: 3, round: 2, homeTeam: x, awayTeam: player),
      ];

      List<LeagueTableEntry> rebuild(List<LeagueMatch> input) =>
          MatchSimulationService.rebuildLeagueTable(
            playerClub: player,
            fixtures: input,
            division: 1,
            divisions: const {},
            fallbackTable: const [],
          );

      final table = rebuild(fixtures);
      final reversed = rebuild(fixtures.reversed.toList());

      LeagueTableEntry entry(List<LeagueTableEntry> t, String club) =>
          t.firstWhere((e) => e.club == club);

      final p = entry(table, player);
      expect(p.played, 1);
      expect(p.wins, 1);
      expect(p.goalsFor, 2);
      expect(p.goalsAgainst, 1);
      expect(entry(table, x).losses, 1);
      expect(entry(table, y).draws, 1);

      // Три сыгранных клуба-участника + остальные без матчей.
      expect(table.fold<int>(0, (sum, e) => sum + e.played), 4);

      String signature(List<LeagueTableEntry> t) {
        final rows =
            t
                .map(
                  (e) =>
                      '${e.club}:${e.played}:${e.wins}:${e.draws}:'
                      '${e.losses}:${e.goalsFor}:${e.goalsAgainst}',
                )
                .toList()
              ..sort();
        return rows.join('|');
      }

      expect(signature(reversed), signature(table));
    });

    test('rebuilds the correct table for every second-division league', () {
      final divisions = LeagueDivisionService.createInitialDivisions();

      for (final league in LeagueDivisionService.twoTierLeagues) {
        for (var division = 1; division <= 2; division++) {
          final currentClubs =
              divisions[LeagueDivisionService.key(league, division)]!;
          final otherClubs =
              divisions[LeagueDivisionService.key(league, division == 1 ? 2 : 1)]!;
          final player = currentClubs[0];
          final opponent = currentClubs[1];
          final third = currentClubs[2];
          final fourth = currentClubs[3];

          final table = MatchSimulationService.rebuildLeagueTable(
            playerClub: player,
            fixtures: [
              LeagueMatch(
                id: 1,
                round: 1,
                homeTeam: player,
                awayTeam: opponent,
                homeGoals: 2,
                awayGoals: 0,
              ),
              LeagueMatch(
                id: 2,
                round: 1,
                homeTeam: third,
                awayTeam: fourth,
                homeGoals: 1,
                awayGoals: 1,
              ),
              // Междивизионный матч из ошибочного/старого сохранения
              // не должен менять ни одну из таблиц.
              LeagueMatch(
                id: 3,
                round: 2,
                homeTeam: player,
                awayTeam: otherClubs.first,
                homeGoals: 7,
                awayGoals: 0,
              ),
            ],
            division: division,
            divisions: divisions,
            fallbackTable: const [],
          );

          expect(
            table.map((entry) => entry.club).toSet(),
            currentClubs.toSet(),
            reason: '${league.name}, division $division must contain only its clubs',
          );
          expect(
            table.fold<int>(0, (sum, entry) => sum + entry.played),
            4,
            reason: '${league.name}, division $division must count only two valid fixtures',
          );
          expect(
            table.firstWhere((entry) => entry.club == player).played,
            1,
            reason: '${league.name}, division $division player match count',
          );
        }
      }
    });

    test('uses a promoted club actual division after promotion and relegation', () {
      final divisions = LeagueDivisionService.createInitialDivisions();
      final topKey = LeagueDivisionService.key(League.england, 1);
      final secondKey = LeagueDivisionService.key(League.england, 2);
      final top = divisions[topKey]!;
      final second = divisions[secondKey]!;
      final finalTables = <String, List<LeagueTableEntry>>{
        topKey: [
          for (var i = 0; i < top.length; i++)
            LeagueTableEntry(
              club: top[i],
              played: 38,
              wins: top.length - i,
              draws: 0,
              losses: i,
              goalsFor: 60 - i,
              goalsAgainst: 10 + i,
            ),
        ],
        secondKey: [
          for (var i = 0; i < second.length; i++)
            LeagueTableEntry(
              club: second[i],
              played: 46,
              wins: second.length - i,
              draws: 0,
              losses: i,
              goalsFor: 70 - i,
              goalsAgainst: 10 + i,
            ),
        ],
      };
      final nextDivisions = LeagueDivisionService.advanceSeason(
        divisions: divisions,
        finalTables: finalTables,
      );
      final promotedClub = second.first;
      final nextTop = nextDivisions[topKey]!;
      final opponent = nextTop.firstWhere((club) => club != promotedClub);

      final table = MatchSimulationService.rebuildLeagueTable(
        playerClub: promotedClub,
        // Передаём старый дивизион намеренно: сервис должен доверять
        // обновлённому сохранённому составу после повышения.
        division: 2,
        divisions: nextDivisions,
        fixtures: [
          LeagueMatch(
            id: 1,
            round: 1,
            homeTeam: promotedClub,
            awayTeam: opponent,
            homeGoals: 1,
            awayGoals: 0,
          ),
        ],
        fallbackTable: const [],
      );

      expect(table.map((entry) => entry.club).toSet(), nextTop.toSet());
      expect(table.firstWhere((entry) => entry.club == promotedClub).wins, 1);
    });

    test('returns the fallback table when the club has no league', () {
      final fallback = LeagueTable.create('A', ['B']);

      final result = MatchSimulationService.rebuildLeagueTable(
        playerClub: 'Несуществующий клуб FC',
        fixtures: const [],
        division: 1,
        divisions: const {},
        fallbackTable: fallback,
      );

      expect(identical(result, fallback), isTrue);
    });
  });
}
