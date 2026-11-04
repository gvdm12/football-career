class SponsorOffer {
  final String id;
  final String brand;
  final int paymentPerSeason;
  final int signingBonus;
  final int contractYears;

  const SponsorOffer({
    required this.id,
    required this.brand,
    required this.paymentPerSeason,
    required this.signingBonus,
    required this.contractYears,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'brand': brand,
    'paymentPerSeason': paymentPerSeason,
    'signingBonus': signingBonus,
    'contractYears': contractYears,
  };

  factory SponsorOffer.fromJson(Map<String, dynamic> json) => SponsorOffer(
    id: json['id'] as String? ?? '',
    brand: json['brand'] as String? ?? 'Sponsor',
    paymentPerSeason: (json['paymentPerSeason'] as num?)?.toInt() ?? 0,
    signingBonus: (json['signingBonus'] as num?)?.toInt() ?? 0,
    contractYears: ((json['contractYears'] as num?)?.toInt() ?? 1).clamp(1, 3),
  );
}

class SponsorContract {
  final String brand;
  final int paymentPerSeason;
  final int seasonsRemaining;
  final int goalBonus;

  const SponsorContract({
    required this.brand,
    required this.paymentPerSeason,
    required this.seasonsRemaining,
    this.goalBonus = 0,
  });

  SponsorContract copyWith({int? seasonsRemaining}) => SponsorContract(
    brand: brand,
    paymentPerSeason: paymentPerSeason,
    seasonsRemaining: seasonsRemaining ?? this.seasonsRemaining,
    goalBonus: goalBonus,
  );

  int payoutForSeason(int goals) =>
      paymentPerSeason + (goals.clamp(0, 25) * goalBonus);

  Map<String, dynamic> toJson() => {
    'brand': brand,
    'paymentPerSeason': paymentPerSeason,
    'seasonsRemaining': seasonsRemaining,
    'goalBonus': goalBonus,
  };

  factory SponsorContract.fromJson(Map<String, dynamic> json) => SponsorContract(
    brand: json['brand'] as String? ?? 'Sponsor',
    paymentPerSeason: (json['paymentPerSeason'] as num?)?.toInt() ?? 0,
    seasonsRemaining: ((json['seasonsRemaining'] as num?)?.toInt() ?? 1).clamp(0, 3),
    goalBonus: (json['goalBonus'] as num?)?.toInt() ?? 0,
  );
}
