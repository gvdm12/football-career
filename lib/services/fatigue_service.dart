import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/models/season_match.dart';

/// Усталость игрока: накапливается от матчей и снимается отдыхом.
///
/// Шкала 0..100. Каждый сыгранный матч любого турнира добавляет нагрузку,
/// а каждый тур лиги ("неделя") даёт восстановление. Поэтому в плотном
/// календаре (кубок, еврокубки) усталость растёт, а запасной за неделю
/// отдыхает. Модель не знает про UI и легко тестируется.
class FatigueService {
  const FatigueService._();

  static const int max = 100;

  /// Нагрузка за сыгранный матч.
  static const int matchLoad = 11;

  /// Восстановление за тур лиги (неделя без дополнительных матчей).
  static const int weeklyRecovery = 10;

  /// До этого значения усталость ни на что не влияет.
  static const int skillPenaltyThreshold = 40;

  /// С этого значения тренер реже выпускает игрока в старте.
  static const int selectionThreshold = 60;

  /// Новое значение усталости после матча.
  ///
  /// Нагрузка начисляется, только если игрок вышел на поле. Восстановление
  /// даётся в матче лиги независимо от участия игрока.
  static int afterMatch({
    required int current,
    required bool playerPlayed,
    required bool isLeagueFixture,
  }) {
    var value = current;
    if (playerPlayed) value += matchLoad;
    if (isLeagueFixture) value -= weeklyRecovery;
    return value.clamp(0, max).toInt();
  }

  /// Является ли [match] ближайшим матчем лиги клуба игрока.
  ///
  /// Матч лиги определяется по первому несыгранному матчу календаря:
  /// совпадают хозяева и гости. Кубок и еврокубки в календарь лиги
  /// не входят, поэтому восстановления не дают.
  static bool isLeagueFixture({
    required Match match,
    required String playerClub,
    required List<SeasonMatch> seasonMatches,
  }) {
    SeasonMatch? next;
    for (final item in seasonMatches) {
      if (!item.isPlayed) {
        next = item;
        break;
      }
    }
    if (next == null) return false;

    final home = next.isHome ? playerClub : next.opponent;
    final away = next.isHome ? next.opponent : playerClub;
    return match.homeTeam == home && match.awayTeam == away;
  }

  /// Штраф к физическим навыкам (скорость, физика) в матче: 0..6.
  static int physicalSkillPenalty(int fatigue) {
    if (fatigue <= skillPenaltyThreshold) return 0;
    final span = max - skillPenaltyThreshold;
    return (((fatigue - skillPenaltyThreshold) / span) * 6).round().clamp(0, 6);
  }

  /// Штраф к остальным навыкам: вдвое меньше физического.
  static int technicalSkillPenalty(int fatigue) =>
      physicalSkillPenalty(fatigue) ~/ 2;

  /// Снижение шанса выйти в старте: 0..0.16.
  static double selectionPenalty(int fatigue) {
    if (fatigue <= selectionThreshold) return 0;
    return ((fatigue - selectionThreshold) * 0.004).clamp(0.0, 0.16).toDouble();
  }

  /// Название уровня усталости.
  static String label(int fatigue, {required bool english}) {
    if (fatigue < 25) return english ? 'Fresh' : 'Свеж';
    if (fatigue < 50) return english ? 'Normal' : 'В норме';
    if (fatigue < 75) return english ? 'Tired' : 'Устал';
    return english ? 'Exhausted' : 'Измотан';
  }
}
