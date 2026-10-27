import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/champions_league.dart';
import 'package:flutter_football/models/europa_league.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/cup_match.dart';
import 'package:flutter_football/models/league_match.dart';
import 'package:flutter_football/models/league_table.dart';
import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/models/season_match.dart';
import 'package:flutter_football/screens/development_screen.dart';
import 'package:flutter_football/screens/league_table/league_table_screen.dart';
import 'package:flutter_football/screens/match/match_screen.dart';
import 'package:flutter_football/screens/transfers/transfer_screen.dart';
import 'package:flutter_football/screens/world_cup_screen.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/career_storage.dart';
import 'package:flutter_football/screens/career_end_screen.dart';
import 'package:flutter_svg/svg.dart';

class SeasonScreen extends StatefulWidget {
  final Career career;
  final bool calendarOnly;

  const SeasonScreen({
    super.key,
    required this.career,
    this.calendarOnly = false,
  });

  @override
  State<SeasonScreen> createState() => _SeasonScreenState();
}

class _SeasonScreenState extends State<SeasonScreen> {
  late Career career;
  bool isSaving = false;
  bool seasonFinishing = false;

  @override
  void initState() {
    super.initState();
    career = widget.career;

  }

  bool get worldCupBlocksSeason {
    final tournament = career.worldCup;
    return tournament != null &&
        !tournament.isCompleted &&
        tournament.isPlayerCalledUp;
  }

  Future<void> _openWorldCup() async {
    final tournament = career.worldCup;
    if (!mounted || tournament == null || tournament.isCompleted) return;

    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(builder: (_) => WorldCupScreen(career: career)),
    );

    if (!mounted || updatedCareer == null) return;
    setState(() => career = updatedCareer);
    await _saveCareer(updatedCareer);
  }

  Widget _buildWorldCupCalendarSection({required bool blocksSeason}) {
    final tournament = career.worldCup;
    if (tournament == null) return const SizedBox.shrink();

    final status = tournament.isCompleted
        ? 'Турнир завершён · чемпион: ${tournament.champion ?? 'не определён'}'
        : tournament.isPlayerCalledUp
            ? 'Вас вызвали в сборную — сыграйте чемпионат мира перед клубным сезоном'
            : 'Чемпионат мира проходит параллельно с клубным сезоном';
    final nationalMatches = [
      ...tournament.matchHistory,
      ...tournament.matches,
    ].where(
      (match) =>
          match.homeTeam == career.player.nationality ||
          match.awayTeam == career.player.nationality,
    ).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2110),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: blocksSeason
              ? const Color(0xFF22C55E)
              : const Color(0xFF24552C),
          width: blocksSeason ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/worldcup.svg',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Чемпионат мира',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${tournament.season}/22',
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(status, style: const TextStyle(color: Colors.white70)),
          if (nationalMatches.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Матчи вашей сборной',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ...nationalMatches.map((match) {
              final isPlayed = match.isPlayed;
              final isHome = match.homeTeam == career.player.nationality;
              final opponent = isHome ? match.awayTeam : match.homeTeam;
              final score = isPlayed
                  ? '${match.homeGoals} : ${match.awayGoals}'
                  : '— : —';
              return Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF061B0C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sports_soccer,
                      color: Color(0xFF8BE07F),
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${isHome ? 'Дома' : 'В гостях'}: $opponent',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      score,
                      style: TextStyle(
                        color: isPlayed
                            ? const Color(0xFF8BE07F)
                            : Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (!tournament.isCompleted) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSaving ? null : _openWorldCup,
                icon: const Icon(Icons.sports_soccer),
                label: Text(
                  tournament.isPlayerCalledUp
                      ? 'Открыть матчи сборной'
                      : 'Открыть чемпионат мира',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  int get playedMatches =>
      career.seasonMatches.where((match) => match.isPlayed).length;

  bool get seasonFinished {
    final leagueFinished =
        career.seasonMatches.isNotEmpty &&
        career.seasonMatches.every((match) => match.isPlayed);

    if (!leagueFinished) return false;

    // Если клуб участвует в ЛЧ, проверяем, остались ли
    // у него незавершённые матчи именно текущей стадии.
    final tournament = career.championsLeague;
    final club = career.player.club;

    if (tournament != null &&
        tournament.stage != ChampionsLeagueStage.completed) {
      final playerTie = tournament.ties.where(
        (tie) => tie.homeTeam == club || tie.awayTeam == club,
      );

      for (final tie in playerTie) {
        if (tournament.stage == ChampionsLeagueStage.finalMatch) {
          if (!tie.isFinalPlayed) return false;
        } else if (!tie.isCompleted) {
          return false;
        }
      }

      // Если клуб прошёл дальше, но следующая стадия ещё не создана,
      // сезон пока не завершаем.
      if (playerTie.isNotEmpty &&
          playerTie.every((tie) => tie.winner == club) &&
          tournament.stage != ChampionsLeagueStage.finalMatch &&
          tournament.ties.every((tie) => tie.isCompleted)) {
        return false;
      }
    }

    final europa = career.europaLeague;
    if (europa != null &&
        europa.stage != EuropaLeagueStage.completed) {
      final playerTie = europa.ties.where(
        (tie) => tie.homeTeam == club || tie.awayTeam == club,
      );
      for (final tie in playerTie) {
        if (europa.stage == EuropaLeagueStage.finalMatch) {
          if (!tie.isFinalPlayed) return false;
        } else if (!tie.isCompleted) {
          return false;
        }
      }
      if (playerTie.isNotEmpty &&
          playerTie.every((tie) => tie.winner == club) &&
          europa.stage != EuropaLeagueStage.finalMatch &&
          europa.ties.every((tie) => tie.isCompleted)) {
        return false;
      }
    }

    final cup = career.domesticCup;
    if (cup == null) return true;

    final playerCupMatches = cup.matches.where(
      (match) => match.homeTeam == club || match.awayTeam == club,
    );

    if (playerCupMatches.any((match) => !match.isPlayed)) {
      return false;
    }

    return cup.isFinished || !cup.isTeamStillInCup(club);
  }

  ChampionsLeagueTie? get currentChampionsLeagueTie {
    final tournament = career.championsLeague;
    if (tournament == null ||
        tournament.stage == ChampionsLeagueStage.completed) {
      return null;
    }

    for (final tie in tournament.ties) {
      if (tie.homeTeam != career.player.club &&
          tie.awayTeam != career.player.club) {
        continue;
      }

      if (tournament.stage == ChampionsLeagueStage.finalMatch) {
        if (!tie.isFinalPlayed) return tie;
      } else if (!tie.isCompleted) {
        return tie;
      }
    }

    return null;
  }

  bool get isChampionsLeagueMatchAvailable {
    final tie = currentChampionsLeagueTie;
    if (tie == null) return false;

    final tournament = career.championsLeague!;

    if (tournament.stage == ChampionsLeagueStage.finalMatch) {
      return !tie.isFinalPlayed;
    }

    return !tie.isFirstLegPlayed || !tie.isSecondLegPlayed;
  }

  EuropaLeagueTie? get currentEuropaLeagueTie {
    final tournament = career.europaLeague;
    if (tournament == null ||
        tournament.stage == EuropaLeagueStage.completed) {
      return null;
    }

    for (final tie in tournament.ties) {
      if (tie.homeTeam != career.player.club &&
          tie.awayTeam != career.player.club) {
        continue;
      }

      if (tournament.stage == EuropaLeagueStage.finalMatch) {
        if (!tie.isFinalPlayed) return tie;
      } else if (!tie.isCompleted) {
        return tie;
      }
    }

    return null;
  }

  bool get isEuropaLeagueMatchAvailable {
    final tie = currentEuropaLeagueTie;
    if (tie == null) return false;

    final tournament = career.europaLeague!;

    if (tournament.stage == EuropaLeagueStage.finalMatch) {
      return !tie.isFinalPlayed;
    }

    return !tie.isFirstLegPlayed || !tie.isSecondLegPlayed;
  }

  int? get currentEuropaLeagueTieIndex {
    final tournament = career.europaLeague;
    if (tournament == null ||
        tournament.stage == EuropaLeagueStage.completed) {
      return null;
    }

    final club = career.player.club;
    for (var i = 0; i < tournament.ties.length; i++) {
      final tie = tournament.ties[i];
      if (tie.homeTeam != club && tie.awayTeam != club) continue;

      if (tournament.stage == EuropaLeagueStage.finalMatch) {
        if (!tie.isFinalPlayed) return i;
      } else if (!tie.isCompleted &&
          (!tie.isFirstLegPlayed || !tie.isSecondLegPlayed)) {
        return i;
      }
    }
    return null;
  }

  SeasonMatch? get currentMatch {
    for (final match in career.seasonMatches) {
      if (!match.isPlayed) return match;
    }
    return null;
  }

  CupMatch? get currentCupMatch {
    final cup = career.domesticCup;
    if (cup == null) return null;

    final club = career.player.club;

    for (final match in cup.matches) {
      if (!match.isPlayed &&
          (match.homeTeam == club || match.awayTeam == club)) {
        return match;
      }
    }

    return null;
  }

  int? get currentChampionsLeagueTieIndex {
    final tournament = career.championsLeague;
    if (tournament == null ||
        tournament.stage == ChampionsLeagueStage.completed) {
      return null;
    }

    final club = career.player.club;

    for (var i = 0; i < tournament.ties.length; i++) {
      final tie = tournament.ties[i];

      if (tie.homeTeam != club && tie.awayTeam != club) {
        continue;
      }

      if (tournament.stage == ChampionsLeagueStage.finalMatch) {
        if (!tie.isFinalPlayed) return i;
      } else if (!tie.isCompleted) {
        if (!tie.isFirstLegPlayed || !tie.isSecondLegPlayed) {
          return i;
        }
      }
    }

    return null;
  }

  bool get playerStillInChampionsLeague {
    final tournament = career.championsLeague;

    if (tournament == null ||
        tournament.stage == ChampionsLeagueStage.completed) {
      return false;
    }

    final club = career.player.club;

    return tournament.ties.any(
      (tie) =>
          (tie.homeTeam == club || tie.awayTeam == club) &&
          (tie.winner == null || tie.winner == club),
    );
  }

  int _cupScheduledRound(CupMatch match) {
    final totalLeagueMatches = career.seasonMatches.length;

    if (totalLeagueMatches == 0) return 1;

    final progress = switch (match.round) {
      1 => 0.15,
      2 => 0.40,
      3 => 0.65,
      4 => 0.85,
      _ => 0.50,
    };

    return (totalLeagueMatches * progress).round().clamp(1, totalLeagueMatches);
  }

  double _championsLeagueScheduledPosition() {
    final tournament = career.championsLeague;
    final index = currentChampionsLeagueTieIndex;

    if (tournament == null || index == null) {
      return double.infinity;
    }

    final tie = tournament.ties[index];
    final isFinal = tournament.stage == ChampionsLeagueStage.finalMatch;
    final isSecondLeg = !isFinal && tie.isFirstLegPlayed;

    final progress = switch (tournament.stage) {
      ChampionsLeagueStage.roundOf32 => isSecondLeg ? 0.18 : 0.10,
      ChampionsLeagueStage.roundOf16 => isSecondLeg ? 0.38 : 0.30,
      ChampionsLeagueStage.quarterFinal => isSecondLeg ? 0.58 : 0.50,
      ChampionsLeagueStage.semiFinal => isSecondLeg ? 0.78 : 0.70,
      ChampionsLeagueStage.finalMatch => 0.92,
      ChampionsLeagueStage.completed => 1.0,
    };

    return (career.seasonMatches.length * progress).clamp(
      1.0,
      career.seasonMatches.length.toDouble(),
    );
  }

  double _championsLeagueHistoryPosition(ChampionsLeagueMatchHistory match) {
    final progress = switch (match.stage) {
      ChampionsLeagueStage.roundOf32 => match.leg == 1 ? 0.10 : 0.18,
      ChampionsLeagueStage.roundOf16 => match.leg == 1 ? 0.30 : 0.38,
      ChampionsLeagueStage.quarterFinal => match.leg == 1 ? 0.50 : 0.58,
      ChampionsLeagueStage.semiFinal => match.leg == 1 ? 0.70 : 0.78,
      ChampionsLeagueStage.finalMatch => 0.92,
      ChampionsLeagueStage.completed => 1.0,
    };

    final totalMatches = career.seasonMatches.length;

    if (totalMatches == 0) return 1.0;

    return (totalMatches * progress).clamp(1.0, totalMatches.toDouble());
  }

  Widget _buildChampionsLeagueHistoryRow(ChampionsLeagueMatchHistory match) {
    final club = career.player.club;
    final isHome = match.homeTeam == club;
    final opponent = isHome ? match.awayTeam : match.homeTeam;

    final playerGoals = isHome ? match.homeGoals : match.awayGoals;
    final opponentGoals = isHome ? match.awayGoals : match.homeGoals;

    final playerPenalties = isHome ? match.homePenalties : match.awayPenalties;
    final opponentPenalties = isHome
        ? match.awayPenalties
        : match.homePenalties;

    final hasPenalties = playerPenalties != null && opponentPenalties != null;

    // Определяем результат с учётом пенальти.
    final won = hasPenalties
        ? playerPenalties > opponentPenalties
        : playerGoals > opponentGoals;

    final drawn = playerGoals == opponentGoals && !hasPenalties;

    final resultColor = won
        ? const Color(0xFF8BE07F)
        : drawn
        ? Colors.orangeAccent
        : Colors.redAccent;

    final matchTitle = match.stage == ChampionsLeagueStage.finalMatch
        ? AppStrings.finalStage
        : match.leg == 1
        ? AppStrings.firstLegLabel
        : AppStrings.secondLegLabel;

    final score = hasPenalties
        ? '$playerGoals : $opponentGoals '
              '${AppStrings.penaltiesShort} $playerPenalties:$opponentPenalties'
        : '$playerGoals : $opponentGoals';

    String? outcomeLabel;

    if (match.stage == ChampionsLeagueStage.finalMatch &&
        match.winner != null) {
      outcomeLabel = AppStrings.tournamentWinner(match.winner!);
    } else if (match.leg == 2 && match.winner != null) {
      outcomeLabel = match.winner == club
          ? AppStrings.advancedToNextRound
          : AppStrings.winnerAdvancedToNextRound(match.winner!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2110),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xFF8DB8FF), width: 4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: SvgPicture.asset(
              'assets/icons/ucl.svg',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.championsLeague} · ${AppStrings.tournamentStageName(match.stage.title)}',
                  style: const TextStyle(
                    color: Color(0xFF8DB8FF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$matchTitle · ${isHome ? AppStrings.homeVenue : AppStrings.awayVenue}: $opponent',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                if (outcomeLabel != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    outcomeLabel,
                    style: TextStyle(
                      color: match.stage == ChampionsLeagueStage.finalMatch
                          ? const Color(0xFFFFD54F)
                          : const Color(0xFF8BE07F),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              score,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: resultColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _europaLeagueScheduledPosition() {
    final tournament = career.europaLeague;
    final index = currentEuropaLeagueTieIndex;

    if (tournament == null || index == null) {
      return double.infinity;
    }

    final tie = tournament.ties[index];
    final isFinal = tournament.stage == EuropaLeagueStage.finalMatch;
    final isSecondLeg = !isFinal && tie.isFirstLegPlayed;

    final progress = switch (tournament.stage) {
      EuropaLeagueStage.roundOf32 => isSecondLeg ? 0.18 : 0.10,
      EuropaLeagueStage.roundOf16 => isSecondLeg ? 0.38 : 0.30,
      EuropaLeagueStage.quarterFinal => isSecondLeg ? 0.58 : 0.50,
      EuropaLeagueStage.semiFinal => isSecondLeg ? 0.78 : 0.70,
      EuropaLeagueStage.finalMatch => 0.92,
      EuropaLeagueStage.completed => 1.0,
    };

    return (career.seasonMatches.length * progress).clamp(
      1.0,
      career.seasonMatches.length.toDouble(),
    );
  }

  double _europaLeagueHistoryPosition(EuropaLeagueMatchHistory match) {
    final progress = switch (match.stage) {
      EuropaLeagueStage.roundOf32 => match.leg == 1 ? 0.10 : 0.18,
      EuropaLeagueStage.roundOf16 => match.leg == 1 ? 0.30 : 0.38,
      EuropaLeagueStage.quarterFinal => match.leg == 1 ? 0.50 : 0.58,
      EuropaLeagueStage.semiFinal => match.leg == 1 ? 0.70 : 0.78,
      EuropaLeagueStage.finalMatch => 0.92,
      EuropaLeagueStage.completed => 1.0,
    };

    final totalMatches = career.seasonMatches.length;

    if (totalMatches == 0) return 1.0;

    return (totalMatches * progress).clamp(1.0, totalMatches.toDouble());
  }

  Widget _buildEuropaLeagueHistoryRow(EuropaLeagueMatchHistory match) {
    final club = career.player.club;
    final isHome = match.homeTeam == club;
    final opponent = isHome ? match.awayTeam : match.homeTeam;

    final playerGoals = isHome ? match.homeGoals : match.awayGoals;
    final opponentGoals = isHome ? match.awayGoals : match.homeGoals;

    final playerPenalties = isHome ? match.homePenalties : match.awayPenalties;
    final opponentPenalties = isHome
        ? match.awayPenalties
        : match.homePenalties;

    final hasPenalties = playerPenalties != null && opponentPenalties != null;

    // Определяем результат с учётом пенальти.
    final won = hasPenalties
        ? playerPenalties > opponentPenalties
        : playerGoals > opponentGoals;

    final drawn = playerGoals == opponentGoals && !hasPenalties;

    final resultColor = won
        ? const Color(0xFF8BE07F)
        : drawn
        ? Colors.orangeAccent
        : Colors.redAccent;

    final matchTitle = match.stage == EuropaLeagueStage.finalMatch
        ? AppStrings.finalStage
        : match.leg == 1
        ? AppStrings.firstLegLabel
        : AppStrings.secondLegLabel;

    final score = hasPenalties
        ? '$playerGoals : $opponentGoals '
              '${AppStrings.penaltiesShort} $playerPenalties:$opponentPenalties'
        : '$playerGoals : $opponentGoals';

    String? outcomeLabel;

    if (match.stage == EuropaLeagueStage.finalMatch &&
        match.winner != null) {
      outcomeLabel = AppStrings.tournamentWinner(match.winner!);
    } else if (match.leg == 2 && match.winner != null) {
      outcomeLabel = match.winner == club
          ? AppStrings.advancedToNextRound
          : AppStrings.winnerAdvancedToNextRound(match.winner!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2110),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xFF8DB8FF), width: 4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: SvgPicture.asset(
              'assets/icons/europaleague.svg',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.europaLeague} · ${AppStrings.tournamentStageName(match.stage.title)}',
                  style: const TextStyle(
                    color: Color(0xFF8DB8FF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$matchTitle · ${isHome ? AppStrings.homeVenue : AppStrings.awayVenue}: $opponent',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                if (outcomeLabel != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    outcomeLabel,
                    style: TextStyle(
                      color: match.stage == EuropaLeagueStage.finalMatch
                          ? const Color(0xFFFFD54F)
                          : const Color(0xFF8BE07F),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              score,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: resultColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEuropaLeagueMatchRow() {
    final tournament = career.europaLeague;
    final index = currentEuropaLeagueTieIndex;

    if (tournament == null || index == null) {
      return const SizedBox.shrink();
    }

    final tie = tournament.ties[index];
    final club = career.player.club;
    final isFinal = tournament.stage == EuropaLeagueStage.finalMatch;
    final isFirstLeg = !isFinal && !tie.isFirstLegPlayed;

    final isHome = isFinal || isFirstLeg
        ? tie.homeTeam == club
        : tie.awayTeam == club;

    final opponent = tie.homeTeam == club ? tie.awayTeam : tie.homeTeam;

    final isPlayed = isFinal
        ? tie.isFinalPlayed
        : isFirstLeg
        ? tie.isFirstLegPlayed
        : tie.isSecondLegPlayed;

    String result = AppStrings.pendingResult;
    if (isPlayed) {
      final homeGoals = isFinal
          ? tie.finalHomeGoals
          : isFirstLeg
          ? tie.firstLegHomeGoals
          : tie.secondLegHomeGoals;

      final awayGoals = isFinal
          ? tie.finalAwayGoals
          : isFirstLeg
          ? tie.firstLegAwayGoals
          : tie.secondLegAwayGoals;

      result = isHome ? '$homeGoals : $awayGoals' : '$awayGoals : $homeGoals';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2110),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xFF8DB8FF), width: 4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: SvgPicture.asset(
              'assets/icons/europaleague.svg',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.europaLeague} · ${AppStrings.tournamentStageName(tournament.stage.title)}',
                  style: const TextStyle(
                    color: Color(0xFF8DB8FF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isHome ? AppStrings.homeVenue : AppStrings.awayVenue}: $opponent',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            result,
            style: TextStyle(
              color: isPlayed ? const Color(0xFF8BE07F) : Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCareer(Career value) async {
    try {
      await CareerStorage.save(value);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.matchCalendarError)));
    }
  }

  Future<void> _playMatch(SeasonMatch seasonMatch) async {
    if (isSaving || seasonFinishing || seasonMatch.isPlayed) return;

    final nextMatch = currentMatch;

    if (nextMatch == null || nextMatch.number != seasonMatch.number) {
      return;
    }

    final match = Match.generate(
      player: career.player,
      career: career,
      opponent: seasonMatch.opponent,
      isHome: seasonMatch.isHome,
    );

    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MatchScreen(career: career, match: match, isCupMatch: true),
      ),
    );

    if (!mounted || updatedCareer == null) return;

    // Проверяем, что матч соответствует клубу игрока и сопернику.
    final expectedHomeTeam = seasonMatch.isHome
        ? career.player.club
        : seasonMatch.opponent;
    final expectedAwayTeam = seasonMatch.isHome
        ? seasonMatch.opponent
        : career.player.club;

    if (match.homeTeam != expectedHomeTeam ||
        match.awayTeam != expectedAwayTeam) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.matchCalendarError)));
      return;
    }

    // Сохраняем результат матча в календаре игрока.
    final updatedSeasonMatches = updatedCareer.seasonMatches.map((item) {
      if (item.number == seasonMatch.number && !item.isPlayed) {
        return item.copyWith(result: match);
      }

      return item;
    }).toList();

    // Сохраняем результат в общем календаре лиги.
    final updatedLeagueMatches = updatedCareer.leagueMatches.map((fixture) {
      final isSameMatch =
          fixture.round == seasonMatch.number &&
          fixture.homeTeam == match.homeTeam &&
          fixture.awayTeam == match.awayTeam;

      if (isSameMatch && !fixture.isPlayed) {
        return fixture.copyWith(
          homeGoals: match.homeGoals,
          awayGoals: match.awayGoals,
        );
      }

      return fixture;
    }).toList();

    // Симулируем только ещё не сыгранные матчи этого тура.
    final completedLeagueMatches = _simulateBackgroundRound(
      updatedLeagueMatches,
      seasonMatch.number,
    );

    // Полностью пересчитываем таблицу по сохранённым результатам.
    final updatedTable = _rebuildLeagueTable(
      updatedCareer.player.club,
      completedLeagueMatches,
    );

    final completeCareer = updatedCareer.copyWith(
      seasonMatches: updatedSeasonMatches,
      leagueMatches: completedLeagueMatches,
      leagueTable: updatedTable,
    );

    setState(() {
      career = completeCareer;
      isSaving = true;
    });

    await _saveCareer(completeCareer);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });
  }

  Widget _buildChampionsLeagueMatchRow() {
    final tournament = career.championsLeague;
    final index = currentChampionsLeagueTieIndex;

    if (tournament == null || index == null) {
      return const SizedBox.shrink();
    }

    final tie = tournament.ties[index];
    final club = career.player.club;
    final isFinal = tournament.stage == ChampionsLeagueStage.finalMatch;
    final isFirstLeg = !isFinal && !tie.isFirstLegPlayed;

    final isHome = isFinal || isFirstLeg
        ? tie.homeTeam == club
        : tie.awayTeam == club;

    final opponent = tie.homeTeam == club ? tie.awayTeam : tie.homeTeam;

    final isPlayed = isFinal
        ? tie.isFinalPlayed
        : isFirstLeg
        ? tie.isFirstLegPlayed
        : tie.isSecondLegPlayed;

    String result = AppStrings.pendingResult;
    if (isPlayed) {
      final homeGoals = isFinal
          ? tie.finalHomeGoals
          : isFirstLeg
          ? tie.firstLegHomeGoals
          : tie.secondLegHomeGoals;

      final awayGoals = isFinal
          ? tie.finalAwayGoals
          : isFirstLeg
          ? tie.firstLegAwayGoals
          : tie.secondLegAwayGoals;

      result = isHome ? '$homeGoals : $awayGoals' : '$awayGoals : $homeGoals';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2110),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xFF8DB8FF), width: 4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: SvgPicture.asset(
              'assets/icons/ucl.svg',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.championsLeague} · ${AppStrings.tournamentStageName(tournament.stage.title)}',
                  style: const TextStyle(
                    color: Color(0xFF8DB8FF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isHome ? AppStrings.homeVenue : AppStrings.awayVenue}: $opponent',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            result,
            style: TextStyle(
              color: isPlayed ? const Color(0xFF8BE07F) : Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playChampionsLeagueMatch() async {
    if (isSaving || seasonFinishing) return;

    final tournament = career.championsLeague;
    final tieIndex = currentChampionsLeagueTieIndex;

    if (tournament == null || tieIndex == null) return;

    final tie = tournament.ties[tieIndex];
    final club = career.player.club;
    final isFinal = tournament.stage == ChampionsLeagueStage.finalMatch;
    final isFirstLeg = !isFinal && !tie.isFirstLegPlayed;

    // Определяем, на какой стороне поля играет клуб игрока.
    final isHome = isFinal || isFirstLeg
        ? tie.homeTeam == club
        : tie.awayTeam == club;

    final opponent = tie.homeTeam == club ? tie.awayTeam : tie.homeTeam;

    final generatedMatch = Match.generate(
      player: career.player,
      career: career,
      opponent: opponent,
      isHome: isHome,
    );

    final homeGoals = generatedMatch.homeGoals;
    final awayGoals = generatedMatch.awayGoals;

    int? homePenalties;
    int? awayPenalties;

    // Проверяем, нужна ли серия пенальти.
    bool needsPenalties = false;

    if (isFinal) {
      // В финале пенальти нужны при ничьей.
      needsPenalties = homeGoals == awayGoals;
    } else if (!isFirstLeg) {
      // В ответном матче сравниваем общий счёт двух встреч.
      final homeTeamAggregate = tie.firstLegHomeGoals! + awayGoals;

      final awayTeamAggregate = tie.firstLegAwayGoals! + homeGoals;

      needsPenalties = homeTeamAggregate == awayTeamAggregate;
    }

    // Генерируем пенальти ДО открытия экрана матча.
    if (needsPenalties) {
      final random = Random();

      homePenalties = 3 + random.nextInt(3);
      awayPenalties = 3 + random.nextInt(3);

      while (homePenalties == awayPenalties) {
        awayPenalties = 3 + random.nextInt(3);
      }
    }

    // Создаём матч с уже готовым счётом пенальти.
    final match = Match(
      homeTeam: generatedMatch.homeTeam,
      awayTeam: generatedMatch.awayTeam,
      homeGoals: generatedMatch.homeGoals,
      awayGoals: generatedMatch.awayGoals,
      playerGoals: generatedMatch.playerGoals,
      playerAssists: generatedMatch.playerAssists,
      yellowCards: generatedMatch.yellowCards,
      redCards: generatedMatch.redCards,
      playerRating: generatedMatch.playerRating,
      playerPlayed: generatedMatch.playerPlayed,
      homePenalties: homePenalties,
      awayPenalties: awayPenalties,
    );

    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MatchScreen(career: career, match: match, isCupMatch: true),
      ),
    );

    if (!mounted || updatedCareer == null) return;

    var updatedTournament = updatedCareer.championsLeague ?? tournament;

    if (isFinal) {
      updatedTournament = updatedTournament.playFinal(
        homeGoals: match.homeGoals,
        awayGoals: match.awayGoals,
        homePenalties: match.homePenalties,
        awayPenalties: match.awayPenalties,
      );
    } else {
      updatedTournament = updatedTournament.playLeg(
        tieIndex: tieIndex,
        isFirstLeg: isFirstLeg,
        homeGoals: match.homeGoals,
        awayGoals: match.awayGoals,
        homePenalties: match.homePenalties,
        awayPenalties: match.awayPenalties,
      );

      // Симулируем остальные пары этого игрового дня.
      final random = Random();

      for (var i = 0; i < updatedTournament.ties.length; i++) {
        if (i == tieIndex) continue;

        final otherTie = updatedTournament.ties[i];

        if (isFirstLeg) {
          if (otherTie.isFirstLegPlayed || otherTie.isCompleted) {
            continue;
          }
        } else {
          if (!otherTie.isFirstLegPlayed ||
              otherTie.isSecondLegPlayed ||
              otherTie.isCompleted) {
            continue;
          }
        }

        final actualHome = isFirstLeg ? otherTie.homeTeam : otherTie.awayTeam;

        final actualAway = isFirstLeg ? otherTie.awayTeam : otherTie.homeTeam;

        final homeStrength = _effectiveClubStrength(actualHome);
        final awayStrength = _effectiveClubStrength(actualAway);

        final simulatedHomeGoals = _simulateGoals(
          homeStrength,
          awayStrength,
          random,
          homeAdvantage: true,
        );

        final simulatedAwayGoals = _simulateGoals(
          awayStrength,
          homeStrength,
          random,
        );

        updatedTournament = updatedTournament.playLeg(
          tieIndex: i,
          isFirstLeg: isFirstLeg,
          homeGoals: simulatedHomeGoals,
          awayGoals: simulatedAwayGoals,
        );
      }
    }

    // Автоматически переходим к следующей стадии.
    if (!isFinal &&
        updatedTournament.ties.isNotEmpty &&
        updatedTournament.ties.every((tie) => tie.isCompleted)) {
      updatedTournament = updatedTournament.advanceStage();
    }

    final resultCareer = updatedCareer.copyWith(
      championsLeague: updatedTournament,
    );

    setState(() {
      career = resultCareer;
      isSaving = true;
    });

    await _saveCareer(resultCareer);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });
  }

  Future<void> _playEuropaLeagueMatch() async {
    if (isSaving || seasonFinishing) return;

    final tournament = career.europaLeague;
    final tieIndex = currentEuropaLeagueTieIndex;

    if (tournament == null || tieIndex == null) return;

    final tie = tournament.ties[tieIndex];
    final club = career.player.club;
    final isFinal = tournament.stage == EuropaLeagueStage.finalMatch;
    final isFirstLeg = !isFinal && !tie.isFirstLegPlayed;

    // Определяем, на какой стороне поля играет клуб игрока.
    final isHome = isFinal || isFirstLeg
        ? tie.homeTeam == club
        : tie.awayTeam == club;

    final opponent = tie.homeTeam == club ? tie.awayTeam : tie.homeTeam;

    final generatedMatch = Match.generate(
      player: career.player,
      career: career,
      opponent: opponent,
      isHome: isHome,
    );

    final homeGoals = generatedMatch.homeGoals;
    final awayGoals = generatedMatch.awayGoals;

    int? homePenalties;
    int? awayPenalties;

    // Проверяем, нужна ли серия пенальти.
    bool needsPenalties = false;

    if (isFinal) {
      // В финале пенальти нужны при ничьей.
      needsPenalties = homeGoals == awayGoals;
    } else if (!isFirstLeg) {
      // В ответном матче сравниваем общий счёт двух встреч.
      final homeTeamAggregate = tie.firstLegHomeGoals! + awayGoals;

      final awayTeamAggregate = tie.firstLegAwayGoals! + homeGoals;

      needsPenalties = homeTeamAggregate == awayTeamAggregate;
    }

    // Генерируем пенальти ДО открытия экрана матча.
    if (needsPenalties) {
      final random = Random();

      homePenalties = 3 + random.nextInt(3);
      awayPenalties = 3 + random.nextInt(3);

      while (homePenalties == awayPenalties) {
        awayPenalties = 3 + random.nextInt(3);
      }
    }

    // Создаём матч с уже готовым счётом пенальти.
    final match = Match(
      homeTeam: generatedMatch.homeTeam,
      awayTeam: generatedMatch.awayTeam,
      homeGoals: generatedMatch.homeGoals,
      awayGoals: generatedMatch.awayGoals,
      playerGoals: generatedMatch.playerGoals,
      playerAssists: generatedMatch.playerAssists,
      yellowCards: generatedMatch.yellowCards,
      redCards: generatedMatch.redCards,
      playerRating: generatedMatch.playerRating,
      playerPlayed: generatedMatch.playerPlayed,
      homePenalties: homePenalties,
      awayPenalties: awayPenalties,
    );

    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MatchScreen(career: career, match: match, isCupMatch: true),
      ),
    );

    if (!mounted || updatedCareer == null) return;

    var updatedTournament = updatedCareer.europaLeague ?? tournament;

    if (isFinal) {
      updatedTournament = updatedTournament.playFinal(
        homeGoals: match.homeGoals,
        awayGoals: match.awayGoals,
        homePenalties: match.homePenalties,
        awayPenalties: match.awayPenalties,
      );
    } else {
      updatedTournament = updatedTournament.playLeg(
        tieIndex: tieIndex,
        isFirstLeg: isFirstLeg,
        homeGoals: match.homeGoals,
        awayGoals: match.awayGoals,
        homePenalties: match.homePenalties,
        awayPenalties: match.awayPenalties,
      );

      // Симулируем остальные пары этого игрового дня.
      final random = Random();

      for (var i = 0; i < updatedTournament.ties.length; i++) {
        if (i == tieIndex) continue;

        final otherTie = updatedTournament.ties[i];

        if (isFirstLeg) {
          if (otherTie.isFirstLegPlayed || otherTie.isCompleted) {
            continue;
          }
        } else {
          if (!otherTie.isFirstLegPlayed ||
              otherTie.isSecondLegPlayed ||
              otherTie.isCompleted) {
            continue;
          }
        }

        final actualHome = isFirstLeg ? otherTie.homeTeam : otherTie.awayTeam;

        final actualAway = isFirstLeg ? otherTie.awayTeam : otherTie.homeTeam;

        final homeStrength = _effectiveClubStrength(actualHome);
        final awayStrength = _effectiveClubStrength(actualAway);

        final simulatedHomeGoals = _simulateGoals(
          homeStrength,
          awayStrength,
          random,
          homeAdvantage: true,
        );

        final simulatedAwayGoals = _simulateGoals(
          awayStrength,
          homeStrength,
          random,
        );

        updatedTournament = updatedTournament.playLeg(
          tieIndex: i,
          isFirstLeg: isFirstLeg,
          homeGoals: simulatedHomeGoals,
          awayGoals: simulatedAwayGoals,
        );
      }
    }

    // Автоматически переходим к следующей стадии.
    if (!isFinal &&
        updatedTournament.ties.isNotEmpty &&
        updatedTournament.ties.every((tie) => tie.isCompleted)) {
      updatedTournament = updatedTournament.advanceStage();
    }

    final resultCareer = updatedCareer.copyWith(
      europaLeague: updatedTournament,
    );

    setState(() {
      career = resultCareer;
      isSaving = true;
    });

    await _saveCareer(resultCareer);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });
  }

  // Future<void> _advanceChampionsLeague() async {
  //   if (isSaving || seasonFinishing) return;

  //   final tournament = career.championsLeague;
  //   if (tournament == null ||
  //       tournament.stage == ChampionsLeagueStage.finalMatch ||
  //       tournament.stage == ChampionsLeagueStage.completed ||
  //       tournament.ties.isEmpty ||
  //       tournament.ties.any((tie) => !tie.isCompleted)) {
  //     return;
  //   }

  //   final updatedTournament = tournament.advanceStage();
  //   final updatedCareer = career.copyWith(championsLeague: updatedTournament);

  //   setState(() {
  //     career = updatedCareer;
  //     isSaving = true;
  //   });

  //   await _saveCareer(updatedCareer);

  //   if (!mounted) return;

  //   setState(() {
  //     isSaving = false;
  //   });
  // }

  Future<void> _playCupMatch(CupMatch cupMatch) async {
    if (isSaving || seasonFinishing || cupMatch.isPlayed) return;

    final cup = career.domesticCup;
    if (cup == null) return;

    final playerClub = career.player.club;

    // Проверяем, что это действительно матч текущего кубкового раунда.
    final isPlayerMatch =
        cupMatch.homeTeam == playerClub || cupMatch.awayTeam == playerClub;

    if (!isPlayerMatch) return;

    // Нельзя играть матч из будущего или уже завершённой стадии.
    if (cupMatch.round != cup.currentRound) return;

    // Можно сыграть только ближайший доступный матч игрока.
    final nextCupMatch = currentCupMatch;
    if (nextCupMatch == null || nextCupMatch.id != cupMatch.id) return;

    final opponent = cupMatch.homeTeam == playerClub
        ? cupMatch.awayTeam
        : cupMatch.homeTeam;

    final isHome = cupMatch.homeTeam == playerClub;

    final generatedMatch = Match.generate(
      player: career.player,
      career: career,
      opponent: opponent,
      isHome: isHome,
    );

    int? homePenalties;
    int? awayPenalties;

    if (generatedMatch.homeGoals == generatedMatch.awayGoals) {
      final random = Random();

      homePenalties = 3 + random.nextInt(3);
      awayPenalties = 3 + random.nextInt(3);

      while (homePenalties == awayPenalties) {
        awayPenalties = 3 + random.nextInt(3);
      }
    }

    final match = Match(
      homeTeam: generatedMatch.homeTeam,
      awayTeam: generatedMatch.awayTeam,
      homeGoals: generatedMatch.homeGoals,
      awayGoals: generatedMatch.awayGoals,
      playerGoals: generatedMatch.playerGoals,
      playerAssists: generatedMatch.playerAssists,
      yellowCards: generatedMatch.yellowCards,
      redCards: generatedMatch.redCards,
      playerRating: generatedMatch.playerRating,
      playerPlayed: generatedMatch.playerPlayed,
      homePenalties: homePenalties,
      awayPenalties: awayPenalties,
    );

    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MatchScreen(career: career, match: match, isCupMatch: true),
      ),
    );

    if (!mounted || updatedCareer == null) return;

    // Используем тот же объект матча, который был передан в MatchScreen.
    final homeGoals = match.homeGoals;
    final awayGoals = match.awayGoals;

    var updatedCup = updatedCareer.domesticCup ?? cup;

    updatedCup = updatedCup.recordResult(
      matchId: cupMatch.id,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      homePenalties: homePenalties,
      awayPenalties: awayPenalties,
    );

    // Симулируем остальные матчи этого раунда.
    // Симулируем остальные матчи этого раунда.
    final roundMatches = updatedCup.matches
        .where((m) => m.round == cupMatch.round && !m.isPlayed)
        .toList();

    final random = Random();

    for (final otherMatch in roundMatches) {
      final homeStrength = _effectiveClubStrength(otherMatch.homeTeam);
      final awayStrength = _effectiveClubStrength(otherMatch.awayTeam);

      final homeGoals = _simulateGoals(
        homeStrength,
        awayStrength,
        random,
        homeAdvantage: true,
      );

      final awayGoals = _simulateGoals(awayStrength, homeStrength, random);

      int? penaltiesHome;
      int? penaltiesAway;

      if (homeGoals == awayGoals) {
        penaltiesHome = 3 + random.nextInt(3);
        penaltiesAway = 3 + random.nextInt(3);

        while (penaltiesHome == penaltiesAway) {
          penaltiesAway = 3 + random.nextInt(3);
        }
      }

      updatedCup = updatedCup.recordResult(
        matchId: otherMatch.id,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        homePenalties: penaltiesHome,
        awayPenalties: penaltiesAway,
      );
    }

    // Если клуб прошёл дальше, создаём следующий раунд.
    final playerWon =
        updatedCup.matches.firstWhere((m) => m.id == cupMatch.id).winner ==
        playerClub;

    if (playerWon && cupMatch.round < 4) {
      updatedCup = updatedCup.advanceRound();
    }

    final resultCareer = updatedCareer.copyWith(domesticCup: updatedCup);

    setState(() {
      career = resultCareer;
    });

    await _saveCareer(resultCareer);
  }

  List<LeagueMatch> _simulateBackgroundRound(
    List<LeagueMatch> fixtures,
    int round,
  ) {
    final random = Random();

    return fixtures.map((fixture) {
      if (fixture.round != round || fixture.isPlayed) {
        return fixture;
      }

      if (fixture.homeTeam == career.player.club ||
          fixture.awayTeam == career.player.club) {
        return fixture;
      }

      final homeStrength = _effectiveClubStrength(fixture.homeTeam);
      final awayStrength = _effectiveClubStrength(fixture.awayTeam);

      final homeGoals = _simulateGoals(
        homeStrength,
        awayStrength,
        random,
        homeAdvantage: true,
      );

      final awayGoals = _simulateGoals(awayStrength, homeStrength, random);

      return fixture.copyWith(homeGoals: homeGoals, awayGoals: awayGoals);
    }).toList();
  }

  int _effectiveClubStrength(String clubName) {
    return Clubs.effectiveStrength(
      clubName: clubName,
      playerClub: career.player.club,
      playerOverall: career.player.overall,
    );
  }

  int _simulateGoals(
    int teamStrength,
    int opponentStrength,
    Random random, {
    bool homeAdvantage = false,
  }) {
    final strengthDifference = teamStrength - opponentStrength;

    // Базовое ожидаемое количество голов.
    // Разница в силе влияет на атаку, но не гарантирует победу.
    final expectedGoals =
        (1.35 + strengthDifference * 0.035 + (homeAdvantage ? 0.15 : 0.0))
            .clamp(0.35, 2.8)
            .toDouble();

    // Распределение Пуассона.
    final threshold = exp(-expectedGoals);
    var product = 1.0;
    var goals = 0;

    do {
      goals++;
      product *= random.nextDouble();
    } while (product > threshold);

    return (goals - 1).clamp(0, 8).toInt();
  }

  List<LeagueTableEntry> _rebuildLeagueTable(
    String playerClub,
    List<LeagueMatch> fixtures,
  ) {
    final league = Clubs.leagueOf(playerClub);

    if (league == null) {
      return career.leagueTable;
    }

    final clubs = Clubs.byLeague(league);
    final opponents = clubs
        .where((club) => club.name != playerClub)
        .map((club) => club.name)
        .toList();

    var table = LeagueTable.create(playerClub, opponents);

    final playedFixtures =
        fixtures.where((fixture) => fixture.isPlayed).toList()..sort((a, b) {
          final roundComparison = a.round.compareTo(b.round);
          if (roundComparison != 0) return roundComparison;
          return a.id.compareTo(b.id);
        });

    for (final fixture in playedFixtures) {
      table = LeagueTable.applyMatch(
        table: table,
        homeTeam: fixture.homeTeam,
        awayTeam: fixture.awayTeam,
        homeGoals: fixture.homeGoals!,
        awayGoals: fixture.awayGoals!,
      );
    }

    return table;
  }

  Future<void> _finishSeason() async {
    if (!seasonFinished || isSaving || seasonFinishing) return;

    setState(() {
      seasonFinishing = true;
      isSaving = true;
    });

    final alreadyArchived = career.history.any(
      (stats) => stats.season == career.season,
    );

    var completedCareer = career.archiveCurrentSeason();

    // Зарплата и очки развития начисляются только один раз.
    if (!alreadyArchived) {
      completedCareer = completedCareer.copyWith(
        money: completedCareer.money + completedCareer.monthlySalary * 12,
      );
    }

    setState(() {
      career = completedCareer;
    });

    await _saveCareer(completedCareer);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    final developmentResult = await Navigator.push<Career>(
      context,
      MaterialPageRoute(builder: (_) => DevelopmentScreen(career: career)),
    );

    if (!mounted) return;

    if (developmentResult != null) {
      setState(() {
        career = developmentResult;
      });

      await _saveCareer(developmentResult);
    }

    if (!mounted) return;

    // Старый контракт уменьшается перед трансферным окном.
    // Новый контракт, подписанный в окне, сразу не уменьшается.
    if (!alreadyArchived) {
      final updatedContractCareer = career.copyWith(
        contractYears: career.contractYears > 0 ? career.contractYears - 1 : 0,
      );

      setState(() {
        career = updatedContractCareer;
      });

      await _saveCareer(updatedContractCareer);
    }

    if (!mounted) return;

    // После 20-го сезона карьера завершается.
    // Награды и статистика сезона к этому моменту уже сохранены.
    if (career.season >= 20) {
      final finishedCareer = career.copyWith(isCareerFinished: true);

      setState(() {
        career = finishedCareer;
        isSaving = true;
      });

      await _saveCareer(finishedCareer);

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      final endResult = await Navigator.push<Career>(
        context,
        MaterialPageRoute(
          builder: (_) => CareerEndScreen(career: finishedCareer),
        ),
      );

      if (!mounted) return;

      // Передаём завершённую карьеру обратно в PlayerScreen.
      Navigator.pop(context, endResult ?? finishedCareer);

      return;
    }

    await _openTransferWindowAndStartSeason();
  }

  Future<void> _openTransferWindowAndStartSeason() async {
    final transferResult = await Navigator.push<Career>(
      context,
      MaterialPageRoute(builder: (_) => TransferScreen(career: career)),
    );

    if (!mounted) return;

    // Если игрок принял предложение, используем карьеру после трансфера.
    if (transferResult != null) {
      career = transferResult;
    }

    // После трансферов сразу начинаем следующий сезон.
    // История текущего сезона уже сохранена до смены клуба.
    final nextCareer = career.startNextSeason();

    setState(() {
      career = nextCareer;
      isSaving = true;
    });

    await _saveCareer(nextCareer);

    if (!mounted) return;

    if (widget.calendarOnly) {
      Navigator.pop(context, nextCareer);
      return;
    }

    setState(() {
      isSaving = false;
      seasonFinishing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Durations.medium4,
        content: Text(
          '${AppStrings.seasonStarted} ${nextCareer.season} '
          '${AppStrings.seasonStartedSuffix}',
        ),
      ),
    );
  }

  Future<void> _openLeagueTable() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LeagueTableScreen(career: career)),
    );
  }

  Future<void> _openCalendar() async {
    final result = await Navigator.push<Career>(
      context,
      MaterialPageRoute(
        builder: (_) => SeasonScreen(career: career, calendarOnly: true),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => career = result);
    await _saveCareer(result);
  }

  Widget _buildCalendarButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _openCalendar(),
        icon: const Icon(Icons.calendar_month_rounded),
        label: const Text('КАЛЕНДАРЬ СЕЗОНА'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 3, 3, 3),
          backgroundColor: const Color.fromARGB(255, 189, 177, 177),
          side: const BorderSide(color: Color(0xFF24552C)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextMatch = currentMatch;
    final nextCupMatch = currentCupMatch;
    final nextUclIndex = currentChampionsLeagueTieIndex;

    final leaguePosition = nextMatch?.number.toDouble() ?? double.infinity;

    final cupPosition = nextCupMatch == null
        ? double.infinity
        : _cupScheduledRound(nextCupMatch) + 0.5;

    final uclPosition = nextUclIndex == null
        ? double.infinity
        : _championsLeagueScheduledPosition();
    final nextEuropaIndex = currentEuropaLeagueTieIndex;
    final europaPosition = nextEuropaIndex == null
        ? double.infinity
        : _europaLeagueScheduledPosition();

    final showUcl = uclPosition <= leaguePosition &&
        uclPosition <= cupPosition && uclPosition <= europaPosition;
    final showEuropa = !showUcl &&
        europaPosition <= leaguePosition && europaPosition <= cupPosition;
    final showCup = !showUcl && !showEuropa && cupPosition < leaguePosition;

    return PopScope<Career>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, career);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF061B0C),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(82, 81, 84, 82),
          foregroundColor: Colors.white,
          // shape: const RoundedRectangleBorder(
          //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
          // ),
          title: Text(
            widget.calendarOnly
                ? AppStrings.seasonCalendar
                : '${AppStrings.seasonTitle} ${career.season}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            if (!widget.calendarOnly)
              IconButton(
                tooltip: AppStrings.leagueTableTooltip,
                onPressed: _openLeagueTable,
                icon: SvgPicture.asset(
                  'assets/icons/table.svg',
                  width: 34,
                  height: 34,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.20,
                child: Image.asset('assets/images/fon2.png', fit: BoxFit.cover),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  if (!widget.calendarOnly) _buildCareerHeader(),
                  Expanded(
                    child: widget.calendarOnly
                        ? ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              if (career.worldCup != null)
                                _buildWorldCupCalendarSection(
                                  blocksSeason: worldCupBlocksSeason,
                                ),
                              if (!worldCupBlocksSeason) ...[
                                _buildSeasonMatches(),
                                const SizedBox(height: 16),
                                _buildSeasonButton(),
                              ] else
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  child: Text(
                                    'Календарь лиги будет доступен после завершения чемпионата мира.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                            ],
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              _buildProgressCard(),
                              const SizedBox(height: 16),
                              if (isSaving)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF8BE07F),
                                    ),
                                  ),
                                ),
                              if (career.worldCup != null)
                                _buildWorldCupCalendarSection(
                                  blocksSeason: worldCupBlocksSeason,
                                ),
                              if (worldCupBlocksSeason)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  child: Text(
                                    'Клубные матчи откроются после завершения чемпионата мира.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              else if (!seasonFinished && showUcl)
                                _buildNextChampionsLeagueMatchCard()
                              else if (!seasonFinished && showEuropa)
                                _buildNextEuropaLeagueMatchCard()
                              else if (!seasonFinished &&
                                  showCup &&
                                  nextCupMatch != null)
                                _buildNextCupMatchCard(nextCupMatch)
                              else if (!seasonFinished && nextMatch != null)
                                _buildNextMatchCard(nextMatch),
                              const SizedBox(height: 12),
                              _buildCalendarButton(),
                              const SizedBox(height: 10),
                              if (!worldCupBlocksSeason) _buildSeasonButton(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerHeader() {
    final primary = ClubColors.primary(career.player.club);
    final secondary = ClubColors.secondary(career.player.club);
    final league = Clubs.leagueOf(career.player.club);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            Color.lerp(primary, secondary, 0.25)!,
            const Color(0xFF071B0D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.yourClub,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [secondary, primary]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                child: Center(
                  child: Text(
                    career.player.club.isNotEmpty
                        ? career.player.club[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: secondary.computeLuminance() > 0.45
                          ? Colors.black
                          : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      career.player.club,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (league != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 103, 116, 108),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 30, 74, 42),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              league.logoAsset,
                              width: 26,
                              height: 26,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                league.displayName,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 253, 254, 253),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _headerStat(
                  AppStrings.seasonTitle,
                  '${career.season}/20',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _headerStat(
                  AppStrings.matchesLabel,
                  '$playedMatches/${career.seasonMatches.length}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _headerStat(AppStrings.ageLabel, '${career.player.age}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildCareerHeader() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: const BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           Color.fromARGB(255, 83, 87, 194),
  //           Color.fromARGB(255, 45, 67, 234),
  //           Color.fromARGB(255, 7, 1, 91),
  //         ],
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'ТВОЙ КЛУБ',
  //           style: TextStyle(
  //             color: Color.fromARGB(255, 254, 254, 254),
  //             fontSize: 12,
  //             fontWeight: FontWeight.bold,
  //             letterSpacing: 1.4,
  //           ),
  //         ),
  //         const SizedBox(height: 6),
  //         Text(
  //           career.player.club,
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontSize: 23,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           children: [
  //             _headerStat('Сезон', '${career.season}'),
  //             _headerStat(
  //               'Матчи',
  //               '$playedMatches/${career.seasonMatches.length}',
  //             ),
  //             _headerStat('Возраст', '${career.player.age}'),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _headerStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 80, 82, 80),
            Color.fromARGB(255, 59, 70, 63),
            Color(0xFF1A211C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color.fromARGB(255, 228, 232, 229),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(122, 83, 87, 194),
            Color.fromARGB(121, 53, 37, 142),
            Color.fromARGB(95, 12, 15, 100),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF24552C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppStrings.seasonStats,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _statItem(AppStrings.matchesLabel, '${career.matches}'),
              _statItem(AppStrings.goalsStat, '${career.goals}'),
              _statItem(AppStrings.assistsStat, '${career.assists}'),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              _statItem(AppStrings.yellowStat, '${career.yellowCards}'),
              _statItem(AppStrings.redStat, '${career.redCards}'),
              _statItem(
                AppStrings.ratingStat,
                career.averageRating?.toStringAsFixed(1) ?? '—',
              ),
            ],
          ),
          SizedBox(height: 4),
          Divider(height: 0.5, color: const Color.fromARGB(255, 131, 130, 130)),
          if (seasonFinished) ...[
            const SizedBox(height: 5),
            _buildTrophiesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildTrophiesSection() {
    final trophies = <String>[];

    // Чемпион страны
    final table = [...career.leagueTable]
      ..sort((a, b) {
        final pointsComparison = b.points.compareTo(a.points);
        if (pointsComparison != 0) return pointsComparison;

        return b.goalDifference.compareTo(a.goalDifference);
      });

    if (table.isNotEmpty && table.first.club == career.player.club) {
      trophies.add('Чемпион лиги');
    }

    // Кубок страны
    final cup = career.domesticCup;

    if (cup != null && cup.isFinished && cup.champion == career.player.club) {
      trophies.add('кубок страны');
    }

    // Лига чемпионов
    final championsLeague = career.championsLeague;

    if (championsLeague != null &&
        championsLeague.stage == ChampionsLeagueStage.completed &&
        championsLeague.champion == career.player.club) {
      trophies.add('Лига чемпионов');
    }

    // Лига Европы
    final europaLeague = career.europaLeague;
    if (europaLeague != null &&
        europaLeague.stage == EuropaLeagueStage.completed &&
        europaLeague.champion == career.player.club) {
      trophies.add('Лига Европы');
    }

    final worldCup = career.worldCup;
    if (worldCup != null &&
        worldCup.season == career.season &&
        worldCup.isCompleted &&
        worldCup.isPlayerCalledUp &&
        worldCup.champion == career.player.nationality) {
      trophies.add('Чемпион мира');
    }

    final league = Clubs.leagueOf(career.player.club);

    if (league != null && career.goals >= league.goldenBootGoalThreshold) {
      trophies.add('Золотая бутса');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppStrings.seasonTrophies,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),

        // Общий контейнер для всех трофеев
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color.fromARGB(147, 88, 86, 86),
            borderRadius: BorderRadius.circular(10),
          ),
          child: trophies.isEmpty
              ? Text(
                  AppStrings.noSeasonTrophies,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60),
                )
              : Column(
                  children: trophies.map((trophy) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          if (trophy == 'Лига Европы' ||
                              trophy == 'Чемпион мира')
                            SvgPicture.asset(
                              trophy == 'Лига Европы'
                                  ? 'assets/icons/europaleague.svg'
                                  : 'assets/icons/worldcup.svg',
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            )
                          else
                            Image.asset(
                              trophy == 'Лига чемпионов'
                                  ? 'assets/icons/uclphoto.png'
                                  : trophy == 'Золотая бутса'
                                  ? 'assets/icons/boot.png'
                                  : 'assets/icons/cup1.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppStrings.achievementName(trophy),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildChampionsLeagueCard() {
  //   final tournament = career.championsLeague;

  //   if (tournament == null ||
  //       !tournament.participants.contains(career.player.club)) {
  //     return const SizedBox.shrink();
  //   }

  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         colors: [Color(0xFF142D52), Color(0xFF0B1930), Color(0xFF102B17)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: const Color(0xFF5688D8)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             SvgPicture.asset(
  //               'assets/icons/ucl.svg',
  //               width: 28,
  //               height: 28,
  //               fit: BoxFit.contain,
  //             ),
  //             const SizedBox(width: 10),
  //             const Expanded(
  //               child: Text(
  //                 'ЛИГА ЧЕМПИОНОВ',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 17,
  //                   fontWeight: FontWeight.w900,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           tournament.stage.title,
  //           style: const TextStyle(
  //             color: Color(0xFF8DB8FF),
  //             fontSize: 14,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 14),
  //         if (tournament.stage == ChampionsLeagueStage.completed)
  //           Text(
  //             'Победитель: ${tournament.champion ?? "не определён"}',
  //             style: const TextStyle(
  //               color: Color(0xFF8BE07F),
  //               fontWeight: FontWeight.bold,
  //             ),
  //           )
  //         else
  //           ...tournament.ties.map((tie) {
  //             final firstLeg = tie.isFirstLegPlayed
  //                 ? '${tie.firstLegHomeGoals} : ${tie.firstLegAwayGoals}'
  //                 : '— : —';

  //             final secondLeg = tie.isSecondLegPlayed
  //                 ? '${tie.secondLegHomeGoals} : ${tie.secondLegAwayGoals}'
  //                 : '— : —';

  //             final finalResult = tie.isFinalPlayed
  //                 ? '${tie.finalHomeGoals} : ${tie.finalAwayGoals}'
  //                 : null;

  //             return Container(
  //               margin: const EdgeInsets.only(bottom: 8),
  //               padding: const EdgeInsets.all(10),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFF071526),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     '${tie.homeTeam} — ${tie.awayTeam}',
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 6),
  //                   if (tournament.stage == ChampionsLeagueStage.finalMatch)
  //                     Text(
  //                       'Финал: ${finalResult ?? "матч не сыгран"}',
  //                       style: const TextStyle(color: Colors.white70),
  //                     )
  //                   else ...[
  //                     Text(
  //                       'Первый матч: $firstLeg',
  //                       style: const TextStyle(color: Colors.white70),
  //                     ),
  //                     Text(
  //                       'Ответный матч: $secondLeg',
  //                       style: const TextStyle(color: Colors.white70),
  //                     ),
  //                   ],
  //                   if (tie.decidedByPenalties)
  //                     const Text(
  //                       'Победа по пенальти',
  //                       style: TextStyle(
  //                         color: Color(0xFF8BE07F),
  //                         fontSize: 12,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //             );
  //           }),

  //         if (currentChampionsLeagueTieIndex != null) ...[
  //           const SizedBox(height: 8),
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton.icon(
  //               onPressed: isSaving || seasonFinishing
  //                   ? null
  //                   : _playChampionsLeagueMatch,
  //               icon: const Icon(Icons.sports_soccer),
  //               label: Text(
  //                 tournament.stage == ChampionsLeagueStage.finalMatch
  //                     ? 'ИГРАТЬ ФИНАЛ'
  //                     : tournament
  //                           .ties[currentChampionsLeagueTieIndex!]
  //                           .isFirstLegPlayed
  //                     ? 'ИГРАТЬ ОТВЕТНЫЙ МАТЧ'
  //                     : 'ИГРАТЬ ПЕРВЫЙ МАТЧ',
  //               ),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: const Color(0xFF8DB8FF),
  //                 foregroundColor: const Color(0xFF071526),
  //                 padding: const EdgeInsets.symmetric(vertical: 14),
  //               ),
  //             ),
  //           ),
  //         ],

  //         if (tournament.stage != ChampionsLeagueStage.finalMatch &&
  //             tournament.stage != ChampionsLeagueStage.completed &&
  //             tournament.ties.isNotEmpty &&
  //             tournament.ties.every((tie) => tie.isCompleted)) ...[
  //           const SizedBox(height: 8),
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton(
  //               onPressed: isSaving || seasonFinishing
  //                   ? null
  //                   : _advanceChampionsLeague,
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: const Color(0xFF8BE07F),
  //                 foregroundColor: const Color(0xFF082A12),
  //                 padding: const EdgeInsets.symmetric(vertical: 14),
  //               ),
  //               child: Text(
  //                 'ПЕРЕЙТИ: ${tournament.stage.next.title.toUpperCase()}',
  //                 style: const TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildNextMatchCard(SeasonMatch match) {
    final playerColor = ClubColors.primary(career.player.club);
    final opponentColor = ClubColors.primary(match.opponent);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            playerColor,
            Color.lerp(playerColor, opponentColor, 0.45)!,
            const Color(0xFF102B17),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: opponentColor.withValues(alpha: 0.8)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.nextMatch,
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            match.isHome
                ? '${career.player.club} — ${match.opponent}'
                : '${match.opponent} — ${career.player.club}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${AppStrings.round} ${match.number} • '
            '${match.isHome ? AppStrings.home : AppStrings.away}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving || seasonFinishing
                  ? null
                  : () => _playMatch(match),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 249, 249, 249),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                ),
              ),
              child: Text(
                AppStrings.playMatch,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextCupMatchCard(CupMatch match) {
    final playerClub = career.player.club;
    final isHome = match.homeTeam == playerClub;
    final opponent = isHome ? match.awayTeam : match.homeTeam;

    final stage = switch (match.round) {
      1 => AppStrings.cupStageName(1),
      2 => AppStrings.cupStageName(2),
      3 => AppStrings.cupStageName(3),
      4 => AppStrings.cupStageName(4),
      _ => AppStrings.nationalCup,
    };

    final playerColor = ClubColors.primary(playerClub);
    final opponentColor = ClubColors.primary(opponent);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            playerColor,
            Color.lerp(playerColor, opponentColor, 0.45)!,
            const Color(0xFF102B17),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF8BE07F)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/cup.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(
                '${AppStrings.nextMatchUpper} · ${AppStrings.nationalCup.toUpperCase()}',
                style: TextStyle(
                  color: Color.fromARGB(255, 243, 245, 243),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${stage} · ${isHome ? AppStrings.homeVenue : AppStrings.awayVenue}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            isHome ? '$playerClub — $opponent' : '$opponent — $playerClub',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving || seasonFinishing
                  ? null
                  : () => _playCupMatch(match),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                foregroundColor: const Color.fromARGB(255, 1, 1, 1),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                ),
              ),
              child: Text(
                AppStrings.playMatchUpper,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonMatches() {
    final cup = career.domesticCup;
    final playerClub = career.player.club;
    final totalLeagueMatches = career.seasonMatches.length;

    final List<MapEntry<double, Widget>> calendarItems = [];

    for (final match in career.seasonMatches) {
      calendarItems.add(
        MapEntry(match.number.toDouble(), _buildMatchRow(match)),
      );
    }

    final cupMatches =
        cup?.matches.where((match) {
          final involvesPlayer =
              match.homeTeam == playerClub || match.awayTeam == playerClub;

          if (!involvesPlayer) return false;

          if (!cup.isTeamStillInCup(playerClub)) {
            return match.isPlayed;
          }

          return true;
        }).toList() ??
        <CupMatch>[];

    if (totalLeagueMatches > 0) {
      for (final match in cupMatches) {
        final progress = switch (match.round) {
          1 => 0.15,
          2 => 0.40,
          3 => 0.65,
          4 => 0.85,
          _ => 0.50,
        };

        final position = (totalLeagueMatches * progress).clamp(
          1.0,
          totalLeagueMatches.toDouble(),
        );

        calendarItems.add(MapEntry(position + 0.5, _buildCupMatchRow(match)));
      }

      final tournament = career.championsLeague;

      if (tournament != null && tournament.participants.contains(playerClub)) {
        // Все уже сыгранные матчи ЛЧ именно этого игрока.
        for (final match in tournament.matchHistory) {
          if (match.homeTeam != playerClub && match.awayTeam != playerClub) {
            continue;
          }

          calendarItems.add(
            MapEntry(
              _championsLeagueHistoryPosition(match),
              _buildChampionsLeagueHistoryRow(match),
            ),
          );
        }

        // Следующий матч игрока, если он ещё участвует в турнире.
        if (currentChampionsLeagueTieIndex != null) {
          calendarItems.add(
            MapEntry(
              _championsLeagueScheduledPosition(),
              _buildChampionsLeagueMatchRow(),
            ),
          );
        }
      }

      final europa = career.europaLeague;
      if (europa != null && europa.participants.contains(playerClub)) {
        for (final match in europa.matchHistory) {
          if (match.homeTeam != playerClub && match.awayTeam != playerClub) {
            continue;
          }
          calendarItems.add(
            MapEntry(
              _europaLeagueHistoryPosition(match),
              _buildEuropaLeagueHistoryRow(match),
            ),
          );
        }

        if (currentEuropaLeagueTieIndex != null) {
          calendarItems.add(
            MapEntry(
              _europaLeagueScheduledPosition(),
              _buildEuropaLeagueMatchRow(),
            ),
          );
        }
      }
    }

    calendarItems.sort((a, b) => a.key.compareTo(b.key));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(62, 28, 79, 41),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF24552C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.seasonCalendar,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (calendarItems.isEmpty)
            Text(
              AppStrings.matchesNotCreated,
              style: const TextStyle(color: Colors.white60),
            )
          else
            ...calendarItems.map((item) => item.value),
        ],
      ),
    );
  }

  Widget _buildNextChampionsLeagueMatchCard() {
    final tournament = career.championsLeague;
    final index = currentChampionsLeagueTieIndex;

    if (tournament == null || index == null) {
      return const SizedBox.shrink();
    }

    final tie = tournament.ties[index];
    final club = career.player.club;
    final isFinal = tournament.stage == ChampionsLeagueStage.finalMatch;
    final isFirstLeg = !isFinal && !tie.isFirstLegPlayed;
    final isHome = isFinal || isFirstLeg
        ? tie.homeTeam == club
        : tie.awayTeam == club;
    final opponent = tie.homeTeam == club ? tie.awayTeam : tie.homeTeam;

    final matchTitle = isFinal
        ? AppStrings.finalStage
        : isFirstLeg
        ? AppStrings.firstLegLabel
        : AppStrings.secondLegLabel;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5688D8)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Фоновое фото с прозрачностью
            Positioned.fill(
              child: Opacity(
                opacity: 0.5, // Меняй от 0.0 до 1.0
                child: Image.asset('assets/images/uclcard2.png'),
              ),
            ),

            // Градиент поверх фото
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF142D52).withValues(alpha: 0.65),
                      const Color.fromARGB(
                        255,
                        13,
                        31,
                        60,
                      ).withValues(alpha: 0.65),
                      const Color.fromARGB(
                        255,
                        16,
                        19,
                        43,
                      ).withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),

            // Содержимое карточки
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ucl.svg',
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${AppStrings.nextMatchUpper} · ${AppStrings.championsLeague.toUpperCase()}',
                          style: TextStyle(
                            color: Color(0xFF8DB8FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppStrings.tournamentStageName(tournament.stage.title)} · $matchTitle',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isHome ? '$club — $opponent' : '$opponent — $club',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving || seasonFinishing
                          ? null
                          : _playChampionsLeagueMatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8DB8FF),
                        foregroundColor: const Color(0xFF071526),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        AppStrings.playMatchUpper,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextEuropaLeagueMatchCard() {
    final tournament = career.europaLeague;
    final index = currentEuropaLeagueTieIndex;

    if (tournament == null || index == null) {
      return const SizedBox.shrink();
    }

    final tie = tournament.ties[index];
    final club = career.player.club;
    final isFinal = tournament.stage == EuropaLeagueStage.finalMatch;
    final isFirstLeg = !isFinal && !tie.isFirstLegPlayed;
    final isHome = isFinal || isFirstLeg
        ? tie.homeTeam == club
        : tie.awayTeam == club;
    final opponent = tie.homeTeam == club ? tie.awayTeam : tie.homeTeam;

    final matchTitle = isFinal
        ? AppStrings.finalStage
        : isFirstLeg
        ? AppStrings.firstLegLabel
        : AppStrings.secondLegLabel;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC857)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Фоновое фото с прозрачностью
            Positioned.fill(
              child: Opacity(
                opacity: 0.5, // Меняй от 0.0 до 1.0
                child: Image.asset('assets/images/fon2.png'),
              ),
            ),

            // Градиент поверх фото
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF493714).withValues(alpha: 0.65),
                      const Color.fromARGB(
                        255,
                        13,
                        31,
                        60,
                      ).withValues(alpha: 0.65),
                      const Color.fromARGB(
                        255,
                        16,
                        19,
                        43,
                      ).withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),

            // Содержимое карточки
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFC857), size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${AppStrings.nextMatchUpper} · ${AppStrings.europaLeague.toUpperCase()}',
                          style: TextStyle(
                            color: Color(0xFFFFC857),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppStrings.tournamentStageName(tournament.stage.title)} · $matchTitle',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isHome ? '$club — $opponent' : '$opponent — $club',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving || seasonFinishing
                          ? null
                          : _playEuropaLeagueMatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC857),
                        foregroundColor: const Color(0xFF1A1204),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        AppStrings.playMatchUpper,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupMatchRow(CupMatch cupMatch) {
    final playerClub = career.player.club;
    final isHome = cupMatch.homeTeam == playerClub;
    final opponent = isHome ? cupMatch.awayTeam : cupMatch.homeTeam;

    final stage = switch (cupMatch.round) {
      1 => AppStrings.cupStageName(1),
      2 => AppStrings.cupStageName(2),
      3 => AppStrings.cupStageName(3),
      4 => AppStrings.cupStageName(4),
      _ => AppStrings.nationalCup,
    };

    String? resultText;
    Color resultColor = Colors.white54;

    if (cupMatch.isPlayed) {
      resultText = '${cupMatch.homeGoals} : ${cupMatch.awayGoals}';

      if (cupMatch.isDraw) {
        resultText +=
            ' (пен. ${cupMatch.homePenalties}:${cupMatch.awayPenalties})';
      }

      if (cupMatch.winner == playerClub) {
        resultColor = const Color(0xFF8BE07F);
      } else {
        resultColor = Colors.redAccent;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.lerp(
          const Color(0xFF0A2110),
          ClubColors.primary(opponent),
          0.12,
        )!,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: const Color(0xFF8BE07F), width: 4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Image.asset(
              'assets/icons/cup.png',
              width: 25,
              height: 25,
              fit: BoxFit.contain,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.nationalCup} · $stage',
                  style: const TextStyle(
                    color: Color(0xFF8BE07F),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isHome ? AppStrings.home : AppStrings.away}: $opponent',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
          if (resultText != null) const SizedBox(width: 8),
          if (resultText != null)
            Flexible(
              child: Text(
                resultText,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: resultColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchRow(SeasonMatch match) {
    final result = match.result;

    String? resultText;
    Color resultColor = Colors.white54;

    if (match.isPlayed && result != null) {
      final playerGoals = match.isHome ? result.homeGoals : result.awayGoals;

      final opponentGoals = match.isHome ? result.awayGoals : result.homeGoals;

      resultText = match.playerDidNotPlay
          ? '$playerGoals : $opponentGoals | ${AppStrings.didNotPlay}'
          : '$playerGoals : $opponentGoals';

      if (playerGoals > opponentGoals) {
        resultColor = const Color(0xFF8BE07F);
      } else if (playerGoals < opponentGoals) {
        resultColor = Colors.redAccent;
      } else {
        resultColor = Colors.orangeAccent;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.lerp(
          const Color(0xFF0A2110),
          ClubColors.primary(match.opponent),
          0.12,
        )!,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: ClubColors.primary(match.opponent), width: 4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text(
              '${match.number} ${AppStrings.round.toLowerCase()}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              '${match.isHome ? AppStrings.home : AppStrings.away}: '
              '${match.opponent}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          if (resultText != null)
            Text(
              resultText,
              style: TextStyle(
                color: resultColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeasonButton() {
    if (!seasonFinished) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving || seasonFinishing ? null : _finishSeason,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8BE07F),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          AppStrings.finishSeason,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
