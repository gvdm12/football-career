enum CareerDifficulty { easy, normal, hard }

/// Настройки, выбранные перед началом карьеры.
class CareerSettings {
  final bool allowAnyStartingClub;
  final CareerDifficulty difficulty;
  final bool realisticTransfers;
  final double injuryFrequency;
  final double developmentSpeed;

  const CareerSettings({
    this.allowAnyStartingClub = false,
    this.difficulty = CareerDifficulty.normal,
    this.realisticTransfers = true,
    this.injuryFrequency = 1.0,
    this.developmentSpeed = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'allowAnyStartingClub': allowAnyStartingClub,
    'difficulty': difficulty.name,
    'realisticTransfers': realisticTransfers,
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
      realisticTransfers: json['realisticTransfers'] as bool? ?? true,
      injuryFrequency: ((json['injuryFrequency'] as num?)?.toDouble() ?? 1.0)
          .clamp(0.0, 2.0)
          .toDouble(),
      developmentSpeed: ((json['developmentSpeed'] as num?)?.toDouble() ?? 1.0)
          .clamp(0.5, 1.5)
          .toDouble(),
    );
  }
}
