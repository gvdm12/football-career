import 'dart:math';

import 'player.dart';

class PositionRival {
  final String id;
  final String name;
  final PlayerPosition position;
  final int age;
  final int overall;
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
    this.matches = 0,
    this.goals = 0,
    this.assists = 0,
    this.averageRating = 6.5,
    this.form = 0,
  });

  PositionRival copyWith({
    int? age,
    int? overall,
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
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 6.5,
      form: (json['form'] as num?)?.toInt() ?? 0,
    );
  }

  static const Map<PlayerPosition, List<String>> _names = {
    PlayerPosition.goalkeeper: ['Алексей Волков', 'Даниэль Коста', 'Марк Фишер'],
    PlayerPosition.defender: ['Илья Морозов', 'Лукас Мартин', 'Эрик Браун'],
    PlayerPosition.midfielder: ['Артём Соколов', 'Матео Ромеро', 'Оливер Кларк'],
    PlayerPosition.forward: ['Даниэль Силва', 'Максим Орлов', 'Лео Мартинес'],
  };

  static List<PositionRival> generate({
    required Player player,
    required int season,
    int count = 2,
  }) {
    final random = Random((player.name + '|' + player.club + '|' + season.toString()).hashCode);
    final names = List<String>.from(_names[player.position]!)..shuffle(random);
    return List.generate(count.clamp(1, 3).toInt(), (index) {
      final delta = random.nextInt(11) - 4;
      final overall = (player.overall + delta).clamp(55, 95).toInt();
      return PositionRival(
        id: 's' + season.toString() + '_' + player.position.name + '_' + (index + 1).toString(),
        name: names[index],
        position: player.position,
        age: 19 + random.nextInt(12),
        overall: overall,
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
      final rating = (6.0 + random.nextDouble() * 2.0).clamp(5.0, 9.0).toDouble();
      final average = ((rival.averageRating * rival.matches) + rating) / matches;
      final form = (rival.form + (rating >= 7.2 ? 1 : rating < 6.0 ? -1 : 0)).clamp(-5, 5).toInt();
      return rival.copyWith(
        matches: matches,
        goals: rival.goals + goals,
        assists: rival.assists + assists,
        averageRating: double.parse(average.toStringAsFixed(2)),
        form: form,
      );
    }).toList();
  }

  static List<PositionRival> nextSeason(List<PositionRival> rivals, int season) {
    return rivals.map((rival) {
      final age = rival.age + 1;
      final ageChange = age >= 33 ? -2 : age <= 23 ? 1 : 0;
      return PositionRival(
        id: 's' + season.toString() + '_' + rival.position.name + '_' + rival.id.hashCode.abs().toString(),
        name: rival.name,
        position: rival.position,
        age: age,
        overall: (rival.overall + ageChange).clamp(50, 95).toInt(),
        averageRating: 6.5,
      );
    }).toList();
  }
}
