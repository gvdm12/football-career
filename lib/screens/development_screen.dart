import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/services/app_strings.dart';

class DevelopmentScreen extends StatefulWidget {
  final Career career;

  const DevelopmentScreen({super.key, required this.career});

  @override
  State<DevelopmentScreen> createState() => _DevelopmentScreenState();
}

class _DevelopmentScreenState extends State<DevelopmentScreen> {
  late Career career;

  final Set<SkillName> selectedSkills = {};

  @override
  void initState() {
    super.initState();
    career = widget.career;
  }

  Player get player => career.player;

  int get availablePoints => career.developmentPoints;

  bool get advancedDevelopment =>
      career.history.length >= 6 && career.history.length <= 12;

  int get multiSkillBonus => advancedDevelopment ? 2 : 1;

  int get singleSkillBonus => advancedDevelopment ? 6 : 3;

  void toggleSkill(SkillName skill) {
    if (availablePoints < multiSkillBonus * 3) {
      return;
    }

    setState(() {
      if (selectedSkills.contains(skill)) {
        selectedSkills.remove(skill);
      } else if (selectedSkills.length < 3) {
        selectedSkills.add(skill);
      }
    });
  }

  void upgradeSelected() {
    final pointsToSpend = multiSkillBonus * 3;

    if (availablePoints < pointsToSpend || selectedSkills.length != 3) {
      return;
    }

    var skills = player.skills;

    for (final skill in selectedSkills) {
      skills = _increaseSkill(skills, skill, multiSkillBonus);
    }

    _applySkills(skills, pointsToSpend);
  }

  void upgradeOneSkill(SkillName skill) {
    if (availablePoints < singleSkillBonus) {
      return;
    }

    final skills = _increaseSkill(player.skills, skill, singleSkillBonus);

    _applySkills(skills, singleSkillBonus);
  }

  PlayerSkills _increaseSkill(
    PlayerSkills skills,
    SkillName skill,
    int amount,
  ) {
    switch (skill) {
      case SkillName.pace:
        return skills.copyWith(pace: (skills.pace + amount).clamp(0, 99));

      case SkillName.shooting:
        return skills.copyWith(
          shooting: (skills.shooting + amount).clamp(0, 99),
        );

      case SkillName.physical:
        return skills.copyWith(
          physical: (skills.physical + amount).clamp(0, 99),
        );

      case SkillName.passing:
        return skills.copyWith(passing: (skills.passing + amount).clamp(0, 99));

      case SkillName.defending:
        return skills.copyWith(
          defending: (skills.defending + amount).clamp(0, 99),
        );

      case SkillName.dribbling:
        return skills.copyWith(
          dribbling: (skills.dribbling + amount).clamp(0, 99),
        );
      case SkillName.heading:
        return skills.copyWith(heading: (skills.heading + amount).clamp(0, 99));
      case SkillName.vision:
        return skills.copyWith(vision: (skills.vision + amount).clamp(0, 99));
    }
  }

  void _applySkills(PlayerSkills skills, int pointsToSpend) {
    final newOverall = calculateOverall(
      skills: skills,
      position: player.position,
    );

    final newPlayer = player.copyWith(skills: skills, overall: newOverall);

    setState(() {
      career = career.copyWith(
        player: newPlayer,
        developmentPoints: availablePoints - pointsToSpend,
      );

      selectedSkills.clear();
    });
  }

  String skillName(SkillName skill) {
    switch (skill) {
      case SkillName.pace:
        return AppStrings.pace;
      case SkillName.shooting:
        return AppStrings.shooting;
      case SkillName.physical:
        return AppStrings.physical;
      case SkillName.passing:
        return AppStrings.passing;
      case SkillName.defending:
        return AppStrings.defending;
      case SkillName.dribbling:
        return AppStrings.dribbling;
      case SkillName.heading:
        return AppStrings.heading;
      case SkillName.vision:
        return AppStrings.vision;
    }
  }

  IconData skillIcon(SkillName skill) {
    switch (skill) {
      case SkillName.pace:
        return Icons.bolt;
      case SkillName.physical:
        return Icons.fitness_center;
      case SkillName.passing:
        return Icons.adjust;
      case SkillName.shooting:
        return Icons.gps_fixed;
      case SkillName.defending:
        return Icons.shield;
      case SkillName.dribbling:
        return Icons.blur_circular;
      case SkillName.heading:
        return Icons.sports_soccer;
      case SkillName.vision:
        return Icons.visibility;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF04160A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B3A1A),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () {
          //     Navigator.pop(context, career);
          //   },
          // ),
          title: Text(
            AppStrings.developmentScreenTitle,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 1 / 6,
                child: Image.asset(
                  'assets/images/training.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 4),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      children: SkillName.values.map((skill) {
                        return _buildSkillCard(skill);
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    _buildUpgradeButtons(),
                    const SizedBox(height: 14),
                    _buildFinishButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF14401E)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          Expanded(
            flex: 6,
            child: Text(
              player.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              'OVR ${player.overall}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF8BE07F),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Flexible(
            flex: 4,
            child: Text(
              AppStrings.availableDevelopmentPoints(availablePoints),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFFFFD75A),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(SkillName skill) {
    final value = player.skills.getSkill(skill);
    final selected = selectedSkills.contains(skill);

    return GestureDetector(
      onTap: availablePoints >= 3 ? () => toggleSkill(skill) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF12381B)
              : const Color.fromARGB(180, 111, 111, 111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF5DBB68) : const Color(0xFF14401E),
          ),
        ),
        child: Row(
          children: [
            Icon(skillIcon(skill), color: const Color(0xFF8BE07F), size: 20),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                skillName(skill),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle,
                color: Color(0xFF8BE07F),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeButtons() {
    return Column(
      children: [
        // Улучшение трёх выбранных навыков
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed:
                availablePoints >= multiSkillBonus * 3 &&
                    selectedSkills.length == 3
                ? upgradeSelected
                : null,
            child: Text(
              AppStrings.upgradeThreeSkills(multiSkillBonus),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          AppStrings.chooseOneSkillFor(singleSkillBonus),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF6FA87A), fontSize: 13),
        ),

        const SizedBox(height: 10),

        // Шесть кнопок улучшения в два столбца
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.7,
          children: SkillName.values.map((skill) {
            return OutlinedButton(
              onPressed: availablePoints >= singleSkillBonus
                  ? () => upgradeOneSkill(skill)
                  : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '${skillName(skill)} +$singleSkillBonus',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(14),
          ),
        ),
        onPressed: () {
          Navigator.pop(context, career);
        },
        child: Text(
          AppStrings.doneButton,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
