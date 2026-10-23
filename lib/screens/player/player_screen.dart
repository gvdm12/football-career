import 'package:flutter/material.dart';

import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/player_status.dart';
import 'package:flutter_football/screens/career_end_screen.dart';
// import 'package:flutter_football/screens/development_screen.dart';
import 'package:flutter_football/screens/home/home_screen.dart';
import 'package:flutter_football/screens/match/match_screen.dart';
import 'package:flutter_football/screens/news_screen.dart';
import 'package:flutter_football/screens/season/season_screen.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_svg/svg.dart';

class PlayerScreen extends StatefulWidget {
  final Career career;

  const PlayerScreen({super.key, required this.career});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late Career career;

  Player get player => career.player;

  PlayerStatus get playerStatus {
    return PlayerStatusCalculator.calculate(
      overall: player.overall,
      clubName: player.club,
    );
  }

  int get careerMatches =>
      career.history.fold(0, (sum, season) => sum + season.matches) +
      career.matches;

  int get careerGoals =>
      career.history.fold(0, (sum, season) => sum + season.goals) +
      career.goals;

  int get careerAssists =>
      career.history.fold(0, (sum, season) => sum + season.assists) +
      career.assists;

  int get careerYellowCards =>
      career.history.fold(0, (sum, season) => sum + season.yellowCards) +
      career.yellowCards;

  int get careerRedCards =>
      career.history.fold(0, (sum, season) => sum + season.redCards) +
      career.redCards;

  double? get careerAverageRating {
    var totalRating = 0.0;
    var totalMatches = 0;

    for (final season in career.history) {
      if (season.averageRating != null && season.matches > 0) {
        totalRating += season.averageRating! * season.matches;
        totalMatches += season.matches;
      }
    }

    if (career.averageRating != null && career.matches > 0) {
      totalRating += career.averageRating! * career.matches;
      totalMatches += career.matches;
    }

    return totalMatches == 0 ? null : totalRating / totalMatches;
  }

  @override
  void initState() {
    super.initState();
    career = widget.career;
  }

  void _openNews() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewsScreen(career: career)),
    );
  }

  // Future<void> _openDevelopment() async {
  //   final updatedCareer = await Navigator.push<Career>(
  //     context,
  //     MaterialPageRoute(builder: (_) => DevelopmentScreen(career: career)),
  //   );

  //   if (!mounted) return;

  //   if (updatedCareer != null) {
  //     setState(() {
  //       career = updatedCareer;
  //     });
  //   }
  // }

  Future<void> _openSeason() async {
    if (career.isCareerFinished) {
      return;
    }

    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(builder: (_) => SeasonScreen(career: career)),
    );

    if (!mounted) return;

    if (updatedCareer != null) {
      setState(() {
        career = updatedCareer;
      });
    }
  }

  Future<void> playMatch() async {
    final match = Match.generate(
      player: career.player,
      career: career,
      opponent: 'Спартак',
      isHome: true,
    );

    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MatchScreen(career: career, match: match, isCupMatch: true),
      ),
    );

    if (!mounted) return;

    if (updatedCareer != null) {
      setState(() {
        career = updatedCareer;
      });
    }
  }

  void _showCareerHistory() {
    final history = career.history;

    final totalMatches = history.fold<int>(
      0,
      (sum, stats) => sum + stats.matches,
    );

    final totalGoals = history.fold<int>(0, (sum, stats) => sum + stats.goals);

    final totalAssists = history.fold<int>(
      0,
      (sum, stats) => sum + stats.assists,
    );

    final totalClubs = history
        .map((stats) => stats.club)
        .where((club) => club != 'Без клуба')
        .toSet()
        .length;

    final bestSeason = history.isEmpty
        ? null
        : history.reduce((a, b) => a.goals >= b.goals ? a : b);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF04160A),
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF8BE07F),
                        ),
                        tooltip: AppStrings.back,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          AppStrings.careerHistory,
                          style: const TextStyle(
                            color: Color(0xFF8BE07F),
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2A12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF3E9950)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.careerStatistics,
                          style: const TextStyle(
                            color: Color(0xFF8BE07F),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _CareerHistoryStat(
                                label: AppStrings.matches,
                                value: '$totalMatches',
                              ),
                            ),
                            Expanded(
                              child: _CareerHistoryStat(
                                label: AppStrings.goalsLabel,
                                value: '$totalGoals',
                              ),
                            ),
                            Expanded(
                              child: _CareerHistoryStat(
                                label: AppStrings.assistsLabel,
                                value: '$totalAssists',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _CareerHistoryStat(
                                label: AppStrings.clubs,
                                value: '$totalClubs',
                              ),
                            ),
                            Expanded(
                              child: _CareerHistoryStat(
                                label: AppStrings.seasons,
                                value: '${history.length}',
                              ),
                            ),
                            Expanded(
                              child: _CareerHistoryStat(
                                label: AppStrings.bestSeason,
                                value: bestSeason == null
                                    ? '-'
                                    : AppStrings.goalsShort(bestSeason.goals),
                              ),
                            ),
                          ],
                        ),
                        if (bestSeason != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            '${AppStrings.seasonNumber(bestSeason.season)} · '
                            '${bestSeason.club}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    AppStrings.completedSeasons,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: history.isEmpty
                        ? Center(
                            child: Text(
                              AppStrings.noCompletedSeasons,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: history.length,
                            itemBuilder: (_, index) {
                              final stats = history[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0x14FFFFFF),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.seasonNumber(stats.season),
                                      style: const TextStyle(
                                        color: Color(0xFF8BE07F),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      stats.club,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _HistoryLine(
                                      label: AppStrings.matches,
                                      value: '${stats.matches}',
                                    ),
                                    _HistoryLine(
                                      label: AppStrings.goalsColon,
                                      value: '${stats.goals}',
                                    ),
                                    _HistoryLine(
                                      label: AppStrings.assistsColon,
                                      value: '${stats.assists}',
                                    ),
                                    _HistoryLine(
                                      label: AppStrings.yellowCardsColon,
                                      value: '${stats.yellowCards}',
                                    ),
                                    _HistoryLine(
                                      label: AppStrings.redCardsColon,
                                      value: '${stats.redCards}',
                                    ),
                                    _HistoryLine(
                                      label: AppStrings.averageRating,
                                      value:
                                          stats.averageRating?.toStringAsFixed(
                                            2,
                                          ) ??
                                          '-',
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppStrings.seasonAchievements,
                                      style: const TextStyle(
                                        color: Color(0xFF8BE07F),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (stats.achievements.isEmpty)
                                      Text(
                                        AppStrings.noAchievements,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                        ),
                                      )
                                    else
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: stats.achievements.map((
                                          achievement,
                                        ) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF14401E),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: const Color(0xFF3E9950),
                                              ),
                                            ),
                                            child: Text(
                                              achievement,
                                              style: const TextStyle(
                                                color: Color(0xFF8BE07F),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B3A1A), Color(0xFF082A12), Color(0xFF04160A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildPlayerCard(),
                const SizedBox(height: 10),
                _buildStatisticsCard(),
                const SizedBox(height: 10),
                _buildClubCard(),
                const SizedBox(height: 10),

                // const SizedBox(height: 10),

                // SizedBox(
                //   width: double.infinity,
                //   height: 55,
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       side: const BorderSide(
                //         color: Color.fromARGB(255, 255, 255, 255),
                //       ),
                //     ),
                //     onPressed: _openDevelopment,
                //     child: Text(
                //       AppStrings.development,
                //       style: const TextStyle(
                //         fontWeight: FontWeight.w900,
                //         color: Color.fromARGB(255, 255, 255, 255),
                //       ),
                //     ),
                //   ),
                // ),
                // История карьеры и новости в одной строке
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _showCareerHistory,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppStrings.careerHistory,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: _openNews,
                          icon: const Icon(
                            Icons.newspaper,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Flexible(
                            child: Text(
                              AppStrings.footballNews,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Сезон или итоги карьеры — ниже на всю ширину
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: career.isCareerFinished
                          ? const Color(0xFFB8860B)
                          : const Color.fromARGB(124, 77, 80, 78),
                      side: BorderSide(
                        color: career.isCareerFinished
                            ? const Color(0xFFFFD700)
                            : const Color.fromARGB(255, 255, 255, 255),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(14),
                      ),
                    ),
                    onPressed: career.isCareerFinished
                        ? _openCareerEnd
                        : _openSeason,
                    child: Text(
                      career.isCareerFinished
                          ? 'ИТОГИ КАРЬЕРЫ'
                          : AppStrings.seasonButton,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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

  void _openCareerEnd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CareerEndScreen(career: career)),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFF185526)),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Color(0xFF57A963),
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          AppStrings.myPlayer,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF14401E)),
      ),
      child: Column(
        children: [
          // Верхняя часть аватар слева информация справа
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(),

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
                            style: const TextStyle(
                              color: Color(0xFF8BE07F),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    _buildPositionRatingPill(),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Нижняя часть: статистика
          _buildStatRows(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
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
        width: 25,
        height: 25,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildPositionRatingPill() {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(102, 112, 119, 114),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color.fromARGB(255, 101, 103, 102)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF12381B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF3E9950)),
            ),
            child: Text(
              _positionName(player.position),
              style: const TextStyle(
                color: Color(0xFF8BCF91),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            AppStrings.ratingLabel,
            style: const TextStyle(
              color: Color.fromARGB(255, 253, 253, 253),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
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
    );
  }

  Widget _buildStatRows() {
    final stats = [
      _Stat(
        AppStrings.pace,
        player.skills.pace,
        Icons.bolt,
        const Color(0xFFC8E04A),
      ),
      _Stat(
        AppStrings.physical,
        player.skills.physical,
        Icons.fitness_center,
        const Color(0xFFFFC94A),
      ),
      _Stat(
        AppStrings.passing,
        player.skills.passing,
        Icons.adjust,
        const Color(0xFF5FD070),
      ),
      _Stat(
        AppStrings.shooting,
        player.skills.shooting,
        Icons.gps_fixed,
        const Color(0xFFFF6B4A),
      ),
      _Stat(
        AppStrings.defending,
        player.skills.defending,
        Icons.shield,
        const Color(0xFF7EA7FF),
      ),
      _Stat(
        AppStrings.dribbling,
        player.skills.dribbling,
        Icons.blur_circular,
        const Color(0xFF4AA8FF),
      ),
      _Stat(AppStrings.heading, player.skills.heading, Icons.sports_soccer, const Color(0xFFFF9F43)),
      _Stat(AppStrings.vision, player.skills.vision, Icons.visibility, const Color(0xFFB78BFA)),
    ];

    return Column(
      children: [
        for (int i = 0; i < stats.length; i++) ...[
          _StatRow(stat: stats[i]),
          if (i != stats.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF14401E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppStrings.careerStats,
            style: const TextStyle(
              color: Color(0xFF8BE07F),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CareerStat(
                  title: AppStrings.matchesUpper,
                  value: '$careerMatches',
                ),
              ),
              Expanded(
                child: _CareerStat(
                  title: AppStrings.goalsUpper,
                  value: '$careerGoals',
                ),
              ),
              Expanded(
                child: _CareerStat(
                  title: AppStrings.assistsUpper,
                  value: '$careerAssists',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _CareerStat(
                  title: AppStrings.averageUpper,
                  value: careerAverageRating == null
                      ? '—'
                      : careerAverageRating!.toStringAsFixed(1),
                ),
              ),
              Expanded(
                child: _CareerStat(
                  title: AppStrings.yellowUpper,
                  value: '$careerYellowCards',
                ),
              ),
              Expanded(
                child: _CareerStat(
                  title: AppStrings.redUpper,
                  value: '$careerRedCards',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF14401E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppStrings.careerAndFinances,
            style: const TextStyle(
              color: Color(0xFF8BE07F),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(title: AppStrings.club, value: player.club),
          _InfoRow(
            title: AppStrings.teamStatus,
            value: playerStatus.displayName,
          ),
          _InfoRow(
            title: AppStrings.clubStrength,
            value: () {
              final baseStrength = Clubs.getByName(player.club).strength;

              final effectiveStrength = Clubs.effectiveStrength(
                clubName: player.club,
                playerClub: player.club,
                playerOverall: player.overall,
              );

              final bonus = effectiveStrength - baseStrength;

              return bonus > 0 ? '$baseStrength (+$bonus)' : '$baseStrength';
            }(),
          ),
          _InfoRow(
            title: AppStrings.age,
            value: '${player.age} ${AppStrings.yearsOld}',
          ),
          _InfoRow(title: AppStrings.season, value: '${career.season}'),
          _InfoRow(
            title: AppStrings.contract,
            value: '${career.contractYears} ${AppStrings.years}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(color: Color(0xFF24552C)),
          ),
          _InfoRow(
            title: AppStrings.monthlySalary,
            value: '${_formatMoney(career.monthlySalary)} €',
          ),
          _InfoRow(
            title: AppStrings.savings,
            value: '${_formatMoney(career.money)} €',
          ),
        ],
      ),
    );
  }

  String _formatMoney(int amount) {
    final digits = amount.toString();
    final result = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        result.write(' ');
      }
      result.write(digits[i]);
    }

    return result.toString();
  }

  String _positionName(PlayerPosition position) {
    switch (position) {
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
}

class _CareerStat extends StatelessWidget {
  final String title;
  final String value;

  const _CareerStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Color.fromARGB(255, 23, 186, 50),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6FA87A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final _Stat stat;

  const _StatRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(stat.icon, color: stat.color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label,
                style: const TextStyle(
                  color: Color(0xFFD5E8D8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              _StatBar(value: stat.value),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 32,
          child: Text(
            '${stat.value}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatBar extends StatelessWidget {
  final int value;

  const _StatBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 100) / 100),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Container(
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFF123C1D),
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
                      Color.fromARGB(255, 204, 206, 87),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CareerHistoryStat extends StatelessWidget {
  final String label;
  final String value;

  const _CareerHistoryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}

class _HistoryLine extends StatelessWidget {
  final String label;
  final String value;

  const _HistoryLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class _Stat {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _Stat(this.label, this.value, this.icon, this.color);
}

const Map<String, String> _flagCodes = {
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

  if (code == null) {
    return '🏳️';
  }

  return String.fromCharCodes(code.codeUnits.map((c) => 0x1F1E6 + c - 0x41));
}
