import 'dart:math';

import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/player_status.dart';
import 'player.dart';
import 'career.dart';

class Match {
  final String homeTeam;
  final String awayTeam;
  final int homeGoals;
  final int awayGoals;
  final int? homePenalties;
  final int? awayPenalties;
  final int playerGoals;
  final int playerAssists;
  final int yellowCards;
  final int redCards;
  final double playerRating;
  final bool playerPlayed;

  const Match({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeGoals,
    required this.awayGoals,
    required this.playerGoals,
    required this.playerAssists,
    required this.yellowCards,
    required this.redCards,
    required this.playerRating,
    this.playerPlayed = true,
    this.homePenalties,
    this.awayPenalties,
  });

  bool get isDraw => homeGoals == awayGoals;

  bool isPlayerWin(String playerClub) {
    final playerGoals = homeTeam == playerClub ? homeGoals : awayGoals;

    final opponentGoals = homeTeam == playerClub ? awayGoals : homeGoals;

    return playerGoals > opponentGoals;
  }

  bool get hasPenalties => homePenalties != null && awayPenalties != null;

  bool isPlayerLoss(String playerClub) {
    final playerGoals = homeTeam == playerClub ? homeGoals : awayGoals;

    final opponentGoals = homeTeam == playerClub ? awayGoals : homeGoals;

    return playerGoals < opponentGoals;
  }

  factory Match.generate({
    required Player player,
    required Career career,
    required String opponent,
    required bool isHome,
  }) {
    final random = Random();

    final homeTeam = isHome ? player.club : opponent;
    final awayTeam = isHome ? opponent : player.club;

    // ------------------------------------------------------------
    // 1. СИЛА КОМАНД И УЧАСТИЕ ИГРОКА
    // ------------------------------------------------------------

    final opponentClub = Clubs.getByName(opponent);

    // Сила клуба игрока с учётом бонуса за общий рейтинг.
    final playerClubStrength = Clubs.effectiveStrength(
      clubName: player.club,
      playerClub: player.club,
      playerOverall: player.overall,
    );

    // Сила соперника остаётся базовой.
    final opponentStrength = opponentClub.strength;

    final homeStrength = isHome ? playerClubStrength : opponentStrength;

    final awayStrength = isHome ? opponentStrength : playerClubStrength;

    final strengthDifference = homeStrength - awayStrength;

    final status = PlayerStatusCalculator.calculate(
      overall: player.overall,
      clubName: player.club,
    );

    // Вероятность выхода на поле.
    final ratingDifference = player.overall - playerClubStrength;
    double playChance;

    if (ratingDifference >= 10) {
      playChance = 0.98;
    } else if (ratingDifference >= 5) {
      playChance = 0.94;
    } else if (ratingDifference >= 0) {
      playChance = 0.88;
    } else if (ratingDifference >= -5) {
      playChance = 0.72;
    } else if (ratingDifference >= -10) {
      playChance = 0.60;
    } else {
      playChance = 0.35;
    }

    switch (status) {
      case PlayerStatus.starter:
        playChance = max(playChance, 0.90);
        break;
      case PlayerStatus.rotation:
        playChance = max(playChance, 0.70);
        break;
      case PlayerStatus.substitute:
        playChance = max(playChance, 0.50);
        break;
    }

    final playerPlayed = random.nextDouble() < playChance;

    // ------------------------------------------------------------
    // 2. БАЗОВАЯ СИЛА АТАКИ
    // ------------------------------------------------------------

    // Обе команды используют одинаковую базовую формулу.
    // Преимущество хозяев учитывается отдельно.
    double homeExpectedGoals = 1.35 + strengthDifference * 0.035 + 0.15;

    double awayExpectedGoals = 1.35 - strengthDifference * 0.035;

    // ------------------------------------------------------------
    // 3. ВЛИЯНИЕ ИГРОКА НА РЕЗУЛЬТАТ
    // ------------------------------------------------------------

    if (playerPlayed) {
      final skills = player.skills;

      switch (player.position) {
        case PlayerPosition.forward:
          // Нападающий влияет прежде всего на создание и реализацию моментов.
          final attackPower =
              skills.shooting * 0.45 +
              skills.dribbling * 0.30 +
              skills.pace * 0.25;

          final attackBonus =
              ((attackPower - 60) * 0.004 + (player.overall - 60) * 0.003)
                  .clamp(-0.08, 0.18)
                  .toDouble();

          if (isHome) {
            homeExpectedGoals += attackBonus;
          } else {
            awayExpectedGoals += attackBonus;
          }
          break;

        case PlayerPosition.midfielder:
          // Полузащитник помогает продвижению мяча и атаке.
          final midfieldPower =
              skills.passing * 0.35 +
              skills.dribbling * 0.30 +
              skills.shooting * 0.20 +
              skills.pace * 0.10;

          final attackBonus =
              ((midfieldPower - 60) * 0.003 + (player.overall - 60) * 0.002)
                  .clamp(-0.06, 0.13)
                  .toDouble();

          if (isHome) {
            homeExpectedGoals += attackBonus;
          } else {
            awayExpectedGoals += attackBonus;
          }
          break;

        case PlayerPosition.defender:
          // Хороший защитник немного уменьшает ожидаемые голы соперника.
          final defenseBonus =
              ((skills.defending - 60) * 0.003 +
                      (skills.physical - 60) * 0.0015)
                  .clamp(-0.06, 0.15)
                  .toDouble();

          if (isHome) {
            awayExpectedGoals -= defenseBonus;
          } else {
            homeExpectedGoals -= defenseBonus;
          }
          break;

        case PlayerPosition.goalkeeper:
          // Вратарь влияет на защиту, если эта позиция используется.
          final defenseBonus =
              ((skills.defending - 60) * 0.004 + (skills.physical - 60) * 0.001)
                  .clamp(-0.06, 0.16)
                  .toDouble();

          if (isHome) {
            awayExpectedGoals -= defenseBonus;
          } else {
            homeExpectedGoals -= defenseBonus;
          }
          break;
      }
    }

    // Не допускаем отрицательных или чрезмерных ожиданий голов.
    homeExpectedGoals = homeExpectedGoals.clamp(0.35, 2.8).toDouble();

    awayExpectedGoals = awayExpectedGoals.clamp(0.35, 2.8).toDouble();

    // Генерируем окончательный счёт.
    final homeGoals = _generateGoals(random, homeExpectedGoals);
    final awayGoals = _generateGoals(random, awayExpectedGoals);

    final teamGoals = isHome ? homeGoals : awayGoals;
    final opponentGoals = isHome ? awayGoals : homeGoals;

    // ------------------------------------------------------------
    // 4. ДЕЙСТВИЯ ИГРОКА
    // ------------------------------------------------------------

    int playerGoals = 0;
    int playerAssists = 0;

    // ST
    if (player.position == PlayerPosition.forward) {
      playerGoals = _generateForwardGoals(
        random: random,
        player: player,
        teamGoals: teamGoals,
      );

      playerAssists = _generateForwardAssists(
        random: random,
        player: player,
        teamGoals: teamGoals,
        playerGoals: playerGoals,
      );
    }

    // CM
    if (player.position == PlayerPosition.midfielder) {
      playerGoals = _generateMidfielderGoals(
        random: random,
        player: player,
        teamGoals: teamGoals,
      );

      playerAssists = _generateMidfielderAssists(
        random: random,
        player: player,
        teamGoals: teamGoals,
        playerGoals: playerGoals,
      );
    }

    // CB
    if (player.position == PlayerPosition.defender) {
      playerGoals = _generateDefenderGoals(
        random: random,
        player: player,
        teamGoals: teamGoals,
      );

      playerAssists = _generateDefenderAssists(
        random: random,
        player: player,
        teamGoals: teamGoals,
        playerGoals: playerGoals,
      );
    }

    // Игрок не может забить/ассистировать больше,
    // чем забила команда.
    playerGoals = min(playerGoals, teamGoals);

    playerAssists = min(playerAssists, max(0, teamGoals - playerGoals));

    // ------------------------------------------------------------
    // 3. КАРТОЧКИ
    // ------------------------------------------------------------

    int yellowCards = 0;
    int redCards = 0;

    if (random.nextDouble() < _yellowCardChance(player)) {
      yellowCards = 1;
    }

    if (yellowCards == 1 && random.nextDouble() < _redCardChance(player)) {
      redCards = 1;
    }

    // ------------------------------------------------------------
    // 4. РЕЙТИНГ
    // ------------------------------------------------------------

    double rating = _calculateRating(
      random: random,
      player: player,
      teamGoals: teamGoals,
      opponentGoals: opponentGoals,
      playerGoals: playerGoals,
      playerAssists: playerAssists,
      yellowCards: yellowCards,
      redCards: redCards,
    );

    if (!playerPlayed) {
      playerGoals = 0;
      playerAssists = 0;
      yellowCards = 0;
      redCards = 0;
      rating = 0.0;
    }

    return Match(
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      playerGoals: playerGoals,
      playerAssists: playerAssists,
      yellowCards: yellowCards,
      redCards: redCards,
      playerRating: double.parse(rating.toStringAsFixed(1)),
      playerPlayed: playerPlayed,
    );
  }

  // ============================================================
  // ГОЛЫ КОМАНДЫ
  // ============================================================

  static int _generateGoals(Random random, double expectedGoals) {
    // Распределение Пуассона: учитываем ожидаемое количество голов.
    // Чем сильнее команда, тем выше ожидаемое количество голов.
    final lambda = expectedGoals.clamp(0.1, 6.0);
    final limit = exp(-lambda);

    double product = 1.0;
    int count = 0;

    do {
      count++;
      product *= random.nextDouble();
    } while (product > limit);

    return count - 1;
  }

  // ============================================================
  // ST
  // ============================================================

  static int _generateForwardGoals({
    required Random random,
    required Player player,
    required int teamGoals,
  }) {
    if (teamGoals == 0) {
      return 0;
    }

    final skills = player.skills;

    final attackPower =
        skills.shooting * 0.50 + skills.dribbling * 0.30 + skills.pace * 0.20;

    // Базовая вероятность остаётся зависимой от навыков и рейтинга.
    double chance =
        0.24 + (attackPower / 100) * 0.25 + (player.overall - 60) * 0.002;

    final club = Clubs.getByName(player.club);
    chance += (club.strength - 70) * 0.003;

    chance = chance.clamp(0.20, 0.55);

    int goals = 0;

    for (int i = 0; i < teamGoals; i++) {
      // Первый гол — обычный шанс.
      // Второй — реже, третий и последующие — ещё реже.
      double currentChance;

      if (goals == 0) {
        currentChance = chance;
      } else if (goals == 1) {
        currentChance = chance * 0.55;
      } else {
        currentChance = chance * 0.29;
      }

      if (random.nextDouble() < currentChance) {
        goals++;
      }
    }

    return min(goals, teamGoals);
  }

  static int _generateForwardAssists({
    required Random random,
    required Player player,
    required int teamGoals,
    required int playerGoals,
  }) {
    final remainingGoals = teamGoals - playerGoals;

    if (remainingGoals <= 0) {
      return 0;
    }

    final chance =
        0.10 + player.skills.passing * 0.003 + player.skills.dribbling * 0.002;

    return random.nextDouble() < chance ? 1 : 0;
  }

  // ============================================================
  // CM
  // ============================================================

  static int _generateMidfielderGoals({
    required Random random,
    required Player player,
    required int teamGoals,
  }) {
    if (teamGoals == 0) {
      return 0;
    }

    final skills = player.skills;

    final attackPower =
        skills.shooting * 0.45 +
        skills.dribbling * 0.30 +
        skills.passing * 0.25;

    final chance = 0.07 + (attackPower / 100) * 0.18;

    int goals = 0;

    for (int i = 0; i < teamGoals; i++) {
      if (random.nextDouble() < chance) {
        goals++;
      }
    }

    return min(goals, 2);
  }

  static int _generateMidfielderAssists({
    required Random random,
    required Player player,
    required int teamGoals,
    required int playerGoals,
  }) {
    final remainingGoals = teamGoals - playerGoals;

    if (remainingGoals <= 0) {
      return 0;
    }

    // Для CM пас имеет большое значение.
    final chance =
        0.11 + player.skills.passing * 0.003 + player.skills.dribbling * 0.002;

    int assists = 0;

    for (int i = 0; i < remainingGoals; i++) {
      if (random.nextDouble() < chance) {
        assists++;
      }
    }

    return min(assists, 2);
  }

  // ============================================================
  // CB
  // ============================================================

  static int _generateDefenderGoals({
    required Random random,
    required Player player,
    required int teamGoals,
  }) {
    if (teamGoals == 0) {
      return 0;
    }

    // Защитник забивает редко.
    final chance =
        0.015 +
        player.skills.defending * 0.0005 +
        player.skills.physical * 0.0003;

    return random.nextDouble() < chance ? 1 : 0;
  }

  static int _generateDefenderAssists({
    required Random random,
    required Player player,
    required int teamGoals,
    required int playerGoals,
  }) {
    final remainingGoals = teamGoals - playerGoals;

    if (remainingGoals <= 0) {
      return 0;
    }

    final chance = 0.025 + player.skills.passing * 0.0015;

    return random.nextDouble() < chance ? 1 : 0;
  }

  // ============================================================
  // КАРТОЧКИ
  // ============================================================

  static double _yellowCardChance(Player player) {
    switch (player.position) {
      case PlayerPosition.forward:
        return 0.08;

      case PlayerPosition.midfielder:
        return 0.11;

      case PlayerPosition.defender:
        return 0.16;

      // В игре вратаря нет, но enum пока оставляем
      // для совместимости с моделью.
      case PlayerPosition.goalkeeper:
        return 0.10;
    }
  }

  static double _redCardChance(Player player) {
    switch (player.position) {
      case PlayerPosition.forward:
        return 0.025;

      case PlayerPosition.midfielder:
        return 0.035;

      case PlayerPosition.defender:
        return 0.05;

      case PlayerPosition.goalkeeper:
        return 0.03;
    }
  }

  // ============================================================
  // РЕЙТИНГ ИГРОКА
  // ============================================================

  static double _calculateRating({
    required Random random,
    required Player player,
    required int teamGoals,
    required int opponentGoals,
    required int playerGoals,
    required int playerAssists,
    required int yellowCards,
    required int redCards,
  }) {
    double rating = 6.0;

    final difference = teamGoals - opponentGoals;

    // ----------------------------------------------------------
    // Результат команды
    // ----------------------------------------------------------

    if (difference > 0) {
      rating += 0.5;
    } else if (difference < 0) {
      rating -= 0.4;
    }

    // ----------------------------------------------------------
    // ST
    // ----------------------------------------------------------

    if (player.position == PlayerPosition.forward) {
      rating += playerGoals * 1.3;
      rating += playerAssists * 0.6;

      // Хороший удар помогает получать стабильный рейтинг.
      rating += (player.skills.shooting - 50) * 0.014;

      rating += (player.skills.dribbling - 50) * 0.006;
    }

    // ----------------------------------------------------------
    // CM
    // ----------------------------------------------------------

    if (player.position == PlayerPosition.midfielder) {
      rating += playerGoals * 1.0;
      rating += playerAssists * 0.9;

      rating += (player.skills.passing - 50) * 0.014;

      rating += (player.skills.dribbling - 50) * 0.006;
    }

    // ----------------------------------------------------------
    // CB
    // ----------------------------------------------------------

    if (player.position == PlayerPosition.defender) {
      rating += playerGoals * 1.3;
      rating += playerAssists * 0.5;

      // Хорошая защита помогает держать рейтинг.
      rating += (player.skills.defending - 50) * 0.014;

      rating += (player.skills.physical - 50) * 0.006;

      // Защитник особенно страдает от пропущенных.
      if (opponentGoals == 0) {
        rating += 0.5;
      } else if (opponentGoals >= 3) {
        rating -= 0.5;
      }
    }

    // ----------------------------------------------------------
    // Карточки
    // ----------------------------------------------------------

    if (yellowCards > 0) {
      rating -= 0.4;
    }

    if (redCards > 0) {
      rating -= 1.5;
    }

    // ----------------------------------------------------------
    // Небольшая случайность
    // ----------------------------------------------------------

    rating += random.nextDouble() * 0.8 - 0.4;

    return rating.clamp(4.0, 10.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeGoals': homeGoals,
      'awayGoals': awayGoals,
      'playerGoals': playerGoals,
      'playerAssists': playerAssists,
      'yellowCards': yellowCards,
      'redCards': redCards,
      'playerRating': playerRating,
      'playerPlayed': playerPlayed,
      'homePenalties': homePenalties,
      'awayPenalties': awayPenalties,
    };
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      homeTeam: json['homeTeam'] as String? ?? '',
      awayTeam: json['awayTeam'] as String? ?? '',
      homeGoals: (json['homeGoals'] as num?)?.toInt() ?? 0,
      awayGoals: (json['awayGoals'] as num?)?.toInt() ?? 0,
      playerGoals: (json['playerGoals'] as num?)?.toInt() ?? 0,
      playerAssists: (json['playerAssists'] as num?)?.toInt() ?? 0,
      yellowCards: (json['yellowCards'] as num?)?.toInt() ?? 0,
      redCards: (json['redCards'] as num?)?.toInt() ?? 0,
      playerRating: (json['playerRating'] as num?)?.toDouble() ?? 6.0,
      playerPlayed: json['playerPlayed'] as bool? ?? true,
      homePenalties: (json['homePenalties'] as num?)?.toInt(),
      awayPenalties: (json['awayPenalties'] as num?)?.toInt(),
    );
  }
}
