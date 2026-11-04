enum CareerDifficulty { easy, normal, hard }

/// Настройки, выбранные перед началом карьеры.
class CareerSettings {
  final bool allowAnyStartingClub;
  final CareerDifficulty difficulty;
  final bool limitTransfersToFiveYears;
  final bool playWithoutInjuries;
  final double injuryFrequency;
  final double developmentSpeed;

  const CareerSettings({
    this.allowAnyStartingClub = false,
    this.difficulty = CareerDifficulty.normal,
    this.limitTransfersToFiveYears = false,
    this.playWithoutInjuries = false,
    this.injuryFrequency = 1.0,
    this.developmentSpeed = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'allowAnyStartingClub': allowAnyStartingClub,
    'difficulty': difficulty.name,
    'limitTransfersToFiveYears': limitTransfersToFiveYears,
    'playWithoutInjuries': playWithoutInjuries,
    'injuryFrequency': injuryFrequency,
    'developmentSpeed': developmentSpeed,
  };

  factory CareerSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CareerSettings();
    return CareerSettings(
      allowAnyStartingClub: json['allowAnyStartingClub'] as bool? ?? false,
      difficulty: CareerDifficulty.values.firstWhere(
        (value) => value.name == json['difficulty'],
        orElse: () => CareerDifficulty.normal,
      ),
      limitTransfersToFiveYears:
          json['limitTransfersToFiveYears'] as bool? ?? false,
      playWithoutInjuries: json['playWithoutInjuries'] as bool? ?? false,
      injuryFrequency: ((json['injuryFrequency'] as num?)?.toDouble() ?? 1.0)
          .clamp(0.0, 2.0)
          .toDouble(),
      developmentSpeed: ((json['developmentSpeed'] as num?)?.toDouble() ?? 1.0)
          .clamp(0.5, 1.5)
          .toDouble(),
    );
  }
}
