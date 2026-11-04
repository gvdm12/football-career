import 'dart:math';

import 'career_coach_transfer.dart';

/// Реальные главные тренеры клубов с реальными составами в игре.
/// Имена хранятся на английском, чтобы единообразно отображаться в карьере.
class RealClubCoaches {
  const RealClubCoaches._();

  static const Map<String, String> baseCoaches = {
    'Real Madrid': 'Jose Mourinho',
    'Barcelona': 'Hansi Flick',
    'Atletico Madrid': 'Diego Simeone',
    'Real Betis': 'Manuel Pellegrini',
    'Real Sociedad': 'Pellegrino Matarazzo',
    'Sevilla': 'Luis Garcia Plaza',
    'Villarreal': 'Inigo Perez',
    'Athletic Bilbao': 'Edin Terzic',
    'PSG': 'Luis Enrique',
    'Lille': 'Davide Ancelotti',
    'Marseille': 'Bruno Genesio',
    'Monaco': 'Filipe Luis',
    'Strasbourg': 'Hugo Oliveira',
    'Lyon': 'Paulo Fonseca',
    'Liverpool': 'Andoni Iraola',
    'Manchester City': 'Enzo Maresca',
    'Arsenal': 'Mikel Arteta',
    'Tottenham': 'Roberto De Zerbi',
    'Manchester United': 'Michael Carrick',
    'Chelsea': 'Xabi Alonso',
    'Newcastle United': 'Matthias Jaissle',
    'Brighton': 'Fabian Hurzeler',
    'Aston Villa': 'Unai Emery',
    'Bayern Munich': 'Vincent Kompany',
    'Borussia Dortmund': 'Niko Kovac',
    'Bayer Leverkusen': 'Carles Martinez',
    'RB Leipzig': 'Martin Demichelis',
    'VfB Stuttgart': 'Sebastian Hoeness',
    'Inter': 'Cristian Chivu',
    'Napoli': 'Massimiliano Allegri',
    'Juventus': 'Luciano Spalletti',
    'AC Milan': 'Ruben Amorim',
    'Roma': 'Gian Piero Gasperini',
    'Lazio': 'Gennaro Gattuso',
    'Atalanta': 'Maurizio Sarri',
    'Fiorentina': 'Paolo Vanoli',
    'Zenit': 'Sergei Semak',
    'CSKA Moscow': 'Dmitry Igdisamov',
    'Spartak Moscow': 'Juan Carlos Carcedo',
    'Krasnodar': 'Murad Musayev',
    'Lokomotiv Moscow': 'Mikhail Galaktionov',
    'Dynamo Makhachkala': 'Vadim Yevseyev',
    'Dynamo Moscow': 'Sandro Schwarz',
    'Ajax': 'Michel',
    'PSV': 'Peter Bosz',
    'Feyenoord': 'Giovanni van Bronckhorst',
    'Club Brugge': 'Ivan Leko',
    'Union Saint-Gilloise': 'David Hubert',
    'Benfica': 'Marco Silva',
    'Sporting CP': 'Rui Borges',
    'Porto': 'Francesco Farioli',
    'Braga': 'Carlos Vicens',
    'Fenerbahce': 'Emre Belozoglu',
    'Galatasaray': 'Okan Buruk',
  };

  static Map<String, String> currentCoaches(
    List<CareerCoachTransfer> transfers,
  ) {
    final coaches = Map<String, String>.from(baseCoaches);
    final ordered = [...transfers]
      ..sort((a, b) => a.season.compareTo(b.season));

    for (final transfer in ordered) {
      if (coaches[transfer.fromClub] != transfer.coachName) continue;
      coaches.remove(transfer.fromClub);
      coaches[transfer.toClub] = transfer.coachName;
    }
    return coaches;
  }

  static String? coachForClub(
    String clubName,
    List<CareerCoachTransfer> transfers,
  ) => currentCoaches(transfers)[clubName];

  /// Каждый сезон с вероятностью 45% происходит обмен тренерами между
  /// двумя клубами из базы реальных составов.
  static List<CareerCoachTransfer> simulateSeason({
    required int season,
    required List<CareerCoachTransfer> previousTransfers,
  }) {
    final random = Random(season * 7919 + 37);
    if (random.nextInt(100) >= 45) return const [];

    final coaches = currentCoaches(previousTransfers);
    final clubs = coaches.keys.toList()..sort();
    if (clubs.length < 2) return const [];

    final firstIndex = random.nextInt(clubs.length);
    var secondIndex = random.nextInt(clubs.length - 1);
    if (secondIndex >= firstIndex) secondIndex++;

    final firstClub = clubs[firstIndex];
    final secondClub = clubs[secondIndex];
    final firstCoach = coaches[firstClub]!;
    final secondCoach = coaches[secondClub]!;

    return [
      CareerCoachTransfer(
        coachName: firstCoach,
        fromClub: firstClub,
        toClub: secondClub,
        season: season,
      ),
      CareerCoachTransfer(
        coachName: secondCoach,
        fromClub: secondClub,
        toClub: firstClub,
        season: season,
      ),
    ];
  }
}
