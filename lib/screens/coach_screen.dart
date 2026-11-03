import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/player_status.dart';
import 'package:flutter_football/services/app_strings.dart';

class CoachScreen extends StatefulWidget {
  final Career career;

  const CoachScreen({super.key, required this.career});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  late Career career;

  @override
  void initState() {
    super.initState();
    career = widget.career;
  }

  bool get _canTalk => career.matches - career.lastConversationMatch >= 4;

  Future<void> _talkToCoach() async {
    if (!_canTalk) return;
    final change = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF14251B),
        title: Text(career.coachName, style: const TextStyle(color: Colors.white)),
        content: const Text(
          'Тренер готов обсудить вашу роль в команде. Как вы хотите начать разговор?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, 3), child: const Text('Попросить больше игрового времени')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, 1), child: const Text('Обсудить свою роль спокойно')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, -2), child: const Text('Потребовать место в основе')),
        ],
      ),
    );
    if (!mounted || change == null) return;
    setState(() {
      career = career.copyWith(
        coachTrust: (career.coachTrust + change).clamp(0, 100).toInt(),
        lastConversationMatch: career.matches,
      );
    });
  }

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
        .clamp(1, 100)
        .toInt();
  }

  String get _coachMood {
    if (career.coachTrust >= 85) {
      return AppStrings.isEnglish
          ? 'Excellent relationship'
          : 'Отличные отношения';
    }
    if (career.coachTrust >= 65) {
      return AppStrings.isEnglish
          ? 'Positive relationship'
          : 'Хорошие отношения';
    }
    if (career.coachTrust >= 40) {
      return AppStrings.isEnglish
          ? 'Uncertain relationship'
          : 'Неоднозначные отношения';
    }
    return AppStrings.isEnglish
        ? 'Tense relationship'
        : 'Напряжённые отношения';
  }

  @override
  Widget build(BuildContext context) {
    final status = PlayerStatusCalculator.calculate(
      overall: career.player.overall,
      clubName: career.player.club,
      rivals: career.rivals,
      coachTrust: career.coachTrust,
      reputation: PlayerStatusCalculator.calculateReputation(
        overall: career.player.overall,
        averageRating: career.averageRating,
        coachTrust: career.coachTrust,
        trophies: career.history.fold<int>(0, (sum, item) => sum + item.achievements.length),
      ),
      averageRating: career.averageRating,
    );

    return PopScope<Career>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, career);
      },
      child: Scaffold(
      backgroundColor: const Color(0xFF07130F),
      appBar: AppBar(
        backgroundColor: const Color(0xAA18241F),
        foregroundColor: Colors.white,
        title: Text(
          AppStrings.coachProfileTitle,
          style: TextStyle(fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, career),
        ),
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
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF24552C),
                      child: Icon(
                        Icons.sports,
                        color: Color(0xFF8BE07F),
                        size: 24,
                      ),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            career.player.club,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _meter(AppStrings.coachTrust, career.coachTrust),
                const SizedBox(height: 8),
                Text(
                  _coachMood,
                  style: const TextStyle(
                    color: Color(0xFF8BE07F),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _canTalk ? _talkToCoach : null,
                    icon: const Icon(Icons.forum_outlined, size: 17),
                    label: Text(
                      _canTalk
                          ? 'Переговоры с тренером'
                          : 'Новый разговор через ${(4 - (career.matches - career.lastConversationMatch)).clamp(0, 4)} матча',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.playerReputation.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF8BE07F),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_reputation',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 5),
                      child: Text(
                        '/100',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
                _meter(AppStrings.playerReputation, _reputation),
                const SizedBox(height: 8),
                _line(AppStrings.squadRole, status.displayName),
                _line(AppStrings.ratingLabel, career.player.overall.toString()),
                _line(
                  AppStrings.currentForm,
                  career.averageRating?.toStringAsFixed(2) ?? '—',
                ),
                _line(AppStrings.matches, career.matches.toString()),
                _line(AppStrings.goalsLabel, career.goals.toString()),
                _line(AppStrings.assistsLabel, career.assists.toString()),
                _line(
                  AppStrings.careerAwards,
                  career.history
                      .fold<int>(
                        0,
                        (sum, season) => sum + season.achievements.length,
                      )
                      .toString(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

        ],
      ),
      ),
    );
  }

  Widget _meter(String title, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white70)),
            ),
            Text(
              '$value/100',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.13),
                Colors.white.withValues(alpha: 0.055),
                const Color(0xFF101B16).withValues(alpha: 0.42),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.24),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
