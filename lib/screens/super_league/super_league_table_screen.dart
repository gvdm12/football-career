import 'package:flutter/material.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/super_league_career.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuperLeagueTableScreen extends StatelessWidget {
  final SuperLeagueCareer career;
  const SuperLeagueTableScreen({super.key, required this.career});

  static const Color green = Color(0xFF8BE07F);

  @override
  Widget build(BuildContext context) {
    final standings = career.standings;
    return Scaffold(
      backgroundColor: const Color(0xFF061B0C),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(82, 81, 84, 82),
        foregroundColor: Colors.white,
        title: const Text(
          AppStrings.superLeagueTableTitle,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.20,
              child: Image.asset('assets/images/uclfon.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0B3A1A),
                          Color(0xFF082A12),
                          Color(0xFF04160A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF14401E)),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/table.svg',
                          width: 38,
                          height: 38,
                          color: green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.seasonOfTen(career.season),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildHeader(),
                  const SizedBox(height: 8),
                  ...List.generate(
                    standings.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildRow(index + 1, standings[index]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 215, 219, 6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF14401E)),
    ),
    child: const Row(
      children: [
        SizedBox(
          width: 25,
          child: Text(
            '#',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          ),
        ),
        Expanded(
          child: Text(
            AppStrings.clubColumn,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          ),
        ),
        SizedBox(
          width: 30,
          child: Text(
            AppStrings.playedColumn,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          ),
        ),
        SizedBox(
          width: 55,
          child: Text(
            AppStrings.goalDifferenceColumn,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            AppStrings.pointsColumn,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );

  Widget _buildRow(int position, SuperLeagueStanding entry) {
    final isPlayerClub = entry.club == career.player.club;
    final difference = entry.goalDifference;
    final primary = ClubColors.primary(entry.club);
    final secondary = ClubColors.secondary(entry.club);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isPlayerClub ? const Color(0xB414401E) : const Color(0x72665353),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPlayerClub
              ? const Color(0xFF4F9F59)
              : const Color(0xFF14401E),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 25,
            child: Text(
              '$position',
              style: TextStyle(
                color: isPlayerClub ? green : Colors.white70,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [secondary, primary]),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    entry.club.isNotEmpty ? entry.club[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: secondary.computeLuminance() > 0.45
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.club,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isPlayerClub
                          ? FontWeight.w900
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${entry.played}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 55,
            child: Text(
              difference >= 0 ? '+$difference' : '$difference',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: difference >= 0 ? green : const Color(0xFFFF7777),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${entry.points}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
