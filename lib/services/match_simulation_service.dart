import 'dart:math';

import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_division_service.dart';
import 'package:flutter_football/models/league_match.dart';
import 'package:flutter_football/models/league_table.dart';

/// Чистая логика симуляции матчей и пересчёта таблицы.
///
/// Раньше эти методы жили в `_SeasonScreenState` и зависели от виджета.
/// Теперь они не знают про UI и принимают всё нужное параметрами,
/// поэтому их можно тестировать и переиспользовать (например, в кубках
/// и еврокубках, где тот же расчёт голов).
class MatchSimulationService {
  const MatchSimulationService._();

  /// Количество голов команды по распределению Пуассона.
  ///
  /// Разница в силе влияет на ожидаемое число голов, но не гарантирует
  /// победу. Результат ограничен диапазоном 0..8.
  static int simulateGoals(
    int teamStrength,
    int opponentStrength,
    Random random, {
    bool homeAdvantage = false,
  }) {
    final strengthDifference = teamStrength - opponentStrength;

    final expectedGoals =
        (1.35 + strengthDifference * 0.035 + (homeAdvantage ? 0.15 : 0.0))
            .clamp(0.35, 2.8)
            .toDouble();

    final threshold = exp(-expectedGoals);
    var product = 1.0;
    var goals = 0;

    do {
      goals++;
      product *= random.nextDouble();
    } while (product > threshold);

    return (goals - 1).clamp(0, 8).toInt();
  }

  /// Симулирует ещё не сыгранные матчи указанного тура.
  ///
  /// Матчи клуба игрока, уже сыгранные матчи и матчи других туров
  /// возвращаются без изменений.
  static List<LeagueMatch> simulateBackgroundRound({
    required List<LeagueMatch> fixtures,
    required int round,
    required String playerClub,
    required int playerOverall,
    Random? random,
  }) {
    final rng = random ?? Random();

    return fixtures.map((fixture) {
      if (fixture.round != round || fixture.isPlayed) {
        return fixture;
      }

      if (fixture.homeTeam == playerClub || fixture.awayTeam == playerClub) {
        return fixture;
      }

      final homeStrength = Clubs.effectiveStrength(
        clubName: fixture.homeTeam,
        playerClub: playerClub,
        playerOverall: playerOverall,
      );
      final awayStrength = Clubs.effectiveStrength(
        clubName: fixture.awayTeam,
        playerClub: playerClub,
        playerOverall: playerOverall,
      );

      final homeGoals = simulateGoals(
        homeStrength,
        awayStrength,
        rng,
        homeAdvantage: true,
      );
      final awayGoals = simulateGoals(awayStrength, homeStrength, rng);

      return fixture.copyWith(homeGoals: homeGoals, awayGoals: awayGoals);
    }).toList();
  }

  /// Полностью пересчитывает таблицу по сыгранным матчам.
  ///
  /// Если у клуба игрока не найден чемпионат, возвращается
  /// [fallbackTable] без изменений.
  static List<LeagueTableEntry> rebuildLeagueTable({
    required String playerClub,
    required List<LeagueMatch> fixtures,
    required int division,
    required Map<String, List<String>> divisions,
    required List<LeagueTableEntry> fallbackTable,
  }) {
    final league = Clubs.leagueOf(playerClub);

    if (league == null) {
      return fallbackTable;
    }

    // Состав дивизиона из сохранения важнее базового дивизиона клуба:
    // после повышения/вылета клуб может сменить уровень между сезонами.
    final actualDivision =
        LeagueDivisionService.divisionForClub(playerClub, divisions) ??
        division;
    final clubs = LeagueDivisionService.clubsFor(
      league,
      actualDivision,
      divisions,
    );
    final divisionClubs = clubs.map((club) => club.name).toSet();

    // Не строим таблицу с клубом, отсутствующим в выбранном дивизионе.
    if (!divisionClubs.contains(playerClub)) {
      return fallbackTable;
    }

    final opponents = divisionClubs
        .where((club) => club != playerClub)
        .toList();

    var table = LeagueTable.create(playerClub, opponents);

    // Защита от старых/рассинхронизированных сохранений: в таблицу попадают
    // только матчи между двумя клубами текущего дивизиона.
    final playedFixtures = fixtures
        .where(
          (fixture) =>
              fixture.isPlayed &&
              fixture.homeTeam != fixture.awayTeam &&
              divisionClubs.contains(fixture.homeTeam) &&
              divisionClubs.contains(fixture.awayTeam),
        )
        .toList()
      ..sort((a, b) {
        final roundComparison = a.round.compareTo(b.round);
        if (roundComparison != 0) return roundComparison;
        return a.id.compareTo(b.id);
      });

    for (final fixture in playedFixtures) {
      table = LeagueTable.applyMatch(
        table: table,
        homeTeam: fixture.homeTeam,
        awayTeam: fixture.awayTeam,
        homeGoals: fixture.homeGoals!,
        awayGoals: fixture.awayGoals!,
      );
    }

    return table;
  }
}
