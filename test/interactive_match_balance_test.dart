import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/services/interactive_match_balance.dart';

const _fieldPositions = [
  PlayerPosition.forward,
  PlayerPosition.midfielder,
  PlayerPosition.defender,
];

void main() {
  group('opponent quality', () {
    test('equal teams give no modifier', () {
      expect(
        InteractiveMatchBalance.opponentQualityModifier(
          teamStrength: 75,
          opponentStrength: 75,
        ),
        0,
      );
    });

    test('a stronger opponent hurts, a weaker one helps', () {
      final hard = InteractiveMatchBalance.opponentQualityModifier(
        teamStrength: 55,
        opponentStrength: 90,
      );
      final easy = InteractiveMatchBalance.opponentQualityModifier(
        teamStrength: 90,
        opponentStrength: 55,
      );
      expect(hard, lessThan(0));
      expect(easy, greaterThan(0));
      expect(hard.abs(), greaterThan(easy.abs()));
    });

    test('is capped for huge gaps', () {
      expect(
        InteractiveMatchBalance.opponentQualityModifier(
          teamStrength: 40,
          opponentStrength: 99,
        ),
        -0.08,
      );
      expect(
        InteractiveMatchBalance.opponentQualityModifier(
          teamStrength: 99,
          opponentStrength: 40,
        ),
        0.05,
      );
    });
  });

  group('player level, form and adaptive difficulty', () {
    test('a star in a weak team gets a bonus, a weak player a penalty', () {
      expect(
        InteractiveMatchBalance.playerLevelModifier(
          playerOverall: 85,
          teamStrength: 70,
        ),
        greaterThan(0),
      );
      expect(
        InteractiveMatchBalance.playerLevelModifier(
          playerOverall: 60,
          teamStrength: 80,
        ),
        lessThan(0),
      );
      expect(
        InteractiveMatchBalance.playerLevelModifier(
          playerOverall: 99,
          teamStrength: 40,
        ),
        0.04,
      );
    });

    test('form: unknown is neutral, good helps, bad hurts, capped', () {
      expect(InteractiveMatchBalance.formModifier(null), 0);
      expect(InteractiveMatchBalance.formModifier(8.0), closeTo(0.03, 1e-9));
      expect(InteractiveMatchBalance.formModifier(5.0), closeTo(-0.03, 1e-9));
      expect(InteractiveMatchBalance.formModifier(10.0), 0.04);
      expect(InteractiveMatchBalance.formModifier(1.0), -0.04);
    });

    test('adaptive difficulty needs a few attempts first', () {
      expect(
        InteractiveMatchBalance.adaptiveModifier(attempts: 3, successes: 3),
        0,
      );
    });

    test('a hot streak makes things harder, a cold one easier', () {
      expect(
        InteractiveMatchBalance.adaptiveModifier(attempts: 10, successes: 10),
        lessThan(0),
      );
      expect(
        InteractiveMatchBalance.adaptiveModifier(attempts: 10, successes: 0),
        greaterThan(0),
      );
      expect(
        InteractiveMatchBalance.adaptiveModifier(attempts: 10, successes: 6)
            .abs(),
        lessThan(0.01),
      );
    });

    test('the effect ramps up with the number of attempts', () {
      final early = InteractiveMatchBalance.adaptiveModifier(
        attempts: 4,
        successes: 0,
      );
      final full = InteractiveMatchBalance.adaptiveModifier(
        attempts: 10,
        successes: 0,
      );
      expect(early, greaterThan(0));
      expect(full, greaterThan(early));
      expect(full, lessThanOrEqualTo(0.05));
    });

    test('the total modifier always stays within -0.14..0.10', () {
      for (final team in [40, 70, 99]) {
        for (final opponent in [40, 70, 99]) {
          for (final overall in [40, 70, 99]) {
            for (final form in [null, 1.0, 6.5, 10.0]) {
              for (final successes in [0, 5, 10]) {
                final value = InteractiveMatchBalance.successModifier(
                  teamStrength: team,
                  opponentStrength: opponent,
                  playerOverall: overall,
                  formRating: form,
                  attempts: 10,
                  successes: successes,
                );
                expect(value, inInclusiveRange(-0.14, 0.10));
              }
            }
          }
        }
      }
    });

    test('a top club vs a minnow is easier than the reverse', () {
      double modifier(int team, int opponent) =>
          InteractiveMatchBalance.successModifier(
            teamStrength: team,
            opponentStrength: opponent,
            playerOverall: 75,
            formRating: 6.5,
            attempts: 0,
            successes: 0,
          );
      expect(modifier(88, 62), greaterThan(modifier(62, 88)));
    });
  });

  group('context moments', () {
    test('goalkeepers never get a context phase', () {
      expect(
        InteractiveMatchBalance.pickContextPhase(
          position: PlayerPosition.goalkeeper,
          teamStrength: 80,
          opponentStrength: 60,
          minute: 70,
          goalDifference: -1,
          roll: 0,
          variantRoll: 0,
        ),
        isNull,
      );
    });

    test('a dominant team gets attacking moments', () {
      String? pick(double variant) => InteractiveMatchBalance.pickContextPhase(
        position: PlayerPosition.forward,
        teamStrength: 85,
        opponentStrength: 60,
        minute: 30,
        goalDifference: 0,
        roll: 0.1,
        variantRoll: variant,
      );
      expect(pick(0.2), 'box');
      expect(pick(0.9), 'wideAttack');
    });

    test('an underdog gets defensive moments', () {
      expect(
        InteractiveMatchBalance.pickContextPhase(
          position: PlayerPosition.forward,
          teamStrength: 60,
          opponentStrength: 85,
          minute: 30,
          goalDifference: 0,
          roll: 0.1,
          variantRoll: 0.5,
        ),
        'isolatedPress',
      );
    });

    test('a high roll falls through to the regular position moments', () {
      for (final position in _fieldPositions) {
        expect(
          InteractiveMatchBalance.pickContextPhase(
            position: position,
            teamStrength: 75,
            opponentStrength: 75,
            minute: 30,
            goalDifference: 0,
            roll: 0.99,
            variantRoll: 0.5,
          ),
          isNull,
        );
      }
    });

    test('trailing late raises attack, leading late raises defence', () {
      double attack(int minute, int diff) =>
          InteractiveMatchBalance.attackProbability(
            teamStrength: 75,
            opponentStrength: 75,
            minute: minute,
            goalDifference: diff,
          );
      double defence(int minute, int diff) =>
          InteractiveMatchBalance.defenceProbability(
            teamStrength: 75,
            opponentStrength: 75,
            minute: minute,
            goalDifference: diff,
          );

      expect(attack(80, -1), greaterThan(attack(80, 0)));
      expect(attack(80, 1), lessThan(attack(80, 0)));
      expect(defence(80, 1), greaterThan(defence(80, 0)));
      expect(defence(80, -1), lessThan(defence(80, 0)));
      // Раньше 65-й минуты счёт на выбор эпизода не влияет.
      expect(attack(30, -1), attack(30, 0));
    });

    test('leading late gives midfielders a counter-attack', () {
      expect(
        InteractiveMatchBalance.pickContextPhase(
          position: PlayerPosition.midfielder,
          teamStrength: 75,
          opponentStrength: 75,
          minute: 80,
          goalDifference: 1,
          roll: 0.01,
          variantRoll: 0.5,
        ),
        'counterAttack',
      );
    });

    test('probabilities are always valid and leave room for regular moments', () {
      for (final team in [40, 70, 99]) {
        for (final opponent in [40, 70, 99]) {
          for (final minute in [10, 66, 85]) {
            for (final diff in [-2, 0, 2]) {
              final attack = InteractiveMatchBalance.attackProbability(
                teamStrength: team,
                opponentStrength: opponent,
                minute: minute,
                goalDifference: diff,
              );
              final defence = InteractiveMatchBalance.defenceProbability(
                teamStrength: team,
                opponentStrength: opponent,
                minute: minute,
                goalDifference: diff,
              );
              expect(attack, inInclusiveRange(0.0, 0.45));
              expect(defence, inInclusiveRange(0.0, 0.45));
              expect(attack + defence, lessThanOrEqualTo(0.9));
            }
          }
        }
      }
    });

    test('every phase that can be picked has a text for that position', () {
      const allowed = {
        PlayerPosition.forward: {'box', 'wideAttack', 'isolatedPress'},
        PlayerPosition.midfielder: {
          'finalThird',
          'counterAttack',
          'defend',
          'pressingTrap',
        },
        PlayerPosition.defender: {'overlapRun', 'defend', 'defensiveLine'},
      };

      for (final position in _fieldPositions) {
        for (final team in [50, 75, 95]) {
          for (final opponent in [50, 75, 95]) {
            for (final minute in [20, 72]) {
              for (final diff in [-1, 0, 1]) {
                for (var r = 0; r < 20; r++) {
                  for (var v = 0; v < 5; v++) {
                    final phase = InteractiveMatchBalance.pickContextPhase(
                      position: position,
                      teamStrength: team,
                      opponentStrength: opponent,
                      minute: minute,
                      goalDifference: diff,
                      roll: r / 20,
                      variantRoll: v / 5,
                    );
                    if (phase == null) continue;

                    expect(allowed[position], contains(phase));
                    final text = InteractiveMatchBalance.momentText(
                      phase,
                      position,
                    );
                    expect(text, isNotNull);
                    expect(text!.title, isNotEmpty);
                    expect(text.description, isNotEmpty);
                  }
                }
              }
            }
          }
        }
      }
    });

    test('defend text depends on the position', () {
      final defender = InteractiveMatchBalance.momentText(
        'defend',
        PlayerPosition.defender,
      );
      final midfielder = InteractiveMatchBalance.momentText(
        'defend',
        PlayerPosition.midfielder,
      );
      expect(defender!.title, isNot(midfielder!.title));
    });

    test('unknown phases have no text', () {
      expect(
        InteractiveMatchBalance.momentText('nope', PlayerPosition.forward),
        isNull,
      );
    });
  });

  group('rating adjustment for the team result', () {
    double adjust(
      PlayerPosition position,
      int goalsFor,
      int goalsAgainst, {
      int team = 75,
      int opponent = 75,
    }) => InteractiveMatchBalance.teamResultRatingAdjustment(
      position: position,
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
      teamStrength: team,
      opponentStrength: opponent,
    );

    test('a win is worth more than a draw, a draw more than a loss', () {
      final win = adjust(PlayerPosition.midfielder, 2, 0);
      final draw = adjust(PlayerPosition.midfielder, 1, 1);
      final loss = adjust(PlayerPosition.midfielder, 0, 2);
      expect(win, greaterThan(draw));
      expect(draw, greaterThan(loss));
    });

    test('a win over a stronger side beats the same win over a weaker one', () {
      final upset = adjust(PlayerPosition.forward, 1, 0, team: 60, opponent: 85);
      final routine = adjust(
        PlayerPosition.forward,
        1,
        0,
        team: 85,
        opponent: 60,
      );
      expect(upset, greaterThan(routine));
    });

    test('losing to a weaker side hurts more than losing to a stronger one', () {
      final shock = adjust(PlayerPosition.forward, 0, 1, team: 85, opponent: 60);
      final expected = adjust(
        PlayerPosition.forward,
        0,
        1,
        team: 60,
        opponent: 85,
      );
      expect(shock, lessThan(expected));
    });

    test('clean sheets reward goalkeepers and defenders most', () {
      final keeper = adjust(PlayerPosition.goalkeeper, 1, 0);
      final defender = adjust(PlayerPosition.defender, 1, 0);
      final midfielder = adjust(PlayerPosition.midfielder, 1, 0);
      final forward = adjust(PlayerPosition.forward, 1, 0);
      expect(keeper, greaterThan(defender));
      expect(defender, greaterThan(midfielder));
      expect(midfielder, greaterThan(forward));
    });

    test('conceding hurts keepers and defenders', () {
      expect(
        adjust(PlayerPosition.goalkeeper, 1, 3),
        lessThan(adjust(PlayerPosition.goalkeeper, 1, 1)),
      );
      expect(
        adjust(PlayerPosition.defender, 1, 3),
        lessThan(adjust(PlayerPosition.defender, 1, 1)),
      );
    });

    test('a goalless draw is a small minus for a forward only', () {
      expect(adjust(PlayerPosition.forward, 0, 0), lessThan(0));
      expect(adjust(PlayerPosition.forward, 1, 1), closeTo(0, 1e-9));
    });

    test('stays within -0.7..0.9', () {
      expect(adjust(PlayerPosition.goalkeeper, 0, 6), -0.7);
      for (final position in PlayerPosition.values) {
        for (var gf = 0; gf <= 6; gf++) {
          for (var ga = 0; ga <= 6; ga++) {
            expect(adjust(position, gf, ga), inInclusiveRange(-0.7, 0.9));
          }
        }
      }
    });
  });

  group('coach instructions', () {
    test('the text depends on the score', () {
      final trailing = InteractiveMatchBalance.coachInstructionText(-1);
      final level = InteractiveMatchBalance.coachInstructionText(0);
      final leading = InteractiveMatchBalance.coachInstructionText(1);
      expect(
        {trailing.description, level.description, leading.description},
        hasLength(3),
      );
    });

    test('pressing is a gamble: more goals for both sides', () {
      final effect = InteractiveMatchBalance.coachInstructionEffect(
        action: 'instrPress',
        goalDifference: 0,
      );
      expect(effect.ownXg, greaterThan(1));
      expect(effect.opponentXg, greaterThan(1));
    });

    test('holding trades chances for safety', () {
      final effect = InteractiveMatchBalance.coachInstructionEffect(
        action: 'instrHold',
        goalDifference: 0,
      );
      expect(effect.ownXg, lessThan(1));
      expect(effect.opponentXg, lessThan(effect.ownXg));
    });

    test('the right call for the scoreline is rewarded, the wrong one is not', () {
      double rating(String action, int diff) =>
          InteractiveMatchBalance.coachInstructionEffect(
            action: action,
            goalDifference: diff,
          ).rating;

      expect(rating('instrPress', -1), greaterThan(rating('instrPress', 1)));
      expect(rating('instrHold', 1), greaterThan(rating('instrHold', -1)));
    });

    test('keeping the pace changes nothing', () {
      final effect = InteractiveMatchBalance.coachInstructionEffect(
        action: 'instrKeep',
        goalDifference: -1,
      );
      expect(effect.ownXg, 1.0);
      expect(effect.opponentXg, 1.0);
      expect(effect.rating, 0.0);
      expect(effect.message, isNotEmpty);
    });
  });
}
