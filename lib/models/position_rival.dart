import 'dart:math';

import 'player.dart';

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
      jerseyNumber: ((json['jerseyNumber'] as num?)?.toInt() ?? 20 + (json['id'] as String? ?? '').hashCode.abs() % 70).clamp(1, 99).toInt(),
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
      'Илья Морозов', 'Лукас Мартин', 'Эрик Браун',
      'Давид Гарсия', 'Маттиас Кляйн', 'Адам Новак',
    ],
    PlayerPosition.midfielder: [
      'Артём Соколов',
      'Матео Ромеро',
      'Оливер Кларк',
      'Алекс Мюллер',
      'Федерико Росси',
      'Самир Хаддад',
    ],
    PlayerPosition.forward: [
      'Даниэль Силва', 'Максим Орлов', 'Лео Мартинес',
      'Рафаэль Коста', 'Тьяго Алвес', 'Юсуф Диалло',
    ],
  };

  static List<PositionRival> generate({
    required Player player,
    required int season,
    int count = 2,
  }) {
    final random = Random(('${player.name}|${player.club}|$season').hashCode);
    final names = List<String>.from(_names[player.position]!)
      ..removeWhere((name) => name == player.name)
      ..shuffle(random);
    final takenNumbers = <int>{player.jerseyNumber};
    return List.generate(count.clamp(1, 3).toInt(), (index) {
      final delta = random.nextInt(11) - 4;
      final overall = (player.overall + delta).clamp(55, 95).toInt();
      final available = List<int>.generate(99, (i) => i + 1)..removeWhere(takenNumbers.contains);
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
  static List<PositionRival> advanceMatch(List<PositionRival> rivals) {
    final random = Random();
    return rivals.map((rival) {
      if (random.nextDouble() > 0.78) return rival;
      final matches = rival.matches + 1;
      var goals = 0;
      var assists = 0;
      switch (rival.position) {
        case PlayerPosition.forward:
          if (random.nextDouble() < rival.overall / 260) goals = 1;
          if (random.nextDouble() < 0.12) assists = 1;
          break;
        case PlayerPosition.midfielder:
          if (random.nextDouble() < rival.overall / 500) goals = 1;
          if (random.nextDouble() < 0.22) assists = 1;
          break;
        case PlayerPosition.defender:
          if (random.nextDouble() < 0.055) goals = 1;
          if (random.nextDouble() < 0.10) assists = 1;
          break;
        case PlayerPosition.goalkeeper:
          break;
      }
      final rating = (6.0 + random.nextDouble() * 2.0)
          .clamp(5.0, 9.0)
          .toDouble();
      final average =
          ((rival.averageRating * rival.matches) + rating) / matches;
      final form =
          (rival.form +
                  (rating >= 7.2
                      ? 1
                      : rating < 6.0
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
      final ageChange = age >= 33 ? -2 : age <= 23 ? 1 : 0;
      remaining.add(PositionRival(
        id: 's${season}_${rival.id}',
        name: rival.name,
        position: rival.position,
        age: age,
        overall: (rival.overall + ageChange).clamp(50, 95).toInt(),
        jerseyNumber: rival.jerseyNumber,
        averageRating: 6.5,
      ));
    }
    final targetCount = rivals.isEmpty ? 2 : rivals.length;
    final names = List<String>.from(_names[player.position]!)
      ..removeWhere((name) => name == player.name || rivals.any((r) => r.name == name))
      ..shuffle(random);
    while (remaining.length < targetCount) {
      final index = remaining.length;
      final takenNumbers = <int>{
        player.jerseyNumber,
        ...remaining.map((r) => r.jerseyNumber),
        ...vacatedNumbers,
      };
      final available = List<int>.generate(99, (i) => i + 1)..removeWhere(takenNumbers.contains);
      if (available.isEmpty) break;
      final name = names.isNotEmpty ? names.removeAt(0) : 'Игрок ${season}_${index + 1}';
      final number = available[random.nextInt(available.length)];
      final delta = random.nextInt(11) - 4;
      remaining.add(PositionRival(
        id: 's${season}_new_${index + 1}_${random.nextInt(100000)}',
        name: name,
        position: player.position,
        age: 18 + random.nextInt(13),
        overall: (player.overall + delta).clamp(55, 95).toInt(),
        jerseyNumber: number,
        averageRating: 6.2 + random.nextDouble() * 0.9,
        form: random.nextInt(7) - 3,
      ));
    }
    return remaining;
  }
}
