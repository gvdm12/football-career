import 'club.dart';
import 'league_table.dart';

/// Меняет силу клубов по итогам каждого завершённого сезона.
class ClubStrengthService {
  static Map<String, int> update({
    required Map<String, int> currentStrengths,
    required Map<League, List<LeagueTableEntry>> standings,
    required String? domesticCupWinner,
    required String? championsLeagueWinner,
    required String? europaLeagueWinner,
  }) {
    final updated = <String, int>{...currentStrengths};

    for (final league in League.values) {
      final table = standings[league];
      if (table == null || table.isEmpty) continue;

      final ordered = [...table]
        ..sort((a, b) {
          final points = b.points.compareTo(a.points);
          if (points != 0) return points;
          final difference = b.goalDifference.compareTo(a.goalDifference);
          if (difference != 0) return difference;
          return b.goalsFor.compareTo(a.goalsFor);
        });
      // Сравниваем итоговое место с силой команд до обновления сезона,
      // чтобы изменения одной команды не влияли на расчёт остальных.
      final expectedOrder = [...Clubs.byLeague(league)]
        ..sort((a, b) => b.strength.compareTo(a.strength));

      for (var index = 0; index < ordered.length; index++) {
        final clubName = ordered[index].club;
        final base = updated[clubName] ?? Clubs.all
            .firstWhere((club) => club.name == clubName,
                orElse: () => Clubs.all.first)
            .baseStrength;
        final expectedIndex = expectedOrder.indexWhere(
          (club) => club.name == clubName,
        );
        if (expectedIndex < 0) continue;

        final positionAdvantage = expectedIndex - index;
        final performanceChange = (positionAdvantage / 4).round();
        final pointsPerGame = ordered[index].played == 0
            ? 0.0
            : ordered[index].points / ordered[index].played;
        final formChange = pointsPerGame >= 2.2
            ? 1
            : pointsPerGame <= 0.75
                ? -1
                : 0;
        final change = (performanceChange + formChange).clamp(-3, 3);
        updated[clubName] = (base + change).clamp(45, 97).toInt();
      }
    }

    final cupWinner = domesticCupWinner;
    if (cupWinner != null) {
      updated[cupWinner] = ((updated[cupWinner] ??
              Clubs.getByName(cupWinner).strength) +
          1).clamp(45, 97).toInt();
    }

    if (championsLeagueWinner != null) {
      updated[championsLeagueWinner] =
          ((updated[championsLeagueWinner] ??
                      Clubs.getByName(championsLeagueWinner).strength) +
                  2)
              .clamp(45, 97)
              .toInt();
    }

    if (europaLeagueWinner != null) {
      updated[europaLeagueWinner] =
          ((updated[europaLeagueWinner] ??
                      Clubs.getByName(europaLeagueWinner).strength) +
                  1)
              .clamp(45, 97)
              .toInt();
    }

    return updated;
  }
}
