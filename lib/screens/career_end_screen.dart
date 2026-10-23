import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/season_stats.dart';
import 'package:flutter_football/services/app_strings.dart';

class CareerEndScreen extends StatelessWidget {
  final Career career;

  const CareerEndScreen({super.key, required this.career});

  int get totalMatches =>
      career.history.fold(0, (sum, item) => sum + item.matches);

  int get totalGoals => career.history.fold(0, (sum, item) => sum + item.goals);

  int get totalAssists =>
      career.history.fold(0, (sum, item) => sum + item.assists);

  int get totalYellowCards =>
      career.history.fold(0, (sum, item) => sum + item.yellowCards);

  int get totalRedCards =>
      career.history.fold(0, (sum, item) => sum + item.redCards);

  int get leagueTitles => career.history.fold(
    0,
    (sum, item) =>
        sum + item.achievements.where((a) => a == 'Чемпион страны').length,
  );

  int get nationalCups => career.history.fold(
    0,
    (sum, item) =>
        sum +
        item.achievements.where((a) => a == 'Обладатель кубка страны').length,
  );

  int get championsLeagueTitles => career.history.fold(
    0,
    (sum, item) =>
        sum +
        item.achievements.where((a) => a == 'Победитель Лиги чемпионов').length,
  );

  int get goldenBoots => career.history.fold(
    0,
    (sum, item) =>
        sum + item.achievements.where((a) => a == 'Золотая бутса').length,
  );

  int get totalTrophies => leagueTitles + nationalCups + championsLeagueTitles;

  double? get careerAverageRating {
    var ratingSum = 0.0;
    var ratedMatches = 0;

    for (final SeasonStats item in career.history) {
      if (item.averageRating != null && item.matches > 0) {
        ratingSum += item.averageRating! * item.matches;
        ratedMatches += item.matches;
      }
    }

    if (ratedMatches == 0) return null;
    return ratingSum / ratedMatches;
  }

  @override
  Widget build(BuildContext context) {
    final clubs = <String>[];

    for (final item in career.history) {
      if (!clubs.contains(item.club)) {
        clubs.add(item.club);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF061B0C),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: Text(AppStrings.careerEndTitle),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.20,
              child: Image.asset(
                'assets/images/careerend.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 70,
                  color: Color.fromARGB(255, 243, 118, 2),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.careerFinished,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 254, 254, 254),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.careerFinishedDescription(
                    career.player.name,
                    career.history.length,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                _section(AppStrings.overallStatistics, [
                  _stat(AppStrings.matches, totalMatches.toString()),
                  _stat(AppStrings.goalsLabel, totalGoals.toString()),
                  _stat(AppStrings.assistsLabel, totalAssists.toString()),
                  _stat(
                    AppStrings.yellowCardsLabel,
                    totalYellowCards.toString(),
                  ),
                  _stat(AppStrings.redCardsLabel, totalRedCards.toString()),
                  _stat(
                    AppStrings.averageRating,
                    careerAverageRating?.toStringAsFixed(2) ?? '—',
                  ),
                  _stat(
                    AppStrings.earnedAndRemainingMoney,
                    '${career.money} €',
                  ),
                ]),
                const SizedBox(height: 10),
                _section(AppStrings.trophiesDuringCareer, [
                  _stat(AppStrings.totalTrophies, totalTrophies.toString()),
                  _stat(AppStrings.nationalChampionships, leagueTitles.toString()),
                  _stat(AppStrings.nationalCups, nationalCups.toString()),
                  _stat(AppStrings.championsLeague, championsLeagueTitles.toString()),
                  const Divider(color: Color(0xFF24552C)),
                  _stat(AppStrings.goldenBootTrophy, goldenBoots.toString()),
                ]),
                const SizedBox(height: 10),
                _section(
                  AppStrings.clubsDuringCareer,
                  clubs.isEmpty
                      ? [_stat(AppStrings.clubLabel, career.player.club)]
                      : clubs.asMap().entries.map((entry) {
                          return _stat(
                            AppStrings.clubNumber(entry.key + 1),
                            entry.value,
                          );
                        }).toList(),
                ),
                const SizedBox(height: 16),
                _section(
                  AppStrings.seasonHistory,
                  career.history.reversed.map((item) {
                    return _stat(
                      AppStrings.seasonSummaryTitle(item.season, item.club),
                      AppStrings.seasonSummaryStats(
                        item.matches,
                        item.goals,
                        item.assists,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, career),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BE07F),
                      foregroundColor: const Color(0xFF082A12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      AppStrings.returnButton,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(175, 72, 73, 72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF24552C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          const SizedBox(width: 30),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
