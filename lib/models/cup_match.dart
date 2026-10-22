class CupMatch {
  final int id;
  final int round;
  final String homeTeam;
  final String awayTeam;
  final int? homeGoals;
  final int? awayGoals;
  final String? winner;
  final int? homePenalties;
  final int? awayPenalties;

  const CupMatch({
    required this.id,
    required this.round,
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals,
    this.awayGoals,
    this.winner,
    this.homePenalties,
    this.awayPenalties,
  });

  bool get isPlayed => homeGoals != null && awayGoals != null && winner != null;
  bool get isDraw => isPlayed && homeGoals == awayGoals;

  CupMatch copyWith({
    int? id,
    int? round,
    String? homeTeam,
    String? awayTeam,
    int? homeGoals,
    int? awayGoals,
    String? winner,
    int? homePenalties,
    int? awayPenalties,
  }) {
    return CupMatch(
      id: id ?? this.id,
      round: round ?? this.round,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
      winner: winner ?? this.winner,
      homePenalties: homePenalties ?? this.homePenalties,
      awayPenalties: awayPenalties ?? this.awayPenalties,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'round': round,
    'homeTeam': homeTeam,
    'awayTeam': awayTeam,
    'homeGoals': homeGoals,
    'awayGoals': awayGoals,
    'winner': winner,
    'homePenalties': homePenalties,
    'awayPenalties': awayPenalties,
  };

  factory CupMatch.fromJson(Map<String, dynamic> json) {
    return CupMatch(
      id: (json['id'] as num?)?.toInt() ?? 0,
      round: (json['round'] as num?)?.toInt() ?? 1,
      homeTeam: json['homeTeam'] as String? ?? '',
      awayTeam: json['awayTeam'] as String? ?? '',
      homeGoals: (json['homeGoals'] as num?)?.toInt(),
      awayGoals: (json['awayGoals'] as num?)?.toInt(),
      winner: json['winner'] as String?,
      homePenalties: (json['homePenalties'] as num?)?.toInt(),
      awayPenalties: (json['awayPenalties'] as num?)?.toInt(),
    );
  }
}
