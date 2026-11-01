import 'package:flutter_football/models/player.dart';

class SeasonAward {
  final int season;
  final String category;
  final String playerName;
  final String club;
  final PlayerPosition position;
  final int age;
  final int matches;
  final int goals;
  final int assists;
  final double averageRating;
  final double score;
  final bool isCareerPlayer;

  const SeasonAward({
    required this.season,
    required this.category,
    required this.playerName,
    required this.club,
    required this.position,
    required this.age,
    required this.matches,
    required this.goals,
    required this.assists,
    required this.averageRating,
    required this.score,
    this.isCareerPlayer = false,
  });

  String get positionLabel => switch (position) {
    PlayerPosition.goalkeeper => 'ВР',
    PlayerPosition.defender => 'ЗЩ',
    PlayerPosition.midfielder => 'ПЗ',
    PlayerPosition.forward => 'НП',
  };

  Map<String, dynamic> toJson() => {
    'season': season,
    'category': category,
    'playerName': playerName,
    'club': club,
    'position': position.name,
    'age': age,
    'matches': matches,
    'goals': goals,
    'assists': assists,
    'averageRating': averageRating,
    'score': score,
    'isCareerPlayer': isCareerPlayer,
  };

  factory SeasonAward.fromJson(Map<String, dynamic> json) => SeasonAward(
    season: (json['season'] as num?)?.toInt() ?? 1,
    category: json['category'] as String? ?? 'Награда сезона',
    playerName: json['playerName'] as String? ?? 'Игрок',
    club: json['club'] as String? ?? 'Без клуба',
    position: PlayerPosition.values.firstWhere(
      (value) => value.name == json['position'],
      orElse: () => PlayerPosition.forward,
    ),
    age: (json['age'] as num?)?.toInt() ?? 25,
    matches: (json['matches'] as num?)?.toInt() ?? 0,
    goals: (json['goals'] as num?)?.toInt() ?? 0,
    assists: (json['assists'] as num?)?.toInt() ?? 0,
    averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
    score: (json['score'] as num?)?.toDouble() ?? 0,
    isCareerPlayer: json['isCareerPlayer'] as bool? ?? false,
  );
}
