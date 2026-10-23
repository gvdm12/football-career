import 'package:flutter/material.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/super_league_career.dart';
import 'package:flutter_football/screens/super_league/super_league_create_player_screen.dart';
import 'package:flutter_football/screens/super_league/super_league_career_screen.dart';
import 'package:flutter_football/services/super_league_storage.dart';

class SuperLeagueClubSelectionScreen extends StatefulWidget {
  const SuperLeagueClubSelectionScreen({super.key});

  @override
  State<SuperLeagueClubSelectionScreen> createState() => _SuperLeagueClubSelectionScreenState();
}

class _SuperLeagueClubSelectionScreenState extends State<SuperLeagueClubSelectionScreen> {
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
        backgroundColor: const Color.fromARGB(82, 81, 84, 82),
        foregroundColor: Colors.white,
        title: const Text(
          'СУПЕРЛИГА',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
      ),
      body: Stack(children: [
        Positioned.fill(child: Opacity(opacity: 0.20,
          child: Image.asset('assets/images/fon2.png', fit: BoxFit.cover))),
        SafeArea(child: Column(
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
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final club = _clubs[index];
                  final selected = club.name == _selectedClubName;

                  return Material(
                    color: selected
                        ? const Color(0xFF16401E)
                        : const Color(0x14FFFFFF),
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
                            color: selected ? const Color(0xFF8BE07F) : const Color(0xFF14401E),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  ClubColors.secondary(club.name),
                                  ClubColors.primary(club.name),
                                ]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                club.name
                                    .split(' ')
                                    .map(
                                      (part) => part.isNotEmpty ? part[0] : '',
                                    )
                                    .take(2)
                                    .join()
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: ClubColors.secondary(club.name).computeLuminance() > 0.45 ? Colors.black : Colors.white,
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
                                      color: Colors.white.withValues(
                                        alpha: 0.58,
                                      ),
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

                          try {
                            final career = SuperLeagueCareer.newCareer(player);
                            await SuperLeagueStorage.saveCareer(career);
                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SuperLeagueCareerScreen(career: career),
                              ),
                            );
                          } catch (error) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Не удалось сохранить карьеру Суперлиги.'),
                              ),
                            );
                          }
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
        )),
      ]),
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
