enum SuperLeagueDivision {
  first,
  second,
}

extension SuperLeagueDivisionInfo on SuperLeagueDivision {
  String get displayName {
    switch (this) {
      case SuperLeagueDivision.first:
        return '1-й дивизион';
      case SuperLeagueDivision.second:
        return '2-й дивизион';
    }
  }

  int get clubCount {
    switch (this) {
      case SuperLeagueDivision.first:
        return 20;
      case SuperLeagueDivision.second:
        return 22;
    }
  }
}

/// Клубы, участвующие в Суперлиге. Названия должны совпадать с Clubs.all.
class SuperLeagueDivisionConfig {
  const SuperLeagueDivisionConfig._();

  static const List<String> firstDivisionClubs = [
    'Barcelona',
    'Real Madrid',
    'Atletico Madrid',
    'Inter',
    'Napoli',
    'AC Milan',
    'Juventus',
    'Roma',
    'Liverpool',
    'Manchester City',
    'Arsenal',
    'Chelsea',
    'Manchester United',
    'Tottenham',
    'Bayern Munich',
    'Bayer Leverkusen',
    'Borussia Dortmund',
    'PSG',
    'Monaco',
    'Marseille',
  ];

  static const List<String> secondDivisionClubs = [
    'Aston Villa',
    'Newcastle United',
    'Brighton',
    'Real Betis',
    'Villarreal',
    'Real Sociedad',
    'Lazio',
    'Atalanta',
    'Como',
    'VfB Stuttgart',
    'RB Leipzig',
    'Strasbourg',
    'Lille',
    'Ajax',
    'Feyenoord',
    'Club Brugge',
    'Krasnodar',
    'CSKA Moscow',
    'Fenerbahce',
    'Galatasaray',
    'Sporting CP',
    'Benfica',
  ];

  static List<String> clubsFor(SuperLeagueDivision division) {
    switch (division) {
      case SuperLeagueDivision.first:
        return firstDivisionClubs;
      case SuperLeagueDivision.second:
        return secondDivisionClubs;
    }
  }

  static SuperLeagueDivision divisionOf(String clubName) {
    if (secondDivisionClubs.contains(clubName)) {
      return SuperLeagueDivision.second;
    }
    return SuperLeagueDivision.first;
  }

  static bool containsClub(String clubName) =>
      firstDivisionClubs.contains(clubName) ||
      secondDivisionClubs.contains(clubName);
}
