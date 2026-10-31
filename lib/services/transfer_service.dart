import 'dart:math';

import '../models/career.dart';
import '../models/club.dart';
import '../models/transfer_offer.dart';

class TransferService {
  static final Random _random = Random();

  /// Генерирует срок контракта от 1 до 4 лет.
  static int _generateContractYears({
    required double rating,
    required int contributions,
  }) {
    final exceptional = rating >= 7.5 && contributions >= 18;
    final strong = rating >= 7.2 && contributions >= 12;
    final roll = _random.nextInt(100);

    if (exceptional) {
      if (roll < 5) return 1;
      if (roll < 15) return 2;
      if (roll < 40) return 3;
      return 4;
    }

    if (strong) {
      if (roll < 10) return 1;
      if (roll < 30) return 2;
      if (roll < 60) return 3;
      return 4;
    }

    if (roll < 25) return 1;
    if (roll < 60) return 2;
    if (roll < 85) return 3;
    return 4;
  }

  /// Определяет максимальную силу клуба,
  /// который может заинтересоваться игроком.
  static int _getMaxStrength({
    required int overall,
    required int age,
    required double rating,
    required int contributions,
  }) {
    int strength;

    if (overall < 65) {
      strength = 70;
    } else if (overall < 70) {
      strength = 75;
    } else if (overall < 75) {
      strength = 80;
    } else if (overall < 80) {
      strength = 85;
    } else if (overall < 85) {
      strength = 89;
    } else if (overall < 90) {
      strength = 93;
    } else {
      strength = 97;
    }

    if (rating >= 7.5 && contributions >= 18) {
      strength += 3;
    } else if (rating >= 7.2 && contributions >= 12) {
      strength += 2;
    } else if (rating >= 6.8) {
      strength += 1;
    }

    if (age >= 33) strength -= 2;
    if (age >= 36) strength -= 2;
    if (age >= 39) strength -= 3;

    if (age >= 30 && overall >= 85 && rating >= 7.2) {
      strength += 2;
    }

    return strength.clamp(60, 97).toInt();
  }

  /// Рассчитывает ежемесячную зарплату в евро.
  static int _generateSalary({
    required Club club,
    required int overall,
    required int age,
    required double rating,
    required int contributions,
    required int previousSalary,
    required int agentLevel,
  }) {
    final clubSalary = 2000 * pow(1.14, max(0, club.strength - 60));

    final playerMultiplier = (0.65 + (overall - 60) * 0.035).clamp(0.65, 2.8);

    double performanceMultiplier = 1.0;

    if (rating >= 7.5 && contributions >= 18) {
      performanceMultiplier = 1.25;
    } else if (rating >= 7.2 && contributions >= 12) {
      performanceMultiplier = 1.15;
    } else if (rating >= 6.8) {
      performanceMultiplier = 1.05;
    } else if (rating > 0 && rating < 6.3) {
      performanceMultiplier = 0.90;
    }

    double ageMultiplier = 1.0;

    if (age >= 34) ageMultiplier = 0.92;
    if (age >= 38) ageMultiplier = 0.82;

    final randomMultiplier = 0.90 + _random.nextDouble() * 0.20;

    final calculatedSalary =
        clubSalary *
        playerMultiplier *
        performanceMultiplier *
        ageMultiplier *
        randomMultiplier;

    final salary = previousSalary > 0
        ? calculatedSalary * 0.80 + previousSalary * 0.20
        : calculatedSalary;

    // Саудовские клубы предлагают более высокие зарплаты.
    final isSaudiClub = Clubs.leagueOf(club.name)?.name == 'saudiArabia';

    final leagueMultiplier = !isSaudiClub
        ? 1.0
        : overall >= 85
        ? 1.6
        : overall >= 75
        ? 1.5
        : 1.4;

    final agentMultiplier = 1.0 + (agentLevel.clamp(1, 10) - 1) * 0.02;
    return max(1000, (salary * leagueMultiplier * agentMultiplier).round());
  }

  /// Вес клуба при выборе предложений после 15-го сезона.
  /// Чем больше вес, тем чаще выбирается клуб.
  static double _getLateCareerClubWeight({
    required Club club,
    required int overall,
  }) {
    if (club.strength < 70) {
      return 5.0;
    }

    if (club.strength < 75) {
      return 4.5;
    }

    if (club.strength < 80) {
      return 4.0;
    }

    if (club.strength < 85) {
      return 2.0;
    }

    if (club.strength < 88) {
      return 1.0;
    }

    // Топ-клубы предлагают контракт очень редко.
    return overall >= 85 ? 0.25 : 0.10;
  }

  /// Выбирает клуб случайно с учётом его веса.
  static Club? _pickWeightedClub({
    required List<Club> clubs,
    required int overall,
  }) {
    if (clubs.isEmpty) return null;

    final weights = clubs.map((club) {
      return _getLateCareerClubWeight(club: club, overall: overall);
    }).toList();

    final totalWeight = weights.fold<double>(0, (sum, weight) => sum + weight);

    if (totalWeight <= 0) return null;

    var roll = _random.nextDouble() * totalWeight;

    for (var i = 0; i < clubs.length; i++) {
      roll -= weights[i];

      if (roll < 0) {
        return clubs[i];
      }
    }

    return clubs.last;
  }

  /// Генерирует до трёх предложений от разных клубов.
  static List<TransferOffer> generateOffers(Career career) {
    final player = career.player;
    final overall = player.overall;
    final age = player.age;
    final rating = career.averageRating ?? 0;
    final contributions = career.goals + career.assists;

    final currentClub = player.club == 'Без клуба'
        ? null
        : Clubs.getByName(player.club);

    final currentStrength = currentClub?.strength ?? 60;

    final maxStrength = (_getMaxStrength(
      overall: overall,
      age: age,
      rating: rating,
      contributions: contributions,
    ) +
        career.agentLevel -
        1)
        .clamp(60, 97)
        .toInt();

    final minStrength = max(60, currentStrength - 8);

    final allOtherClubs = Clubs.all
        .where((club) => club.name != player.club)
        .toList();

    if (allOtherClubs.isEmpty) return [];

    var candidates = allOtherClubs.where((club) {
      if (career.season >= 16) {
        // После 15-го сезона допускаем клубы
        // всех уровней в пределах максимальной силы.
        return club.strength <= maxStrength;
      }

      return club.strength >= minStrength &&
          club.strength <= max(maxStrength, currentStrength - 3);
    }).toList();

    // Если клубов мало, расширяем список.
    if (candidates.length < 3) {
      candidates = allOtherClubs
          .where((club) => club.strength <= maxStrength)
          .toList();
    }

    if (candidates.length < 3) {
      candidates = allOtherClubs;
    }

    // По возможности не предлагаем клубы,
    // в которых игрок выступал в последних сезонах.
    final recentClubs = career.history.reversed
        .take(3)
        .map((stats) => stats.club)
        .toSet();

    final clubsWithoutRecent = candidates
        .where((club) => !recentClubs.contains(club.name))
        .toList();

    if (clubsWithoutRecent.length >= 3) {
      candidates = clubsWithoutRecent;
    }

    final selected = <Club>[];

    void addRandomFrom(List<Club> pool) {
      if (selected.length >= 3) return;

      final available = pool
          .where((club) => !selected.any((item) => item.name == club.name))
          .toList();

      if (available.isNotEmpty) {
        selected.add(available[_random.nextInt(available.length)]);
      }
    }

    if (career.season >= 16) {
      // Поздняя карьера:
      // все три предложения выбираются с весами.
      while (selected.length < 3) {
        final available = candidates
            .where((club) => !selected.any((item) => item.name == club.name))
            .toList();

        if (available.isEmpty) break;

        final club = _pickWeightedClub(clubs: available, overall: overall);

        if (club == null) break;

        selected.add(club);
      }
    } else {
      // До 16-го сезона сохраняем прежнюю систему.

      // 1. Клуб примерно того же уровня.
      addRandomFrom(
        candidates
            .where(
              (club) =>
                  club.strength >= currentStrength - 5 &&
                  club.strength <= currentStrength + 2,
            )
            .toList(),
      );

      // 2. Клуб для карьерного роста.
      addRandomFrom(
        candidates
            .where(
              (club) =>
                  club.strength > currentStrength + 2 &&
                  club.strength <= currentStrength + 8,
            )
            .toList(),
      );

      // 3. Вероятность предложения от топ-клуба.
      final exceptionalSeason = rating >= 7.5 && contributions >= 18;

      double topClubChance;

      if (age < 24) {
        topClubChance = exceptionalSeason ? 0.25 : 0.08;
      } else if (age < 30) {
        topClubChance = exceptionalSeason ? 0.30 : 0.12;
      } else if (age < 34) {
        topClubChance = exceptionalSeason ? 0.22 : 0.07;
      } else if (age < 38) {
        topClubChance = exceptionalSeason ? 0.12 : 0.03;
      } else {
        topClubChance = exceptionalSeason ? 0.06 : 0.01;
      }

      if (overall < 80) {
        topClubChance *= 0.4;
      }
      topClubChance = (topClubChance + (career.agentLevel - 1) * 0.015)
          .clamp(0.0, 0.75)
          .toDouble();

      final topClubs = candidates.where((club) => club.strength >= 88).toList();

      if (topClubs.isNotEmpty && _random.nextDouble() < topClubChance) {
        addRandomFrom(topClubs);
      }

      // Заполняем оставшиеся места.
      addRandomFrom(
        candidates
            .where((club) => club.strength > currentStrength + 8)
            .toList(),
      );

      addRandomFrom(candidates);
    }

    return selected.map((club) {
      final contractYears = _generateContractYears(
        rating: rating,
        contributions: contributions,
      );

      final salary = _generateSalary(
        club: club,
        overall: overall,
        age: age,
        rating: rating,
        contributions: contributions,
        previousSalary: career.monthlySalary,
        agentLevel: career.agentLevel,
      );

      return TransferOffer(
        club: club,
        salary: salary,
        contractYears: contractYears,
      );
    }).toList();
  }

  /// Объединяет прежнюю систему трансферов и предложения через агента.
  /// Обычные предложения не получают бонусов уровня агента.
  static List<TransferOffer> generateCombinedOffers(Career career) {
    final ordinary = generateOffers(career.copyWith(agentLevel: 1));
    final ordinaryCount = ordinary.isEmpty ? 0 : 1 + _random.nextInt(2);
    final selected = <TransferOffer>[];

    for (final offer in ordinary.take(ordinaryCount)) {
      selected.add(TransferOffer(
        club: offer.club,
        salary: offer.salary,
        contractYears: offer.contractYears,
      ));
    }

    // Агент открывает дополнительные варианты. Повторно тот же клуб
    // в списке предложений не появляется.
    final agentOffers = (career.agentInterestedClubs.isNotEmpty
        ? generateAgentOffersFromInterest(career)
        : generateOffers(career))
        .where((offer) => !selected.any((item) => item.club.name == offer.club.name))
        .toList()
      ..shuffle(_random);

    final agentCount = agentOffers.isEmpty ? 0 : 1 + _random.nextInt(2);
    for (final offer in agentOffers.take(agentCount)) {
      selected.add(TransferOffer(
        club: offer.club,
        salary: offer.salary,
        contractYears: offer.contractYears,
        isAgentOffer: true,
      ));
    }

    return selected;
  }

  /// Создаёт реальные предложения от клубов, сохранённых на экране агента.
  static List<TransferOffer> generateAgentOffersFromInterest(Career career) {
    final rating = career.averageRating ?? 0;
    final contributions = career.goals + career.assists;
    final offers = <TransferOffer>[];

    for (final clubName in career.agentInterestedClubs) {
      final club = Clubs.getByName(clubName);
      if (club.name == career.player.club) continue;

      final salary = _generateSalary(
        club: club,
        overall: career.player.overall,
        age: career.player.age,
        rating: rating,
        contributions: contributions,
        previousSalary: career.monthlySalary,
        agentLevel: career.agentLevel,
      );

      offers.add(TransferOffer(
        club: club,
        salary: salary,
        contractYears: _generateContractYears(
          rating: rating,
          contributions: contributions,
        ),
        isAgentOffer: true,
      ));
    }

    return offers;
  }

  /// Предложение о продлении контракта с текущим клубом.
  static TransferOffer? generateRenewalOffer(Career career) {
    if (career.player.club == 'Без клуба') return null;
    if (career.contractYears > 1) return null;

    final currentClub = Clubs.getByName(career.player.club);

    final seasonsAtClub = career.history
        .where((stats) => stats.club == career.player.club)
        .length;

    if (seasonsAtClub < 1) return null;

    final rating = career.averageRating ?? 0;
    final contributions = career.goals + career.assists;

    // После 32 лет клубы чаще отказываются продлевать контракт.
    // Чем сильнее клуб и старше игрок, тем выше риск отказа.
    if (career.player.age >= 32) {
      final age = career.player.age;
      double refusalChance;

      if (currentClub.strength >= 85) {
        refusalChance = 0.35;
      } else if (currentClub.strength >= 80) {
        refusalChance = 0.18;
      } else {
        refusalChance = 0.08;
      }

      if (age >= 32 && age <= 33) refusalChance += 0.08;
      if (age >= 33 && age <= 35) refusalChance += 0.20;
      if (age >= 36) refusalChance += 0.35;
      if (rating > 0 && rating < 6.5) refusalChance += 0.25;
      if (rating >= 6.5 && rating < 7.0) refusalChance += 0.12;

      // Отличный сезон помогает сохранить доверие клуба,
      // но не гарантирует продление в зрелом возрасте.
      if (rating >= 7.5 && contributions >= 18) {
        refusalChance -= 0.12;
      } else if (rating >= 7.2 && contributions >= 12) {
        refusalChance -= 0.06;
      }

      refusalChance = refusalChance.clamp(0.05, 0.85);

      if (_random.nextDouble() < refusalChance) {
        return null;
      }
    } else if (rating < 6.5 && _random.nextDouble() < 0.5) {
      // Для игроков младше 32 лет сохраняем прежнее правило.
      return null;
    }

    final contractYears = _generateContractYears(
      rating: rating,
      contributions: contributions,
    );

    final salary = _generateSalary(
      club: currentClub,
      overall: career.player.overall,
      age: career.player.age,
      rating: rating,
      contributions: contributions,
      previousSalary: career.monthlySalary,
      agentLevel: career.agentLevel,
    );

    return TransferOffer(
      club: currentClub,
      salary: salary,
      contractYears: contractYears,
      isRenewal: true,
    );
  }
}
