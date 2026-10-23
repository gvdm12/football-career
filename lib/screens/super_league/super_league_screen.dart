import 'package:flutter/material.dart';
import 'package:flutter_football/screens/super_league/super_league_club_selection_screen.dart';

class SuperLeagueScreen extends StatelessWidget {
  const SuperLeagueScreen({super.key});

  static const Color _green = Color(0xFF22C55E);
  static const Color _background = Color(0xFF061B0C);

  void _startNewGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SuperLeagueClubSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: const Text(
          'СУПЕРЛИГА',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF164A25), Color(0xFF0B2813)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF28683A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: _green,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ТВОЯ ДОРОГА К ВЕРШИНЕ',
                    style: TextStyle(
                      color: Color(0xFF8BE07F),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Суперлига',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Выбери один из 20 топ-клубов, создай футболиста '
                    'с рейтингом 75 и постарайся привести свою команду '
                    'к чемпионству. Тебя ждут 10 сезонов борьбы за титулы.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(
                        child: _ModeStat(
                          icon: Icons.groups_rounded,
                          value: '20',
                          label: 'КЛУБОВ',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _ModeStat(
                          icon: Icons.calendar_month_rounded,
                          value: '10',
                          label: 'СЕЗОНОВ',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _ModeStat(
                          icon: Icons.trending_up_rounded,
                          value: '75',
                          label: 'РЕЙТИНГ',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 58,
              child: ElevatedButton.icon(
                onPressed: () => _startNewGame(context),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text(
                  'НОВАЯ ИГРА',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 58,
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: const Text(
                  'ПРОДОЛЖИТЬ',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  disabledForegroundColor: Colors.white38,
                  side: const BorderSide(color: Color(0xFF285135)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Продолжение станет доступно, когда будет подключено '
              'сохранение карьеры Суперлиги.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ModeStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF08200F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF245431)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF8BE07F), size: 18),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
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
