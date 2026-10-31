import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/screens/match/interactive_match_screen.dart';
import 'package:flutter_football/models/world_cup.dart';
import 'package:flutter_football/services/career_storage.dart';
import 'package:flutter_football/services/app_strings.dart';

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

  Future<void> _continueTournament({bool interactive = false}) async {
    if (busy || tournament.isCompleted) return;
    setState(() => busy = true);
    final playerHasMatch = tournament.matches.any(
      (match) =>
          match.homeTeam == career.player.nationality ||
          match.awayTeam == career.player.nationality,
    );
    final player = career.player;
    final playerCanPlay =
        tournament.isPlayerCalledUp && playerHasMatch && !career.isInjured;
    final playerNationalTeamHasMatch = tournament.isPlayerCalledUp &&
        tournament.matches.any(
          (match) =>
              !match.isPlayed &&
              (match.homeTeam == player.nationality ||
                  match.awayTeam == player.nationality),
        );

    var updatedTournament = tournament;
    Match? playedPlayerMatch;
    if (interactive && playerCanPlay) {
      final playerMatchIndex = tournament.matches.indexWhere(
        (match) =>
            !match.isPlayed &&
            (match.homeTeam == player.nationality ||
                match.awayTeam == player.nationality),
      );
      if (playerMatchIndex < 0) {
        if (mounted) setState(() => busy = false);
        return;
      }
      final playerMatch = tournament.matches[playerMatchIndex];
      final isHome = playerMatch.homeTeam == player.nationality;
      final opponent = isHome ? playerMatch.awayTeam : playerMatch.homeTeam;
      final playedMatch = await Navigator.push<Match>(
        context,
        MaterialPageRoute(
          builder: (_) => InteractiveMatchScreen(
            career: career,
            opponent: opponent,
            isHome: isHome,
            playerTeamName: player.nationality,
            playerTeamStrength: worldCupStrengthOf(player.nationality) +
                ((player.overall - 70) * 0.12).clamp(0, 3).toInt(),
            opponentStrength: worldCupStrengthOf(opponent),
            forcePlayerParticipation: true,
          ),
        ),
      );
      if (!mounted) return;
      if (playedMatch == null) {
        setState(() => busy = false);
        return;
      }
      playedPlayerMatch = playedMatch;
      updatedTournament = tournament.playMatch(
        playerMatchIndex,
        homeGoals: playedMatch.homeGoals,
        awayGoals: playedMatch.awayGoals,
        playerTeam: player.nationality,
        playerOverall: player.overall,
        playerPosition: player.position.name,
        playerShooting: player.skills.shooting,
        playerPassing: player.skills.passing,
        playerDribbling: player.skills.dribbling,
        playerGoalsOverride: playedMatch.playerGoals,
        playerAssistsOverride: playedMatch.playerAssists,
        playerRatingOverride: playedMatch.playerRating,
      );
      // Остальные матчи этого раунда проходят автоматически.
      if (!updatedTournament.isCompleted &&
          updatedTournament.stage == tournament.stage) {
        updatedTournament = updatedTournament.playCurrentRound();
      }
    }
    // Продвигаем только один раунд за нажатие, даже если сборная
    // игрока уже вылетела или игрок не был вызван. Так результаты
    // каждого этапа остаются на экране и доступны в календаре.
    if (!interactive) {
      updatedTournament = tournament.playCurrentRound(
        playerTeam: playerCanPlay ? player.nationality : null,
        playerOverall: player.overall,
        playerPosition: player.position.name,
        playerShooting: player.skills.shooting,
        playerPassing: player.skills.passing,
        playerDribbling: player.skills.dribbling,
      );
    }

    // Если сборная игрока вылетела, автоматически доигрываем турнир до финала.
    final playerTeamStillInTournament = updatedTournament.matches.any(
      (match) =>
          match.homeTeam == player.nationality ||
          match.awayTeam == player.nationality,
    );
    if (!updatedTournament.isCompleted &&
        (!tournament.isPlayerCalledUp || !playerTeamStillInTournament)) {
      updatedTournament = updatedTournament.simulateRemainingMatches();
    }

    final careerAfterMatch = playerNationalTeamHasMatch
        ? career.advanceAfterCompetitionMatch(
            playerParticipated: playerCanPlay,
          )
        : career;
    var updatedCareer = careerAfterMatch.copyWith(
      worldCup: updatedTournament,
    );

    final playerStillInTournament = updatedTournament.matches.any(
      (match) =>
          match.homeTeam == player.nationality ||
          match.awayTeam == player.nationality,
    );
    final isTournamentDecider =
        updatedTournament.isCompleted || !playerStillInTournament;
    final playerMatch = playedPlayerMatch;
    if (playerMatch != null && playerMatch.playerPlayed) {
      final outstanding = playerMatch.playerRating >= 8.5 ||
          playerMatch.playerGoals >= 2 ||
          playerMatch.playerGoals + playerMatch.playerAssists >= 3;
      final poor = playerMatch.playerRating <= 5.5;
      final shouldAsk = isTournamentDecider ||
          (outstanding && Random().nextDouble() < 0.72) ||
          (poor && Random().nextDouble() < 0.62);

      if (shouldAsk) {
        final response = await showDialog<int>(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF102B17),
            title: Text(
              AppStrings.pressConferenceTitle,
              style: const TextStyle(
                color: Color(0xFF8BE07F),
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Text(
              isTournamentDecider
                  ? AppStrings.pressConferenceTournament
                  : outstanding
                  ? AppStrings.pressConferenceGreatMatch
                  : AppStrings.pressConferenceBadMatch,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 0),
                child: Text(AppStrings.skipPressConference),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 1),
                child: Text(AppStrings.pressConferenceTeamFirst),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 2),
                child: Text(AppStrings.pressConferenceConfident),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 3),
                child: Text(AppStrings.pressConferenceDemand),
              ),
            ],
          ),
        );

        final trustChange = switch (response) {
          1 => 2,
          2 => 1,
          3 => -2,
          _ => 0,
        };
        if (trustChange != 0) {
          updatedCareer = updatedCareer.copyWith(
            coachTrust: (updatedCareer.coachTrust + trustChange)
                .clamp(0, 100)
                .toInt(),
          );
        }
      }
    }

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
    final playerCanPlay =
        tournament.isPlayerCalledUp && playerMatch != null && !career.isInjured;

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
                    if (career.isInjured) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Вы травмированы: ${career.injuryName ?? 'повреждение'}. До восстановления осталось матчей: ${career.injuryMatchesRemaining}.',
                        style: const TextStyle(
                          color: Color(0xFFFF7777),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
              if (!tournament.isCompleted) ...[
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: busy
                            ? null
                            : () => _continueTournament(interactive: false),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE8EDE8),
                          foregroundColor: const Color(0xFF102B17),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          playerCanPlay ? 'Симуляция' : 'Продолжить',
                        ),
                      ),
                    ),
                    if (playerCanPlay) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: busy
                              ? null
                              : () => _continueTournament(interactive: true),
                          style: FilledButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Играть'),
                        ),
                      ),
                    ],
                  ],
                ),
              ]
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
