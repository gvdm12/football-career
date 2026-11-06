import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/club.dart';
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
