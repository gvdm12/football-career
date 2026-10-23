import 'dart:math';

enum PlayerPosition { goalkeeper, defender, midfielder, forward }

enum SkillName { pace, physical, shooting, passing, dribbling, defending }

class PlayerSkills {
  final int pace;
  final int physical;
  final int passing;
  final int shooting;
  final int defending;
  final int dribbling;

  const PlayerSkills({
    required this.pace,
    required this.physical,
    required this.passing,
    required this.shooting,
    required this.defending,
    required this.dribbling,
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
        );

      case PlayerPosition.defender:
        return PlayerSkills(
          pace: randomValue(57, 65),
          physical: randomValue(57, 69),
          passing: randomValue(49, 60),
          shooting: randomValue(34, 48),
          defending: randomValue(63, 75),
          dribbling: randomValue(48, 58),
        );

      case PlayerPosition.midfielder:
        return PlayerSkills(
          pace: randomValue(59, 67),
          physical: randomValue(58, 65),
          passing: randomValue(62, 68),
          shooting: randomValue(60, 65),
          defending: randomValue(50, 57),
          dribbling: randomValue(59, 67),
        );

      case PlayerPosition.forward:
        return PlayerSkills(
          pace: randomValue(63, 70),
          physical: randomValue(60, 67),
          passing: randomValue(62, 68),
          shooting: randomValue(65, 69),
          defending: randomValue(40, 56),
          dribbling: randomValue(64, 68),
        );
    }
  }

  int get average {
    return ((pace + physical + passing + shooting + defending + dribbling) / 6)
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
    }
  }

  PlayerSkills copyWith({
    int? pace,
    int? physical,
    int? passing,
    int? shooting,
    int? defending,
    int? dribbling,
  }) {
    return PlayerSkills(
      pace: pace ?? this.pace,
      physical: physical ?? this.physical,
      passing: passing ?? this.passing,
      shooting: shooting ?? this.shooting,
      defending: defending ?? this.defending,
      dribbling: dribbling ?? this.dribbling,
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
        SkillName.pace: 0.05,
        SkillName.physical: 0.15,
        SkillName.passing: 0.20,
        SkillName.shooting: 0.02,
        SkillName.defending: 0.50,
        SkillName.dribbling: 0.08,
      };

    case PlayerPosition.defender:
      weights = {
        SkillName.pace: 0.15,
        SkillName.physical: 0.20,
        SkillName.passing: 0.15,
        SkillName.shooting: 0.03,
        SkillName.defending: 0.35,
        SkillName.dribbling: 0.12,
      };

    case PlayerPosition.midfielder:
      weights = {
        SkillName.pace: 0.15,
        SkillName.physical: 0.12,
        SkillName.passing: 0.28,
        SkillName.shooting: 0.15,
        SkillName.defending: 0.12,
        SkillName.dribbling: 0.16,
      };

    case PlayerPosition.forward:
      weights = {
        SkillName.pace: 0.20,
        SkillName.physical: 0.12,
        SkillName.passing: 0.10,
        SkillName.shooting: 0.35,
        SkillName.defending: 0.03,
        SkillName.dribbling: 0.20,
      };
  }

  final result =
      skills.pace * weights[SkillName.pace]! +
      skills.physical * weights[SkillName.physical]! +
      skills.passing * weights[SkillName.passing]! +
      skills.shooting * weights[SkillName.shooting]! +
      skills.defending * weights[SkillName.defending]! +
      skills.dribbling * weights[SkillName.dribbling]!;

  return result.round();
}
