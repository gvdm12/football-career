enum CareerNewsType { match, achievement, transfer, contract, season }

class CareerNews {
  final String id;
  final int season;
  final int matchNumber;
  final String title;
  final String description;
  final CareerNewsType type;

  const CareerNews({
    required this.id,
    required this.season,
    required this.matchNumber,
    required this.title,
    required this.description,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'season': season,
      'matchNumber': matchNumber,
      'title': title,
      'description': description,
      'type': type.name,
    };
  }

  factory CareerNews.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;

    final type = CareerNewsType.values.firstWhere(
      (value) => value.name == typeName,
      orElse: () => CareerNewsType.match,
    );

    return CareerNews(
      id: json['id'] as String? ?? '',
      season: (json['season'] as num?)?.toInt() ?? 1,
      matchNumber: (json['matchNumber'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: type,
    );
  }
}
