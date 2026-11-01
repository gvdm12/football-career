import 'dart:math';

import 'player.dart';
import 'real_club_squads.dart';

class PositionRival {
  final String id;
  final String name;
  final PlayerPosition position;
  final int age;
  final int overall;
  final int jerseyNumber;
  final int matches;
  final int goals;
  final int assists;
  final double averageRating;
  final int form;

  const PositionRival({
    required this.id,
    required this.name,
    required this.position,
    required this.age,
    required this.overall,
    this.jerseyNumber = 11,
    this.matches = 0,
    this.goals = 0,
    this.assists = 0,
    this.averageRating = 6.5,
    this.form = 0,
  });

  PositionRival copyWith({
    int? age,
    int? overall,
    int? jerseyNumber,
    int? matches,
    int? goals,
    int? assists,
    double? averageRating,
    int? form,
  }) {
    return PositionRival(
      id: id,
      name: name,
      position: position,
      age: age ?? this.age,
      overall: overall ?? this.overall,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      matches: matches ?? this.matches,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      averageRating: averageRating ?? this.averageRating,
      form: form ?? this.form,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position.name,
    'age': age,
    'overall': overall,
    'jerseyNumber': jerseyNumber,
    'matches': matches,
    'goals': goals,
    'assists': assists,
    'averageRating': averageRating,
    'form': form,
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
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 6.5,
      form: (json['form'] as num?)?.toInt() ?? 0,
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
          return PositionRival(
            id: old.id,
            name: candidate.name,
            position: candidate.position,
            age: candidate.age,
            overall: candidate.overall,
            jerseyNumber: candidate.jerseyNumber,
            matches: old.matches,
            goals: old.goals,
            assists: old.assists,
            averageRating: old.averageRating,
            form: old.form,
          );
        }
      }
      return candidate;
    }).toList();
  }

  static List<PositionRival> advanceMatch(List<PositionRival> rivals) {
    final random = Random();
    return rivals.map((rival) {
      // Игроки с хорошей формой чаще выходят на поле, но тренер
      // продолжает ротировать состав, поэтому гарантированных выходов нет.
      final appearanceChance =
          (0.72 + rival.form * 0.025).clamp(0.60, 0.86).toDouble();
      if (random.nextDouble() > appearanceChance) return rival;

      final matches = rival.matches + 1;
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

      // Рейтинг зависит от уровня футболиста и текущей формы,
      // а не генерируется полностью независимо от его характеристик.
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

      return rival.copyWith(
        matches: matches,
        goals: rival.goals + goals,
        assists: rival.assists + assists,
        averageRating: double.parse(average.toStringAsFixed(2)),
        form: form,
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
          : age <= 23
          ? 1
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
