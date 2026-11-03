class CareerWorldTransfer {
  final String playerName;
  final String fromClub;
  final String toClub;
  final String position;
  final int age;
  final int overall;
  final int jerseyNumber;
  final int season;

  const CareerWorldTransfer({
    required this.playerName,
    required this.fromClub,
    required this.toClub,
    required this.position,
    required this.age,
    required this.overall,
    required this.jerseyNumber,
    required this.season,
  });

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'fromClub': fromClub,
    'toClub': toClub,
    'position': position,
    'age': age,
    'overall': overall,
    'jerseyNumber': jerseyNumber,
    'season': season,
  };

  factory CareerWorldTransfer.fromJson(Map<String, dynamic> json) =>
      CareerWorldTransfer(
        playerName: json['playerName'] as String? ?? '',
        fromClub: json['fromClub'] as String? ?? '',
        toClub: json['toClub'] as String? ?? '',
        position: json['position'] as String? ?? 'forward',
        age: (json['age'] as num?)?.toInt() ?? 25,
        overall: (json['overall'] as num?)?.toInt() ?? 70,
        jerseyNumber: (json['jerseyNumber'] as num?)?.toInt() ?? 0,
        season: (json['season'] as num?)?.toInt() ?? 1,
      );
}
