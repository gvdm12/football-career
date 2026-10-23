import 'package:flutter/material.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/super_league_career.dart';
import 'package:flutter_football/screens/super_league/super_league_season_screen.dart';

class SuperLeagueCareerScreen extends StatelessWidget {
  final SuperLeagueCareer career;

  const SuperLeagueCareerScreen({super.key, required this.career});

  Player get player => career.player;

  static const Color _green = Color(0xFF22C55E);
  static const Color _background = Color(0xFF061B0C);
  static const Color _panel = Color(0xFF0B2813);
  static const Color _label = Color(0xFF8BE07F);

  String get _position {
    switch (player.position) {
      case PlayerPosition.goalkeeper: return 'Вратарь';
      case PlayerPosition.defender: return 'Защитник';
      case PlayerPosition.midfielder: return 'Полузащитник';
      case PlayerPosition.forward: return 'Нападающий';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: const Text('КАРЬЕРА СУПЕРЛИГИ',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _playerCard(),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _summaryCard(Icons.cake_rounded, '${player.age}', 'ВОЗРАСТ')),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard(Icons.calendar_month_rounded, '${career.season}/10', 'СЕЗОН')),
            ]),
            const SizedBox(height: 22),
            _sectionTitle('ХАРАКТЕРИСТИКИ ИГРОКА', Icons.analytics_rounded),
            const SizedBox(height: 12),
            _skillsPanel(),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SuperLeagueSeasonScreen(career: career))),
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('ПЕРЕЙТИ К СЕЗОНУ',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF163C22), Color(0xFF102B19), Color(0xFF0B2112)]),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF285438)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ПРОФИЛЬ ФУТБОЛИСТА',
        style: TextStyle(color: _label, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      const SizedBox(height: 16),
      Row(children: [
        Container(
          width: 72, height: 82,
          decoration: BoxDecoration(
            color: const Color(0xFF183D26), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF31583C))),
          child: const Icon(Icons.person_rounded, color: Color(0xFFB7C9BA), size: 52),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(player.name, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900, height: 1.05)),
          const SizedBox(height: 8),
          Text(player.club, style: const TextStyle(color: Color(0xFFD9E1DA), fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text('$_position • ${player.nationality}',
            style: const TextStyle(color: Color(0xFFAAB9AD), fontSize: 12)),
        ])),
        const SizedBox(width: 8),
        Column(children: [
          Text('${player.overall}', style: const TextStyle(color: Color(0xFFE4E9E5), fontSize: 34, fontWeight: FontWeight.w900, height: 1)),
          const SizedBox(height: 5),
          const Text('ОБЩИЙ', style: TextStyle(color: Color(0xFFAAB9AD), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ]),
      ]),
    ]),
  );

  Widget _summaryCard(IconData icon, String value, String label) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
    decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFF25432D))),
    child: Column(children: [
      Icon(icon, color: _label, size: 19), const SizedBox(height: 8),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center,
        style: const TextStyle(color: _label, fontSize: 9, fontWeight: FontWeight.w900)),
    ]),
  );

  Widget _sectionTitle(String title, IconData icon) => Row(children: [
    Icon(icon, color: _label, size: 21), const SizedBox(width: 9),
    Expanded(child: Text(title, style: const TextStyle(
      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.4))),
  ]);

  Widget _skillsPanel() {
    final skills = <({String name, int value, IconData icon})>[
      (name: 'Скорость', value: player.skills.pace, icon: Icons.bolt_rounded),
      (name: 'Физика', value: player.skills.physical, icon: Icons.fitness_center_rounded),
      (name: 'Удары', value: player.skills.shooting, icon: Icons.sports_soccer_rounded),
      (name: 'Пасы', value: player.skills.passing, icon: Icons.swap_horiz_rounded),
      (name: 'Дриблинг', value: player.skills.dribbling, icon: Icons.directions_run_rounded),
      (name: 'Защита', value: player.skills.defending, icon: Icons.security_rounded),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF25432D))),
      child: Column(children: [
        for (var i = 0; i < skills.length; i++) ...[
          Row(children: [
            Icon(skills[i].icon, color: const Color(0xFFAAB9AD), size: 19),
            const SizedBox(width: 10),
            SizedBox(width: 80, child: Text(skills[i].name,
              style: const TextStyle(color: Color(0xFFD0D8D1), fontSize: 12, fontWeight: FontWeight.w700))),
            const SizedBox(width: 10),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: skills[i].value.clamp(0, 100) / 100, minHeight: 7,
                backgroundColor: const Color(0xFF25382A),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF819788)),
              ),
            )),
            const SizedBox(width: 12),
            SizedBox(width: 27, child: Text('${skills[i].value}', textAlign: TextAlign.end,
              style: const TextStyle(color: Color(0xFFE0E6E1), fontSize: 14, fontWeight: FontWeight.w900))),
          ]),
          if (i != skills.length - 1)
            const Padding(padding: EdgeInsets.symmetric(vertical: 11),
              child: Divider(height: 1, color: Color(0xFF25432D))),
        ],
      ]),
    );
  }
}
