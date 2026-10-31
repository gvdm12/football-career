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
  static PlayerStatus calculate({
    required int overall,
    required String clubName,
    List<PositionRival> rivals = const [],
  }) {
    final club = Clubs.getByName(clubName);
    final difference = club.strength - overall;

    PlayerStatus status;

    // Сначала оцениваем уровень игрока относительно силы клуба.
    if (overall >= 80 && difference <= 10) {
      status = PlayerStatus.starter;
    } else if (overall >= 76 && difference <= 4) {
      status = PlayerStatus.starter;
    } else if (overall >= 70 && difference <= 10) {
      status = PlayerStatus.rotation;
    } else if (overall >= 60 && difference >= 5 && difference <= 9) {
      status = PlayerStatus.rotation;
    } else if (difference <= 4) {
      status = PlayerStatus.starter;
    } else {
      status = PlayerStatus.substitute;
    }

    // Два более сильных конкурента отодвигают игрока в запас.
    // Форма влияет на борьбу, но не заменяет общий рейтинг.
    final strongerRivals = rivals.where(
      (rival) => rival.overall + rival.form > overall,
    ).length;

    if (strongerRivals >= 2) return PlayerStatus.substitute;
    if (strongerRivals == 1 && status == PlayerStatus.starter) {
      return PlayerStatus.rotation;
    }
    return status;
  }
}
