import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career_objective.dart';
import 'package:flutter_football/models/sponsor_deal.dart';

void main() {
  group('CareerObjective', () {
    test('tracks progress and completes only at its target', () {
      const objective = CareerObjective(
        id: 's1_goals',
        season: 1,
        metric: CareerObjectiveMetric.goals,
        title: 'Score goals',
        description: 'Score 10 goals',
        target: 10,
        reward: 50000,
      );

      final partial = objective.updateProgress(6);
      expect(partial.progress, 6);
      expect(partial.completed, isFalse);
      expect(partial.progressRatio, 0.6);

      final completed = partial.updateProgress(12);
      expect(completed.progress, 10);
      expect(completed.completed, isTrue);
    });

    test('round-trips through JSON', () {
      const objective = CareerObjective(
        id: 's2_apps',
        season: 2,
        metric: CareerObjectiveMetric.appearances,
        title: 'Play matches',
        description: 'Appear in 20 matches',
        target: 20,
        progress: 8,
        reward: 40000,
      );

      final restored = CareerObjective.fromJson(objective.toJson());
      expect(restored.metric, CareerObjectiveMetric.appearances);
      expect(restored.progress, 8);
      expect(restored.target, 20);
    });
  });

  group('Sponsor deals', () {
    test('calculates a capped goal bonus', () {
      const deal = SponsorContract(
        brand: 'Northstar Athletics',
        paymentPerSeason: 50000,
        seasonsRemaining: 2,
        goalBonus: 500,
      );
      expect(deal.payoutForSeason(10), 55000);
      expect(deal.payoutForSeason(40), 62500);
    });

    test('round-trips an offer through JSON', () {
      const offer = SponsorOffer(
        id: 's1_offer',
        brand: 'Apex Sportswear',
        paymentPerSeason: 60000,
        signingBonus: 12000,
        contractYears: 2,
      );
      final restored = SponsorOffer.fromJson(offer.toJson());
      expect(restored.brand, offer.brand);
      expect(restored.paymentPerSeason, offer.paymentPerSeason);
      expect(restored.contractYears, offer.contractYears);
    });
  });
}
