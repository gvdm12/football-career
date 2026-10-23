import 'package:flutter/material.dart';
import 'package:flutter_football/models/player.dart';

class SuperLeagueCareerScreen extends StatelessWidget {
  final Player player;

  const SuperLeagueCareerScreen({super.key, required this.player});

  static const Color _green = Color(0xFF22C55E);
  static const Color _background = Color(0xFF061B0C);
  static const Color _panel = Color(0xFF0B2813);
  static const Color _label = Color(0xFF8BE07F);

  String get _position {
    switch (player.position) {
      case PlayerPosition.goalkeeper:
        return 'Вратарь';
      case PlayerPosition.defender:
        return 'Защитник';
      case PlayerPosition.midfielder:
        return 'Полузащитник';
      case PlayerPosition.forward:
        return 'Нападающий';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: const Text(
          'КАРЬЕРА СУПЕРЛИГИ',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _buildPlayerHeader(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _summaryCard(Icons.cake_rounded, '${player.age}', 'ВОЗРАСТ')),
                const SizedBox(width: 10),
                Expanded(child: _summaryCard(Icons.calendar_month_rounded, '${player.season}', 'СЕЗОН')),
                const SizedBox(width: 10),
                Expanded(child: _summaryCard(Icons.stars_rounded, '${player.skills.average}', 'СР. НАВЫК')),
              ],
            ),
            const SizedBox(height: 22),
            _sectionTitle('ХАРАКТЕРИСТИКИ ИГРОКА', Icons.analytics_rounded),
            const SizedBox(height: 12),
            _buildSkillsPanel(),
            const SizedBox(height: 22),
            _sectionTitle('СТАТИСТИКА СЕЗОНА', Icons.query_stats_rounded),
            const SizedBox(height: 12),
            _buildSeasonStats(),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF174324)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.save_rounded, color: _label, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Карьера автоматически сохраняется отдельно от обычного режима. '
                      'Следующим этапом подключим календарь, результаты матчей и таблицу Суперлиги.',
                      style: TextStyle(color: Colors.white70, height: 1.45, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF164A25), Color(0xFF0B2813), Color(0xFF07190C)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF28683A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ПРОФИЛЬ ФУТБОЛИСТА',
            style: TextStyle(color: _label, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 82,
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _green.withValues(alpha: 0.35)),
                ),
                child: const Icon(Icons.person_rounded, color: _green, size: 52),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900, height: 1.05),
                    ),
                    const SizedBox(height: 8),
                    Text(player.club, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text('$_position • ${player.nationality}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Text(
                    '${player.overall}',
                    style: const TextStyle(color: _green, fontSize: 34, fontWeight: FontWeight.w900, height: 1),
                  ),
                  const SizedBox(height: 5),
                  const Text('ОБЩИЙ', style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: _label, size: 19),
                const SizedBox(width: 9),
                const Expanded(child: Text('Клуб игрока', style: TextStyle(color: Colors.white70, fontSize: 12))),
                Flexible(
                  child: Text(
                    player.club,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF174324)),
      ),
      child: Column(
        children: [
          Icon(icon, color: _label, size: 19),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: _label, fontSize: 9, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _green, size: 21),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsPanel() {
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
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF174324)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < skills.length; i++) ...[
            _skillRow(skills[i].name, skills[i].value, skills[i].icon),
            if (i != skills.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 11),
                child: Divider(height: 1, color: Color(0xFF174324)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _skillRow(String name, int value, IconData icon) {
    final progress = (value.clamp(0, 100)) / 100;
    return Row(
      children: [
        Icon(icon, color: _label, size: 19),
        const SizedBox(width: 10),
        SizedBox(
          width: 84,
          child: Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFF17351F),
              valueColor: const AlwaysStoppedAnimation<Color>(_green),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 27,
          child: Text(
            '$value',
            textAlign: TextAlign.end,
            style: TextStyle(
              color: value >= 70 ? _green : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonStats() {
    const stats = <({IconData icon, String label, String value})>[
      (icon: Icons.sports_soccer_rounded, label: 'Матчи', value: '0'),
      (icon: Icons.flag_rounded, label: 'Голы', value: '0'),
      (icon: Icons.assistant_rounded, label: 'Ассисты', value: '0'),
      (icon: Icons.star_rounded, label: 'Средняя оценка', value: '—'),
    ];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF174324)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            Row(
              children: [
                Icon(stats[i].icon, color: _label, size: 20),
                const SizedBox(width: 11),
                Expanded(child: Text(stats[i].label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                Text(stats[i].value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
              ],
            ),
            if (i != stats.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFF174324)),
              ),
          ],
        ],
      ),
    );
  }
}
