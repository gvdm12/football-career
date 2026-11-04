import 'club.dart';
import 'position_rival.dart';

enum PlayerStatus { starter, rotation, substitute }

extension PlayerStatusInfo on PlayerStatus {
  String get displayName {
    switch (this) {
      case PlayerStatus.starter:
        return 'Основной состав';
      case PlayerStatus.rotation:
        return 'Ротация';
      case PlayerStatus.substitute:
        return 'Запасной';
    }
  }
}

class PlayerStatusCalculator {
  static int calculateReputation({
    required int overall,
    required double? averageRating,
    required int coachTrust,
    int trophies = 0,
  }) {
    return (overall * 0.55 +
            (averageRating ?? 6.0) * 4 +
            coachTrust * 0.12 +
            trophies * 1.5)
        .round()
        .clamp(1, 100)
        .toInt();
  }

  static PlayerStatus calculate({
    required int overall,
    required String clubName,
    List<PositionRival> rivals = const [],
    int coachTrust = 65,
    int reputation = 60,
    double? averageRating,
    double? formRating,
  }) {
    final club = Clubs.getByName(clubName);
    final difference = overall - club.strength;
    final formBonus = ((formRating ?? averageRating ?? 6.0) - 6.0).clamp(-1.5, 1.5);
    final trustBonus = (coachTrust - 65) / 20;
    final reputationBonus = (reputation - 60) / 25;
    final squadScore = difference + trustBonus + reputationBonus + formBonus;

    // При высоком доверии и репутации игрок своего уровня не должен
    // постоянно оставаться запасным только из-за случайной генерации конкурентов.
    final clearlyTrusted = coachTrust >= 85 && reputation >= 85;
    final playerPerformanceLevel =
        overall + (formBonus * 2).round() + (trustBonus * 0.35).round();
    final strongerRivals = rivals.where((rival) {
      final rivalPerformanceLevel = rival.selectionStrength;
      return rivalPerformanceLevel > playerPerformanceLevel;
    }).toList();
    final clearlyStrongerRivals = strongerRivals.where((rival) {
      final rivalPerformanceLevel = rival.selectionStrength;
      return rivalPerformanceLevel >= playerPerformanceLevel + 6;
    }).length;

    if (clearlyTrusted &&
        difference >= -5 &&
        clearlyStrongerRivals == 0) {
      return PlayerStatus.starter;
    }

    if (squadScore >= -1.0 && clearlyStrongerRivals == 0) {
      return PlayerStatus.starter;
    }

    if (squadScore >= -7.0 && clearlyStrongerRivals <= 1) {
      return PlayerStatus.rotation;
    }

    return PlayerStatus.substitute;
  }
}
