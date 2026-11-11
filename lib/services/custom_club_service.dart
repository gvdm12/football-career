import 'dart:math';

import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_logos.dart';
import 'package:flutter_football/models/custom_club.dart';
import 'package:flutter_football/models/league_table.dart';

/// Проблема с названием клуба или стадиона.
enum ClubNameIssue { tooShort, tooLong, badCharacters, taken }

/// Положение клуба в итоговой таблице.
typedef ClubStanding = ({int position, int teamCount});

/// Финансы клуба за сезон.
class SeasonFinance {
  final int tv;
  final int prize;
  final int tickets;
  final int sponsors;
  final int wages;
  final int upkeep;

  const SeasonFinance({
    required this.tv,
    required this.prize,
    required this.tickets,
    required this.sponsors,
    required this.wages,
    required this.upkeep,
  });

  int get income => tv + prize + tickets + sponsors;
  int get expenses => wages + upkeep;
  int get net => income - expenses;
}

/// Результат конца сезона для созданного клуба.
class CustomClubSeasonOutcome {
  final CustomClub club;
  final SeasonFinance finance;

  /// Изменение силы клуба от улучшений и долгов (добавляется к силе,
  /// которую уже посчитала игра по итогам сезона).
  final int strengthDelta;

  const CustomClubSeasonOutcome({
    required this.club,
    required this.finance,
    required this.strengthDelta,
  });
}

/// Правила режима «Свой клуб»: создание, экономика и развитие клуба.
///
/// Здесь нет UI и нет доступа к глобальному состоянию, поэтому всё
/// проверяется обычными тестами.
class CustomClubService {
  const CustomClubService._();

  static const int minStrength = 70;
  static const int maxStrength = 76;
  static const int maxFacilityLevel = 5;
  static const int startingFunds = 2500000;
  static const int startingFans = 25;
  static const int minFans = 5;
  static const int maxFans = 100;
  static const int minNameLength = 3;
  static const int maxNameLength = 24;
  static const int minStadiumNameLength = 3;
  static const int maxStadiumNameLength = 30;
  static const int maxHistory = 30;

  // ---------------------------------------------------------------------
  // Создание
  // ---------------------------------------------------------------------

  /// Начальная сила нового клуба: случайно от 70 до 76.
  static int rollStrength(Random random) =>
      minStrength + random.nextInt(maxStrength - minStrength + 1);

  /// Убирает лишние пробелы по краям и внутри названия.
  static String cleanName(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ');

  static final RegExp _allowedChars = RegExp(
    r"^[\p{L}\p{N} .'\-]+$",
    unicode: true,
  );

  /// Проверяет название клуба. Возвращает null, если всё в порядке.
  ///
  /// [takenNames] — названия, которые уже есть в игре. Сравнение не зависит
  /// от регистра и знаков, чтобы нельзя было создать «Real-Madrid».
  static ClubNameIssue? validateName(
    String raw, {
    required Iterable<String> takenNames,
  }) {
    final name = cleanName(raw);

    if (name.length < minNameLength) return ClubNameIssue.tooShort;
    if (name.length > maxNameLength) return ClubNameIssue.tooLong;
    if (!_allowedChars.hasMatch(name)) return ClubNameIssue.badCharacters;

    final lower = name.toLowerCase();
    final key = ClubLogos.normalize(name);
    for (final taken in takenNames) {
      if (taken.toLowerCase() == lower) return ClubNameIssue.taken;
      if (key.isNotEmpty && ClubLogos.normalize(taken) == key) {
        return ClubNameIssue.taken;
      }
    }
    return null;
  }

  /// Проверяет название стадиона.
  static ClubNameIssue? validateStadiumName(String raw) {
    final name = cleanName(raw);
    if (name.length < minStadiumNameLength) return ClubNameIssue.tooShort;
    if (name.length > maxStadiumNameLength) return ClubNameIssue.tooLong;
    if (!_allowedChars.hasMatch(name)) return ClubNameIssue.badCharacters;
    return null;
  }

  /// Трёхбуквенное сокращение для таблиц: первые буквы названия.
  static String defaultShortName(String name) {
    final letters = cleanName(name).replaceAll(RegExp(r"[^\p{L}\p{N}]", unicode: true), '');
    if (letters.isEmpty) return 'CLB';
    final cut = letters.length >= 3 ? letters.substring(0, 3) : letters;
    return cut.toUpperCase();
  }

  /// Создаёт новый клуб с начальным бюджетом и случайной силой.
  static CustomClub create({
    required String name,
    required String shortName,
    required ClubBadgeShape badgeShape,
    required ClubBadgeSymbol badgeSymbol,
    required int primaryColor,
    required int secondaryColor,
    required League league,
    required int division,
    required String replacedClub,
    required Random random,
  }) {
    final clean = cleanName(name);
    final short = cleanName(shortName).isEmpty
        ? defaultShortName(clean)
        : cleanName(shortName).toUpperCase();

    return CustomClub(
      name: clean,
      shortName: short.length > 4 ? short.substring(0, 4) : short,
      badgeShape: badgeShape,
      badgeSymbol: badgeSymbol,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      league: league,
      division: division,
      replacedClub: replacedClub,
      baseStrength: rollStrength(random),
      stadiumName: '$clean Arena',
      funds: startingFunds,
      fans: startingFans,
    );
  }

  // ---------------------------------------------------------------------
  // Улучшения
  // ---------------------------------------------------------------------

  static const Map<ClubFacility, int> _baseCost = {
    ClubFacility.academy: 1200000,
    ClubFacility.training: 1500000,
    ClubFacility.scouting: 1800000,
    ClubFacility.stadium: 2000000,
  };

  static const List<double> _costSteps = [1.0, 2.0, 3.5, 5.5, 8.0];

  /// Цена перехода с уровня [level] на следующий или null на максимуме.
  static int? upgradeCost(ClubFacility facility, int level) {
    if (level < 0 || level >= maxFacilityLevel) return null;
    final raw = _baseCost[facility]! * _costSteps[level];
    return (raw / 50000).round() * 50000;
  }

  static bool canUpgrade(CustomClub club, ClubFacility facility) {
    final cost = upgradeCost(facility, club.levelOf(facility));
    return cost != null && club.funds >= cost;
  }

  /// Улучшает объект на один уровень. Возвращает null, если нельзя.
  static CustomClub? upgrade(CustomClub club, ClubFacility facility) {
    final level = club.levelOf(facility);
    final cost = upgradeCost(facility, level);
    if (cost == null || club.funds < cost) return null;

    return club.copyWith(
      funds: club.funds - cost,
      facilityLevels: {...club.facilityLevels, facility: level + 1},
    );
  }

  /// Вместимость стадиона на данном уровне.
  static int stadiumCapacity(int level) => 6000 + 6000 * level;

  /// Рост силы клуба за сезон от улучшений (дробное число).
  static double growthPerSeason(CustomClub club) {
    return club.levelOf(ClubFacility.academy) * 0.20 +
        club.levelOf(ClubFacility.training) * 0.25 +
        club.levelOf(ClubFacility.scouting) * 0.25;
  }

  // ---------------------------------------------------------------------
  // Деньги
  // ---------------------------------------------------------------------

  /// Личные деньги игрока, вложенные в клуб.
  static CustomClub donate(CustomClub club, int amount) {
    if (amount <= 0) return club;
    return club.copyWith(funds: club.funds + amount);
  }

  static int ticketPrice(TicketPolicy policy) {
    switch (policy) {
      case TicketPolicy.affordable:
        return 22;
      case TicketPolicy.standard:
        return 30;
      case TicketPolicy.premium:
        return 42;
    }
  }

  /// Финансы за сезон. [position] == 0 или [teamCount] <= 1 означает
  /// «положение неизвестно», тогда берётся середина таблицы.
  static SeasonFinance seasonFinance({
    required CustomClub club,
    required int position,
    required int teamCount,
    required int division,
    required int strength,
  }) {
    final known = position > 0 && teamCount > 1;
    final fraction = known ? (teamCount - position) / (teamCount - 1) : 0.5;
    final topDivision = division <= 1;

    final tv = topDivision ? 5000000 : 2000000;
    final prize =
        ((topDivision ? 4000000 : 1500000) * fraction).round() +
        (known && position == 1 ? (topDivision ? 3000000 : 1000000) : 0);

    final capacity = stadiumCapacity(club.levelOf(ClubFacility.stadium));
    final fill = 0.35 + 0.6 * club.fans / 100;
    final tickets =
        (capacity * fill * ticketPrice(club.ticketPolicy) * 19).round();
    final sponsors = club.fans * 40000;

    final wages = max(0, strength - 55) * 300000;
    final levels = ClubFacility.values.fold<int>(
      0,
      (sum, facility) => sum + club.levelOf(facility),
    );
    final upkeep = levels * 250000;

    return SeasonFinance(
      tv: tv,
      prize: prize,
      tickets: tickets,
      sponsors: sponsors,
      wages: wages,
      upkeep: upkeep,
    );
  }

  /// Изменение числа болельщиков по итогам сезона.
  static int fansDelta({
    required int position,
    required int teamCount,
    required TicketPolicy policy,
  }) {
    final known = position > 0 && teamCount > 1;
    final fraction = known ? (teamCount - position) / (teamCount - 1) : 0.5;

    var delta = ((fraction - 0.5) * 12).round();
    if (known && position == 1) delta += 4;
    if (policy == TicketPolicy.affordable) delta += 2;
    if (policy == TicketPolicy.premium) delta -= 2;
    return delta;
  }

  // ---------------------------------------------------------------------
  // Конец сезона
  // ---------------------------------------------------------------------

  /// Находит положение клуба в итоговых таблицах дивизионов.
  /// Таблицы сортируются по очкам, разнице мячей и забитым мячам.
  static ClubStanding? standingIn(
    Iterable<List<LeagueTableEntry>> tables,
    String clubName,
  ) {
    for (final table in tables) {
      if (!table.any((entry) => entry.club == clubName)) continue;

      final sorted = [...table]
        ..sort((a, b) {
          final points = b.points.compareTo(a.points);
          if (points != 0) return points;
          final difference = b.goalDifference.compareTo(a.goalDifference);
          if (difference != 0) return difference;
          return b.goalsFor.compareTo(a.goalsFor);
        });
      final index = sorted.indexWhere((entry) => entry.club == clubName);
      return (position: index + 1, teamCount: sorted.length);
    }
    return null;
  }

  /// Подводит итоги сезона: деньги, болельщики, история и рост силы.
  ///
  /// [currentStrength] — сила клуба после обычного пересчёта игры.
  static CustomClubSeasonOutcome applySeasonEnd({
    required CustomClub club,
    required int season,
    required int position,
    required int teamCount,
    required int division,
    required int currentStrength,
  }) {
    final finance = seasonFinance(
      club: club,
      position: position,
      teamCount: teamCount,
      division: division,
      strength: currentStrength,
    );

    final fundsAfter = club.funds + finance.net;
    final inDebt = fundsAfter < 0;

    final progress = club.strengthProgress + growthPerSeason(club);
    final whole = progress.floor();
    final strengthDelta = whole - (inDebt ? 1 : 0);

    var fans =
        club.fans +
        fansDelta(
          position: position,
          teamCount: teamCount,
          policy: club.ticketPolicy,
        ) -
        (inDebt ? 3 : 0);
    fans = fans.clamp(minFans, maxFans).toInt();

    final known = position > 0 && teamCount > 1;
    final entry = CustomClubSeason(
      season: season,
      position: known ? position : 0,
      teamCount: teamCount,
      income: finance.income,
      expenses: finance.expenses,
      fans: fans,
      strength: currentStrength + strengthDelta,
      champion: known && position == 1,
    );

    final history = [...club.history, entry];
    final trimmed = history.length > maxHistory
        ? history.sublist(history.length - maxHistory)
        : history;

    return CustomClubSeasonOutcome(
      club: club.copyWith(
        funds: fundsAfter,
        fans: fans,
        strengthProgress: progress - whole,
        history: trimmed,
      ),
      finance: finance,
      strengthDelta: strengthDelta,
    );
  }
}
