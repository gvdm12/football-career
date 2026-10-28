import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/world_cup.dart';
import 'package:flutter_football/services/career_storage.dart';

class WorldCupScreen extends StatefulWidget {
  final Career career;
  const WorldCupScreen({super.key, required this.career});

  @override
  State<WorldCupScreen> createState() => _WorldCupScreenState();
}

class _WorldCupScreenState extends State<WorldCupScreen> {
  static const Color background = Color(0xFF061B0C);
  static const Color green = Color(0xFF22C55E);
  late Career career;
  late WorldCup tournament;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    career = widget.career;
    tournament = career.worldCup!;
  }

  Future<void> _continueTournament() async {
    if (busy || tournament.isCompleted) return;
    setState(() => busy = true);
    final playerHasMatch = tournament.matches.any(
      (match) =>
          match.homeTeam == career.player.nationality ||
          match.awayTeam == career.player.nationality,
    );
    final playerCanPlay = tournament.isPlayerCalledUp && playerHasMatch;
    final player = career.player;
    // Продвигаем только один раунд за нажатие, даже если сборная
    // игрока уже вылетела или игрок не был вызван. Так результаты
    // каждого этапа остаются на экране и доступны в календаре.
    var updatedTournament = tournament.playCurrentRound(
      playerTeam: playerCanPlay ? player.nationality : null,
      playerOverall: player.overall,
      playerPosition: player.position.name,
      playerShooting: player.skills.shooting,
      playerPassing: player.skills.passing,
      playerDribbling: player.skills.dribbling,
    );

    // Если сборная игрока вылетела, автоматически доигрываем турнир до финала.
    final playerTeamStillInTournament = updatedTournament.matches.any(
      (match) =>
          match.homeTeam == player.nationality ||
          match.awayTeam == player.nationality,
    );
    if (!updatedTournament.isCompleted &&
        (!playerCanPlay || !playerTeamStillInTournament)) {
      updatedTournament = updatedTournament.simulateRemainingMatches();
    }

    final updatedCareer = career.copyWith(worldCup: updatedTournament);
    try {
      await CareerStorage.save(updatedCareer);
      if (!mounted) return;
      setState(() {
        career = updatedCareer;
        tournament = updatedTournament;
        busy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить чемпионат мира')),
      );
      return;
    }
  }

  String get _callUpMessage {
    switch (tournament.playerCallUpStatus) {
      case 'called':
        return 'Вас вызвали в сборную ${career.player.nationality}!';
      case 'reserve':
        return 'Вы в резерве сборной ${career.player.nationality}.';
      case 'country_not_qualified':
        return 'Сборная ${career.player.nationality} не прошла на этот чемпионат мира.';
      default:
        return 'Вас не вызвали в сборную на этот чемпионат мира.';
    }
  }

  Widget _playerStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF123A1D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 9),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamLabel(String team, {bool alignEnd = false}) {
    final strength = worldCupStrengthOf(team);
    return Expanded(
      child: Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.center,
        children: [
          Text(
            team,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 1),
          Text(
            'Сила: $strength',
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: TextStyle(
              color: strength >= 85
                  ? const Color(0xFFFFD54F)
                  : strength >= 80
                  ? green
                  : Colors.white60,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerMatches = tournament.matches
        .where(
          (match) =>
              match.homeTeam == career.player.nationality ||
              match.awayTeam == career.player.nationality,
        )
        .toList();
    final playerMatch = playerMatches.isEmpty ? null : playerMatches.first;
    final playerCanPlay = tournament.isPlayerCalledUp && playerMatch != null;

    return PopScope<Career>(
      canPop: tournament.isCompleted,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B3A1A),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/worldcup.svg',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              const Text('Чемпионат мира'),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2B16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: green.withValues(alpha: 0.55)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Чемпионат мира · сезон ${tournament.season}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _callUpMessage,
                      style: const TextStyle(
                        color: Color(0xFF8BE07F),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 1),
                    if (playerCanPlay) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Матч сборной: ${playerMatch.homeTeam} '
                        '${playerMatch.isPlayed ? playerMatch.homeGoals : '-'} : '
                        '${playerMatch.isPlayed ? playerMatch.awayGoals : '-'} '
                        '${playerMatch.awayTeam}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (tournament.isPlayerCalledUp &&
                        tournament.participants.contains(
                          career.player.nationality,
                        )) ...[
                      const SizedBox(height: 14),
                      const Divider(color: Colors.white24),
                      const Text(
                        'Ваша статистика за сборную',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _playerStat('Матчи', '${tournament.playerMatches}'),
                          _playerStat('Голы', '${tournament.playerGoals}'),
                          _playerStat('Ассисты', '${tournament.playerAssists}'),
                          _playerStat(
                            'Средняя оценка',
                            tournament.playerAverageRating?.toStringAsFixed(
                                  1,
                                ) ??
                                '—',
                          ),
                        ],
                      ),
                    ],
                    if (tournament.champion != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Чемпион мира: ${tournament.champion}',
                        style: const TextStyle(
                          color: Color(0xFFFFD54F),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (tournament.matchHistory.isNotEmpty) ...[
                const SizedBox(height: 13),
                const Text(
                  'Результаты сыгранных матчей',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...tournament.matchHistory.map((match) {
                  final isPlayerTeam =
                      match.homeTeam == career.player.nationality ||
                      match.awayTeam == career.player.nationality;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPlayerTeam
                          ? const Color(0xFF123A1D)
                          : const Color(0xFF0A2110),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isPlayerTeam ? green : Colors.white12,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          match.stage?.title ?? 'Завершённый раунд',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _teamLabel(match.homeTeam),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                '${match.homeGoals} : ${match.awayGoals}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _teamLabel(match.awayTeam, alignEnd: true),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 6),
              Text(
                tournament.stage.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (!tournament.isCompleted)
                ...tournament.matches.map((match) {
                  final isPlayerTeam =
                      match.homeTeam == career.player.nationality ||
                      match.awayTeam == career.player.nationality;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isPlayerTeam
                          ? const Color(0xFF123A1D)
                          : const Color(0xFF0A2110),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isPlayerTeam ? green : Colors.white12,
                      ),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/worldcup.svg',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 6),
                        _teamLabel(match.homeTeam),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            match.isPlayed
                                ? '${match.homeGoals} : ${match.awayGoals}'
                                : '— : —',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _teamLabel(match.awayTeam, alignEnd: true),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 12),
              if (!tournament.isCompleted)
                FilledButton(
                  onPressed: busy ? null : _continueTournament,
                  style: FilledButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    busy
                        ? 'Симуляция...'
                        : playerCanPlay
                        ? 'Сыграть матч сборной'
                        : 'Продолжить чемпионат мира',
                  ),
                )
              else ...[
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, career),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Вернуться в карьеру'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: green),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
