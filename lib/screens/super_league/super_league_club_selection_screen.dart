import 'package:flutter/material.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/super_league_career.dart';
import 'package:flutter_football/models/super_league_division.dart';
import 'package:flutter_football/screens/super_league/super_league_create_player_screen.dart';
import 'package:flutter_football/screens/super_league/super_league_career_screen.dart';
import 'package:flutter_football/services/super_league_storage.dart';

class SuperLeagueClubSelectionScreen extends StatefulWidget {
  const SuperLeagueClubSelectionScreen({super.key});

  @override
  State<SuperLeagueClubSelectionScreen> createState() =>
      _SuperLeagueClubSelectionScreenState();
}

class _SuperLeagueClubSelectionScreenState
    extends State<SuperLeagueClubSelectionScreen> {
  static const Color _green = Color(0xFF22C55E);
  static const Color _background = Color(0xFF061B0C);

  SuperLeagueDivision _selectedDivision = SuperLeagueDivision.first;

  List<Club> get _clubs => SuperLeagueDivisionConfig
      .clubsFor(_selectedDivision)
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
        title: Text(
          AppStrings.superLeague,
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.20,
              child: Image.asset('assets/images/fon2.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.chooseClub,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text(
                      //   '20 клубов • 10 сезонов • стартовый рейтинг игрока 75',
                      //   style: TextStyle(
                      //     color: Colors.white.withValues(alpha: 0.65),
                      //     fontSize: 13,
                      //   ),
                      // ),
                      // const SizedBox(height: 14),
                      Row(
                        children: [
                          _infoChip('${_selectedDivision.clubCount} ${AppStrings.clubsUpper}'),
                          const SizedBox(width: 8),
                          _infoChip('10 ${AppStrings.seasonsUpper}'),
                          const SizedBox(width: 8),
                          _infoChip('${AppStrings.overallUpper} 75'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: SuperLeagueDivision.values.map((division) {
                          final selected = division == _selectedDivision;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: division == SuperLeagueDivision.first ? 8 : 0,
                              ),
                              child: OutlinedButton(
                                onPressed: () => setState(() {
                                  _selectedDivision = division;
                                  _selectedClubName = null;
                                }),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: selected
                                      ? const Color(0xFF16401E)
                                      : const Color(0xFF0A2110),
                                  foregroundColor: selected ? _green : Colors.white70,
                                  side: BorderSide(
                                    color: selected ? _green : const Color(0xFF14401E),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  division.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
                            : const Color.fromARGB(81, 255, 255, 255),
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
                                    ? const Color.fromARGB(255, 63, 217, 43)
                                    : const Color(0xFF14401E),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ClubColors.secondary(club.name),
                                        ClubColors.primary(club.name),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    club.name
                                        .split(' ')
                                        .map(
                                          (part) =>
                                              part.isNotEmpty ? part[0] : '',
                                        )
                                        .take(2)
                                        .join()
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color:
                                          ClubColors.secondary(
                                                club.name,
                                              ).computeLuminance() >
                                              0.45
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
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
                                final career = SuperLeagueCareer.newCareer(
                                  player,
                                );
                                await SuperLeagueStorage.saveCareer(career);
                                if (!mounted) return;
                                navigator.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SuperLeagueCareerScreen(career: career),
                                  ),
                                );
                              } catch (error) {
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppStrings.superLeagueSaveCareerError,
                                    ),
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
                      child: Text(
                        AppStrings.chooseClubButton,
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
        ],
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
