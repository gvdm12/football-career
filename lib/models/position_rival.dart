import 'dart:math';

import 'player.dart';
import 'real_club_squads.dart';

class RivalMonthStats {
  final int matches;
  final int goals;
  final int assists;
  final double ratingSum;

  const RivalMonthStats({
    this.matches = 0,
    this.goals = 0,
    this.assists = 0,
    this.ratingSum = 0,
  });

  double get averageRating => matches == 0 ? 0 : ratingSum / matches;

  RivalMonthStats addMatch({
    required int goals,
    required int assists,
    required double rating,
  }) {
    return RivalMonthStats(
      matches: matches + 1,
      goals: this.goals + goals,
      assists: this.assists + assists,
      ratingSum: ratingSum + rating,
    );
  }

  Map<String, dynamic> toJson() => {
    'matches': matches,
    'goals': goals,
    'assists': assists,
    'ratingSum': ratingSum,
  };

  factory RivalMonthStats.fromJson(Map<String, dynamic> json) {
    return RivalMonthStats(
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      ratingSum: (json['ratingSum'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PositionRival {
  final String id;
  final String name;
  final PlayerPosition position;
  final int age;
  final int overall;
  final int jerseyNumber;
  final int matches;
  final int starts;
  final int substituteAppearances;
  final double? lastRating;
  final int goals;
  final int assists;
  final double averageRating;
  final int form;
  final Map<int, RivalMonthStats> monthlyStats;

  const PositionRival({
    required this.id,
    required this.name,
    required this.position,
    required this.age,
    required this.overall,
    this.jerseyNumber = 11,
    this.matches = 0,
    this.starts = 0,
    this.substituteAppearances = 0,
    this.lastRating,
    this.goals = 0,
    this.assists = 0,
    this.averageRating = 6.5,
    this.form = 0,
    this.monthlyStats = const {},
  });

  PositionRival copyWith({
    int? age,
    int? overall,
    int? jerseyNumber,
    int? matches,
    int? starts,
    int? substituteAppearances,
    double? lastRating,
    int? goals,
    int? assists,
    double? averageRating,
    int? form,
    Map<int, RivalMonthStats>? monthlyStats,
  }) {
    return PositionRival(
      id: id,
      name: name,
      position: position,
      age: age ?? this.age,
      overall: overall ?? this.overall,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      matches: matches ?? this.matches,
      starts: starts ?? this.starts,
      substituteAppearances:
          substituteAppearances ?? this.substituteAppearances,
      lastRating: lastRating ?? this.lastRating,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      averageRating: averageRating ?? this.averageRating,
      form: form ?? this.form,
      monthlyStats: monthlyStats ?? this.monthlyStats,
    );
  }

  /// Условная сила конкурента для борьбы за игровое время.
  /// Регулярные выходы в старте и хорошая форма повышают его вес.
  int get selectionStrength =>
      overall +
      form +
      ((averageRating - 6.5) * 2).round() +
      (matches == 0 ? 0 : (starts / matches * 2).round());

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position.name,
    'age': age,
    'overall': overall,
    'jerseyNumber': jerseyNumber,
    'matches': matches,
    'starts': starts,
    'substituteAppearances': substituteAppearances,
    'lastRating': lastRating,
    'goals': goals,
    'assists': assists,
    'averageRating': averageRating,
    'form': form,
    'monthlyStats': {
      for (final entry in monthlyStats.entries)
        entry.key.toString(): entry.value.toJson(),
    },
  };

  factory PositionRival.fromJson(Map<String, dynamic> json) {
    final positionName = json['position'] as String?;
    return PositionRival(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Игрок',
      position: PlayerPosition.values.firstWhere(
        (value) => value.name == positionName,
        orElse: () => PlayerPosition.forward,
      ),
      age: (json['age'] as num?)?.toInt() ?? 24,
      overall: (json['overall'] as num?)?.toInt() ?? 65,
      jerseyNumber:
          ((json['jerseyNumber'] as num?)?.toInt() ??
                  20 + (json['id'] as String? ?? '').hashCode.abs() % 70)
              .clamp(1, 99)
              .toInt(),
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      starts: (json['starts'] as num?)?.toInt() ?? 0,
      substituteAppearances:
          (json['substituteAppearances'] as num?)?.toInt() ?? 0,
      lastRating: (json['lastRating'] as num?)?.toDouble(),
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 6.5,
      form: (json['form'] as num?)?.toInt() ?? 0,
      monthlyStats: (json['monthlyStats'] as Map?)?.entries.fold<Map<int, RivalMonthStats>>(
            {},
            (result, entry) {
              final month = int.tryParse(entry.key.toString());
              if (month != null && entry.value is Map) {
                result[month] = RivalMonthStats.fromJson(
                  Map<String, dynamic>.from(entry.value as Map),
                );
              }
              return result;
            },
          ) ?? const {},
    );
  }

  static const Map<PlayerPosition, List<String>> _names = {
    PlayerPosition.goalkeeper: [
      'Алексей Волков',
      'Даниэль Коста',
      'Марк Фишер',
      'Иван Петров',
      'Никита Смирнов',
      'Томас Берг',
    ],
    PlayerPosition.defender: [
      'Zakariya Aynaoui',
      'Lucas Martin',
      'Erik Brown',
      'David Garcia',
      'Mathias Kleine',
      'Adam Novak',
    ],
    PlayerPosition.midfielder: [
      'Julien Lacroix',
      'Mateo Romero',
      'Oliver Clarc',
      'Alex Muller',
      'Federico Rossi',
      'Samir Haddad',
      'Erik Costa',
      'Martin Nunes',
    ],
    PlayerPosition.forward: [
      'Daniel Silva',
      'Maxim Orlov',
      'Leo Martinez',
      'Rafael Costa',
      'Thiago Alves',
      'Yusuf Diallo',
      'Jeremy Claytor',
      'Andre Santiago',
      'Mathias Stiller',
    ],
  };

  static int _stableSeed(String value) {
    var hash = 17;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  static List<PositionRival> generate({
    required Player player,
    required int season,
    int count = 2,
  }) {
    final random = Random(_stableSeed('${player.name}|${player.club}|$season'));
    final targetCount = count.clamp(1, 3).toInt();
    final takenNumbers = <int>{player.jerseyNumber};
    final realPlayers =
        RealClubSquads.squads[player.club]?[player.position.name];

    if (realPlayers != null && realPlayers.isNotEmpty) {
      final candidates =
          realPlayers.where((item) => item.name != player.name).toList()
            ..shuffle(random);
      return candidates.take(targetCount).map((item) {
        var number = item.jerseyNumber;
        if (takenNumbers.contains(number)) {
          final available = List<int>.generate(99, (i) => i + 1)
            ..removeWhere(takenNumbers.contains);
          number = available[random.nextInt(available.length)];
        }
        takenNumbers.add(number);
        return PositionRival(
          id: 'real_${player.club}_${player.position.name}_${item.name.hashCode}',
          name: item.name,
          position: player.position,
          age: item.age,
          overall: item.overall,
          jerseyNumber: number,
          averageRating: 6.5 + random.nextDouble() * 0.6,
          form: random.nextInt(5) - 2,
        );
      }).toList();
    }

    final names = List<String>.from(_names[player.position]!)
      ..removeWhere((name) => name == player.name)
      ..shuffle(random);
    return List.generate(targetCount, (index) {
      final delta = random.nextInt(11) - 4;
      final overall = (player.overall + delta).clamp(55, 95).toInt();
      final available = List<int>.generate(99, (i) => i + 1)
        ..removeWhere(takenNumbers.contains);
      final number = available[random.nextInt(available.length)];
      takenNumbers.add(number);
      return PositionRival(
        id: 's${season}_${player.position.name}_${index + 1}',
        name: names[index],
        position: player.position,
        age: 19 + random.nextInt(12),
        overall: overall,
        jerseyNumber: number,
        averageRating: 6.2 + random.nextDouble() * 0.9,
        form: random.nextInt(7) - 3,
      );
    });
  }

  static List<PositionRival> ensureRealCompetitors({
    required Player player,
    required int season,
    required List<PositionRival> existing,
    bool preserveStats = true,
  }) {
    if (RealClubSquads.squads[player.club]?[player.position.name] == null) {
      return existing;
    }
    final generated = generate(
      player: player,
      season: season,
      count: existing.isEmpty ? 2 : existing.length.clamp(1, 3).toInt(),
    );
    return generated.map((candidate) {
      for (final old in existing) {
        if (old.name == candidate.name) {
          if (!preserveStats) {
            final age = old.age + 1;
            final ageChange = age >= 33
                ? -2
                : age <= 23 && old.matches >= 8 && old.averageRating >= 7.0
                    ? 1
                    : age <= 23 &&
                          old.matches >= 8 &&
                          old.averageRating < 6.0
                        ? -1
                        : 0;
            return PositionRival(
              id: old.id,
              name: candidate.name,
              position: candidate.position,
              age: age,
              overall: (old.overall + ageChange).clamp(50, 95).toInt(),
              jerseyNumber: candidate.jerseyNumber,
              averageRating: 6.5,
            );
          }
          return PositionRival(
            id: old.id,
            name: candidate.name,
            position: candidate.position,
            age: candidate.age,
            overall: candidate.overall,
            jerseyNumber: candidate.jerseyNumber,
            matches: old.matches,
            starts: old.starts,
            substituteAppearances: old.substituteAppearances,
            lastRating: old.lastRating,
            goals: old.goals,
            assists: old.assists,
            averageRating: old.averageRating,
            form: old.form,
            monthlyStats: old.monthlyStats,
          );
        }
      }
      return candidate;
    }).toList();
  }

  static List<PositionRival> advanceMatch(
    List<PositionRival> rivals, {
    int? month,
  }) {
    final random = Random();
    return rivals.map((rival) {
      // Без игровой практики форма постепенно возвращается к нейтральной.
      PositionRival coolDownForm() => rival.copyWith(
        form: rival.form > 0
            ? rival.form - 1
            : rival.form < 0
                ? rival.form + 1
                : 0,
      );

      // Форма влияет и на попадание в заявку, и на вероятность выхода на поле.
      final squadChance =
          (0.88 + rival.form * 0.015).clamp(0.78, 0.96).toDouble();
      if (random.nextDouble() > squadChance) return coolDownForm();

      final appearanceChance =
          (0.68 + rival.form * 0.035).clamp(0.52, 0.88).toDouble();
      if (random.nextDouble() > appearanceChance) return coolDownForm();

      final startsChance =
          (0.72 + rival.form * 0.035 + (rival.overall - 70) * 0.006)
              .clamp(0.55, 0.91)
              .toDouble();
      final started = random.nextDouble() < startsChance;
      final matches = rival.matches + 1;
      final starts = rival.starts + (started ? 1 : 0);
      final substituteAppearances =
          rival.substituteAppearances + (started ? 0 : 1);

      var goals = 0;
      var assists = 0;
      switch (rival.position) {
        case PlayerPosition.forward:
          if (random.nextDouble() < rival.overall / 260) goals = 1;
          if (random.nextDouble() < 0.16) assists = 1;
          break;
        case PlayerPosition.midfielder:
          if (random.nextDouble() < rival.overall / 500) goals = 1;
          if (random.nextDouble() < 0.24) assists = 1;
          break;
        case PlayerPosition.defender:
          if (random.nextDouble() < 0.055) goals = 1;
          if (random.nextDouble() < 0.10) assists = 1;
          break;
        case PlayerPosition.goalkeeper:
          break;
      }

      final performanceBase =
          6.35 + (rival.overall - 70) * 0.018 + rival.form * 0.035;
      final rating = (performanceBase + random.nextDouble() * 1.25 - 0.45)
          .clamp(5.0, 9.2)
          .toDouble();
      final average =
          ((rival.averageRating * rival.matches) + rating) / matches;
      final form = (rival.form +
              (rating >= 7.4
                  ? 1
                  : rating < 5.9
                      ? -1
                      : 0))
          .clamp(-5, 5)
          .toInt();

      final monthlyStats = Map<int, RivalMonthStats>.from(rival.monthlyStats);
      if (month != null && month >= 1 && month <= 12) {
        monthlyStats[month] = (monthlyStats[month] ?? const RivalMonthStats())
            .addMatch(goals: goals, assists: assists, rating: rating);
      }

      return rival.copyWith(
        matches: matches,
        starts: starts,
        substituteAppearances: substituteAppearances,
        lastRating: double.parse(rating.toStringAsFixed(2)),
        goals: rival.goals + goals,
        assists: rival.assists + assists,
        averageRating: double.parse(average.toStringAsFixed(2)),
        form: form,
        monthlyStats: monthlyStats,
      );
    }).toList();
  }

  static List<PositionRival> nextSeason(
    List<PositionRival> rivals,
    int season, {
    required Player player,
  }) {
    // В топ-клубах обновляем список из реального состава нужной позиции:
    // футболисты могут меняться между сезонами, но не превращаются в вымышленных.
    if (RealClubSquads.squads[player.club]?[player.position.name] != null) {
      return ensureRealCompetitors(
        player: player,
        season: season,
        existing: rivals,
        preserveStats: false,
      );
    }

    final random = Random();
    final remaining = <PositionRival>[];
    final vacatedNumbers = <int>{};
    for (final rival in rivals) {
      final leavesClub = random.nextDouble() < 0.18;
      if (leavesClub) {
        vacatedNumbers.add(rival.jerseyNumber);
        continue;
      }
      final age = rival.age + 1;
      final ageChange = age >= 33
          ? -2
          : age <= 23 && rival.matches >= 8 && rival.averageRating >= 7.0
          ? 1
          : age <= 23 && rival.matches >= 8 && rival.averageRating < 6.0
          ? -1
          : 0;
      remaining.add(
        PositionRival(
          id: 's${season}_${rival.id}',
          name: rival.name,
          position: rival.position,
          age: age,
          overall: (rival.overall + ageChange).clamp(50, 95).toInt(),
          jerseyNumber: rival.jerseyNumber,
          averageRating: 6.5,
        ),
      );
    }
    final targetCount = rivals.isEmpty ? 2 : rivals.length;
    final names = List<String>.from(_names[player.position]!)
      ..removeWhere(
        (name) => name == player.name || rivals.any((r) => r.name == name),
      )
      ..shuffle(random);
    while (remaining.length < targetCount) {
      final index = remaining.length;
      final takenNumbers = <int>{
        player.jerseyNumber,
        ...remaining.map((r) => r.jerseyNumber),
        ...vacatedNumbers,
      };
      final available = List<int>.generate(99, (i) => i + 1)
        ..removeWhere(takenNumbers.contains);
      if (available.isEmpty) break;
      final name = names.isNotEmpty
          ? names.removeAt(0)
          : 'Игрок ${season}_${index + 1}';
      final number = available[random.nextInt(available.length)];
      final delta = random.nextInt(11) - 4;
      remaining.add(
        PositionRival(
          id: 's${season}_new_${index + 1}_${random.nextInt(100000)}',
          name: name,
          position: player.position,
          age: 18 + random.nextInt(13),
          overall: (player.overall + delta).clamp(55, 95).toInt(),
          jerseyNumber: number,
          averageRating: 6.2 + random.nextDouble() * 0.9,
          form: random.nextInt(7) - 3,
        ),
      );
    }
    return remaining;
  }
}
