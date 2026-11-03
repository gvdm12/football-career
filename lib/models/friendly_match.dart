import 'match.dart';

class FriendlyMatch {
  final int number;
  final String opponent;
  final bool isHome;
  final Match? result;

  const FriendlyMatch({
    required this.number,
    required this.opponent,
    required this.isHome,
    this.result,
  });

  bool get isPlayed => result != null;

  FriendlyMatch copyWith({Match? result}) => FriendlyMatch(
    number: number,
    opponent: opponent,
    isHome: isHome,
    result: result ?? this.result,
  );

  Map<String, dynamic> toJson() => {
    'number': number,
    'opponent': opponent,
    'isHome': isHome,
    'result': result?.toJson(),
  };

  factory FriendlyMatch.fromJson(Map<String, dynamic> json) {
    final rawResult = json['result'];
    return FriendlyMatch(
      number: (json['number'] as num?)?.toInt() ?? 1,
      opponent: json['opponent'] as String? ?? '',
      isHome: json['isHome'] as bool? ?? true,
      result: rawResult is Map
          ? Match.fromJson(Map<String, dynamic>.from(rawResult))
          : null,
    );
  }
}
