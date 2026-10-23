import 'package:flutter/material.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/super_league_career.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuperLeagueDevelopmentScreen extends StatefulWidget {
  final SuperLeagueCareer career;
  const SuperLeagueDevelopmentScreen({super.key, required this.career});

  @override
  State<SuperLeagueDevelopmentScreen> createState() => _SuperLeagueDevelopmentScreenState();
}

class _SuperLeagueDevelopmentScreenState extends State<SuperLeagueDevelopmentScreen> {
  late SuperLeagueCareer _career;
  final Set<SkillName> _selected = {};

  @override
  void initState() {
    super.initState();
    _career = widget.career;
  }

  Player get _player => _career.player;

  String _name(SkillName skill) {
    switch (skill) {
      case SkillName.pace: return 'Скорость';
      case SkillName.physical: return 'Физика';
      case SkillName.shooting: return 'Удары';
      case SkillName.passing: return 'Пасы';
      case SkillName.dribbling: return 'Дриблинг';
      case SkillName.defending: return 'Защита';
    }
  }

  IconData _icon(SkillName skill) {
    switch (skill) {
      case SkillName.pace: return Icons.bolt;
      case SkillName.physical: return Icons.fitness_center;
      case SkillName.shooting: return Icons.gps_fixed;
      case SkillName.passing: return Icons.adjust;
      case SkillName.dribbling: return Icons.blur_circular;
      case SkillName.defending: return Icons.shield;
    }
  }

  int _value(SkillName skill) => _player.skills.getSkill(skill);

  PlayerSkills _increase(PlayerSkills skills, SkillName skill, int amount) {
    final value = (_value(skill) + amount).clamp(0, 99);
    switch (skill) {
      case SkillName.pace: return skills.copyWith(pace: value);
      case SkillName.physical: return skills.copyWith(physical: value);
      case SkillName.shooting: return skills.copyWith(shooting: value);
      case SkillName.passing: return skills.copyWith(passing: value);
      case SkillName.dribbling: return skills.copyWith(dribbling: value);
      case SkillName.defending: return skills.copyWith(defending: value);
    }
  }

  void _upgradeOne(SkillName skill) {
    if (_career.developmentPoints < 3 || _value(skill) >= 99) return;
    var skills = _player.skills;
    skills = _increase(skills, skill, 3);
    _apply(skills, 3);
  }

  void _toggle(SkillName skill) {
    if (_career.developmentPoints < 6 || _value(skill) >= 99) return;
    setState(() {
      if (_selected.contains(skill)) {
        _selected.remove(skill);
      } else if (_selected.length < 3) {
        _selected.add(skill);
      }
    });
  }

  void _upgradeSelected() {
    if (_career.developmentPoints < 6 || _selected.length != 3) return;
    var skills = _player.skills;
    for (final skill in _selected) {
      skills = _increase(skills, skill, 2);
    }
    _apply(skills, 6);
    setState(() => _selected.clear());
  }

  void _apply(PlayerSkills skills, int cost) {
    final overall = calculateOverall(skills: skills, position: _player.position);
    setState(() {
      _career = _career.copyWith(
        player: _player.copyWith(skills: skills, overall: overall),
        developmentPoints: _career.developmentPoints - cost,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<SuperLeagueCareer>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && mounted) Navigator.pop(context, _career);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF061B0C),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(82, 81, 84, 82),
          foregroundColor: Colors.white,
          title: const Text('РАЗВИТИЕ ИГРОКА', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        body: Stack(children: [
          Positioned.fill(child: Opacity(opacity: 0.16,
            child: Image.asset('assets/images/training.png', fit: BoxFit.cover))),
          SafeArea(child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ClubColors.primary(_player.club).withValues(alpha: 0.7), const Color(0xFF071B0D)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ClubColors.primary(_player.club)),
                ),
                child: Row(children: [
                  SvgPicture.asset('assets/icons/player.svg', width: 66, height: 66),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_player.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 5),
                    Text('${_player.club} • РЕЙТИНГ ${_player.overall}',
                      style: const TextStyle(color: Color(0xFF8BE07F), fontWeight: FontWeight.w800, fontSize: 12)),
                  ])),
                ]),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0x14FFFFFF), borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF14401E)),
                ),
                child: Row(children: [
                  const Icon(Icons.bolt, color: Color(0xFF8BE07F), size: 32),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ОЧКИ РАЗВИТИЯ', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text('Трать очки на улучшение навыков', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ])),
                  Text('${_career.developmentPoints}', style: const TextStyle(color: Color(0xFF8BE07F), fontSize: 30, fontWeight: FontWeight.w900)),
                ]),
              ),
              const SizedBox(height: 18),
              const Text('НАВЫКИ', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 10),
              ...SkillName.values.map(_skillCard),
              const SizedBox(height: 14),
              SizedBox(height: 50, child: ElevatedButton(
                onPressed: _selected.length == 3 && _career.developmentPoints >= 6 ? _upgradeSelected : null,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8BE07F), foregroundColor: const Color(0xFF082A12)),
                child: const Text('УЛУЧШИТЬ 3 НАВЫКА (+2)', style: TextStyle(fontWeight: FontWeight.w900)),
              )),
              const SizedBox(height: 10),
              SizedBox(height: 50, child: OutlinedButton(
                onPressed: () => Navigator.pop(context, _career),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF3C884A))),
                child: const Text('ПРОДОЛЖИТЬ К ТРАНСФЕРАМ', style: TextStyle(fontWeight: FontWeight.w900)),
              )),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _skillCard(SkillName skill) {
    final value = _value(skill);
    final selected = _selected.contains(skill);
    final color = switch (skill) {
      SkillName.pace => const Color(0xFFC8E04A),
      SkillName.physical => const Color(0xFFFFC94A),
      SkillName.shooting => const Color(0xFFFF6B4A),
      SkillName.passing => const Color(0xFF5FD070),
      SkillName.dribbling => const Color(0xFF4AA8FF),
      SkillName.defending => const Color(0xFF7EA7FF),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF12381B) : const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? const Color(0xFF8BE07F) : const Color(0xFF14401E)),
      ),
      child: Row(children: [
        Icon(_icon(skill), color: color, size: 23),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_name(skill), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
            value: value / 99, minHeight: 5, backgroundColor: const Color(0xFF12381B),
            valueColor: AlwaysStoppedAnimation<Color>(color))),
        ])),
        const SizedBox(width: 10),
        Text('$value', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
        const SizedBox(width: 6),
        IconButton(
          tooltip: 'Улучшить на 3 за 3 очка',
          onPressed: _career.developmentPoints >= 3 && value < 99 ? () => _upgradeOne(skill) : null,
          icon: const Icon(Icons.add_circle_outline),
          color: const Color(0xFF8BE07F),
        ),
        IconButton(
          tooltip: selected ? 'Убрать из выбора' : 'Выбрать для улучшения',
          onPressed: value < 99 && _career.developmentPoints >= 6 ? () => _toggle(skill) : null,
          icon: Icon(selected ? Icons.check_circle : Icons.circle_outlined),
          color: const Color(0xFF8BE07F),
        ),
      ]),
    );
  }
}
