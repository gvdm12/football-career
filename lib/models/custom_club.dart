import 'package:flutter_football/models/club.dart';

/// Форма эмблемы созданного клуба.
enum ClubBadgeShape { shield, round, hexagon, diamond, pennant, banner }

/// Символ в центре эмблемы.
enum ClubBadgeSymbol { initials, star, ball, trophy, bolt, fire, anchor, crown }

/// Объекты клуба, которые можно улучшать.
enum ClubFacility { academy, training, scouting, stadium }

/// Политика цен на билеты.
enum TicketPolicy { affordable, standard, premium }

/// Итоги одного сезона созданного клуба.
class CustomClubSeason {
  final int season;
  final int position;
  final int teamCount;
  final int income;
  final int expenses;
  final int fans;
  final int strength;
  final bool champion;

  const CustomClubSeason({
    required this.season,
    required this.position,
    required this.teamCount,
    required this.income,
    required this.expenses,
    required this.fans,
    required this.strength,
    this.champion = false,
  });

  int get net => income - expenses;

  Map<String, dynamic> toJson() => {
    'season': season,
    'position': position,
    'teamCount': teamCount,
    'income': income,
    'expenses': expenses,
    'fans': fans,
    'strength': strength,
    'champion': champion,
  };

  factory CustomClubSeason.fromJson(Map<String, dynamic> json) {
    int read(String key) => (json[key] as num?)?.toInt() ?? 0;

    return CustomClubSeason(
      season: read('season'),
      position: read('position'),
      teamCount: read('teamCount'),
      income: read('income'),
      expenses: read('expenses'),
      fans: read('fans'),
      strength: read('strength'),
      champion: json['champion'] as bool? ?? false,
    );
  }
}

/// Клуб, созданный игроком в режиме «Свой клуб».
///
/// Клуб занимает место одного из реальных клубов выбранной лиги
/// ([replacedClub]) и живёт в карьере как обычный клуб, а здесь хранятся
/// только его уникальные данные: облик, бюджет, болельщики и улучшения.
class CustomClub {
  final String name;
  final String shortName;
  final ClubBadgeShape badgeShape;
  final ClubBadgeSymbol badgeSymbol;
  final int primaryColor;
  final int secondaryColor;
  final League league;
  final int division;
  final String replacedClub;

  /// Начальная сила клуба (случайно 70..76).
  final int baseStrength;

  /// Дробная часть роста силы от улучшений, перенесённая на следующий сезон.
  final double strengthProgress;

  final String stadiumName;
  final int funds;
  final int fans;
  final TicketPolicy ticketPolicy;
  final Map<ClubFacility, int> facilityLevels;
  final List<CustomClubSeason> history;
  final int foundedSeason;

  const CustomClub({
    required this.name,
    required this.shortName,
    required this.badgeShape,
    required this.badgeSymbol,
    required this.primaryColor,
    required this.secondaryColor,
    required this.league,
    required this.division,
    required this.replacedClub,
    required this.baseStrength,
    this.strengthProgress = 0,
    required this.stadiumName,
    required this.funds,
    required this.fans,
    this.ticketPolicy = TicketPolicy.standard,
    this.facilityLevels = const {},
    this.history = const [],
    this.foundedSeason = 1,
  });

  int levelOf(ClubFacility facility) => facilityLevels[facility] ?? 0;

  int get titles => history.where((item) => item.champion).length;

  CustomClub copyWith({
    String? shortName,
    ClubBadgeShape? badgeShape,
    ClubBadgeSymbol? badgeSymbol,
    int? primaryColor,
    int? secondaryColor,
    double? strengthProgress,
    String? stadiumName,
    int? funds,
    int? fans,
    TicketPolicy? ticketPolicy,
    Map<ClubFacility, int>? facilityLevels,
    List<CustomClubSeason>? history,
  }) {
    return CustomClub(
      name: name,
      shortName: shortName ?? this.shortName,
      badgeShape: badgeShape ?? this.badgeShape,
      badgeSymbol: badgeSymbol ?? this.badgeSymbol,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      league: league,
      division: division,
      replacedClub: replacedClub,
      baseStrength: baseStrength,
      strengthProgress: strengthProgress ?? this.strengthProgress,
      stadiumName: stadiumName ?? this.stadiumName,
      funds: funds ?? this.funds,
      fans: fans ?? this.fans,
      ticketPolicy: ticketPolicy ?? this.ticketPolicy,
      facilityLevels: facilityLevels ?? this.facilityLevels,
      history: history ?? this.history,
      foundedSeason: foundedSeason,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'shortName': shortName,
    'badgeShape': badgeShape.name,
    'badgeSymbol': badgeSymbol.name,
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
    'league': league.name,
    'division': division,
    'replacedClub': replacedClub,
    'baseStrength': baseStrength,
    'strengthProgress': strengthProgress,
    'stadiumName': stadiumName,
    'funds': funds,
    'fans': fans,
    'ticketPolicy': ticketPolicy.name,
    'facilityLevels': {
      for (final entry in facilityLevels.entries) entry.key.name: entry.value,
    },
    'history': history.map((item) => item.toJson()).toList(),
    'foundedSeason': foundedSeason,
  };

  factory CustomClub.fromJson(Map<String, dynamic> json) {
    T readEnum<T extends Enum>(List<T> values, String key, T fallback) {
      final raw = json[key];
      for (final value in values) {
        if (value.name == raw) return value;
      }
      return fallback;
    }

    final rawLevels = json['facilityLevels'];
    final levels = <ClubFacility, int>{};
    if (rawLevels is Map) {
      for (final facility in ClubFacility.values) {
        final value = rawLevels[facility.name];
        if (value is num) levels[facility] = value.toInt().clamp(0, 5).toInt();
      }
    }

    final rawHistory = json['history'];
    final history = rawHistory is List
        ? rawHistory
              .whereType<Map>()
              .map(
                (item) =>
                    CustomClubSeason.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <CustomClubSeason>[];

    final name = (json['name'] as String?) ?? 'Мой клуб';

    return CustomClub(
      name: name,
      shortName:
          (json['shortName'] as String?) ??
          (name.length >= 3 ? name.substring(0, 3) : name).toUpperCase(),
      badgeShape: readEnum(
        ClubBadgeShape.values,
        'badgeShape',
        ClubBadgeShape.shield,
      ),
      badgeSymbol: readEnum(
        ClubBadgeSymbol.values,
        'badgeSymbol',
        ClubBadgeSymbol.initials,
      ),
      primaryColor: (json['primaryColor'] as num?)?.toInt() ?? 0xFF1E5AA8,
      secondaryColor: (json['secondaryColor'] as num?)?.toInt() ?? 0xFFFFFFFF,
      league: readEnum(League.values, 'league', League.england),
      division: (json['division'] as num?)?.toInt() ?? 1,
      replacedClub: (json['replacedClub'] as String?) ?? '',
      baseStrength: ((json['baseStrength'] as num?)?.toInt() ?? 73)
          .clamp(50, 99)
          .toInt(),
      strengthProgress: (json['strengthProgress'] as num?)?.toDouble() ?? 0,
      stadiumName: (json['stadiumName'] as String?) ?? '$name Arena',
      funds: (json['funds'] as num?)?.toInt() ?? 0,
      fans: ((json['fans'] as num?)?.toInt() ?? 25).clamp(0, 100).toInt(),
      ticketPolicy: readEnum(
        TicketPolicy.values,
        'ticketPolicy',
        TicketPolicy.standard,
      ),
      facilityLevels: levels,
      history: history,
      foundedSeason: (json['foundedSeason'] as num?)?.toInt() ?? 1,
    );
  }
}
