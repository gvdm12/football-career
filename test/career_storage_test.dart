import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/services/career_storage.dart';
import 'package:flutter_football/services/fc_points_service.dart';
import 'package:flutter_football/models/season_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

Career _career(String name) {
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
  final player = Player(
    name: name,
    nationality: 'Россия',
    position: PlayerPosition.forward,
    age: 19,
    season: 1,
    club: Clubs.all.first.name,
    overall: calculateOverall(
      skills: skills,
      position: PlayerPosition.forward,
    ),
    skills: skills,
  );
  return Career.create(player);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('active slot', () {
    test('defaults to slot 1 and persists a new choice', () async {
      expect(await CareerStorage.activeSlot(), 1);

      await CareerStorage.setActiveSlot(2);

      expect(await CareerStorage.activeSlot(), 2);
    });

    test('rejects slots outside the valid range', () async {
      expect(() => CareerStorage.setActiveSlot(0), throwsRangeError);
      expect(
        () => CareerStorage.setActiveSlot(CareerStorage.slotCount + 1),
        throwsRangeError,
      );
    });
  });

  group('save and load', () {
    test('slot 1 keeps the legacy storage key', () async {
      await CareerStorage.setActiveSlot(1);
      await CareerStorage.save(_career('Первый'));

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.containsKey('saved_career_v1'), isTrue);
    });

    test('an existing pre-slots save is readable as slot 1', () async {
      SharedPreferences.setMockInitialValues({
        'saved_career_v1': jsonEncode(_career('Старый').toJson()),
      });

      final loaded = await CareerStorage.loadSlot(1);

      expect(loaded?.player.name, 'Старый');
      expect(await CareerStorage.hasSavedCareer(), isTrue);
    });

    test('saves go to the active slot and do not touch the others', () async {
      await CareerStorage.setActiveSlot(1);
      await CareerStorage.save(_career('Первый'));

      await CareerStorage.setActiveSlot(2);
      await CareerStorage.save(_career('Второй'));

      expect((await CareerStorage.loadSlot(1))?.player.name, 'Первый');
      expect((await CareerStorage.loadSlot(2))?.player.name, 'Второй');
      expect(await CareerStorage.loadSlot(3), isNull);
    });

    test('load() follows the active slot', () async {
      await CareerStorage.saveToSlot(1, _career('Первый'));
      await CareerStorage.saveToSlot(3, _career('Третий'));

      await CareerStorage.setActiveSlot(3);
      expect((await CareerStorage.load())?.player.name, 'Третий');

      await CareerStorage.setActiveSlot(1);
      expect((await CareerStorage.load())?.player.name, 'Первый');
    });
  });

  group('delete', () {
    test('deleteSlot removes only the chosen slot', () async {
      await CareerStorage.saveToSlot(1, _career('Первый'));
      await CareerStorage.saveToSlot(2, _career('Второй'));

      await CareerStorage.deleteSlot(1);

      expect(await CareerStorage.loadSlot(1), isNull);
      expect((await CareerStorage.loadSlot(2))?.player.name, 'Второй');
      expect(await CareerStorage.hasSavedCareer(), isTrue);

      await CareerStorage.deleteSlot(2);
      expect(await CareerStorage.hasSavedCareer(), isFalse);
    });

    test('delete() clears the active slot only', () async {
      await CareerStorage.saveToSlot(1, _career('Первый'));
      await CareerStorage.saveToSlot(2, _career('Второй'));
      await CareerStorage.setActiveSlot(2);

      await CareerStorage.delete();

      expect(await CareerStorage.loadSlot(2), isNull);
      expect((await CareerStorage.loadSlot(1))?.player.name, 'Первый');
    });
  });

  group('FC Points', () {
    test('balance is separate from career slots and persists', () async {
      final career = _career('Игрок').copyWith(
        history: [
          const SeasonStats(
            season: 1,
            club: 'Тестовый клуб',
            matches: 30,
            goals: 12,
            assists: 5,
            yellowCards: 1,
            redCards: 0,
            averageRating: 7.1,
            achievements: ['Чемпион страны', 'Победитель Лиги чемпионов'],
          ),
        ],
      );

      expect(await FCPointsService.balance(), 0);
      final earned = await FCPointsService.awardSeason(career);

      expect(earned, 240);
      expect(await FCPointsService.balance(), 240);
      expect(await FCPointsService.awardSeason(career), 0);
      expect(await FCPointsService.balance(), 240);

      await CareerStorage.deleteSlot(1);
      expect(await FCPointsService.balance(), 530);
    });

    test('different careers can earn rewards for the same season', () async {
      final first = _career('Первый').copyWith(
        history: [
          const SeasonStats(
            season: 1,
            club: 'Клуб',
            matches: 10,
            goals: 1,
            assists: 0,
            yellowCards: 0,
            redCards: 0,
            averageRating: 6.5,
          ),
        ],
      );
      final second = _career('Второй').copyWith(
        history: [
          const SeasonStats(
            season: 1,
            club: 'Клуб',
            matches: 10,
            goals: 1,
            assists: 0,
            yellowCards: 0,
            redCards: 0,
            averageRating: 6.5,
          ),
        ],
      );

      expect(first.careerId, isNot(second.careerId));
      expect(await FCPointsService.awardSeason(first), 80);
      expect(await FCPointsService.awardSeason(second), 80);
      expect(await FCPointsService.balance(), 160);
    });
  });

  group('FC Points shop', () {
    test('buys modes separately and prevents repeat purchases', () async {
      SharedPreferences.setMockInitialValues({
        'fc_points_profile_v1': jsonEncode({
          'balance': 2000,
          'claimedRewards': <String>[],
        }),
      });

      expect(
        await FCPointsService.purchaseMode('any_starting_club'),
        FCPointsPurchaseResult.purchased,
      );
      expect(await FCPointsService.balance(), 500);
      expect(
        await FCPointsService.ownedModes(),
        {'any_starting_club'},
      );

      expect(
        await FCPointsService.purchaseMode('any_starting_club'),
        FCPointsPurchaseResult.alreadyOwned,
      );
      expect(
        await FCPointsService.purchaseMode('career_without_injuries'),
        FCPointsPurchaseResult.insufficientFunds,
      );
      expect(
        await FCPointsService.purchaseMode('unknown_mode'),
        FCPointsPurchaseResult.unknownItem,
      );
      expect(await FCPointsService.balance(), 400);
      expect(await FCPointsService.ownedModes(), {'any_starting_club'});
    });

    test('earning FC Points does not erase purchased modes', () async {
      SharedPreferences.setMockInitialValues({
        'fc_points_profile_v1': jsonEncode({
          'balance': 1000,
          'claimedRewards': <String>[],
        }),
      });
      await FCPointsService.purchaseMode('career_without_injuries');

      final career = _career('Игрок').copyWith(
        history: [
          const SeasonStats(
            season: 1,
            club: 'Клуб',
            matches: 10,
            goals: 1,
            assists: 0,
            yellowCards: 0,
            redCards: 0,
            averageRating: 6.5,
          ),
        ],
      );
      expect(await FCPointsService.awardSeason(career), 10);
      expect(await FCPointsService.balance(), 10);
      expect(
        await FCPointsService.ownedModes(),
        {'career_without_injuries'},
      );
    });

    test('reads older FC Points profiles without owned modes', () async {
      SharedPreferences.setMockInitialValues({
        'fc_points_profile_v1': jsonEncode({
          'balance': 275,
          'claimedRewards': <String>[],
        }),
      });

      expect(await FCPointsService.balance(), 275);
      expect(await FCPointsService.ownedModes(), isEmpty);
    });
  });

  group('slot summaries', () {
    test('describes filled, damaged and empty slots', () async {
      SharedPreferences.setMockInitialValues({
        'saved_career_v1': jsonEncode(_career('Игрок').toJson()),
        'saved_career_slot_2': '{это не json',
      });

      final summaries = await CareerStorage.slotSummaries();

      expect(summaries, hasLength(CareerStorage.slotCount));

      final first = summaries[0];
      expect(first.slot, 1);
      expect(first.hasCareer, isTrue);
      expect(first.playerName, 'Игрок');
      expect(first.club, Clubs.all.first.name);
      expect(first.season, 1);
      expect(first.age, 19);
      expect(first.overall, isNotNull);

      expect(summaries[1].isCorrupted, isTrue);
      expect(summaries[1].hasCareer, isFalse);

      expect(summaries[2].isEmpty, isTrue);
    });

    test('summarize treats malformed JSON shapes as damaged', () {
      expect(CareerStorage.summarize(1, '[]').isCorrupted, isTrue);
      expect(CareerStorage.summarize(1, '{"season": 3}').isCorrupted, isTrue);
      expect(CareerStorage.summarize(1, 'null').isCorrupted, isTrue);
    });

    test('summarize does not change global club state', () async {
      Clubs.resetCareerState();
      final before = Clubs.strengthOverrides.length;

      await CareerStorage.saveToSlot(2, _career('Чужой'));
      await CareerStorage.slotSummaries();

      expect(Clubs.strengthOverrides.length, before);
    });
  });
}
