import 'package:flutter/material.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/super_league_career.dart';
import 'package:flutter_football/screens/super_league/super_league_season_screen.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuperLeagueCareerScreen extends StatefulWidget {
  final SuperLeagueCareer career;
  const SuperLeagueCareerScreen({super.key, required this.career});

  @override
  State<SuperLeagueCareerScreen> createState() =>
      _SuperLeagueCareerScreenState();
}

class _SuperLeagueCareerScreenState extends State<SuperLeagueCareerScreen> {
  late SuperLeagueCareer _career;

  @override
  void initState() {
    super.initState();
    _career = widget.career;
  }

  Player get player => _career.player;

  Future<void> _openSeason() async {
    final updated = await Navigator.push<SuperLeagueCareer>(
      context,
      MaterialPageRoute(
        builder: (_) => SuperLeagueSeasonScreen(career: _career),
      ),
    );
    if (!mounted || updated == null) return;
    setState(() => _career = updated);
  }

  static const Color _green = Color(0xFF8BE07F);
  static const Color _border = Color(0xFF14401E);
  static const Color _panel = Color(0x14FFFFFF);

  static const Map<String, String> _flagCodes = {
    'Россия': 'RU',
    'Бразилия': 'BR',
    'Германия': 'DE',
    'Франция': 'FR',
    'Испания': 'ES',
    'Англия': 'GB',
    'Италия': 'IT',
    'Нидерланды': 'NL',
    'Бельгия': 'BE',
    'Дания': 'DK',
    'Аргентина': 'AR',
    'Хорватия': 'HR',
    'Швейцария': 'CH',
    'Австрия': 'AT',
    'Норвегия': 'NO',
    'Польша': 'PL',
    'Турция': 'TR',
    'Украина': 'UA',
    'Греция': 'GR',
    'Шотландия': 'GB',
    'Ирландия': 'IE',
    'Колумбия': 'CO',
    'Чили': 'CL',
    'Уругвай': 'UY',
    'Канада': 'CA',
    'Мексика': 'MX',
    'США': 'US',
    'Иран': 'IR',
    'Южная Корея': 'KR',
    'Япония': 'JP',
    'Катар': 'QA',
    'Саудовская Аравия': 'SA',
    'Алжир': 'DZ',
    'Марокко': 'MA',
    'Камерун': 'CM',
    'Нигерия': 'NG',
    'Сенегал': 'SN',
    'Египет': 'EG',
    'Тунис': 'TN',
  };

  String _flagEmoji(String nationality) {
    if (nationality == 'Англия') {
      return '\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}';
    }
    if (nationality == 'Шотландия') {
      return '\u{1F3F4}\u{E0067}\u{E0062}\u{E0073}\u{E0063}\u{E0074}\u{E007F}';
    }
    final code = _flagCodes[nationality];
    if (code == null) return '🏳️';
    return String.fromCharCodes(code.codeUnits.map((c) => 0x1F1E6 + c - 0x41));
  }

  String get _position {
    switch (player.position) {
      case PlayerPosition.goalkeeper:
        return 'GK';
      case PlayerPosition.defender:
        return 'CB';
      case PlayerPosition.midfielder:
        return 'CM';
      case PlayerPosition.forward:
        return 'ST';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = ClubColors.primary(player.club);
    final secondary = ClubColors.secondary(player.club);
    return Scaffold(
      backgroundColor: const Color(0xFF061B0C),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(82, 81, 84, 82),
        foregroundColor: Colors.white,
        title: Text(
          AppStrings.superLeague,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
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
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              children: [
                _buildPlayerCard(primary, secondary),
                const SizedBox(height: 10),
                _buildClubCard(primary, secondary),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(125, 88, 85, 85),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.skillsUpper,
                        style: TextStyle(
                          color: _green,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._skillRows(),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openSeason,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BE07F),
                      foregroundColor: const Color(0xFF082A12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    label: Text(
                      AppStrings.seasonButton,
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

  Widget _buildPlayerCard(Color primary, Color secondary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(73, 255, 255, 255),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 206, 212, 208),
                      Color.fromARGB(255, 34, 35, 35),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFF3E9950), width: 2),
                ),
                child: SvgPicture.asset(
                  'assets/icons/player.svg',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          _flagEmoji(player.nationality),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            AppStrings.nationalityName(player.nationality),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _green, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 86, 91, 87),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color.fromARGB(255, 101, 103, 102),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12381B),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF3E9950),
                              ),
                            ),
                            child: Text(
                              _position,
                              style: const TextStyle(
                                color: Color(0xFF8BCF91),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppStrings.overallUpper,
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '${player.overall}',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 182, 247, 4),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(Color primary, Color secondary) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withValues(alpha: 0.45), const Color(0xFF0A2110)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [secondary, primary]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Text(
              player.club.isNotEmpty ? player.club[0].toUpperCase() : '?',
              style: TextStyle(
                color: secondary.computeLuminance() > 0.45
                    ? Colors.black
                    : Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.yourClubUpper,
                  style: TextStyle(
                    color: _green,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  player.club,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          _miniInfo(AppStrings.age.toUpperCase(), '${player.age}'),
          const SizedBox(width: 12),
          _miniInfo(
            AppStrings.seasonUpper(_career.season),
            '${_career.season}/10',
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(String label, String value) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          color: _green,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  List<Widget> _skillRows() {
    final stats = <({String name, int value, IconData icon, Color color})>[
      (
        name: AppStrings.pace,
        value: player.skills.pace,
        icon: Icons.bolt,
        color: Color(0xFFC8E04A),
      ),
      (
        name: AppStrings.physical,
        value: player.skills.physical,
        icon: Icons.fitness_center,
        color: Color(0xFFFFC94A),
      ),
      (
        name: AppStrings.passing,
        value: player.skills.passing,
        icon: Icons.adjust,
        color: Color(0xFF5FD070),
      ),
      (
        name: AppStrings.shooting,
        value: player.skills.shooting,
        icon: Icons.gps_fixed,
        color: Color(0xFFFF6B4A),
      ),
      (
        name: AppStrings.defending,
        value: player.skills.defending,
        icon: Icons.shield,
        color: Color(0xFF7EA7FF),
      ),
      (
        name: AppStrings.dribbling,
        value: player.skills.dribbling,
        icon: Icons.blur_circular,
        color: Color(0xFF4AA8FF),
      ),
      (
        name: AppStrings.heading,
        value: player.skills.heading,
        icon: Icons.sports_soccer,
        color: Color(0xFFFF9F43),
      ),
      (
        name: AppStrings.vision,
        value: player.skills.vision,
        icon: Icons.visibility,
        color: Color(0xFFB78BFA),
      ),
    ];
    return [
      for (var i = 0; i < stats.length; i++) ...[
        Row(
          children: [
            Icon(stats[i].icon, color: stats[i].color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stats[i].name,
                    style: const TextStyle(
                      color: Color(0xFFD5E8D8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: stats[i].value.clamp(0, 100) / 100,
                    ),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) => Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 61, 81, 66),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: t,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 155, 207, 10),
                                  Color.fromARGB(255, 204, 206, 206),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 32,
              child: Text(
                '${stats[i].value}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (i != stats.length - 1) const SizedBox(height: 14),
      ],
    ];
  }
}
