import 'package:flutter/material.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/screens/super_league/super_league_create_player_screen.dart';

class SuperLeagueScreen extends StatefulWidget {
  const SuperLeagueScreen({super.key});

  @override
  State<SuperLeagueScreen> createState() => _SuperLeagueScreenState();
}

class _SuperLeagueScreenState extends State<SuperLeagueScreen> {
  static const Color _green = Color(0xFF22C55E);
  static const Color _background = Color(0xFF061B0C);

  static const List<String> _clubNames = [
    'Barcelona',
    'Real Madrid',
    'Atletico Madrid',
    'Inter',
    'Napoli',
    'AC Milan',
    'Juventus',
    'Roma',
    'Liverpool',
    'Manchester City',
    'Arsenal',
    'Chelsea',
    'Manchester United',
    'Tottenham',
    'Bayern Munich',
    'Bayer Leverkusen',
    'Borussia Dortmund',
    'PSG',
    'Monaco',
    'Marseille',
  ];

  late final List<Club> _clubs = _clubNames
      .map(Clubs.getByName)
      .toList(growable: false);

  String? _selectedClubName;

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Выбери свой клуб',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '20 клубов • 10 сезонов • стартовый рейтинг игрока 75',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _infoChip('20 КЛУБОВ'),
                      const SizedBox(width: 8),
                      _infoChip('10 СЕЗОНОВ'),
                      const SizedBox(width: 8),
                      _infoChip('РЕЙТИНГ 75'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: _clubs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final club = _clubs[index];
                  final selected = club.name == _selectedClubName;

                  return Material(
                    color: selected
                        ? const Color(0xFF164526)
                        : const Color(0xFF0B2813),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() => _selectedClubName = club.name);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? _green
                                : const Color(0xFF174324),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: club.primaryColor.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                club.name
                                    .split(' ')
                                    .map((part) => part.isNotEmpty ? part[0] : '')
                                    .take(2)
                                    .join()
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    club.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    club.league.countryName,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.58),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${club.strength}',
                              style: const TextStyle(
                                color: _green,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              selected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: selected ? _green : Colors.white30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _selectedClubName == null
                      ? null
                      : () async {
                          final club = Clubs.getByName(_selectedClubName!);
                          final player = await Navigator.push<Player>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SuperLeagueCreatePlayerScreen(club: club),
                            ),
                          );

                          if (!mounted || player == null) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Игрок ${player.name} создан для ${player.club}. '
                                'Следующим шагом подключим карьеру Суперлиги.',
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    disabledBackgroundColor: const Color(0xFF18311E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'ВЫБРАТЬ КЛУБ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF10351B),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFF1D4D2A)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9DE5A9),
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
