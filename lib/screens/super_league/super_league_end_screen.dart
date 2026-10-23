import 'package:flutter/material.dart';
import 'package:flutter_football/models/super_league_career.dart';

class SuperLeagueEndScreen extends StatelessWidget {
  final SuperLeagueCareer career;

  const SuperLeagueEndScreen({super.key, required this.career});

  int get totalMatches =>
      career.history.fold(0, (sum, item) => sum + item.matches);
  int get totalGoals => career.history.fold(0, (sum, item) => sum + item.goals);
  int get totalAssists =>
      career.history.fold(0, (sum, item) => sum + item.assists);
  int get titles => career.history.where((item) => item.champion).length;

  double get averageRating {
    final matches = career.history.fold<int>(
      0,
      (sum, item) => sum + item.matches,
    );
    if (matches == 0) return 0;
    return career.history.fold<double>(
          0,
          (sum, item) => sum + item.averageRating * item.matches,
        ) /
        matches;
  }

  @override
  Widget build(BuildContext context) {
    final clubs = <String>[];
    for (final item in career.history) {
      if (!clubs.contains(item.club)) clubs.add(item.club);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF061B0C),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: const Text(
          'ИТОГИ КАРЬЕРЫ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 205, 246, 2),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.20,
              child: Image.asset(
                'assets/images/careerend.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 60,
                  color: Color(0xFFFFC857),
                ),
                const SizedBox(height: 12),
                const Text(
                  'КАРЬЕРА СУПЕРЛИГИ ЗАВЕРШЕНА!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${career.player.name} прошёл все 10 сезонов',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _section('ОБЩАЯ СТАТИСТИКА', [
                  _stat('Сыграно матчей', '$totalMatches'),
                  _stat('Забито голов', '$totalGoals'),
                  _stat('Голевых передач', '$totalAssists'),
                  _stat(
                    'Средняя оценка',
                    averageRating == 0 ? '—' : averageRating.toStringAsFixed(2),
                  ),
                ]),
                const SizedBox(height: 8),
                _section('🏆 ТРОФЕИ СУПЕРЛИГИ', [
                  _stat('Всего чемпионских титулов', '$titles'),
                ]),
                const SizedBox(height: 8),
                _section('КЛУБЫ ЗА КАРЬЕРУ', [
                  if (clubs.isEmpty) _stat('Клуб', career.player.club),
                  ...clubs.asMap().entries.map(
                    (entry) => _stat('Клуб ${entry.key + 1}', entry.value),
                  ),
                ]),
                const SizedBox(height: 8),
                _section('ИСТОРИЯ СЕЗОНОВ', [
                  ...career.history.reversed.map(
                    (item) => _stat(
                      'Сезон ${item.season} • ${item.club}${item.champion ? ' 🏆' : ''}',
                      '${item.matches} матч.  •  ${item.goals} гол.  •  ${item.assists} асс.',
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, career),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BE07F),
                      foregroundColor: const Color(0xFF082A12),
                    ),
                    child: const Text(
                      'ВЕРНУТЬСЯ',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color.fromARGB(175, 72, 73, 72),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF24552C)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    ),
  );

  Widget _stat(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white70)),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
