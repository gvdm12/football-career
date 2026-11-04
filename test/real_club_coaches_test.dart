import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/career_coach_transfer.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/real_club_coaches.dart';
import 'package:flutter_football/models/real_club_squads.dart';

void main() {
  group('Real club coaches', () {
    test('every club with a real squad has a real manager entry', () {
      final realClubs = RealClubSquads.squads.keys.toSet();

      expect(RealClubCoaches.baseCoaches.keys.toSet(), containsAll(realClubs));
      expect(
        RealClubCoaches.baseCoaches.values.every(
          (name) => name.trim().isNotEmpty && name == name.trim(),
        ),
        isTrue,
      );
    });

    test('manager changes swap both clubs and preserve the real names', () {
      List<CareerCoachTransfer>? changes;

      for (var season = 1; season <= 200; season++) {
        final generated = RealClubCoaches.simulateSeason(
          season: season,
          previousTransfers: const [],
        );
        if (generated.isNotEmpty) {
          changes = generated;
          break;
        }
      }

      expect(changes, isNotNull);
      final change = changes!.single;
      final current = RealClubCoaches.currentCoaches([change]);

      expect(current[change.fromClub], change.replacementCoachName);
      expect(current[change.toClub], change.coachName);
      expect(current.length, RealClubCoaches.baseCoaches.length);
    });

    test('coach transfers persist in career saves and update the player coach', () {
      final player = Player.create(
        name: 'Test Player',
        nationality: 'Россия',
        position: PlayerPosition.forward,
        club: 'Real Madrid',
      );
      final career = Career.create(player).copyWith(
        coachTransfers: const [
          CareerCoachTransfer(
            coachName: 'Jose Mourinho',
            fromClub: 'Real Madrid',
            toClub: 'Barcelona',
            replacementCoachName: 'Hansi Flick',
            season: 2,
          ),
        ],
        coachName: 'Hansi Flick',
      );

      final restored = Career.fromJson(career.toJson());

      expect(restored.coachTransfers, hasLength(1));
      expect(restored.coachTransfers.single.coachName, 'Jose Mourinho');
      expect(restored.coachName, 'Hansi Flick');
    });

    test('new careers use the real club manager name', () {
      final player = Player.create(
        name: 'Test Player',
        nationality: 'Россия',
        position: PlayerPosition.forward,
        club: 'Real Madrid',
      );

      final career = Career.create(player);

      expect(career.coachName, 'Jose Mourinho');
    });
  });
}
