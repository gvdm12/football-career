import 'dart:math';

enum PlayerPosition { goalkeeper, defender, midfielder, forward }

enum SkillName {
  pace,
  physical,
  shooting,
  passing,
  dribbling,
  defending,
  heading,
  vision,
}

class PlayerSkills {
  final int pace;
  final int physical;
  final int passing;
  final int shooting;
  final int defending;
  final int dribbling;
  final int heading;
  final int vision;

  const PlayerSkills({
    required this.pace,
    required this.physical,
    required this.passing,
    required this.shooting,
    required this.defending,
    required this.dribbling,
    this.heading = 50,
    this.vision = 50,
  });

  static PlayerSkills initial(PlayerPosition position) {
    final random = Random();

    int randomValue(int min, int max) {
      return min + random.nextInt(max - min + 1);
    }

    switch (position) {
      case PlayerPosition.goalkeeper:
        return PlayerSkills(
          pace: randomValue(50, 65),
          physical: randomValue(50, 65),
          passing: randomValue(45, 60),
          shooting: randomValue(15, 30),
          defending: randomValue(60, 75),
          dribbling: randomValue(25, 40),
          heading: randomValue(20, 35),
          vision: randomValue(48, 60),
        );

      case PlayerPosition.defender:
        return PlayerSkills(
          pace: randomValue(52, 65),
          physical: randomValue(57, 67),
          passing: randomValue(48, 60),
          shooting: randomValue(25, 40),
          defending: randomValue(60, 75),
          dribbling: randomValue(45, 58),
          heading: randomValue(60, 75),
          vision: randomValue(45, 60),
        );

      case PlayerPosition.midfielder:
        return PlayerSkills(
          pace: randomValue(59, 67),
          physical: randomValue(59, 67),
          passing: randomValue(64, 70),
          shooting: randomValue(61, 66),
          defending: randomValue(53, 59),
          dribbling: randomValue(60, 67),
          heading: randomValue(49, 58),
          vision: randomValue(68, 78),
        );

      case PlayerPosition.forward:
        return PlayerSkills(
          pace: randomValue(64, 70),
          physical: randomValue(61, 67),
          passing: randomValue(62, 68),
          shooting: randomValue(67, 69),
          defending: randomValue(45, 56),
          dribbling: randomValue(65, 69),
          heading: randomValue(65, 72),
          vision: randomValue(60, 68),
        );
    }
  }

  int get average {
    return ((pace +
                physical +
                passing +
                shooting +
                defending +
                dribbling +
                heading +
                vision) /
            8)
        .round();
  }

  int getSkill(SkillName skill) {
    switch (skill) {
      case SkillName.pace:
        return pace;
      case SkillName.physical:
        return physical;
      case SkillName.passing:
        return passing;
      case SkillName.shooting:
        return shooting;
      case SkillName.defending:
        return defending;
      case SkillName.dribbling:
        return dribbling;
      case SkillName.heading:
        return heading;
      case SkillName.vision:
        return vision;
    }
  }

  PlayerSkills copyWith({
    int? pace,
    int? physical,
    int? passing,
    int? shooting,
    int? defending,
    int? dribbling,
    int? heading,
    int? vision,
  }) {
    return PlayerSkills(
      pace: pace ?? this.pace,
      physical: physical ?? this.physical,
      passing: passing ?? this.passing,
      shooting: shooting ?? this.shooting,
      defending: defending ?? this.defending,
      dribbling: dribbling ?? this.dribbling,
      heading: heading ?? this.heading,
      vision: vision ?? this.vision,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pace': pace,
      'physical': physical,
      'passing': passing,
      'shooting': shooting,
      'defending': defending,
      'dribbling': dribbling,
      'heading': heading,
      'vision': vision,
    };
  }

  factory PlayerSkills.fromJson(Map<String, dynamic> json) {
    int readSkill(String key, int fallback) {
      return (json[key] as num?)?.toInt() ?? fallback;
    }

    return PlayerSkills(
      pace: readSkill('pace', 50),
      physical: readSkill('physical', 50),
      passing: readSkill('passing', 50),
      shooting: readSkill('shooting', 50),
      defending: readSkill('defending', 50),
      dribbling: readSkill('dribbling', 50),
      heading: readSkill('heading', 50),
      vision: readSkill('vision', 50),
    );
  }
}

class Player {
  final String name;
  final String nationality;
  final PlayerPosition position;

  final int age;
  final int season;
  final String club;

  final int overall;
  final PlayerSkills skills;

  const Player({
    required this.name,
    required this.nationality,
    required this.position,
    required this.age,
    required this.season,
    required this.club,
    required this.overall,
    required this.skills,
  });

  factory Player.create({
    required String name,
    required String nationality,
    required PlayerPosition position,
    String club = 'Без клуба',
  }) {
    final skills = PlayerSkills.initial(position);

    return Player(
      name: name,
      nationality: nationality,
      position: position,
      age: 17,
      season: 1,
      club: club,
      overall: calculateOverall(skills: skills, position: position),
      skills: skills,
    );
  }

  Player copyWith({
    String? name,
    String? nationality,
    PlayerPosition? position,
    int? age,
    int? season,
    String? club,
    int? overall,
    PlayerSkills? skills,
  }) {
    return Player(
      name: name ?? this.name,
      nationality: nationality ?? this.nationality,
      position: position ?? this.position,
      age: age ?? this.age,
      season: season ?? this.season,
      club: club ?? this.club,
      overall: overall ?? this.overall,
      skills: skills ?? this.skills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nationality': nationality,
      'position': position.name,
      'age': age,
      'season': season,
      'club': club,
      'overall': overall,
      'skills': skills.toJson(),
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    final positionName = json['position'] as String? ?? 'forward';

    final position = PlayerPosition.values.firstWhere(
      (value) => value.name == positionName,
      orElse: () => PlayerPosition.forward,
    );

    final rawSkills = json['skills'];

    final skills = rawSkills is Map
        ? PlayerSkills.fromJson(Map<String, dynamic>.from(rawSkills))
        : PlayerSkills.initial(position);

    return Player(
      name: json['name'] as String? ?? 'player',
      nationality: json['nationality'] as String? ?? 'Россия',
      position: position,
      age: (json['age'] as num?)?.toInt() ?? 17,
      season: (json['season'] as num?)?.toInt() ?? 1,
      club: json['club'] as String? ?? 'Без клуба',
      overall:
          (json['overall'] as num?)?.toInt() ??
          calculateOverall(skills: skills, position: position),
      skills: skills,
    );
  }
}

int calculateOverall({
  required PlayerSkills skills,
  required PlayerPosition position,
}) {
  late final Map<SkillName, double> weights;

  switch (position) {
    case PlayerPosition.goalkeeper:
      weights = {
        SkillName.pace: 0.0425,
        SkillName.physical: 0.1275,
        SkillName.passing: 0.17,
        SkillName.shooting: 0.017,
        SkillName.defending: 0.425,
        SkillName.dribbling: 0.068,
        SkillName.heading: 0.02,
        SkillName.vision: 0.13,
      };

    case PlayerPosition.defender:
      weights = {
        SkillName.pace: 0.1245,
        SkillName.physical: 0.166,
        SkillName.passing: 0.1245,
        SkillName.shooting: 0.0249,
        SkillName.defending: 0.2905,
        SkillName.dribbling: 0.0996,
        SkillName.heading: 0.12,
        SkillName.vision: 0.05,
      };

    case PlayerPosition.midfielder:
      weights = {
        SkillName.pace: 0.123,
        SkillName.physical: 0.0984,
        SkillName.passing: 0.2296,
        SkillName.shooting: 0.123,
        SkillName.defending: 0.0984,
        SkillName.dribbling: 0.1312,
        SkillName.heading: 0.04,
        SkillName.vision: 0.1564,
      };

    case PlayerPosition.forward:
      weights = {
        SkillName.pace: 0.166,
        SkillName.physical: 0.0996,
        SkillName.passing: 0.083,
        SkillName.shooting: 0.2905,
        SkillName.defending: 0.0249,
        SkillName.dribbling: 0.166,
        SkillName.heading: 0.12,
        SkillName.vision: 0.05,
      };
  }

  final result =
      skills.pace * weights[SkillName.pace]! +
      skills.physical * weights[SkillName.physical]! +
      skills.passing * weights[SkillName.passing]! +
      skills.shooting * weights[SkillName.shooting]! +
      skills.defending * weights[SkillName.defending]! +
      skills.dribbling * weights[SkillName.dribbling]! +
      skills.heading * weights[SkillName.heading]! +
      skills.vision * weights[SkillName.vision]!;

  return result.round();
}
