import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_season_simulator.dart';
import 'package:flutter_football/models/league_division_service.dart';
import 'package:flutter_football/services/app_strings.dart';

class LeagueTableScreen extends StatelessWidget {
  final Career career;

  const LeagueTableScreen({super.key, required this.career});

  static const Color green = Color(0xFF8BE07F);

  @override
  Widget build(BuildContext context) {
    final league = Clubs.leagueOf(career.player.club);
    final hasTwoDivisions =
        league != null && LeagueDivisionService.hasSecondDivision(league);

    if (!hasTwoDivisions) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(82, 81, 84, 82),
          foregroundColor: Colors.white,
          title: Text(
            AppStrings.leagueTable,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: _buildTable(career.leagueTable, 1, false),
      );
    }

    final divisions = career.leagueDivisions.isEmpty
        ? LeagueDivisionService.createInitialDivisions()
        : career.leagueDivisions;
    final playedRounds = career.leagueTable.isEmpty
        ? 0
        : career.leagueTable.first.played;
    final simulatedTables = LeagueDivisionService.simulateAllDivisions(
      divisions: divisions,
      season: career.season,
      roundsToSimulate: playedRounds,
    );
    final firstDivisionTable = career.currentLeagueDivision == 1
        ? career.leagueTable
        : simulatedTables[
                LeagueDivisionService.key(league, 1)] ??
            const [];
    final secondDivisionTable = career.currentLeagueDivision == 2
        ? career.leagueTable
        : simulatedTables[
                LeagueDivisionService.key(league, 2)] ??
            const [];

    return DefaultTabController(
      length: 2,
      initialIndex: career.currentLeagueDivision == 2 ? 1 : 0,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(82, 81, 84, 82),
          foregroundColor: Colors.white,
          title: Text(
            AppStrings.leagueTable,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          bottom: TabBar(
            indicatorColor: green,
            labelColor: green,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: AppStrings.isEnglish ? 'First Division' : 'Первая лига'),
              Tab(text: AppStrings.isEnglish ? 'Second Division' : 'Вторая лига'),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.20,
                child: Image.asset(
                  'assets/images/uclfon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: TabBarView(
                children: [
                  _buildTable(firstDivisionTable, 1, true),
                  _buildTable(secondDivisionTable, 2, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(
    List<dynamic> table,
    int division,
    bool hasTwoDivisions,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildQualificationLegend(division, hasTwoDivisions),
          const SizedBox(height: 8),
          _buildHeader(),
          const SizedBox(height: 8),
          ...List.generate(table.length, (index) {
            final entry = table[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildRow(
                index + 1,
                entry,
                division,
                table.length,
                hasTwoDivisions,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQualificationLegend(int division, bool hasTwoDivisions) {
    if (division == 2 && hasTwoDivisions) {
      return Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          _legendItem(const Color(0xFF42A5F5), 'Повышение'),
        ],
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        if (division == 1) ...[
          _legendItem(const Color(0xFF42A5F5), 'Лига чемпионов'),
          _legendItem(const Color(0xFFFFA726), 'Лига Европы'),
        ],
        if (hasTwoDivisions)
          _legendItem(const Color(0xFFFF7777), 'Вылет во второй дивизион'),
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

  Widget _buildRow(
    int position,
    dynamic entry,
    int division,
    int tableLength,
    bool hasTwoDivisions,
  ) {
    final isPlayerClub = entry.club == career.player.club;
    final difference = entry.goalDifference;
    final league = Clubs.leagueOf(career.player.club);
    final isSecondDivision = division == 2;
    final qualificationSlots = league == null || isSecondDivision
        ? 0
        : LeagueSeasonSimulator.qualificationSlots[league] ?? 0;

    final qualifiesForChampionsLeague =
        !isSecondDivision && position <= qualificationSlots;
    final europaSlots = league == null || isSecondDivision
        ? null
        : LeagueSeasonSimulator.europaLeagueSlots[league];
    final qualifiesForEuropaLeague =
        !qualifiesForChampionsLeague &&
        europaSlots != null &&
        position >= europaSlots.$1 &&
        position < europaSlots.$1 + europaSlots.$2;
    final movementPlaces = league == null
        ? 2
        : LeagueDivisionService.movementPlaces(league);
    final promotionPosition =
        hasTwoDivisions && isSecondDivision && position <= movementPlaces;
    final relegationPosition = hasTwoDivisions &&
        !isSecondDivision &&
        position > tableLength - movementPlaces;

    final qualificationColor =
        qualifiesForChampionsLeague || promotionPosition
        ? const Color(0xFF42A5F5)
        : qualifiesForEuropaLeague
        ? const Color(0xFFFFA726)
        : relegationPosition
        ? const Color(0xFFFF7777)
        : Colors.white70;
    final positionColor = isPlayerClub ? green : qualificationColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isPlayerClub
            ? const Color.fromARGB(184, 86, 81, 7)
            : qualifiesForChampionsLeague || promotionPosition
            ? const Color.fromARGB(205, 22, 59, 98)
            : qualifiesForEuropaLeague
            ? const Color.fromARGB(205, 112, 67, 18)
            : relegationPosition
            ? const Color.fromARGB(160, 100, 30, 30)
            : const Color.fromARGB(114, 86, 83, 83),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPlayerClub
              ? const Color(0xFF4F9F59)
              : qualifiesForChampionsLeague || promotionPosition
              ? const Color(0xFF42A5F5)
              : qualifiesForEuropaLeague
              ? const Color(0xFFFFA726)
              : relegationPosition
              ? const Color(0xFFFF7777)
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
