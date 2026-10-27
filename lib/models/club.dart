import 'package:flutter/material.dart';
import 'club_colors.dart';

enum League {
  england,
  spain,
  france,
  russia,
  italy,
  germany,
  turkey,
  belgium,
  netherlands,
  saudiArabia,
  mls,
  portugal,
}

extension LeagueInfo on League {
  String get displayName {
    switch (this) {
      case League.england:
        return 'Premier League';
      case League.spain:
        return 'La Liga';
      case League.france:
        return 'Ligue 1';
      case League.russia:
        return 'RPL';
      case League.italy:
        return 'Serie A';
      case League.germany:
        return 'Bundesliga';
      case League.turkey:
        return 'Süper Lig';
      case League.belgium:
        return 'Belgian Pro League';
      case League.netherlands:
        return 'Eredivisie';
      case League.saudiArabia:
        return 'Saudi Pro League';
      case League.mls:
        return 'MLS';
      case League.portugal:
        return 'Liga Portugal';
    }
  }

  String get logoAsset {
    switch (this) {
      case League.england:
        return 'assets/leagues/epl.png';
      case League.spain:
        return 'assets/leagues/laliga.png';
      case League.italy:
        return 'assets/leagues/italian.png';
      case League.germany:
        return 'assets/leagues/bundesliga.png';
      case League.france:
        return 'assets/leagues/ligue1.png';
      case League.russia:
        return 'assets/leagues/rpl.png';
      case League.netherlands:
        return 'assets/leagues/eredivisie.png';
      case League.portugal:
        return 'assets/leagues/portugalian.png';
      case League.turkey:
        return 'assets/leagues/turkiyeliga.png';
      case League.belgium:
        return 'assets/leagues/belgium.png';
      case League.saudiArabia:
        return 'assets/leagues/saudi.png';
      case League.mls:
        return 'assets/leagues/mls.png';
    }
  }

  String get countryName {
    switch (this) {
      case League.england:
        return 'Англия';
      case League.spain:
        return 'Испания';
      case League.france:
        return 'Франция';
      case League.russia:
        return 'Россия';
      case League.italy:
        return 'Италия';
      case League.germany:
        return 'Германия';
      case League.turkey:
        return 'Турция';
      case League.belgium:
        return 'Бельгия';
      case League.netherlands:
        return 'Нидерланды';
      case League.saudiArabia:
        return 'Саудовская Аравия';
      case League.mls:
        return 'США и Канада';
      case League.portugal:
        return 'Португалия';
    }
  }

  int get goldenBootGoalThreshold {
    switch (this) {
      // Слабые лиги
      case League.russia:
      case League.belgium:
      case League.turkey:
      case League.mls:
      case League.saudiArabia:
        return 21;

      // тоже средние
      case League.netherlands:
      case League.portugal:
        return 23;

      // Средние лиги
      case League.france:
      case League.germany:
      case League.italy:
        return 27;

      // Сильные лиги
      case League.england:
      case League.spain:
        return 35;
    }
  }

  int get teamCount {
    switch (this) {
      case League.england:
      case League.spain:
      case League.italy:
        return 20;

      case League.germany:
      case League.france:
      case League.turkey:
      case League.belgium:
      case League.netherlands:
      case League.saudiArabia:
      case League.portugal:
        return 18;

      case League.russia:
        return 16;

      case League.mls:
        return 30;
    }
  }

  int get matchesPerSeason {
    // MLS: специальный формат, 34 матча на клуб.
    if (this == League.mls) {
      return 34;
    }

    return (teamCount - 1) * 2;
  }

  int get rounds => matchesPerSeason;
}

class Club {
  final String name;
  final League league;
  final int strength;
  Color get primaryColor => ClubColors.primary(name);

  Color get secondaryColor => ClubColors.secondary(name);

  const Club({
    required this.name,
    required this.league,
    required this.strength,
  });
}

class Clubs {
  static const List<Club> all = [
    // =====================================================
    // АНГЛИЯ — PREMIER LEAGUE 2026/27 (20)
    // =====================================================
    Club(name: 'Arsenal', league: League.england, strength: 86),
    Club(name: 'Aston Villa', league: League.england, strength: 81),
    Club(name: 'Bournemouth', league: League.england, strength: 77),
    Club(name: 'Brentford', league: League.england, strength: 78),
    Club(name: 'Brighton', league: League.england, strength: 80),
    Club(name: 'Chelsea', league: League.england, strength: 84),
    Club(name: 'Coventry City', league: League.england, strength: 70),
    Club(name: 'Crystal Palace', league: League.england, strength: 77),
    Club(name: 'Everton', league: League.england, strength: 75),
    Club(name: 'Fulham', league: League.england, strength: 74),
    Club(name: 'Hull City', league: League.england, strength: 70),
    Club(name: 'Ipswich Town', league: League.england, strength: 70),
    Club(name: 'Leeds United', league: League.england, strength: 73),
    Club(name: 'Liverpool', league: League.england, strength: 87),
    Club(name: 'Manchester City', league: League.england, strength: 87),
    Club(name: 'Manchester United', league: League.england, strength: 83),
    Club(name: 'Newcastle United', league: League.england, strength: 80),
    Club(name: 'Nottingham Forest', league: League.england, strength: 76),
    Club(name: 'Sunderland', league: League.england, strength: 74),
    Club(name: 'Tottenham', league: League.england, strength: 82),

    // =====================================================
    // ИСПАНИЯ — LA LIGA 2026/27 (20)
    // =====================================================
    Club(name: 'Athletic Bilbao', league: League.spain, strength: 80),
    Club(name: 'Atletico Madrid', league: League.spain, strength: 85),
    Club(name: 'Barcelona', league: League.spain, strength: 90),
    Club(name: 'Celta Vigo', league: League.spain, strength: 75),
    Club(name: 'Deportivo Alaves', league: League.spain, strength: 73),
    Club(name: 'Deportivo La Coruna', league: League.spain, strength: 72),
    Club(name: 'Elche', league: League.spain, strength: 71),
    Club(name: 'Espanyol', league: League.spain, strength: 74),
    Club(name: 'Getafe', league: League.spain, strength: 75),
    Club(name: 'Levante', league: League.spain, strength: 72),
    Club(name: 'Malaga', league: League.spain, strength: 71),
    Club(name: 'Osasuna', league: League.spain, strength: 76),
    Club(name: 'Racing Santander', league: League.spain, strength: 71),
    Club(name: 'Rayo Vallecano', league: League.spain, strength: 73),
    Club(name: 'Real Betis', league: League.spain, strength: 81),
    Club(name: 'Real Madrid', league: League.spain, strength: 89),
    Club(name: 'Real Sociedad', league: League.spain, strength: 80),
    Club(name: 'Sevilla', league: League.spain, strength: 78),
    Club(name: 'Valencia', league: League.spain, strength: 77),
    Club(name: 'Villarreal', league: League.spain, strength: 81),

    // =====================================================
    // ИТАЛИЯ — SERIE A 2026/27 (20)
    // =====================================================
    Club(name: 'AC Milan', league: League.italy, strength: 84),
    Club(name: 'Atalanta', league: League.italy, strength: 79),
    Club(name: 'Bologna', league: League.italy, strength: 75),
    Club(name: 'Cagliari', league: League.italy, strength: 74),
    Club(name: 'Como', league: League.italy, strength: 80),
    Club(name: 'Fiorentina', league: League.italy, strength: 78),
    Club(name: 'Frosinone', league: League.italy, strength: 70),
    Club(name: 'Genoa', league: League.italy, strength: 75),
    Club(name: 'Inter', league: League.italy, strength: 86),
    Club(name: 'Juventus', league: League.italy, strength: 84),
    Club(name: 'Lazio', league: League.italy, strength: 77),
    Club(name: 'Lecce', league: League.italy, strength: 71),
    Club(name: 'Monza', league: League.italy, strength: 73),
    Club(name: 'Napoli', league: League.italy, strength: 85),
    Club(name: 'Parma', league: League.italy, strength: 74),
    Club(name: 'Roma', league: League.italy, strength: 84),
    Club(name: 'Sassuolo', league: League.italy, strength: 75),
    Club(name: 'Torino', league: League.italy, strength: 76),
    Club(name: 'Udinese', league: League.italy, strength: 74),
    Club(name: 'Venezia', league: League.italy, strength: 72),

    // =====================================================
    // ГЕРМАНИЯ — BUNDESLIGA 2026/27 (18)
    // =====================================================
    Club(name: 'Augsburg', league: League.germany, strength: 75),
    Club(name: 'Bayern Munich', league: League.germany, strength: 90),
    Club(name: 'Bayer Leverkusen', league: League.germany, strength: 82),
    Club(name: 'Borussia Dortmund', league: League.germany, strength: 83),
    Club(name: 'Monchengladbach', league: League.germany, strength: 76),
    Club(name: 'Eintracht Frankfurt', league: League.germany, strength: 78),
    Club(name: 'Elversberg', league: League.germany, strength: 69),
    Club(name: 'Hamburger SV', league: League.germany, strength: 74),
    Club(name: 'Hoffenheim', league: League.germany, strength: 75),
    Club(name: 'Mainz 05', league: League.germany, strength: 76),
    Club(name: 'Paderborn', league: League.germany, strength: 70),
    Club(name: 'RB Leipzig', league: League.germany, strength: 82),
    Club(name: 'Schalke 04', league: League.germany, strength: 74),
    Club(name: 'SC Freiburg', league: League.germany, strength: 78),
    Club(name: 'Union Berlin', league: League.germany, strength: 76),
    Club(name: 'VfB Stuttgart', league: League.germany, strength: 82),
    Club(name: 'Werder Bremen', league: League.germany, strength: 74),
    Club(name: 'FC Koln', league: League.germany, strength: 72),

    // =====================================================
    // ФРАНЦИЯ — LIGUE 1 2026/27 (18)
    // =====================================================
    Club(name: 'Angers', league: League.france, strength: 72),
    Club(name: 'Auxerre', league: League.france, strength: 70),
    Club(name: 'Brest', league: League.france, strength: 76),
    Club(name: 'Le Havre', league: League.france, strength: 72),
    Club(name: 'Le Mans', league: League.france, strength: 70),
    Club(name: 'Lille', league: League.france, strength: 80),
    Club(name: 'Lorient', league: League.france, strength: 72),
    Club(name: 'Lyon', league: League.france, strength: 79),
    Club(name: 'Marseille', league: League.france, strength: 80),
    Club(name: 'Monaco', league: League.france, strength: 82),
    Club(name: 'Paris FC', league: League.france, strength: 75),
    Club(name: 'PSG', league: League.france, strength: 90),
    Club(name: 'Rennes', league: League.france, strength: 79),
    Club(name: 'Strasbourg', league: League.france, strength: 78),
    Club(name: 'Toulouse', league: League.france, strength: 75),
    Club(name: 'Troyes', league: League.france, strength: 70),
    Club(name: 'Lens', league: League.france, strength: 79),
    Club(name: 'Nice', league: League.france, strength: 77),

    // =====================================================
    // РОССИЯ — РПЛ 2026/27 (16)
    // =====================================================
    Club(name: 'Akron Tolyatti', league: League.russia, strength: 68),
    Club(name: 'Akhmat Grozny', league: League.russia, strength: 71),
    Club(name: 'Baltika Kaliningrad', league: League.russia, strength: 72),
    Club(name: 'CSKA Moscow', league: League.russia, strength: 79),
    Club(name: 'Dynamo Makhachkala', league: League.russia, strength: 71),
    Club(name: 'Dynamo Moscow', league: League.russia, strength: 76),
    Club(name: 'Fakel Voronezh', league: League.russia, strength: 68),
    Club(name: 'Krasnodar', league: League.russia, strength: 79),
    Club(name: 'Krylia Sovetov', league: League.russia, strength: 70),
    Club(name: 'Lokomotiv Moscow', league: League.russia, strength: 76),
    Club(name: 'Orenburg', league: League.russia, strength: 69),
    Club(name: 'Rodina Moscow', league: League.russia, strength: 68),
    Club(name: 'Rostov', league: League.russia, strength: 71),
    Club(name: 'Rubin Kazan', league: League.russia, strength: 72),
    Club(name: 'Spartak Moscow', league: League.russia, strength: 78),
    Club(name: 'Zenit', league: League.russia, strength: 78),

    // =====================================================
    // ТУРЦИЯ — SÜPER LIG 2026/27 (18)
    // =====================================================
    Club(name: 'Alanyaspor', league: League.turkey, strength: 74),
    Club(name: 'Amedspor', league: League.turkey, strength: 72),
    Club(name: 'Istanbul Basaksehir', league: League.turkey, strength: 78),
    Club(name: 'Besiktas', league: League.turkey, strength: 81),
    Club(name: 'Corum FK', league: League.turkey, strength: 70),
    Club(name: 'Erzurumspor', league: League.turkey, strength: 70),
    Club(name: 'Eyupspor', league: League.turkey, strength: 72),
    Club(name: 'Fenerbahce', league: League.turkey, strength: 82),
    Club(name: 'Galatasaray', league: League.turkey, strength: 83),
    Club(name: 'Gaziantep FK', league: League.turkey, strength: 73),
    Club(name: 'Genclerbirligi', league: League.turkey, strength: 72),
    Club(name: 'Goztepe', league: League.turkey, strength: 75),
    Club(name: 'Kasimpasa', league: League.turkey, strength: 72),
    Club(name: 'Kocaelispor', league: League.turkey, strength: 72),
    Club(name: 'Konyaspor', league: League.turkey, strength: 73),
    Club(name: 'Rizespor', league: League.turkey, strength: 72),
    Club(name: 'Samsunspor', league: League.turkey, strength: 75),
    Club(name: 'Trabzonspor', league: League.turkey, strength: 80),

    // =====================================================
    // БЕЛЬГИЯ — BELGIAN PRO LEAGUE 2026/27 (18)
    // =====================================================
    Club(name: 'Anderlecht', league: League.belgium, strength: 79),
    Club(name: 'Antwerp', league: League.belgium, strength: 77),
    Club(name: 'Beveren', league: League.belgium, strength: 70),
    Club(name: 'Cercle Brugge', league: League.belgium, strength: 75),
    Club(name: 'Charleroi', league: League.belgium, strength: 73),
    Club(name: 'Club Brugge', league: League.belgium, strength: 82),
    Club(name: 'Genk', league: League.belgium, strength: 78),
    Club(name: 'Gent', league: League.belgium, strength: 77),
    Club(name: 'Kortrijk', league: League.belgium, strength: 71),
    Club(name: 'La Louviere', league: League.belgium, strength: 70),
    Club(name: 'Lommel SK', league: League.belgium, strength: 70),
    Club(name: 'Mechelen', league: League.belgium, strength: 74),
    Club(name: 'OH Leuven', league: League.belgium, strength: 72),
    Club(name: 'Sint-Truiden', league: League.belgium, strength: 74),
    Club(name: 'Standard Liege', league: League.belgium, strength: 76),
    Club(name: 'Union Saint-Gilloise', league: League.belgium, strength: 79),
    Club(name: 'Westerlo', league: League.belgium, strength: 72),
    Club(name: 'Zulte Waregem', league: League.belgium, strength: 71),

    // =====================================================
    // НИДЕРЛАНДЫ — EREDIVISIE 2026/27 (18)
    // =====================================================
    Club(name: 'ADO Den Haag', league: League.netherlands, strength: 72),
    Club(name: 'Ajax', league: League.netherlands, strength: 82),
    Club(name: 'AZ Alkmaar', league: League.netherlands, strength: 79),
    Club(name: 'Excelsior', league: League.netherlands, strength: 71),
    Club(name: 'FC Groningen', league: League.netherlands, strength: 74),
    Club(name: 'FC Twente', league: League.netherlands, strength: 75),
    Club(name: 'FC Utrecht', league: League.netherlands, strength: 77),
    Club(name: 'Feyenoord', league: League.netherlands, strength: 82),
    Club(name: 'Fortuna Sittard', league: League.netherlands, strength: 71),
    Club(name: 'Go Ahead Eagles', league: League.netherlands, strength: 73),
    Club(name: 'NEC Nijmegen', league: League.netherlands, strength: 74),
    Club(name: 'PEC Zwolle', league: League.netherlands, strength: 72),
    Club(name: 'PSV', league: League.netherlands, strength: 82),
    Club(name: 'SC Cambuur', league: League.netherlands, strength: 71),
    Club(name: 'SC Heerenveen', league: League.netherlands, strength: 73),
    Club(name: 'Sparta Rotterdam', league: League.netherlands, strength: 74),
    Club(name: 'Telstar', league: League.netherlands, strength: 70),
    Club(name: 'Willem II', league: League.netherlands, strength: 70),

    // =====================================================
    // САУДОВСКАЯ АРАВИЯ — SAUDI PRO LEAGUE 2026/27 (18)
    // =====================================================
    Club(name: 'Al Nassr', league: League.saudiArabia, strength: 84),
    Club(name: 'Al Hilal', league: League.saudiArabia, strength: 84),
    Club(name: 'Al Ahli', league: League.saudiArabia, strength: 83),
    Club(name: 'Al Qadsiah', league: League.saudiArabia, strength: 81),
    Club(name: 'Al Ittihad', league: League.saudiArabia, strength: 82),
    Club(name: 'Al Taawoun', league: League.saudiArabia, strength: 73),
    Club(name: 'Al Ettifaq', league: League.saudiArabia, strength: 76),
    Club(name: 'NEOM SC', league: League.saudiArabia, strength: 73),
    Club(name: 'Al Hazem', league: League.saudiArabia, strength: 72),
    Club(name: 'Al Fayha', league: League.saudiArabia, strength: 73),
    Club(name: 'Al Fateh', league: League.saudiArabia, strength: 72),
    Club(name: 'Al Khaleej', league: League.saudiArabia, strength: 73),
    Club(name: 'Al Shabab', league: League.saudiArabia, strength: 76),
    Club(name: 'Al Kholood', league: League.saudiArabia, strength: 72),
    Club(name: 'Al Riyadh', league: League.saudiArabia, strength: 71),
    Club(name: 'Abha', league: League.saudiArabia, strength: 72),
    Club(name: 'Al Faisaly', league: League.saudiArabia, strength: 71),
    Club(name: 'Diriyah', league: League.saudiArabia, strength: 75),

    // =====================================================
    // ПОРТУГАЛИЯ — LIGA PORTUGAL 2026/27 (18)
    // =====================================================
    Club(name: 'Academico de Viseu', league: League.portugal, strength: 70),
    Club(name: 'Alverca', league: League.portugal, strength: 70),
    Club(name: 'Arouca', league: League.portugal, strength: 74),
    Club(name: 'Benfica', league: League.portugal, strength: 83),
    Club(name: 'Braga', league: League.portugal, strength: 81),
    Club(name: 'Casa Pia', league: League.portugal, strength: 73),
    Club(name: 'Santa Clara', league: League.portugal, strength: 73),
    Club(name: 'Estoril', league: League.portugal, strength: 74),
    Club(name: 'Estrela Amadora', league: League.portugal, strength: 72),
    Club(name: 'Famalicao', league: League.portugal, strength: 75),
    Club(name: 'Gil Vicente', league: League.portugal, strength: 74),
    Club(name: 'Guimaraes', league: League.portugal, strength: 76),
    Club(name: 'Maritimo', league: League.portugal, strength: 71),
    Club(name: 'Moreirense', league: League.portugal, strength: 73),
    Club(name: 'Nacional', league: League.portugal, strength: 71),
    Club(name: 'Porto', league: League.portugal, strength: 82),
    Club(name: 'Rio Ave', league: League.portugal, strength: 73),
    Club(name: 'Sporting CP', league: League.portugal, strength: 83),

    // =====================================================
    // MLS — США И КАНАДА 2026 (30)
    // =====================================================
    Club(name: 'Atlanta United', league: League.mls, strength: 74),
    Club(name: 'Austin FC', league: League.mls, strength: 74),
    Club(name: 'CF Montreal', league: League.mls, strength: 72),
    Club(name: 'Charlotte FC', league: League.mls, strength: 75),
    Club(name: 'Chicago Fire', league: League.mls, strength: 74),
    Club(name: 'Colorado Rapids', league: League.mls, strength: 72),
    Club(name: 'Columbus Crew', league: League.mls, strength: 79),
    Club(name: 'DC United', league: League.mls, strength: 73),
    Club(name: 'FC Cincinnati', league: League.mls, strength: 79),
    Club(name: 'FC Dallas', league: League.mls, strength: 74),
    Club(name: 'Houston Dynamo', league: League.mls, strength: 75),
    Club(name: 'Inter Miami', league: League.mls, strength: 83),
    Club(name: 'LA Galaxy', league: League.mls, strength: 79),
    Club(name: 'Los Angeles FC', league: League.mls, strength: 81),
    Club(name: 'Minnesota United', league: League.mls, strength: 76),
    Club(name: 'Nashville SC', league: League.mls, strength: 77),
    Club(name: 'New England Revolution', league: League.mls, strength: 74),
    Club(name: 'New York City FC', league: League.mls, strength: 77),
    Club(name: 'Orlando City', league: League.mls, strength: 77),
    Club(name: 'Philadelphia Union', league: League.mls, strength: 79),
    Club(name: 'Portland Timbers', league: League.mls, strength: 76),
    Club(name: 'Real Salt Lake', league: League.mls, strength: 75),
    Club(name: 'New York Red Bulls', league: League.mls, strength: 77),
    Club(name: 'San Diego FC', league: League.mls, strength: 78),
    Club(name: 'San Jose Earthquakes', league: League.mls, strength: 73),
    Club(name: 'Seattle Sounders', league: League.mls, strength: 80),
    Club(name: 'Sporting Kansas City', league: League.mls, strength: 73),
    Club(name: 'St. Louis City', league: League.mls, strength: 74),
    Club(name: 'Toronto FC', league: League.mls, strength: 74),
    Club(name: 'Vancouver Whitecaps', league: League.mls, strength: 79),
  ];

  /// Рассчитывает силу клуба с учётом рейтинга игрока.
  /// Бонус действует только на клуб, в котором он выступает.
  static int effectiveStrength({
    required String clubName,
    required String playerClub,
    required int playerOverall,
  }) {
    final club = getByName(clubName);
    final baseStrength = club.strength;

    // Остальные клубы не получают бонус.
    if (clubName != playerClub) {
      return baseStrength;
    }

    // Игрок с рейтингом 82+ усиливает клуб силой 73 или ниже.
    if (playerOverall >= 82 && baseStrength <= 73) {
      return baseStrength + 3;
    }

    // Игрок с рейтингом 78+ усиливает клуб силой ниже 76
    if (playerOverall >= 78 && baseStrength < 76) {
      return baseStrength + 2;
    }
    // Игрок с рейтингом 80+ усиливает клуб силой ниже 80
    if (playerOverall >= 80 && baseStrength < 80) {
      return baseStrength + 1;
    }
    // Игрок с рейтингом 86+ усиливает клуб силой ниже 84
    if (playerOverall >= 86 && baseStrength < 84) {
      return baseStrength + 1;
    }

    // Игрок с рейтингом 74–77 усиливает клуб силой 71 или ниже.
    if (playerOverall >= 74 && playerOverall < 78 && baseStrength <= 71) {
      return baseStrength + 3;
    }

    return baseStrength;
  }

  /// Находит клуб по названию.
  /// Старое поведение сохранено для совместимости.
  static Club getByName(String name) {
    return all.firstWhere((club) => club.name == name, orElse: () => all.last);
  }

  /// Возвращает клубы выбранного чемпионата.
  static List<Club> byLeague(League league) {
    return all.where((club) => club.league == league).toList();
  }

  /// Возвращает чемпионат по названию клуба.
  static League? leagueOf(String clubName) {
    for (final club in all) {
      if (club.name == clubName) {
        return club.league;
      }
    }
    return null;
  }

  /// Три случайных клуба для начала карьеры.
  static List<Club> randomStartingClubs() {
    final clubs = all.where((club) => club.strength <= 73).toList()..shuffle();

    return clubs.take(3).toList();
  }

  /// Клубы, доступные игроку по его рейтингу.
  static List<Club> availableForPlayer(int overall) {
    return all.where((club) {
      return club.strength <= overall + 12;
    }).toList();
  }
}
