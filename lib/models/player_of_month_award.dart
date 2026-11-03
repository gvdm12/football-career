import 'package:flutter_football/models/player.dart';

class PlayerOfMonthAward {
  final int season;
  final int month;
  final String playerName;
  final String club;
  final PlayerPosition position;
  final int overall;
  final int age;
  final int matches;
  final int goals;
  final int assists;
  final double averageRating;
  final double score;
  final bool isCareerPlayer;

  const PlayerOfMonthAward({
    required this.season,
    required this.month,
    required this.playerName,
    required this.club,
    required this.position,
    required this.overall,
    this.age = 25,
    required this.matches,
    required this.goals,
    required this.assists,
    required this.averageRating,
    required this.score,
    this.isCareerPlayer = false,
  });

  Map<String, dynamic> toJson() => {
    'season': season,
    'month': month,
    'playerName': playerName,
    'club': club,
    'position': position.name,
    'overall': overall,
    'age': age,
    'matches': matches,
    'goals': goals,
    'assists': assists,
    'averageRating': averageRating,
    'score': score,
    'isCareerPlayer': isCareerPlayer,
  };

  factory PlayerOfMonthAward.fromJson(Map<String, dynamic> json) {
    return PlayerOfMonthAward(
      season: (json['season'] as num?)?.toInt() ?? 1,
      month: (json['month'] as num?)?.toInt() ?? 1,
      playerName: (json['playerName'] as String? ?? 'Игрок').replaceFirst(RegExp(r'\s+\d{2}
      club: json['club'] as String? ?? 'Неизвестный клуб',
      position: PlayerPosition.values.firstWhere(
        (item) => item.name == json['position'],
        orElse: () => PlayerPosition.forward,
      ),
      overall: (json['overall'] as num?)?.toInt() ?? 60,
      age: (json['age'] as num?)?.toInt() ?? 25,
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 6.0,
      score: (json['score'] as num?)?.toDouble() ?? 0,
      isCareerPlayer: json['isCareerPlayer'] as bool? ?? false,
    );
  }

  String get monthName {
    final index = month < 1 ? 0 : month > 12 ? 11 : month - 1;
    return const [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
    ][index];
  }
}
), ''),
      club: json['club'] as String? ?? 'Неизвестный клуб',
      position: PlayerPosition.values.firstWhere(
        (item) => item.name == json['position'],
        orElse: () => PlayerPosition.forward,
      ),
      overall: (json['overall'] as num?)?.toInt() ?? 60,
      age: (json['age'] as num?)?.toInt() ?? 25,
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 6.0,
      score: (json['score'] as num?)?.toDouble() ?? 0,
      isCareerPlayer: json['isCareerPlayer'] as bool? ?? false,
    );
  }

  String get monthName {
    final index = month < 1 ? 0 : month > 12 ? 11 : month - 1;
    return const [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
    ][index];
  }
}
