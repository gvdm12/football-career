import 'package:flutter/material.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/super_league_career.dart';

class SuperLeagueCalendarScreen extends StatelessWidget {
  final SuperLeagueCareer career;

  const SuperLeagueCalendarScreen({super.key, required this.career});

  static const Color _bg = Color(0xFF061B0C);
  static const Color _green = Color(0xFF8BE07F);

  @override
  Widget build(BuildContext context) {
    final fixtures = career.fixtures
        .where((fixture) =>
            fixture.homeTeam == career.player.club ||
            fixture.awayTeam == career.player.club)
        .toList()
      ..sort((a, b) => a.round.compareTo(b.round));
    final played = fixtures.where((fixture) => fixture.isPlayed).length;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: Text(AppStrings.calendarTitle,
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/images/fon2.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B2813),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF24552C)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.seasonUpper(career.season),
                          style: const TextStyle(color: _green, fontSize: 12,
                              fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Text(career.player.club,
                          style: const TextStyle(color: Colors.white, fontSize: 20,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: fixtures.isEmpty ? 0 : played / fixtures.length,
                                minHeight: 7,
                                backgroundColor: const Color(0xFF12381B),
                                valueColor: const AlwaysStoppedAnimation<Color>(_green),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('$played / ${fixtures.length}',
                              style: const TextStyle(color: Colors.white70,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...fixtures.map((fixture) {
                  final isHome = fixture.homeTeam == career.player.club;
                  final opponent = isHome ? fixture.awayTeam : fixture.homeTeam;
                  final primary = ClubColors.primary(opponent);
                  final score = fixture.isPlayed
                      ? '${fixture.homeGoals} : ${fixture.awayGoals}'
                      : '— : —';
                  final won = fixture.isPlayed &&
                      ((isHome && fixture.homeGoals! > fixture.awayGoals!) ||
                       (!isHome && fixture.awayGoals! > fixture.homeGoals!));
                  final drawn = fixture.isPlayed &&
                      fixture.homeGoals == fixture.awayGoals;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color.lerp(const Color(0xFF0A2110), primary, 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(color: primary, width: 4),
                        top: BorderSide(color: const Color(0xFF24552C).withValues(alpha: 0.6)),
                        right: BorderSide(color: const Color(0xFF24552C).withValues(alpha: 0.6)),
                        bottom: BorderSide(color: const Color(0xFF24552C).withValues(alpha: 0.6)),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 34,
                          child: Text('${fixture.round}',
                              style: const TextStyle(color: Colors.white54,
                                  fontSize: 12, fontWeight: FontWeight.w800)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isHome ? AppStrings.homeMatchUpper : AppStrings.awayMatchUpper,
                                  style: const TextStyle(color: _green, fontSize: 9,
                                      fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                              const SizedBox(height: 4),
                              Text(isHome
                                  ? '${career.player.club} — $opponent'
                                  : '$opponent — ${career.player.club}',
                                  style: TextStyle(
                                    color: fixture.isPlayed ? Colors.white70 : Colors.white,
                                    fontSize: 12,
                                    fontWeight: fixture.isPlayed ? FontWeight.w500 : FontWeight.w800,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(score, style: TextStyle(
                              color: !fixture.isPlayed ? Colors.white54 :
                                  won ? _green : drawn ? Colors.white : const Color(0xFFFF9B9B),
                              fontSize: 14, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 3),
                            Text(fixture.isPlayed ? AppStrings.playedStatus : AppStrings.pendingStatus,
                                style: const TextStyle(color: Colors.white38,
                                    fontSize: 8, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
