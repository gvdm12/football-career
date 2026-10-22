import 'match.dart';

class SeasonMatch {
  final int number;
  final String opponent;
  final bool isHome;
  final Match? result;

  const SeasonMatch({
    required this.number,
    required this.opponent,
    required this.isHome,
    this.result,
  });

  /// Матч команды уже завершён.
  bool get isPlayed => result != null;

  /// Игрок участвовал в завершённом матче.
  bool get playerPlayed => result?.playerPlayed ?? false;

  /// Матч завершён, но игрок не участвовал.
  bool get playerDidNotPlay => isPlayed && !playerPlayed;

  SeasonMatch copyWith({
    int? number,
    String? opponent,
    bool? isHome,
    Match? result,
  }) {
    return SeasonMatch(
      number: number ?? this.number,
      opponent: opponent ?? this.opponent,
      isHome: isHome ?? this.isHome,
      result: result ?? this.result,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'opponent': opponent,
      'isHome': isHome,
      'result': result?.toJson(),
    };
  }

  factory SeasonMatch.fromJson(Map<String, dynamic> json) {
    final rawResult = json['result'];

    return SeasonMatch(
      number: (json['number'] as num?)?.toInt() ?? 1,
      opponent: json['opponent'] as String? ?? '',
      isHome: json['isHome'] as bool? ?? true,
      result: rawResult is Map
          ? Match.fromJson(Map<String, dynamic>.from(rawResult))
          : null,
    );
  }
}
