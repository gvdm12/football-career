import 'package:flutter/material.dart';

import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/services/app_strings.dart';

class MatchScreen extends StatelessWidget {
  final Career career;
  final Match match;

  final bool isCupMatch;

  const MatchScreen({
    super.key,
    required this.career,
    required this.match,
    required this.isCupMatch,
  });

  bool get isPlayerWin => match.isPlayerWin(career.player.club);

  bool get isPlayerDraw => match.isDraw;

  bool get isPlayerLoss => match.isPlayerLoss(career.player.club);

  String get resultText {
    if (isPlayerWin) return AppStrings.victory;
    if (isPlayerDraw) return AppStrings.draw;
    return AppStrings.defeat;
  }

  Color get resultColor {
    if (isPlayerWin) return const Color(0xFF8BE07F);
    if (isPlayerDraw) return const Color(0xFFFFD75A);
    return const Color(0xFFFF7777);
  }

  void _finishMatch(BuildContext context) {
    final updatedCareer = career.afterMatch(match);

    if (!context.mounted) return;

    Navigator.pop(context, updatedCareer);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF04160A),
        // appBar: AppBar(
        //   toolbarHeight: 40,
        //   backgroundColor: const Color.fromARGB(255, 8, 174, 61),
        //   foregroundColor: Colors.white,
        //   automaticallyImplyLeading: false,
        //   title: Text(
        //     AppStrings.matchTitle,
        //     style: const TextStyle(fontWeight: FontWeight.w900),
        //   ),
        // ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  resultText,
                  style: TextStyle(
                    color: resultColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                _buildScoreCard(),
                const SizedBox(height: 8),
                _buildPlayerStats(),
                const SizedBox(height: 8),
                _buildMatchInfo(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(213, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                      side: BorderSide(color: ClubColors.defaultPrimary),
                    ),
                    onPressed: () => _finishMatch(context),
                    child: Text(
                      AppStrings.finishMatch,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    final homePrimary = ClubColors.primary(match.homeTeam);
    final homeSecondary = ClubColors.secondary(match.homeTeam);
    final awayPrimary = ClubColors.primary(match.awayTeam);
    final awaySecondary = ClubColors.secondary(match.awayTeam);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 57, 57, 59),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF14401E)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTeam(
                  name: match.homeTeam,
                  primary: homePrimary,
                  secondary: homeSecondary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: _buildTeam(
                  name: match.awayTeam,
                  primary: awayPrimary,
                  secondary: awaySecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${match.homeGoals} : ${match.awayGoals}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (match.hasPenalties) ...[
            const SizedBox(height: 6),
            Text(
              '${AppStrings.penaltiesShort} ${match.homePenalties} : ${match.awayPenalties}',
              style: const TextStyle(
                color: Color(0xFF8BE07F),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeam({
    required String name,
    required Color primary,
    required Color secondary,
  }) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: _readableTextColor(primary),
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Color _readableTextColor(Color color) {
    return color.computeLuminance() > 0.45 ? Colors.black : Colors.white;
  }

  Widget _buildPlayerStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 49, 49, 51),
            Color.fromARGB(255, 90, 89, 95),
            Color.fromARGB(189, 104, 104, 115),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF14401E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppStrings.playerStatistics,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 1),
          _StatRow(
            title: AppStrings.rating,
            value: match.playerRating.toStringAsFixed(1),
          ),
          _StatRow(title: AppStrings.goals, value: '${match.playerGoals}'),
          _StatRow(title: AppStrings.assists, value: '${match.playerAssists}'),
          _StatRow(
            title: AppStrings.yellowCards,
            value: '${match.yellowCards}',
          ),
          _StatRow(title: AppStrings.redCards, value: '${match.redCards}'),
        ],
      ),
    );
  }

  Widget _buildMatchInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 57, 57, 59),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF14401E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppStrings.afterMatch,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 1),
          _StatRow(
            title: AppStrings.totalMatches,
            value: '${career.matches + 1}',
          ),
          _StatRow(
            title: AppStrings.totalGoals,
            value: '${career.goals + match.playerGoals}',
          ),
          _StatRow(
            title: AppStrings.totalAssists,
            value: '${career.assists + match.playerAssists}',
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String title;
  final String value;

  const _StatRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
