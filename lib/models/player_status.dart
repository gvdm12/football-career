import 'club.dart';

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
  }) {
    final club = Clubs.getByName(clubName);
    final difference = club.strength - overall;

    // Сильный игрок должен быть основным даже
    // в клубе, который немного превосходит его.
    if (overall >= 80 && difference <= 10) {
      return PlayerStatus.starter;
    }

    // Игроки с рейтингом 76–79 могут быть основными,
    // если клуб не превосходит их больше чем на 4 пункта.
    if (overall >= 76 && difference <= 4) {
      return PlayerStatus.starter;
    }

    // Игроки с рейтингом 70–79 при заметно более
    // сильном клубе обычно относятся к ротации.
    if (overall >= 70 && difference <= 10) {
      return PlayerStatus.rotation;
    }

    // Для игроков с рейтингом 60–69 разница в 5–9
    // пунктов означает ротацию, а 10 и более — запас.
    if (overall >= 60 && difference >= 5 && difference <= 9) {
      return PlayerStatus.rotation;
    }

    if (difference <= 4) {
      return PlayerStatus.starter;
    }

    return PlayerStatus.substitute;
  }
}
