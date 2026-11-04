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
      // Раньше частота травм дополнительно менялась сложностью.
      // Нормализуем старые сохранения, чтобы коэффициент не применялся дважды.
      injuryFrequency: 1.0,
      developmentSpeed: ((json['developmentSpeed'] as num?)?.toDouble() ?? 1.0)
          .clamp(0.5, 1.5)
          .toDouble(),
    );
  }
}


/// Единые коэффициенты игровых эффектов сложности.
/// Коэффициенты не переопределяют настройку скорости развития карьеры.
extension CareerDifficultyEffects on CareerDifficulty {
  double get matchExpectedGoalsShift => switch (this) {
    CareerDifficulty.easy => 0.15,
    CareerDifficulty.normal => 0.0,
    CareerDifficulty.hard => -0.15,
  };

  double get injuryChanceMultiplier => switch (this) {
    CareerDifficulty.easy => 0.85,
    CareerDifficulty.normal => 1.0,
    CareerDifficulty.hard => 1.2,
  };

  double get selectionChanceAdjustment => switch (this) {
    CareerDifficulty.easy => 0.06,
    CareerDifficulty.normal => 0.0,
    CareerDifficulty.hard => -0.06,
  };

  double get interactiveActionAdjustment => switch (this) {
    CareerDifficulty.easy => 0.05,
    CareerDifficulty.normal => 0.0,
    CareerDifficulty.hard => -0.05,
  };

  double get opponentPressureMultiplier => switch (this) {
    CareerDifficulty.easy => 0.85,
    CareerDifficulty.normal => 1.0,
    CareerDifficulty.hard => 1.15,
  };

  double get coachTrustMultiplier => switch (this) {
    CareerDifficulty.easy => 0.8,
    CareerDifficulty.normal => 1.0,
    CareerDifficulty.hard => 1.2,
  };
}
