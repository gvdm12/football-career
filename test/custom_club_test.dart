import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/club_logos.dart';
import 'package:flutter_football/models/custom_club.dart';
import 'package:flutter_football/models/league_player_season_stats.dart';
import 'package:flutter_football/models/league_table.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/services/custom_club_service.dart';
import 'package:flutter_football/services/fc_points_service.dart';
import 'package:flutter_football/widgets/custom_club_badge.dart';

CustomClub makeClub({int seed = 1, League league = League.spain}) {
  final replaced = Clubs.builtInByLeagueDivision(league, 1).first;
  return CustomClubService.create(
    name: 'Polar Wolves',
    shortName: '',
    badgeShape: ClubBadgeShape.shield,
    badgeSymbol: ClubBadgeSymbol.star,
    primaryColor: 0xFFD32F2F,
    secondaryColor: 0xFFFFFFFF,
    league: league,
    division: 1,
    replacedClub: replaced.name,
    random: Random(seed),
  );
}

Career makeCareer(CustomClub club) {
  Clubs.registerCustomClub(club);
  final player = Player.create(
    name: 'Test Player',
    nationality: 'Россия',
    position: PlayerPosition.forward,
    club: club.name,
  );
  return Career.create(player, customClub: club);
}

void main() {
  setUp(() => Clubs.resetCareerState());
  tearDown(() => Clubs.resetCareerState());

  group('creation rules', () {
    test('strength is random from 70 to 76 and every value can appear', () {
      final random = Random(7);
      final values = List.generate(
        600,
        (_) => CustomClubService.rollStrength(random),
      );
      expect(values.every((value) => value >= 70 && value <= 76), isTrue);
      expect(values.toSet().length, 7);
    });

    test('names are cleaned and validated', () {
      final taken = Clubs.builtInNames;
      expect(CustomClubService.cleanName('  Red   Star  '), 'Red Star');

      expect(
        CustomClubService.validateName('ab', takenNames: taken),
        ClubNameIssue.tooShort,
      );
      expect(
        CustomClubService.validateName('a' * 25, takenNames: taken),
        ClubNameIssue.tooLong,
      );
      expect(
        CustomClubService.validateName('Club!', takenNames: taken),
        ClubNameIssue.badCharacters,
      );
      expect(
        CustomClubService.validateName('Polar Wolves 1', takenNames: taken),
        isNull,
      );
      expect(
        CustomClubService.validateName('Динамо Север', takenNames: taken),
        isNull,
      );
    });

    test('names of real clubs are taken, even with different case or marks', () {
      final taken = Clubs.builtInNames.toList();
      expect(
        CustomClubService.validateName('real madrid', takenNames: taken),
        ClubNameIssue.taken,
      );
      expect(
        CustomClubService.validateName('Real-Madrid', takenNames: taken),
        ClubNameIssue.taken,
      );
    });

    test('stadium names are validated', () {
      expect(CustomClubService.validateStadiumName('ab'), ClubNameIssue.tooShort);
      expect(
        CustomClubService.validateStadiumName('x' * 31),
        ClubNameIssue.tooLong,
      );
      expect(CustomClubService.validateStadiumName('Old Park'), isNull);
    });

    test('short names are built from the first letters', () {
      expect(CustomClubService.defaultShortName('Red Star'), 'RED');
      expect(CustomClubService.defaultShortName('ab'), 'AB');
      expect(CustomClubService.defaultShortName('Динамо'), 'ДИН');
      expect(CustomClubService.defaultShortName(''), 'CLB');
    });

    test('a new club starts with funds, fans and its own stadium', () {
      final club = makeClub();
      expect(club.name, 'Polar Wolves');
      expect(club.shortName, 'POL');
      expect(club.baseStrength, inInclusiveRange(70, 76));
      expect(club.funds, CustomClubService.startingFunds);
      expect(club.fans, CustomClubService.startingFans);
      expect(club.stadiumName, 'Polar Wolves Arena');
      expect(club.facilityLevels, isEmpty);
      expect(club.history, isEmpty);
    });
  });

  group('development', () {
    test('upgrade costs grow with the level and end at the maximum', () {
      for (final facility in ClubFacility.values) {
        int? previous;
        for (var level = 0; level < CustomClubService.maxFacilityLevel; level++) {
          final cost = CustomClubService.upgradeCost(facility, level)!;
          expect(cost % 50000, 0);
          if (previous != null) expect(cost, greaterThan(previous));
          previous = cost;
        }
        expect(
          CustomClubService.upgradeCost(
            facility,
            CustomClubService.maxFacilityLevel,
          ),
          isNull,
        );
      }
      expect(CustomClubService.upgradeCost(ClubFacility.academy, 0), 1200000);
    });

    test('an upgrade costs money and raises the level by one', () {
      final club = makeClub();
      final upgraded = CustomClubService.upgrade(club, ClubFacility.academy)!;

      expect(upgraded.levelOf(ClubFacility.academy), 1);
      expect(upgraded.funds, club.funds - 1200000);
      expect(club.levelOf(ClubFacility.academy), 0);
    });

    test('an upgrade is refused without money or at the maximum level', () {
      final poor = makeClub().copyWith(funds: 100);
      expect(CustomClubService.upgrade(poor, ClubFacility.academy), isNull);
      expect(CustomClubService.canUpgrade(poor, ClubFacility.academy), isFalse);

      final maxed = makeClub().copyWith(
        funds: 999999999,
        facilityLevels: {ClubFacility.stadium: 5},
      );
      expect(CustomClubService.upgrade(maxed, ClubFacility.stadium), isNull);
    });

    test('stadium capacity and growth follow the levels', () {
      expect(CustomClubService.stadiumCapacity(0), 6000);
      expect(CustomClubService.stadiumCapacity(5), 36000);

      expect(CustomClubService.growthPerSeason(makeClub()), 0);
      final academy = makeClub().copyWith(
        facilityLevels: {ClubFacility.academy: 5},
      );
      expect(CustomClubService.growthPerSeason(academy), closeTo(1.0, 1e-9));
    });

    test('investing personal money adds to the club funds', () {
      final club = makeClub();
      expect(CustomClubService.donate(club, 500000).funds, club.funds + 500000);
      expect(CustomClubService.donate(club, 0).funds, club.funds);
      expect(CustomClubService.donate(club, -5).funds, club.funds);
    });
  });

  group('season finance', () {
    SeasonFinance finance(
      CustomClub club, {
      int position = 10,
      int teamCount = 20,
      int division = 1,
    }) => CustomClubService.seasonFinance(
      club: club,
      position: position,
      teamCount: teamCount,
      division: division,
      strength: 73,
    );

    test('net is income minus expenses', () {
      final result = finance(makeClub());
      expect(result.net, result.income - result.expenses);
      expect(result.income, greaterThan(0));
    });

    test('a higher finish earns more', () {
      final club = makeClub();
      expect(
        finance(club, position: 1).prize,
        greaterThan(finance(club, position: 20).prize),
      );
    });

    test('the top division pays more than the second one', () {
      final club = makeClub();
      expect(finance(club).tv, greaterThan(finance(club, division: 2).tv));
    });

    test('expensive tickets bring more money, cheap ones fewer', () {
      final base = makeClub();
      final cheap = base.copyWith(ticketPolicy: TicketPolicy.affordable);
      final premium = base.copyWith(ticketPolicy: TicketPolicy.premium);
      expect(finance(premium).tickets, greaterThan(finance(cheap).tickets));
    });

    test('a bigger stadium raises ticket income and upkeep', () {
      final base = makeClub();
      final big = base.copyWith(facilityLevels: {ClubFacility.stadium: 3});
      expect(finance(big).tickets, greaterThan(finance(base).tickets));
      expect(finance(big).upkeep, greaterThan(finance(base).upkeep));
    });

    test('an unknown position is treated as mid-table', () {
      final club = makeClub();
      final unknown = finance(club, position: 0, teamCount: 0);
      final middle = finance(club, position: 10, teamCount: 19);
      expect(unknown.prize, middle.prize);
    });

    test('fans react to results and ticket prices', () {
      int delta(int position, [TicketPolicy policy = TicketPolicy.standard]) =>
          CustomClubService.fansDelta(
            position: position,
            teamCount: 20,
            policy: policy,
          );

      expect(delta(1), greaterThan(0));
      expect(delta(20), lessThan(0));
      expect(delta(10, TicketPolicy.affordable), greaterThan(delta(10)));
      expect(delta(10, TicketPolicy.premium), lessThan(delta(10)));
    });
  });

  group('end of season', () {
    CustomClubSeasonOutcome endSeason(CustomClub club, {int position = 1}) =>
        CustomClubService.applySeasonEnd(
          club: club,
          season: 1,
          position: position,
          teamCount: 20,
          division: 1,
          currentStrength: 73,
        );

    test('funds, fans and history are updated', () {
      final club = makeClub();
      final outcome = endSeason(club);

      expect(outcome.club.funds, club.funds + outcome.finance.net);
      expect(outcome.club.fans, greaterThan(club.fans));
      expect(outcome.club.history, hasLength(1));
      expect(outcome.club.history.single.champion, isTrue);
      expect(outcome.club.titles, 1);
    });

    test('fans always stay within limits', () {
      var club = makeClub().copyWith(fans: 98);
      club = endSeason(club).club;
      expect(club.fans, lessThanOrEqualTo(CustomClubService.maxFans));

      var low = makeClub().copyWith(fans: 6);
      for (var i = 0; i < 5; i++) {
        low = endSeason(low, position: 20).club;
      }
      expect(low.fans, greaterThanOrEqualTo(CustomClubService.minFans));
    });

    test('growth from upgrades is carried over between seasons', () {
      var club = makeClub().copyWith(
        facilityLevels: {ClubFacility.training: 1},
      );
      var total = 0;
      for (var i = 0; i < 4; i++) {
        final outcome = endSeason(club, position: 10);
        total += outcome.strengthDelta;
        club = outcome.club;
      }
      expect(total, 1);
      expect(club.strengthProgress, closeTo(0, 1e-9));
    });

    test('debt costs strength and fans', () {
      final indebted = makeClub().copyWith(funds: -80000000);
      final normal = makeClub();

      final bad = endSeason(indebted, position: 10);
      final good = endSeason(normal, position: 10);

      expect(bad.strengthDelta, good.strengthDelta - 1);
      expect(bad.club.fans, lessThan(good.club.fans));
    });

    test('the history keeps only the latest seasons', () {
      var club = makeClub();
      for (var i = 0; i < CustomClubService.maxHistory + 5; i++) {
        club = endSeason(club, position: 10).club;
      }
      expect(club.history, hasLength(CustomClubService.maxHistory));
    });

    test('the standing is found by points, goal difference and goals', () {
      var table = LeagueTable.create('A', ['B', 'C', 'D']);
      table = LeagueTable.applyMatch(
        table: table,
        homeTeam: 'B',
        awayTeam: 'C',
        homeGoals: 3,
        awayGoals: 0,
      );
      table = LeagueTable.applyMatch(
        table: table,
        homeTeam: 'A',
        awayTeam: 'D',
        homeGoals: 1,
        awayGoals: 0,
      );

      final standingB = CustomClubService.standingIn([table], 'B')!;
      final standingA = CustomClubService.standingIn([table], 'A')!;
      final standingC = CustomClubService.standingIn([table], 'C')!;

      expect(standingB.position, 1);
      expect(standingA.position, 2);
      expect(standingC.position, 4);
      expect(standingB.teamCount, 4);
      expect(CustomClubService.standingIn([table], 'Z'), isNull);
    });
  });

  group('model', () {
    test('survives a JSON round trip', () {
      final club = makeClub().copyWith(
        funds: 1234567,
        fans: 61,
        ticketPolicy: TicketPolicy.premium,
        facilityLevels: {ClubFacility.academy: 2, ClubFacility.stadium: 4},
        history: const [
          CustomClubSeason(
            season: 1,
            position: 3,
            teamCount: 20,
            income: 10,
            expenses: 4,
            fans: 30,
            strength: 74,
          ),
        ],
        strengthProgress: 0.35,
      );

      final restored = CustomClub.fromJson(
        jsonDecode(jsonEncode(club.toJson())) as Map<String, dynamic>,
      );

      expect(restored.name, club.name);
      expect(restored.shortName, club.shortName);
      expect(restored.badgeShape, club.badgeShape);
      expect(restored.badgeSymbol, club.badgeSymbol);
      expect(restored.primaryColor, club.primaryColor);
      expect(restored.league, club.league);
      expect(restored.replacedClub, club.replacedClub);
      expect(restored.baseStrength, club.baseStrength);
      expect(restored.funds, 1234567);
      expect(restored.fans, 61);
      expect(restored.ticketPolicy, TicketPolicy.premium);
      expect(restored.levelOf(ClubFacility.academy), 2);
      expect(restored.levelOf(ClubFacility.stadium), 4);
      expect(restored.levelOf(ClubFacility.training), 0);
      expect(restored.history.single.position, 3);
      expect(restored.strengthProgress, closeTo(0.35, 1e-9));
    });

    test('broken data falls back to safe defaults', () {
      final restored = CustomClub.fromJson({
        'name': 'Test FC',
        'badgeShape': 'nonsense',
        'league': 'nowhere',
        'fans': 500,
        'baseStrength': 5,
        'facilityLevels': {'academy': 99},
        'history': 'oops',
      });

      expect(restored.badgeShape, ClubBadgeShape.shield);
      expect(restored.league, League.england);
      expect(restored.fans, 100);
      expect(restored.baseStrength, 50);
      expect(restored.levelOf(ClubFacility.academy), 5);
      expect(restored.history, isEmpty);
    });
  });

  group('club registry', () {
    test('the custom club takes the place of the replaced club', () {
      final before = List<Club>.of(Clubs.all);
      final club = makeClub();
      final replacedIndex = before.indexWhere(
        (item) => item.name == club.replacedClub,
      );

      Clubs.registerCustomClub(club);

      expect(Clubs.all.length, before.length);
      expect(Clubs.all.any((item) => item.name == club.replacedClub), isFalse);
      expect(Clubs.all[replacedIndex].name, club.name);
      expect(Clubs.leagueOf(club.name), League.spain);
      expect(Clubs.divisionOf(club.name), 1);
      expect(
        Clubs.byLeagueDivision(League.spain, 1).any((c) => c.name == club.name),
        isTrue,
      );
      expect(
        Clubs.getByName(club.name).strength,
        closeTo(club.baseStrength, 4),
      );
      expect(Clubs.isCustomClub(club.name), isTrue);
    });

    test('built-in names never include the custom club', () {
      final club = makeClub();
      Clubs.registerCustomClub(club);

      expect(Clubs.builtInNames, contains(club.replacedClub));
      expect(Clubs.builtInNames, isNot(contains(club.name)));
    });

    test('resetting the career state removes the custom club', () {
      final club = makeClub();
      Clubs.registerCustomClub(club);

      Clubs.resetCareerState();

      expect(Clubs.customClub, isNull);
      expect(Clubs.all.any((item) => item.name == club.replacedClub), isTrue);
      expect(Clubs.all.any((item) => item.name == club.name), isFalse);
    });

    test('colours and badge come from the custom club', () {
      final club = makeClub();
      Clubs.registerCustomClub(club);

      expect(ClubColors.primary(club.name), Color(club.primaryColor));
      expect(ClubColors.secondary(club.name), Color(club.secondaryColor));
      expect(ClubLogos.assetFor(club.name), isNull);
    });

    test('every badge shape fits inside its square', () {
      for (final shape in ClubBadgeShape.values) {
        final bounds = CustomClubBadge.pathFor(
          shape,
          const Size.square(100),
        ).getBounds();
        expect(bounds.left, greaterThanOrEqualTo(0), reason: '$shape');
        expect(bounds.top, greaterThanOrEqualTo(0), reason: '$shape');
        expect(bounds.right, lessThanOrEqualTo(100), reason: '$shape');
        expect(bounds.bottom, lessThanOrEqualTo(100), reason: '$shape');
        expect(bounds.width, greaterThan(50), reason: '$shape');
      }
    });
  });

  group('career with a custom club', () {
    test('a new career starts for the custom club', () {
      final club = makeClub();
      final career = makeCareer(club);

      expect(career.customClub?.name, club.name);
      expect(career.player.club, club.name);
      expect(Clubs.customClub?.name, club.name);
      expect(career.seasonMatches, isNotEmpty);
      expect(career.leagueTable.any((entry) => entry.club == club.name), isTrue);
      expect(
        career.leagueTable.any((entry) => entry.club == club.replacedClub),
        isFalse,
      );
    });

    test('the club survives saving and loading', () {
      final club = makeClub();
      final career = makeCareer(club).copyWith(
        customClub: club.copyWith(funds: 7777777),
      );
      final json =
          jsonDecode(jsonEncode(career.toJson())) as Map<String, dynamic>;

      Clubs.resetCareerState();
      final loaded = Career.fromJson(json);

      expect(loaded.customClub?.funds, 7777777);
      expect(loaded.player.club, club.name);
      expect(Clubs.customClub?.name, club.name);
    });

    test('loading a normal career clears the custom club', () {
      final normalPlayer = Player.create(
        name: 'Normal',
        nationality: 'Россия',
        position: PlayerPosition.forward,
        club: 'Real Madrid',
      );
      final normal = Career.create(normalPlayer);
      final normalJson =
          jsonDecode(jsonEncode(normal.toJson())) as Map<String, dynamic>;
      expect(normalJson['customClub'], isNull);

      Clubs.registerCustomClub(makeClub());
      final loaded = Career.fromJson(normalJson);

      expect(loaded.customClub, isNull);
      expect(Clubs.customClub, isNull);
    });

    test('the next season keeps the club and records its history', () {
      final club = makeClub();
      final career = makeCareer(club);

      final next = career.startNextSeason();

      expect(next.customClub, isNotNull);
      expect(next.customClub!.name, club.name);
      expect(next.customClub!.history, hasLength(1));
      expect(next.customClub!.history.single.season, career.season);
      expect(Clubs.customClub?.name, club.name);
    });

    test('upgrades make the club stronger in the next season', () {
      final club = makeClub();
      final plain = makeCareer(club);
      final upgraded = makeCareer(club).copyWith(
        customClub: club.copyWith(facilityLevels: {ClubFacility.academy: 5}),
      );

      final plainNext = plain.startNextSeason();
      final upgradedNext = upgraded.startNextSeason();

      expect(
        upgradedNext.clubStrengths[club.name]! -
            plainNext.clubStrengths[club.name]!,
        1,
      );
    });
  });

  group('squad and shop', () {
    test('the generated squad is complete, stable and fits the club strength', () {
      final club = makeClub();
      Clubs.registerCustomClub(club);

      final squad = LeaguePlayerStatsService.generatedSquad(
        club: club.name,
        season: 1,
      );
      final again = LeaguePlayerStatsService.generatedSquad(
        club: club.name,
        season: 1,
      );

      final players = squad.values.expand((list) => list).toList();
      expect(squad.keys, containsAll(['goalkeeper', 'defender', 'midfielder', 'forward']));
      expect(players, hasLength(19));
      expect(players.map((p) => p.jerseyNumber).toSet(), hasLength(19));
      expect(
        players.every(
          (p) => (p.overall - club.baseStrength).abs() <= 9,
        ),
        isTrue,
      );
      expect(
        again.values.expand((l) => l).map((p) => p.name).toList(),
        players.map((p) => p.name).toList(),
      );
    });

    test('the mode is sold in the FC points shop for 4000', () {
      final item = FCPointsService.shopItems.firstWhere(
        (item) => item.id == 'custom_club',
      );
      expect(item.price, 4000);
    });
  });
}
