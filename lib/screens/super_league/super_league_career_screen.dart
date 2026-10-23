import 'package:flutter/material.dart';
import 'package:flutter_football/models/player.dart';

class SuperLeagueCareerScreen extends StatelessWidget {
  final Player player;

  const SuperLeagueCareerScreen({super.key, required this.player});

  static const Color _green = Color(0xFF22C55E);

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
      backgroundColor: const Color(0xFF061B0C),
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
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF164A25), Color(0xFF0B2813)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF28683A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ТВОЙ ФУТБОЛИСТ',
                    style: TextStyle(
                      color: Color(0xFF8BE07F),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: _green,
                          size: 38,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              player.club,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$_position • ${player.nationality}',
                              style: const TextStyle(
                                color: Color(0xFF9DE5A9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${player.overall}',
                            style: const TextStyle(
                              color: _green,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'РЕЙТИНГ',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _StatCard(value: '${player.age}', label: 'ВОЗРАСТ')),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(value: '${player.season}', label: 'СЕЗОН')),
                const SizedBox(width: 10),
                const Expanded(child: _StatCard(value: '0', label: 'МАТЧИ')),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0B2813),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF174324)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Карьера создана и сохранена',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Данные футболиста сохраняются отдельно от обычной карьеры. '
                    'Календарь матчей и игровой сезон Суперлиги подключим следующим этапом.',
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                      fontSize: 13,
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
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2813),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF174324)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9DE5A9),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
