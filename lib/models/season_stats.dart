class SeasonStats {
  final int season;
  final String club;

  final int matches;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;
  final double? averageRating;
  final List<String> achievements;

  const SeasonStats({
    required this.season,
    required this.club,
    required this.matches,
    required this.goals,
    required this.assists,
    required this.yellowCards,
    required this.redCards,
    required this.averageRating,
    this.achievements = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'season': season,
      'club': club,
      'matches': matches,
      'goals': goals,
      'assists': assists,
      'yellowCards': yellowCards,
      'redCards': redCards,
      'averageRating': averageRating,
      'achievements': achievements,
    };
  }

  factory SeasonStats.fromJson(Map<String, dynamic> json) {
    return SeasonStats(
      season: (json['season'] as num?)?.toInt() ?? 1,
      club: json['club'] as String? ?? 'Без клуба',
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      yellowCards: (json['yellowCards'] as num?)?.toInt() ?? 0,
      redCards: (json['redCards'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      achievements:
          (json['achievements'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const [],
    );
  }
}
