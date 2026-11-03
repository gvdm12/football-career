import 'dart:math';

import '../models/career_world_transfer.dart';
import '../models/club.dart';
import '../models/real_club_squads.dart';

class WorldTransferService {
  static final Random _random = Random();

  /// Генерирует несколько переходов реальных игроков между сезонами.
  /// Игроки выбираются из фактических ростеров, поэтому один футболист
  /// не может одновременно оказаться в двух клубах.
  static List<CareerWorldTransfer> simulateSeason({
    required int season,
    required List<CareerWorldTransfer> previousTransfers,
    required bool realistic,
  }) {
    RealClubSquads.applyCareerTransfers(previousTransfers);
    final created = <CareerWorldTransfer>[];
    final transferCount = 1 + _random.nextInt(3);

    for (var index = 0; index < transferCount; index++) {
      final candidates = <({String club, String position, RealClubPlayer player})>[];
      for (final club in RealClubSquads.squads.entries) {
        for (final group in club.value.entries) {
          for (final player in group.value) {
            if (group.value.length <= 1) continue;
            if (player.overall < 78 || player.age > 33) continue;
            if (created.any((transfer) => transfer.playerName == player.name)) {
              continue;
            }
            candidates.add((club: club.key, position: group.key, player: player));
          }
        }
      }
      if (candidates.isEmpty) break;

      candidates.shuffle(_random);
      var moved = false;
      for (final candidate in candidates) {
        final source = Clubs.getByName(candidate.club);
        final destinations = Clubs.all
            .map((club) => Clubs.getByName(club.name))
            .where((club) {
          if (club.name == candidate.club) return false;
          final destinationRoster = RealClubSquads.squads[club.name];
          final positionCount = destinationRoster?[candidate.position]?.length ?? 0;
          final positionLimit = candidate.position == 'goalkeeper'
              ? 2
              : candidate.position == 'forward'
                  ? 4
                  : 5;
          if (positionCount >= positionLimit) return false;
          if (realistic && (club.strength - source.strength).abs() > 12) {
            return false;
          }
          if (candidate.player.overall > club.strength + 12) return false;
          if (club.strength > candidate.player.overall + 15) return false;
          return true;
        }).toList();
        if (destinations.isEmpty) continue;

        destinations.shuffle(_random);
        final destination = destinations.first;
        final transfer = CareerWorldTransfer(
          playerName: candidate.player.name,
          fromClub: candidate.club,
          toClub: destination.name,
          position: candidate.position,
          age: candidate.player.age,
          overall: candidate.player.overall,
          jerseyNumber: candidate.player.jerseyNumber,
          season: season,
        );
        created.add(transfer);
        RealClubSquads.applyCareerTransfers([
          ...previousTransfers,
          ...created,
        ]);
        moved = true;
        break;
      }
      if (!moved) break;
    }
    return created;
  }
}
