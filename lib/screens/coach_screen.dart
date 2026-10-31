import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/player_status.dart';
import 'package:flutter_football/services/app_strings.dart';

class CoachScreen extends StatelessWidget {
  final Career career;

  const CoachScreen({super.key, required this.career});

  int get _reputation {
    final rating = career.averageRating ?? 6.0;
    final trophies = career.history.fold<int>(
      0,
      (sum, season) => sum + season.achievements.length,
    );
    return (career.player.overall * 0.55 +
            rating * 4 +
            career.coachTrust * 0.12 +
            trophies * 1.5)
        .round()
        .clamp(1, 100);
  }

  String get _coachMood {
    if (career.coachTrust >= 85) {
      return AppStrings.isEnglish ? 'Excellent relationship' : 'Отличные отношения';
    }
    if (career.coachTrust >= 65) {
      return AppStrings.isEnglish ? 'Positive relationship' : 'Хорошие отношения';
    }
    if (career.coachTrust >= 40) {
      return AppStrings.isEnglish ? 'Uncertain relationship' : 'Неоднозначные отношения';
    }
    return AppStrings.isEnglish ? 'Tense relationship' : 'Напряжённые отношения';
  }

  @override
  Widget build(BuildContext context) {
    final status = PlayerStatusCalculator.calculate(
      overall: career.player.overall,
      clubName: career.player.club,
      rivals: career.rivals,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF04160A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: Text(AppStrings.coachProfileTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.headCoach.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF8BE07F),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 27,
                      backgroundColor: Color(0xFF24552C),
                      child: Icon(Icons.sports, color: Color(0xFF8BE07F), size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            career.coachName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            career.player.club,
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _meter(AppStrings.coachTrust, career.coachTrust),
                const SizedBox(height: 8),
                Text(
                  _coachMood,
                  style: const TextStyle(color: Color(0xFF8BE07F), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.playerReputation.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF8BE07F),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_reputation',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 5),
                      child: Text('/100', style: TextStyle(color: Colors.white54)),
                    ),
                  ],
                ),
                _meter(AppStrings.playerReputation, _reputation),
                const SizedBox(height: 18),
                _line(AppStrings.squadRole, status.displayName),
                _line(AppStrings.ratingLabel, career.player.overall.toString()),
                _line(AppStrings.currentForm,
                    career.averageRating?.toStringAsFixed(2) ?? '—'),
                _line(AppStrings.matches, career.matches.toString()),
                _line(AppStrings.goalsLabel, career.goals.toString()),
                _line(AppStrings.assistsLabel, career.assists.toString()),
                _line(
                  AppStrings.seasonAchievements,
                  career.history.fold<int>(
                    0,
                    (sum, season) => sum + season.achievements.length,
                  ).toString(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.positionRivals,
                  style: const TextStyle(
                    color: Color(0xFF8BE07F),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                if (career.rivals.isEmpty)
                  Text(
                    AppStrings.isEnglish ? 'No direct competitors' : 'Прямых конкурентов пока нет',
                    style: const TextStyle(color: Colors.white60),
                  )
                else
                  ...career.rivals.map(
                    (rival) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              rival.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${rival.overall} OVR',
                            style: const TextStyle(
                              color: Color(0xFF8BE07F),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
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

  Widget _meter(String title, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white70))),
            Text('$value/100', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF22C55E)),
          ),
        ),
      ],
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white60))),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2B14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF24552C)),
      ),
      child: child,
    );
  }
}
