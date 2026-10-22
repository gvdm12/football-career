import 'package:flutter_football/models/club.dart';

/// Один матч общего чемпионата.
class LeagueMatch {
  final int id;
  final int round;
  final String homeTeam;
  final String awayTeam;
  final int? homeGoals;
  final int? awayGoals;

  const LeagueMatch({
    required this.id,
    required this.round,
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals,
    this.awayGoals,
  });

  bool get isPlayed => homeGoals != null && awayGoals != null;

  int? get homePoints {
    if (!isPlayed) return null;
    if (homeGoals! > awayGoals!) return 3;
    if (homeGoals! == awayGoals!) return 1;
    return 0;
  }

  int? get awayPoints {
    if (!isPlayed) return null;
    if (awayGoals! > homeGoals!) return 3;
    if (awayGoals! == homeGoals!) return 1;
    return 0;
  }

  LeagueMatch copyWith({
    int? id,
    int? round,
    String? homeTeam,
    String? awayTeam,
    int? homeGoals,
    int? awayGoals,
  }) {
    return LeagueMatch(
      id: id ?? this.id,
      round: round ?? this.round,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'round': round,
    'homeTeam': homeTeam,
    'awayTeam': awayTeam,
    'homeGoals': homeGoals,
    'awayGoals': awayGoals,
  };

  factory LeagueMatch.fromJson(Map<String, dynamic> json) {
    return LeagueMatch(
      id: (json['id'] as num?)?.toInt() ?? 0,
      round: (json['round'] as num?)?.toInt() ?? 1,
      homeTeam: json['homeTeam'] as String? ?? '',
      awayTeam: json['awayTeam'] as String? ?? '',
      homeGoals: (json['homeGoals'] as num?)?.toInt(),
      awayGoals: (json['awayGoals'] as num?)?.toInt(),
    );
  }
}

/// Генератор календаря чемпионата.
///
/// Для лиги с чётным количеством клубов:
/// Англия, Испания, Италия — 38 туров;
/// Германия, Франция — 34 тура;
/// Россия — 30 туров.

class LeagueCalendar {
  static List<LeagueMatch> generate(List<Club> clubs) {
    if (clubs.length < 2) {
      return [];
    }

    if (clubs.map((club) => club.name).toSet().length != clubs.length) {
      throw ArgumentError('В календаре обнаружены повторяющиеся клубы');
    }

    if (clubs.length.isOdd) {
      throw ArgumentError(
        'Для генерации календаря требуется чётное количество клубов',
      );
    }

    // Для MLS используется отдельный формат: 34 матча на команду.
    if (clubs.isNotEmpty && clubs.first.league == League.mls) {
      return _generateMls(clubs);
    }

    // Обычный чемпионат: каждый играет с каждым дома и в гостях.
    final teams = clubs.map((club) => club.name).toList();
    final teamCount = teams.length;
    final roundsPerHalf = teamCount - 1;
    final matchesPerRound = teamCount ~/ 2;

    final rotation = List<String>.from(teams);
    final matches = <LeagueMatch>[];

    for (var roundIndex = 0; roundIndex < roundsPerHalf; roundIndex++) {
      for (var i = 0; i < matchesPerRound; i++) {
        final first = rotation[i];
        final second = rotation[teamCount - 1 - i];

        final firstIsHome = (roundIndex + i).isEven;

        final homeTeam = firstIsHome ? first : second;
        final awayTeam = firstIsHome ? second : first;

        final matchId = roundIndex * matchesPerRound + i + 1;

        matches.add(
          LeagueMatch(
            id: matchId,
            round: roundIndex + 1,
            homeTeam: homeTeam,
            awayTeam: awayTeam,
          ),
        );

        matches.add(
          LeagueMatch(
            id: matchId + roundsPerHalf * matchesPerRound,
            round: roundIndex + 1 + roundsPerHalf,
            homeTeam: awayTeam,
            awayTeam: homeTeam,
          ),
        );
      }

      final lastTeam = rotation.removeLast();
      rotation.insert(1, lastTeam);
    }

    matches.sort((a, b) {
      final roundComparison = a.round.compareTo(b.round);
      if (roundComparison != 0) return roundComparison;
      return a.id.compareTo(b.id);
    });

    return matches;
  }

  /// MLS: 30 клубов, 34 матча на команду.
  /// Первые 29 туров — круговая система.
  /// В турах 30–34 повторяются первые пять туров
  /// с обратным преимуществом домашнего поля.
  static List<LeagueMatch> _generateMls(List<Club> clubs) {
    if (clubs.length != 30) {
      throw ArgumentError(
        'Для календаря MLS ожидается 30 клубов, '
        'получено: ${clubs.length}',
      );
    }

    final teams = clubs.map((club) => club.name).toList();
    final rotation = List<String>.from(teams);

    final teamCount = teams.length;
    final matchesPerRound = teamCount ~/ 2;
    final firstLeg = <List<LeagueMatch>>[];

    var nextId = 1;

    // 29 туров: каждый клуб встречается с каждым по одному разу.
    for (var roundIndex = 0; roundIndex < teamCount - 1; roundIndex++) {
      final roundMatches = <LeagueMatch>[];

      for (var i = 0; i < matchesPerRound; i++) {
        final first = rotation[i];
        final second = rotation[teamCount - 1 - i];

        final firstIsHome = (roundIndex + i).isEven;

        roundMatches.add(
          LeagueMatch(
            id: nextId++,
            round: roundIndex + 1,
            homeTeam: firstIsHome ? first : second,
            awayTeam: firstIsHome ? second : first,
          ),
        );
      }

      firstLeg.add(roundMatches);

      final lastTeam = rotation.removeLast();
      rotation.insert(1, lastTeam);
    }

    final matches = <LeagueMatch>[for (final round in firstLeg) ...round];

    // Ещё пять туров: повторяем первые пять с перестановкой хозяев.
    for (var i = 0; i < 5; i++) {
      final originalRound = firstLeg[i];
      final newRoundNumber = 30 + i;

      for (final original in originalRound) {
        matches.add(
          LeagueMatch(
            id: nextId++,
            round: newRoundNumber,
            homeTeam: original.awayTeam,
            awayTeam: original.homeTeam,
          ),
        );
      }
    }

    matches.sort((a, b) {
      final roundComparison = a.round.compareTo(b.round);
      if (roundComparison != 0) return roundComparison;
      return a.id.compareTo(b.id);
    });

    return matches;
  }
}
