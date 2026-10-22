import 'package:flutter/material.dart';

import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/screens/create%20player/create_player_screen.dart';
import 'package:flutter_football/screens/player/player_screen.dart';
import 'package:flutter_football/screens/super_league/super_league_screen.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/career_storage.dart';
import 'package:flutter_football/settings/settings_screen.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color green = Color(0xFF22C55E);

  bool _hasSavedCareer = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSavedCareer();
  }

  Future<void> _checkSavedCareer() async {
    try {
      final hasSave = await CareerStorage.hasSavedCareer();

      if (!mounted) return;

      setState(() {
        _hasSavedCareer = hasSave;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasSavedCareer = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewCareer() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePlayerScreen()),
    );

    if (!mounted) return;

    await _checkSavedCareer();
  }

  Future<void> _continueCareer() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Career? career = await CareerStorage.load();

      if (!mounted) return;

      if (career == null) {
        setState(() {
          _hasSavedCareer = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppStrings.noSavedCareer)));

        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlayerScreen(career: career)),
      );

      if (!mounted) return;

      await _checkSavedCareer();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.loadCareerError('$e'))));
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 34, 138, 68),
              Color.fromARGB(216, 27, 93, 37),
              Color.fromARGB(56, 33, 62, 38),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _openSettings,
                    icon: SvgPicture.asset(
                      'assets/icons/settings.svg',
                      width: 38,
                      height: 38,
                      fit: BoxFit.contain,
                    ),
                    tooltip: AppStrings.settingsTooltip,
                  ),
                ),

                const Spacer(),

                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: green.withValues(alpha: 0.10),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        109,
                        109,
                        109,
                      ).withValues(alpha: 0.55),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/iconic.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'FOOTBALL',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: Color.fromARGB(255, 28, 255, 111),
                  ),
                ),

                const Text(
                  'Journey',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 7,
                    color: green,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  AppStrings.startCareer,
                  style: TextStyle(
                    color: const Color.fromARGB(
                      255,
                      251,
                      251,
                      251,
                    ).withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _createNewCareer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppStrings.newCareer,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading || !_hasSavedCareer
                        ? null
                        : _continueCareer,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white.withValues(
                        alpha: 0.30,
                      ),
                      side: BorderSide(
                        color: _hasSavedCareer
                            ? green.withValues(alpha: 0.65)
                            : Colors.white.withValues(alpha: 0.18),
                      ),
                      backgroundColor: const Color.fromARGB(136, 68, 122, 77),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 7),
                          )
                        : Text(
                            AppStrings.continueCareer,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SuperLeagueScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.emoji_events_outlined),
                    label: const Text(
                      'СУПЕРЛИГА',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: green.withValues(alpha: 0.8)),
                      backgroundColor: const Color(0xFF10351B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                Text(
                  'Football Journey • 1.0',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
