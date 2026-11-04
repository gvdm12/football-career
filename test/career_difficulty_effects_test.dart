import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career_settings.dart';

void main() {
  group('CareerDifficultyEffects', () {
    test('normal difficulty keeps standard values', () {
      expect(CareerDifficulty.normal.matchExpectedGoalsShift, 0);
      expect(CareerDifficulty.normal.injuryChanceMultiplier, 1);
      expect(CareerDifficulty.normal.selectionChanceAdjustment, 0);
      expect(CareerDifficulty.normal.interactiveActionAdjustment, 0);
      expect(CareerDifficulty.normal.opponentPressureMultiplier, 1);
      expect(CareerDifficulty.normal.coachTrustMultiplier, 1);
    });

    test('easy difficulty makes the career more forgiving', () {
      expect(CareerDifficulty.easy.matchExpectedGoalsShift, 0.15);
      expect(CareerDifficulty.easy.injuryChanceMultiplier, 0.85);
      expect(CareerDifficulty.easy.selectionChanceAdjustment, 0.06);
      expect(CareerDifficulty.easy.interactiveActionAdjustment, 0.05);
      expect(CareerDifficulty.easy.opponentPressureMultiplier, 0.85);
      expect(CareerDifficulty.easy.coachTrustMultiplier, 0.8);
    });

    test('hard difficulty increases the challenge', () {
      expect(CareerDifficulty.hard.matchExpectedGoalsShift, -0.15);
      expect(CareerDifficulty.hard.injuryChanceMultiplier, 1.2);
      expect(CareerDifficulty.hard.selectionChanceAdjustment, -0.06);
      expect(CareerDifficulty.hard.interactiveActionAdjustment, -0.05);
      expect(CareerDifficulty.hard.opponentPressureMultiplier, 1.15);
      expect(CareerDifficulty.hard.coachTrustMultiplier, 1.2);
    });
  });

  test('legacy saves normalize injury frequency but keep development speed', () {
    final settings = CareerSettings.fromJson({
      'difficulty': 'hard',
      'injuryFrequency': 1.2,
      'developmentSpeed': 0.85,
    });

    expect(settings.injuryFrequency, 1.0);
    expect(settings.developmentSpeed, 0.85);
  });
}
