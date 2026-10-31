import 'dart:math';

import 'package:flutter_football/models/club.dart';
import 'player.dart';
import 'career.dart';

class Match {
  /// Стабильное решение о выходе игрока именно в этот матч.
  /// Используется и карточкой матча, и самой симуляцией, чтобы кнопка
  /// не обещала интерактивную игру, если игрок останется вне состава.
  static bool willPlayerPlay({
    required Player player,
    Career? career,
    required String opponent,
    required bool isHome,
  }) {
    if (career?.isInjured == true) return false;

    final clubStrength = Clubs.effectiveStrength(
      clubName: player.club,
      playerClub: player.club,
      playerOverall: player.overall,
    );
    final ratingDifference = player.overall - clubStrength;

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

    final seedText = [
      player.club,
      player.name,
      player.overall.toString(),
      opponent,
      isHome ? 'home' : 'away',
      (career?.season ?? 1).toString(),
    ].join('|');
    var seed = 17;
    for (final unit in seedText.codeUnits) {
      seed = (seed * 31 + unit) & 0x7fffffff;
    }
    final strongerRivals = career?.rivals
            .where((rival) => rival.overall + rival.form > player.overall)
            .length ??
        0;
    final trustBonus = ((career?.coachTrust ?? 65) - 65) * 0.002;
    playChance = (playChance - strongerRivals * 0.14 + trustBonus)
        .clamp(0.12, 0.98)
        .toDouble();

    return Random(seed).nextDouble() < playChance;
  }

  /// Единая модель ожидаемых голов для обычной и интерактивной симуляции.
  /// Возвращает xG хозяев и гостей с учётом силы команд и влияния игрока.
  static ({double home, double away}) calculateExpectedGoals({
    required Player player,
    required String opponent,
    required bool isHome,
    required bool playerPlayed,
    int? playerTeamStrength,
    int? opponentStrength,
  }) {
    final effectivePlayerStrength = playerTeamStrength ??
        Clubs.effectiveStrength(
          clubName: player.club,
          playerClub: player.club,
          playerOverall: player.overall,
        );
    final effectiveOpponentStrength =
        opponentStrength ?? Clubs.getByName(opponent).strength;

    final homeStrength =
        isHome ? effectivePlayerStrength : effectiveOpponentStrength;
    final awayStrength =
        isHome ? effectiveOpponentStrength : effectivePlayerStrength;
    final strengthDifference = homeStrength - awayStrength;

    double homeExpectedGoals =
        1.35 + strengthDifference * 0.035 + 0.15;
    double awayExpectedGoals = 1.35 - strengthDifference * 0.035;

    if (playerPlayed) {
      final skills = player.skills;
      switch (player.position) {
        case PlayerPosition.forward:
          final attackPower =
              skills.shooting * 0.45 +
              skills.dribbling * 0.25 +
              skills.pace * 0.20 +
              skills.heading * 0.15;
          final attackBonus =
              ((attackPower - 60) * 0.004 +
                      (player.overall - 60) * 0.003)
                  .clamp(-0.08, 0.18)
                  .toDouble() +
              (skills.vision - 60) * 0.001;
          if (isHome) {
            homeExpectedGoals += attackBonus;
          } else {
            awayExpectedGoals += attackBonus;
          }
          break;
        case PlayerPosition.midfielder:
          final midfieldPower =
              skills.passing * 0.30 +
              skills.vision * 0.25 +
              skills.dribbling * 0.25 +
              skills.shooting * 0.12 +
              skills.pace * 0.08;
          final attackBonus =
              ((midfieldPower - 60) * 0.003 +
                      (player.overall - 60) * 0.002)
                  .clamp(-0.06, 0.13)
                  .toDouble() +
              (skills.vision - 60) * 0.0015;
          if (isHome) {
            homeExpectedGoals += attackBonus;
          } else {
            awayExpectedGoals += attackBonus;
          }
          break;
        case PlayerPosition.defender:
          final defenseBonus =
              ((skills.defending - 60) * 0.003 +
                      (skills.physical - 60) * 0.0015 +
                      (skills.heading - 60) * 0.0015 +
                      (skills.vision - 60) * 0.0008)
                  .clamp(-0.06, 0.15)
                  .toDouble();
          if (isHome) {
            awayExpectedGoals -= defenseBonus;
          } else {
            homeExpectedGoals -= defenseBonus;
          }
          break;
        case PlayerPosition.goalkeeper:
          final defenseBonus =
              ((skills.defending - 60) * 0.004 +
                      (skills.physical - 60) * 0.001 +
                      (skills.vision - 60) * 0.0008)
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

    return (
      home: homeExpectedGoals.clamp(0.35, 2.8).toDouble(),
      away: awayExpectedGoals.clamp(0.35, 2.8).toDouble(),
    );
  }

  /// Вероятность гола за одну минуту при оставшемся xG.
  static double goalChancePerMinute({
    required double expectedGoalsRemaining,
    required int minutesRemaining,
  }) {
    if (expectedGoalsRemaining <= 0 || minutesRemaining <= 0) return 0;
    return (1 - exp(-expectedGoalsRemaining / minutesRemaining))
        .clamp(0.0, 1.0)
        .toDouble();
  }

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
  final String? injuryName;
  final int injuryMatchesRemaining;

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
    this.injuryName,
    this.injuryMatchesRemaining = 0,
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
    Career? career,
    required String opponent,
    required bool isHome,
  }) {
    final random = Random();

    final homeTeam = isHome ? player.club : opponent;
    final awayTeam = isHome ? opponent : player.club;

    // ------------------------------------------------------------
    // 1. СИЛА КОМАНД И УЧАСТИЕ ИГРОКА
    // ------------------------------------------------------------

    final playerPlayed = willPlayerPlay(
      player: player,
      career: career,
      opponent: opponent,
      isHome: isHome,
    );

    final expectedGoals = calculateExpectedGoals(
      player: player,
      opponent: opponent,
      isHome: isHome,
      playerPlayed: playerPlayed,
    );
    final homeExpectedGoals = expectedGoals.home;
    final awayExpectedGoals = expectedGoals.away;

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
        skills.shooting * 0.42 +
        skills.dribbling * 0.25 +
        skills.pace * 0.18 +
        skills.heading * 0.20;

    // Базовая вероятность остаётся зависимой от навыков и рейтинга.
    double chance =
        0.28 + (attackPower / 100) * 0.25 + (player.overall - 60) * 0.002;

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
        0.10 +
        player.skills.passing * 0.0026 +
        player.skills.dribbling * 0.0015 +
        player.skills.vision * 0.002;

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

    final chance =
        0.07 + (attackPower / 100) * 0.18 + player.skills.vision * 0.0005;

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
        0.09 +
        player.skills.passing * 0.0026 +
        player.skills.dribbling * 0.0015 +
        player.skills.vision * 0.0033;

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
        player.skills.defending * 0.0004 +
        player.skills.physical * 0.0002 +
        player.skills.heading * 0.0008;

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

    final chance =
        0.015 + player.skills.passing * 0.001 + player.skills.vision * 0.0015;

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
