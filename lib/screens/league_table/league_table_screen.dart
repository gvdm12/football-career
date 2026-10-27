import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_season_simulator.dart';
import 'package:flutter_football/services/app_strings.dart';

class LeagueTableScreen extends StatelessWidget {
  final Career career;

  const LeagueTableScreen({super.key, required this.career});

  static const Color green = Color(0xFF8BE07F);

  @override
  Widget build(BuildContext context) {
    final table = career.leagueTable;
    int getChampionsLeagueSlots(League league) {
      return LeagueSeasonSimulator.qualificationSlots[league] ?? 0;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(82, 81, 84, 82),
        foregroundColor: Colors.white,
        title: Text(
          AppStrings.leagueTable,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Stack(
        children: [
          // Фоновая фотография
          Positioned.fill(
            child: Opacity(
              opacity: 0.20, // Прозрачность фото: от 0.0 до 1.0
              child: Image.asset('assets/images/uclfon.png', fit: BoxFit.cover),
            ),
          ),

          // Таблица поверх фотографии
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  _buildQualificationLegend(),
                  const SizedBox(height: 8),
                  _buildHeader(),
                  const SizedBox(height: 8),
                  ...List.generate(table.length, (index) {
                    final entry = table[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildRow(index + 1, entry),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualificationLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _legendItem(const Color(0xFF42A5F5), 'Лига чемпионов'),
        _legendItem(const Color(0xFFFFA726), 'Лига Европы'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 215, 219, 6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF14401E)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 25,
            child: Text(
              '#',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              AppStrings.team,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              AppStrings.playedShort,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 55,
            child: Text(
              AppStrings.goalDifferenceShort,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              AppStrings.pointsShort,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(int position, dynamic entry) {
    final isPlayerClub = entry.club == career.player.club;
    final difference = entry.goalDifference;

    final league = Clubs.leagueOf(career.player.club);
    final qualificationSlots = league == null
        ? 0
        : LeagueSeasonSimulator.qualificationSlots[league] ?? 0;

    final qualifiesForChampionsLeague = position <= qualificationSlots;
    final europaSlots = league == null
        ? null
        : LeagueSeasonSimulator.europaLeagueSlots[league];
    final qualifiesForEuropaLeague =
        !qualifiesForChampionsLeague &&
        europaSlots != null &&
        position >= europaSlots.$1 &&
        position < europaSlots.$1 + europaSlots.$2;

    final qualificationColor = qualifiesForChampionsLeague
        ? const Color(0xFF42A5F5)
        : qualifiesForEuropaLeague
        ? const Color(0xFFFFA726)
        : Colors.white70;

    final positionColor = isPlayerClub ? green : qualificationColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isPlayerClub
            ? const Color.fromARGB(184, 86, 81, 7)
            : qualifiesForChampionsLeague
            ? const Color.fromARGB(205, 22, 59, 98)
            : qualifiesForEuropaLeague
            ? const Color.fromARGB(205, 112, 67, 18)
            : const Color.fromARGB(114, 86, 83, 83),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPlayerClub
              ? const Color(0xFF4F9F59)
              : qualifiesForChampionsLeague
              ? const Color(0xFF42A5F5)
              : qualifiesForEuropaLeague
              ? const Color(0xFFFFA726)
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
                color: positionColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              entry.club,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isPlayerClub ? FontWeight.w900 : FontWeight.w600,
              ),
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
