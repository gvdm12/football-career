import 'dart:math';

import '../models/club.dart';
import '../models/friendly_match.dart';

class PreSeasonService {
  static final Random _random = Random();

  static List<FriendlyMatch> create({
    required String playerClub,
    required int season,
  }) {
    final club = Clubs.all.where((item) => item.name == playerClub).firstOrNull;
    final candidates = Clubs.all.where((item) {
      if (item.name == playerClub) return false;
      if (club == null) return true;
      return (item.strength - club.strength).abs() <= 12;
    }).toList()
      ..shuffle(_random);

    final selected = candidates.take(2).toList();
    return List.generate(selected.length, (index) => FriendlyMatch(
      number: index + 1,
      opponent: selected[index].name,
      isHome: _random.nextBool(),
    ));
  }
}
