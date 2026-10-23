import 'package:flutter/material.dart';
import 'package:flutter_football/models/super_league_career.dart';
import 'package:flutter_football/screens/super_league/super_league_career_screen.dart';
import 'package:flutter_football/screens/super_league/super_league_club_selection_screen.dart';
import 'package:flutter_football/services/super_league_storage.dart';

class SuperLeagueScreen extends StatefulWidget {
  const SuperLeagueScreen({super.key});

  @override
  State<SuperLeagueScreen> createState() => _SuperLeagueScreenState();
}

class _SuperLeagueScreenState extends State<SuperLeagueScreen> {
  static const Color _green = Color(0xFF22C55E);
  static const Color _background = Color(0xFF061B0C);

  bool _isCheckingSave = true;
  bool _hasSavedCareer = false;
  bool _isOpeningCareer = false;

  @override
  void initState() {
    super.initState();
    _checkSavedCareer();
  }

  Future<void> _checkSavedCareer() async {
    try {
      final hasSave = await SuperLeagueStorage.hasSavedCareer();
      if (!mounted) return;
      setState(() {
        _hasSavedCareer = hasSave;
        _isCheckingSave = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasSavedCareer = false;
        _isCheckingSave = false;
      });
    }
  }

  void _startNewGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SuperLeagueClubSelectionScreen()),
    ).then((_) => _checkSavedCareer());
  }

  Future<void> _continueCareer() async {
    if (_isOpeningCareer || !_hasSavedCareer) return;

    setState(() => _isOpeningCareer = true);
    try {
      final career = await SuperLeagueStorage.loadCareer();
      if (!mounted) return;

      if (career == null) {
        setState(() {
          _hasSavedCareer = false;
          _isOpeningCareer = false;
        });
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SuperLeagueCareerScreen(career: career),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.superLeagueSaveError),
        ),
      );
    } finally {
      if (mounted) setState(() => _isOpeningCareer = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(82, 81, 84, 82),
        foregroundColor: Colors.white,
        title: const Text(
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
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0B3A1A),
                        Color(0xFF082A12),
                        Color(0xFF04160A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF14401E)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Image.asset(
                          'assets/icons/cup.png',
                          width: 34,
                          height: 34,
                          fit: BoxFit.contain,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // const Text(
                      //   'ТВОЯ ДОРОГА К ВЕРШИНЕ',
                      //   style: TextStyle(
                      //     color: Color(0xFF8BE07F),
                      //     fontSize: 11,
                      //     fontWeight: FontWeight.w900,
                      //     letterSpacing: 1.5,
                      //   ),
                      // ),
                      // const SizedBox(height: 8),
                      Text(
                        AppStrings.superLeagueName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.superLeagueDescription,
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
                            child: _ModeStat(value: '20', label: AppStrings.clubsUpper),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _ModeStat(value: '10', label: AppStrings.seasonsUpper),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _ModeStat(value: '75', label: AppStrings.overallUpper),
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
                    onPressed: _startNewGame,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text(
                      AppStrings.newGame,
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
                    onPressed:
                        _isCheckingSave || !_hasSavedCareer || _isOpeningCareer
                        ? null
                        : _continueCareer,
                    icon: _isOpeningCareer
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          )
                        : const Icon(Icons.play_circle_outline_rounded),
                    label: Text(
                      _isCheckingSave
                          ? AppStrings.checkingSave
                          : _hasSavedCareer
                          ? 'ПРОДОЛЖИТЬ'
                          : AppStrings.noSave,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      disabledForegroundColor: const Color.fromARGB(
                        250,
                        255,
                        255,
                        255,
                      ),
                      backgroundColor: const Color.fromARGB(187, 85, 82, 82),
                      side: const BorderSide(color: Color(0xFF285135)),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Text(
                //   _hasSavedCareer
                //       ? 'Найдено сохранение Суперлиги.'
                //       : 'Создай игрока, чтобы начать карьеру. '
                //             'После сохранения здесь появится возможность продолжить.',
                //   textAlign: TextAlign.center,
                //   style: const TextStyle(
                //     color: Colors.white54,
                //     fontSize: 12,
                //     height: 1.4,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeStat extends StatelessWidget {
  final String value;
  final String label;

  const _ModeStat({required this.value, required this.label});

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
