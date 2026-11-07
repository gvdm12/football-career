import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/services/fc_points_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('FC Points balance is capped at 99,999 when reading stored data', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'fc_points_profile_v1',
      jsonEncode({
        'balance': 150000,
        'claimedRewards': <String>[],
        'ownedModes': <String>[],
      }),
    );

    expect(await FCPointsService.balance(), 99999);
  });

  test('FC Points balance never becomes negative', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      'fc_points_profile_v1',
      jsonEncode({
        'balance': -250,
        'claimedRewards': <String>[],
        'ownedModes': <String>[],
      }),
    );

    expect(await FCPointsService.balance(), 0);
  });

  test('maximum FC Points balance is 99,999', () {
    expect(FCPointsService.maxBalance, 99999);
  });
}
