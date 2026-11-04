class CareerCoachTransfer {
  final String coachName;
  final String fromClub;
  final String toClub;
  final int season;

  const CareerCoachTransfer({
    required this.coachName,
    required this.fromClub,
    required this.toClub,
    required this.season,
  });

  Map<String, dynamic> toJson() => {
    'coachName': coachName,
    'fromClub': fromClub,
    'toClub': toClub,
    'season': season,
  };

  factory CareerCoachTransfer.fromJson(Map<String, dynamic> json) =>
      CareerCoachTransfer(
        coachName: json['coachName'] as String? ?? '',
        fromClub: json['fromClub'] as String? ?? '',
        toClub: json['toClub'] as String? ?? '',
        season: (json['season'] as num?)?.toInt() ?? 1,
      );
}
