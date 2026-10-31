import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/player_status.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/widgets/jersey_number_picker.dart';

class TeamScreen extends StatelessWidget {
  final Career career;

  const TeamScreen({super.key, required this.career});

  static const _background = Color(0xFF04160A);
  static const _panel = Color(0xFF0B2A12);
  static const _accent = Color(0xFF8BE07F);
  static const _border = Color(0xFF286638);

  String _positionName(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.goalkeeper:
        return 'ВР';
      case PlayerPosition.defender:
        return 'ЗАЩ';
      case PlayerPosition.midfielder:
        return 'ПЗ';
      case PlayerPosition.forward:
        return 'НАП';
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = career.player;
    final club = Clubs.getByName(player.club);
    final status = PlayerStatusCalculator.calculate(
      overall: player.overall,
      clubName: player.club,
      rivals: career.rivals,
    );
    final rivals = [...career.rivals]
      ..sort((a, b) => b.overall.compareTo(a.overall));

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: const Text(
          'КОМАНДА',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B3A1A), Color(0xFF082A12), _background],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ТВОЙ КЛУБ',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF164A24),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _border),
                        ),
                        child: const Icon(Icons.shield_outlined,
                            color: _accent, size: 27),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.club,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Сила клуба: ${club.strength}',
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF123A1D),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFF205B2D),
                          child: Icon(Icons.person, color: _accent),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${player.name}  #${player.jerseyNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${_positionName(player.position)} · ${player.age} лет',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${player.overall}',
                              style: const TextStyle(
                                color: _accent,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              status.displayName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final number = await JerseyNumberPicker.show(
                          context: context,
                          takenNumbers: career.rivals
                              .map((rival) => rival.jerseyNumber)
                              .toSet(),
                          preferredNumber: player.jerseyNumber,
                          english: AppStrings.isEnglish,
                        );
                        if (!context.mounted || number == null) return;
                        Navigator.pop(
                          context,
                          career.copyWith(
                            player: player.copyWith(jerseyNumber: number),
                          ),
                        );
                      },
                      icon: const Icon(Icons.confirmation_number_outlined),
                      label: const Text('ИЗМЕНИТЬ НОМЕР'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _accent,
                        side: const BorderSide(color: _border),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'КОНКУРЕНТЫ ЗА ПОЗИЦИЮ',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  '${rivals.length}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            if (rivals.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: const Text(
                  'Пока нет игроков, конкурирующих с вами за место в составе.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              )
            else
              ...rivals.map((rival) {
                final isStronger = rival.overall + rival.form > player.overall;
                return Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isStronger ? const Color(0xFF8A7040) : _border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF153D20),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Center(
                              child: Text(
                                _positionName(rival.position),
                                style: const TextStyle(
                                  color: _accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${rival.name}  #${rival.jerseyNumber}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${rival.age} лет · Форма ${rival.form > 0 ? '+' : ''}${rival.form}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${rival.overall}',
                            style: TextStyle(
                              color: isStronger ? const Color(0xFFFFD27A) : _accent,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF24552C), height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _stat('Матчи', '${rival.matches}'),
                          _stat('Голы', '${rival.goals}'),
                          _stat('Ассисты', '${rival.assists}'),
                          _stat('Оценка', rival.averageRating.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10251A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF234B2D)),
              ),
              child: const Text(
                'Игровое время зависит от рейтинга и репутации игрока, формы конкурентов и доверия тренера. Статус в команде может меняться по ходу сезона.',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}
