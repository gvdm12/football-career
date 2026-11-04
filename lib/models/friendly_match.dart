import 'match.dart';

class FriendlyMatch {
  final int number;
  final String opponent;
  final bool isHome;
  final Match? result;
  final bool isSkipped;

  const FriendlyMatch({
    required this.number,
    required this.opponent,
    required this.isHome,
    this.result,
    this.isSkipped = false,
  });

  bool get isPlayed => result != null;
  bool get isResolved => isPlayed || isSkipped;

  FriendlyMatch copyWith({Match? result, bool? isSkipped}) => FriendlyMatch(
    number: number,
    opponent: opponent,
    isHome: isHome,
    result: result ?? this.result,
    isSkipped: isSkipped ?? this.isSkipped,
  );

  Map<String, dynamic> toJson() => {
    'number': number,
    'opponent': opponent,
    'isHome': isHome,
    'result': result?.toJson(),
    'isSkipped': isSkipped,
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
      isSkipped: json['isSkipped'] as bool? ?? false,
    );
  }
}
