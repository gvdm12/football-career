import 'dart:math';

import '../models/club.dart';
import '../models/friendly_match.dart';

class PreSeasonService {
  static int _seed(String value) {
    var result = 23;
    for (final unit in value.codeUnits) {
      result = (result * 31 + unit) & 0x7fffffff;
    }
    return result;
  }

  static List<FriendlyMatch> create({
    required String playerClub,
    required int season,
  }) {
    final random = Random(_seed('$playerClub|$season'));
    final matchingClubs = Clubs.all.where((item) => item.name == playerClub).toList();
    final club = matchingClubs.isEmpty ? null : matchingClubs.first;
    final candidates = Clubs.all
        .map((item) => Clubs.getByName(item.name))
        .where((item) {
      if (item.name == playerClub) return false;
      if (club == null) return true;
      return (item.strength - club.strength).abs() <= 12;
    }).toList()
      ..shuffle(random);

    final selected = candidates.take(2 + random.nextInt(3)).toList();
    return List.generate(selected.length, (index) => FriendlyMatch(
      number: index + 1,
      opponent: selected[index].name,
      isHome: random.nextBool(),
    ));
  }
}
