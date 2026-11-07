import 'dart:ui' as ui;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/career_news.dart';
import 'package:flutter_football/models/champions_league.dart';
import 'package:flutter_football/models/europa_league.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/cup_match.dart';
import 'package:flutter_football/models/league_player_season_stats.dart';
import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/models/season_match.dart';
import 'package:flutter_football/models/friendly_match.dart';
import 'package:flutter_football/models/season_stats.dart';
import 'package:flutter_football/models/world_cup.dart';
import 'package:flutter_football/models/player_of_month_award.dart';
import 'package:flutter_football/models/season_award.dart';
import 'package:flutter_football/services/season_award_service.dart';
import 'package:flutter_football/services/player_of_month_service.dart';
import 'package:flutter_football/screens/development_screen.dart';
import 'package:flutter_football/screens/home/home_screen.dart';
import 'package:flutter_football/screens/player/player_screen.dart';
import 'package:flutter_football/screens/shop_screen.dart';
import 'package:flutter_football/screens/coach_screen.dart';
import 'package:flutter_football/screens/team_screen.dart';
import 'package:flutter_football/screens/agent_screen.dart';
import 'package:flutter_football/screens/news_screen.dart';
import 'package:flutter_football/screens/league_table/league_table_screen.dart';
import 'package:flutter_football/screens/match/match_screen.dart';
import 'package:flutter_football/screens/match/interactive_match_screen.dart';
import 'package:flutter_football/screens/transfers/transfer_screen.dart';
import 'package:flutter_football/widgets/jersey_number_picker.dart';
import 'package:flutter_football/screens/world_cup_screen.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/screens/press_conference_dialog.dart';
import 'package:flutter_football/services/career_storage.dart';
import 'package:flutter_football/services/fc_points_service.dart';
import 'package:flutter_football/services/fatigue_service.dart';
import 'package:flutter_football/services/match_simulation_service.dart';
import 'package:flutter_football/screens/career_end_screen.dart';
import 'package:flutter_football/widgets/liquid_glass.dart';
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
  PlayerOfMonthAward? recentMonthlyAward;

  @override
  void initState() {
    super.initState();
    career = widget.career;
  }

  bool _canPlayInteractiveMatch({
    required String opponent,
    required bool isHome,
  }) => Match.willPlayerPlay(
    player: career.player,
    career: career,
    opponent: opponent,
    isHome: isHome,
  );

  bool _playerWonMatchWithPenalties(Match match, String team) {
    final isHome = match.homeTeam == team;
    if (match.hasPenalties) {
      final teamPenalties = isHome
          ? match.homePenalties!
          : match.awayPenalties!;
      final opponentPenalties = isHome
          ? match.awayPenalties!
          : match.homePenalties!;
      return teamPenalties > opponentPenalties;
    }
    final teamGoals = isHome ? match.homeGoals : match.awayGoals;
    final opponentGoals = isHome ? match.awayGoals : match.homeGoals;
    return teamGoals > opponentGoals;
  }

  bool get worldCupBlocksSeason {
    final tournament = career.worldCup;
    return tournament != null &&
        !tournament.isCompleted &&
        tournament.isPlayerCalledUp;
  }

  Future<void> _openWorldCup() async {
    final tournament = career.worldCup;
    if (!mounted || tournament == null) return;

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
    final nationalMatches = [...tournament.matchHistory, ...tournament.matches]
        .where(
          (match) =>
              match.homeTeam == career.player.nationality ||
              match.awayTeam == career.player.nationality,
        )
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
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
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Чемпионат мира',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${tournament.season}/20',
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (nationalMatches.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text(
              'Матчи вашей сборной',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            ...nationalMatches.map((match) {
              final isPlayed = match.isPlayed;
              final isHome = match.homeTeam == career.player.nationality;
              final opponent = isHome ? match.awayTeam : match.homeTeam;
              final score = isPlayed
                  ? '${match.homeGoals} : ${match.awayGoals}'
                  : '— : —';
              return Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF061B0C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sports_soccer,
                      color: Color(0xFF8BE07F),
                      size: 13,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.stage?.title ?? 'Стадия не указана',
                            style: const TextStyle(
                              color: Color(0xFF8BE07F),
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${isHome ? 'Дома' : 'В гостях'}: $opponent',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      score,
                      style: TextStyle(
                        color: isPlayed
                            ? const Color(0xFF8BE07F)
                            : Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 4),
          SizedBox(
            height: 34,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isSaving ? null : _openWorldCup,
              icon: Icon(
                tournament.isCompleted
                    ? Icons.emoji_events
                    : Icons.sports_soccer,
              ),
              label: Text(
                style: TextStyle(fontSize: 13),
                tournament.isCompleted
                    ? 'Смотреть итоги и статистику'
                    : tournament.isPlayerCalledUp
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
      ),
    );
  }

  int get playedMatches =>
      career.seasonMatches.where((match) => match.isPlayed).length;

  int get _worldCupMatchesForSeason {
    final cup = career.worldCup;
    return cup != null && cup.season == career.season && cup.isPlayerCalledUp
        ? cup.playerMatches
        : 0;
  }

  int get _worldCupGoalsForSeason {
    final cup = career.worldCup;
    return cup != null && cup.season == career.season && cup.isPlayerCalledUp
        ? cup.playerGoals
        : 0;
  }

  int get _worldCupAssistsForSeason {
    final cup = career.worldCup;
    return cup != null && cup.season == career.season && cup.isPlayerCalledUp
        ? cup.playerAssists
        : 0;
  }

  int get _seasonMatchesForDisplay =>
      career.matches + _worldCupMatchesForSeason;

  int get _seasonGoalsForDisplay => career.goals + _worldCupGoalsForSeason;

  int get _seasonAssistsForDisplay =>
      career.assists + _worldCupAssistsForSeason;

  double? get _seasonAverageRatingForDisplay {
    final totalMatches = _seasonMatchesForDisplay;
    if (totalMatches == 0) return null;
    final cup =
        career.worldCup != null &&
            career.worldCup!.season == career.season &&
            career.worldCup!.isPlayerCalledUp
        ? career.worldCup
        : null;
    final totalRating =
        (career.averageRating ?? 0) * career.matches +
        (cup?.playerAverageRating ?? 0) * _worldCupMatchesForSeason;
    return totalRating / totalMatches;
  }

  bool get seasonFinished {
    if (worldCupBlocksSeason) return false;

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
    if (europa != null && europa.stage != EuropaLeagueStage.completed) {
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
    if (tournament == null || tournament.stage == EuropaLeagueStage.completed) {
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
    if (tournament == null || tournament.stage == EuropaLeagueStage.completed) {
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
        color: const Color(0xFF0A2110).withValues(alpha: 0.68),
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

    if (match.stage == EuropaLeagueStage.finalMatch && match.winner != null) {
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
        color: const Color(0xFF0A2110).withValues(alpha: 0.68),
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

    return _buildMatchGlassSurface(
      child: Container(
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
      ),
    );
  }

  Widget _buildRecentMonthlyAwardCard() {
    final award = recentMonthlyAward;
    if (award == null || award.isCareerPlayer) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF102719).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFB99A45).withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFFFD54F),
            size: 25,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Игрок месяца · ${award.monthName}',
                  style: const TextStyle(
                    color: Color(0xFFFFD54F),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  award.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!career.rivals.any(
                  (rival) => rival.name == award.playerName,
                ))
                  Text(
                    '${award.club}  ·  ${award.matches} матч.  ·  ${award.goals} гол.  ·  ${award.assists} асс.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  )
                else
                  Text(
                    award.club,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            award.averageRating.toStringAsFixed(1),
            style: const TextStyle(
              color: Color(0xFF8BE07F),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPlayerOfMonthAward(PlayerOfMonthAward award) async {
    if (!mounted) return;
    final isEnglish = AppStrings.isEnglish;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: isEnglish ? 'Close award' : 'Закрыть награду',
      barrierColor: Colors.black.withValues(alpha: 0.58),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340, maxHeight: 390),
              child: _buildLiquidGlassSurface(
                radius: 22,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFD54F,
                          ).withValues(alpha: 0.13),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFFFFD54F,
                            ).withValues(alpha: 0.45),
                          ),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFFFD54F),
                          size: 27,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isEnglish ? 'PLAYER OF THE MONTH' : 'ИГРОК МЕСЯЦА',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFFD54F),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        award.monthName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8BE07F),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        award.playerName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        award.club,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _awardStat(
                            isEnglish ? 'MATCHES' : 'МАТЧИ',
                            award.matches.toString(),
                          ),
                          _awardStat(
                            isEnglish ? 'GOALS' : 'ГОЛЫ',
                            award.goals.toString(),
                          ),
                          _awardStat(
                            isEnglish ? 'ASSISTS' : 'АССИСТЫ',
                            award.assists.toString(),
                          ),
                          _awardStat(
                            isEnglish ? 'RATING' : 'ОЦЕНКА',
                            award.averageRating.toStringAsFixed(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF8BE07F),
                            foregroundColor: const Color(0xFF082A12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEnglish ? 'Continue' : 'Продолжить',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _showSeasonAwards(List<SeasonAward> awards) async {
    if (!mounted || awards.isEmpty) return;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (dialogContext, animation, secondaryAnimation) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 11, sigmaY: 11),
              child: Container(color: Colors.black.withValues(alpha: 0.58)),
            ),
          ),
          Center(
            child: Dialog(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              child: _buildLiquidGlassSurface(
                radius: 26,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                    maxHeight: 560,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Color(0xFFFFD54F),
                          size: 38,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ИТОГИ СЕЗОНА',
                          style: TextStyle(
                            color: Color(0xFF8BE07F),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Flexible(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              for (final award in awards.where(
                                (item) => item.category != 'Команда года',
                              ))
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(11),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10351A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.military_tech,
                                        color: Color(0xFFFFD54F),
                                      ),
                                      const SizedBox(width: 9),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              award.category.toUpperCase(),
                                              style: const TextStyle(
                                                color: Color(0xFF8BE07F),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text(
                                              award.playerName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              award.club,
                                              style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (award.isCareerPlayer)
                                        const Icon(
                                          Icons.stars,
                                          color: Color(0xFFFFD54F),
                                        ),
                                    ],
                                  ),
                                ),
                              _buildLiquidGlassSurface(
                                radius: 18,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'КОМАНДА ГОДА',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 9),
                                      for (final player in awards.where(
                                        (item) =>
                                            item.category == 'Команда года',
                                      ))
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 5,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.055,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.09,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 34,
                                                child: Text(
                                                  player.positionLabel,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  player.playerName,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                player.club,
                                                style: const TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(
                            'Продолжить',
                            style: TextStyle(
                              color: Color(0xFF8BE07F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchGlassSurface({required Widget child, double radius = 18}) {
    // Оставляем только скругление: календарю больше не нужен blur/backdrop.
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }

  Widget _buildLiquidGlassSurface({required Widget child, double radius = 24}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xC91B1D20),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.06),
                blurRadius: 30,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.42),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1,
                child: Container(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _awardStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 3),
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 8)),
      ],
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

  Future<void> _playMatch(
    SeasonMatch seasonMatch, {
    required bool interactive,
  }) async {
    if (isSaving || seasonFinishing || seasonMatch.isPlayed) return;
    if (interactive &&
        !_canPlayInteractiveMatch(
          opponent: seasonMatch.opponent,
          isHome: seasonMatch.isHome,
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            career.isInjured
                ? 'Из-за травмы интерактивный матч недоступен.'
                : 'Тренер не планирует выпускать вас на поле в этом матче.',
          ),
        ),
      );
      return;
    }

    final worldCup = career.worldCup;
    if (worldCup != null && !worldCup.isCompleted) {
      final updatedCareer = await Navigator.push<Career>(
        context,
        MaterialPageRoute(builder: (_) => WorldCupScreen(career: career)),
      );
      if (!mounted || updatedCareer == null) return;
      setState(() => career = updatedCareer);
      await _saveCareer(updatedCareer);
      return;
    }

    final nextMatch = currentMatch;

    if (nextMatch == null || nextMatch.number != seasonMatch.number) {
      return;
    }

    if (!mounted) return;

    Match? match;
    Career? classicUpdatedCareer;
    if (interactive) {
      match = await Navigator.push<Match>(
        context,
        MaterialPageRoute(
          builder: (_) => InteractiveMatchScreen(
            career: career.copyWith(player: career.playerForMatch),
            opponent: seasonMatch.opponent,
            isHome: seasonMatch.isHome,
            playerWillPlay: true,
          ),
        ),
      );
    } else {
      match = Match.generate(
        player: career.playerForMatch,
        career: career,
        opponent: seasonMatch.opponent,
        isHome: seasonMatch.isHome,
      );

      classicUpdatedCareer = await Navigator.push<Career>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MatchScreen(career: career, match: match!, isCupMatch: false),
        ),
      );
    }

    if (!mounted || match == null) return;

    final playedMatch = match;
    var updatedCareer = classicUpdatedCareer ?? career.afterMatch(playedMatch);
    // Проверяем, что матч соответствует клубу игрока и сопернику.
    final expectedHomeTeam = seasonMatch.isHome
        ? career.player.club
        : seasonMatch.opponent;
    final expectedAwayTeam = seasonMatch.isHome
        ? seasonMatch.opponent
        : career.player.club;

    if (playedMatch.homeTeam != expectedHomeTeam ||
        playedMatch.awayTeam != expectedAwayTeam) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.matchCalendarError)));
      return;
    }

    if (interactive) {
      updatedCareer = await _maybeShowPressConference(
        updatedCareer,
        playedMatch,
      );
    }

    // Сохраняем результат матча в календаре игрока.
    final updatedSeasonMatches = updatedCareer.seasonMatches.map((item) {
      if (item.number == seasonMatch.number && !item.isPlayed) {
        return item.copyWith(result: playedMatch);
      }

      return item;
    }).toList();

    // Сохраняем результат в общем календаре лиги.
    final updatedLeagueMatches = updatedCareer.leagueMatches.map((fixture) {
      final isSameMatch =
          fixture.round == seasonMatch.number &&
          fixture.homeTeam == playedMatch.homeTeam &&
          fixture.awayTeam == playedMatch.awayTeam;

      if (isSameMatch && !fixture.isPlayed) {
        return fixture.copyWith(
          homeGoals: playedMatch.homeGoals,
          awayGoals: playedMatch.awayGoals,
        );
      }

      return fixture;
    }).toList();

    // Симулируем только ещё не сыгранные матчи этого тура.
    final completedLeagueMatches =
        MatchSimulationService.simulateBackgroundRound(
          fixtures: updatedLeagueMatches,
          round: seasonMatch.number,
          playerClub: career.player.club,
          playerOverall: career.player.overall,
        );

    // Полностью пересчитываем таблицу по сохранённым результатам.
    final updatedTable = MatchSimulationService.rebuildLeagueTable(
      playerClub: updatedCareer.player.club,
      fixtures: completedLeagueMatches,
      division: career.currentLeagueDivision,
      divisions: career.leagueDivisions,
      fallbackTable: career.leagueTable,
    );

    // Обновляем сезонную статистику футболистов всех клубов лиги.
    // Список обработанных матчей защищает от повторного начисления статистики
    // при загрузке сохранения или повторном пересчёте календаря.
    final leagueStatsUpdate = LeaguePlayerStatsService.update(
      season: updatedCareer.season,
      current: updatedCareer.leaguePlayerStats,
      processedMatchKeys: updatedCareer.leagueStatsProcessedMatchKeys,
      fixtures: completedLeagueMatches,
    );

    var awards = List<PlayerOfMonthAward>.from(
      updatedCareer.playerOfMonthAwards,
    );
    PlayerOfMonthAward? monthlyWinner;
    final totalRounds = updatedSeasonMatches.length;
    if (totalRounds > 0) {
      final month = (((seasonMatch.number * 12) - 1) ~/ totalRounds) + 1;
      final monthEndRound = (month * totalRounds) ~/ 12;
      if (seasonMatch.number == monthEndRound) {
        monthlyWinner = PlayerOfMonthService.create(
          season: updatedCareer.season,
          month: month,
          player: updatedCareer.player,
          playerMatches: updatedSeasonMatches,
          leagueMatches: completedLeagueMatches,
          leaguePlayerStats: leagueStatsUpdate.players,
          previousAwards: awards,
          rivals: updatedCareer.rivals,
        );
        if (monthlyWinner != null) awards.add(monthlyWinner);
      }
    }

    final completeCareer = updatedCareer.copyWith(
      seasonMatches: updatedSeasonMatches,
      leagueMatches: completedLeagueMatches,
      leagueTable: updatedTable,
      leaguePlayerStats: leagueStatsUpdate.players,
      leagueStatsProcessedMatchKeys: leagueStatsUpdate.processedMatchKeys,
      playerOfMonthAwards: awards,
    );

    setState(() {
      career = completeCareer;
      recentMonthlyAward =
          monthlyWinner != null && !monthlyWinner.isCareerPlayer
          ? monthlyWinner
          : null;
      isSaving = true;
    });

    await _saveCareer(completeCareer);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    if (monthlyWinner != null && monthlyWinner.isCareerPlayer) {
      await _showPlayerOfMonthAward(monthlyWinner);
    }
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

    return _buildMatchGlassSurface(
      child: Container(
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
      ),
    );
  }

  Future<void> _playChampionsLeagueMatch({required bool interactive}) async {
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

    if (isFinal) {
      await _showTournamentPreviewConference();
      if (!mounted) return;
    }

    if (interactive &&
        !_canPlayInteractiveMatch(opponent: opponent, isHome: isHome)) {
      return;
    }

    Match generatedMatch;
    Career? interactiveCareer;
    if (interactive) {
      final played = await Navigator.push<Match>(
        context,
        MaterialPageRoute(
          builder: (_) => InteractiveMatchScreen(
            career: career.copyWith(player: career.playerForMatch),
            opponent: opponent,
            isHome: isHome,
            playerWillPlay: true,
            isKnockout: isFinal || !isFirstLeg,
            competition: 'championsLeague',
            homeAggregateGoalsBeforeMatch: isFinal
                ? 0
                : (tie.firstLegAwayGoals ?? 0),
            awayAggregateGoalsBeforeMatch: isFinal
                ? 0
                : (tie.firstLegHomeGoals ?? 0),
          ),
        ),
      );
      if (!mounted || played == null) return;
      generatedMatch = played;
      interactiveCareer = career.afterMatch(played);
    } else {
      generatedMatch = Match.generate(
        player: career.playerForMatch,
        career: career,
        opponent: opponent,
        isHome: isHome,
      );
    }

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

    // Интерактивный матч уже возвращает результат серии пенальти.
    if (generatedMatch.hasPenalties) {
      homePenalties = generatedMatch.homePenalties;
      awayPenalties = generatedMatch.awayPenalties;
    } else if (needsPenalties) {
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

    final homeTeamAggregate = !isFinal && !isFirstLeg
        ? tie.firstLegHomeGoals! + awayGoals
        : 0;
    final awayTeamAggregate = !isFinal && !isFirstLeg
        ? tie.firstLegAwayGoals! + homeGoals
        : 0;
    final playerAggregate = isHome ? awayTeamAggregate : homeTeamAggregate;
    final opponentAggregate = isHome ? homeTeamAggregate : awayTeamAggregate;
    final playerPenalties = isHome ? homePenalties : awayPenalties;
    final opponentPenalties = isHome ? awayPenalties : homePenalties;
    final playerEliminated =
        !isFinal &&
        !isFirstLeg &&
        (playerAggregate < opponentAggregate ||
            (playerAggregate == opponentAggregate &&
                playerPenalties != null &&
                opponentPenalties != null &&
                playerPenalties < opponentPenalties));
    final isTournamentDecider = !isFinal && playerEliminated;

    var updatedCareer = interactive
        ? interactiveCareer
        : await Navigator.push<Career>(
            context,
            MaterialPageRoute(
              builder: (_) => MatchScreen(
                career: career,
                match: match,
                isCupMatch: true,
                isTournamentDecider: isTournamentDecider,
              ),
            ),
          );
    if (interactive && updatedCareer != null) {
      updatedCareer = await _maybeShowPressConference(
        updatedCareer,
        match,
        isTournamentDecider: isTournamentDecider,
        includeSeasonMilestones: false,
      );
    }

    if (!mounted || updatedCareer == null) return;

    if (isFinal &&
        match.playerPlayed &&
        _playerWonMatchWithPenalties(match, career.player.club)) {
      updatedCareer = updatedCareer.copyWith(
        agentCredits: updatedCareer.agentCredits + 10,
      );
    }

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

        final simulatedHomeGoals = MatchSimulationService.simulateGoals(
          homeStrength,
          awayStrength,
          random,
          homeAdvantage: true,
        );

        final simulatedAwayGoals = MatchSimulationService.simulateGoals(
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

  Future<void> _playEuropaLeagueMatch({required bool interactive}) async {
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

    if (interactive &&
        !_canPlayInteractiveMatch(opponent: opponent, isHome: isHome)) {
      return;
    }

    Match generatedMatch;
    Career? interactiveCareer;
    if (interactive) {
      final played = await Navigator.push<Match>(
        context,
        MaterialPageRoute(
          builder: (_) => InteractiveMatchScreen(
            career: career.copyWith(player: career.playerForMatch),
            opponent: opponent,
            isHome: isHome,
            playerWillPlay: true,
            isKnockout: isFinal || !isFirstLeg,
            competition: 'europaLeague',
            homeAggregateGoalsBeforeMatch: isFinal
                ? 0
                : (tie.firstLegAwayGoals ?? 0),
            awayAggregateGoalsBeforeMatch: isFinal
                ? 0
                : (tie.firstLegHomeGoals ?? 0),
          ),
        ),
      );
      if (!mounted || played == null) return;
      generatedMatch = played;
      interactiveCareer = career.afterMatch(played);
    } else {
      generatedMatch = Match.generate(
        player: career.playerForMatch,
        career: career,
        opponent: opponent,
        isHome: isHome,
      );
    }

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

    // Интерактивный матч уже возвращает результат серии пенальти.
    if (generatedMatch.hasPenalties) {
      homePenalties = generatedMatch.homePenalties;
      awayPenalties = generatedMatch.awayPenalties;
    } else if (needsPenalties) {
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

    final homeTeamAggregate = !isFinal && !isFirstLeg
        ? tie.firstLegHomeGoals! + awayGoals
        : 0;
    final awayTeamAggregate = !isFinal && !isFirstLeg
        ? tie.firstLegAwayGoals! + homeGoals
        : 0;
    final playerAggregate = isHome ? awayTeamAggregate : homeTeamAggregate;
    final opponentAggregate = isHome ? homeTeamAggregate : awayTeamAggregate;
    final playerPenalties = isHome ? homePenalties : awayPenalties;
    final opponentPenalties = isHome ? awayPenalties : homePenalties;
    final playerEliminated =
        !isFinal &&
        !isFirstLeg &&
        (playerAggregate < opponentAggregate ||
            (playerAggregate == opponentAggregate &&
                playerPenalties != null &&
                opponentPenalties != null &&
                playerPenalties < opponentPenalties));
    final isTournamentDecider = !isFinal && playerEliminated;

    var updatedCareer = interactive
        ? interactiveCareer
        : await Navigator.push<Career>(
            context,
            MaterialPageRoute(
              builder: (_) => MatchScreen(
                career: career,
                match: match,
                isCupMatch: true,
                isTournamentDecider: isTournamentDecider,
              ),
            ),
          );
    if (interactive && updatedCareer != null) {
      updatedCareer = await _maybeShowPressConference(
        updatedCareer,
        match,
        isTournamentDecider: isTournamentDecider,
        includeSeasonMilestones: false,
      );
    }

    if (!mounted || updatedCareer == null) return;

    if (isFinal &&
        match.playerPlayed &&
        _playerWonMatchWithPenalties(match, career.player.club)) {
      updatedCareer = updatedCareer.copyWith(
        agentCredits: updatedCareer.agentCredits + 10,
      );
    }

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

        final simulatedHomeGoals = MatchSimulationService.simulateGoals(
          homeStrength,
          awayStrength,
          random,
          homeAdvantage: true,
        );

        final simulatedAwayGoals = MatchSimulationService.simulateGoals(
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

  Future<void> _playCupMatch(
    CupMatch cupMatch, {
    required bool interactive,
  }) async {
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

    if (cupMatch.round == cup.totalRounds) {
      await _showTournamentPreviewConference();
      if (!mounted) return;
    }

    if (interactive &&
        !_canPlayInteractiveMatch(opponent: opponent, isHome: isHome)) {
      return;
    }

    Match generatedMatch;
    Career? interactiveCareer;
    if (interactive) {
      final played = await Navigator.push<Match>(
        context,
        MaterialPageRoute(
          builder: (_) => InteractiveMatchScreen(
            career: career.copyWith(player: career.playerForMatch),
            opponent: opponent,
            isHome: isHome,
            playerWillPlay: true,
            isKnockout: true,
          ),
        ),
      );
      if (!mounted || played == null) return;
      generatedMatch = played;
      interactiveCareer = career.afterMatch(played);
    } else {
      generatedMatch = Match.generate(
        player: career.playerForMatch,
        career: career,
        opponent: opponent,
        isHome: isHome,
      );
    }

    int? homePenalties;
    int? awayPenalties;

    if (generatedMatch.hasPenalties) {
      homePenalties = generatedMatch.homePenalties;
      awayPenalties = generatedMatch.awayPenalties;
    } else if (generatedMatch.homeGoals == generatedMatch.awayGoals) {
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

    final cupWinner = match.homeGoals > match.awayGoals
        ? match.homeTeam
        : match.awayGoals > match.homeGoals
        ? match.awayTeam
        : (homePenalties ?? 0) > (awayPenalties ?? 0)
        ? match.homeTeam
        : match.awayTeam;
    final isTournamentDecider = cupWinner != playerClub;

    var updatedCareer = interactive
        ? interactiveCareer
        : await Navigator.push<Career>(
            context,
            MaterialPageRoute(
              builder: (_) => MatchScreen(
                career: career,
                match: match,
                isCupMatch: true,
                isTournamentDecider: isTournamentDecider,
              ),
            ),
          );
    if (interactive && updatedCareer != null) {
      updatedCareer = await _maybeShowPressConference(
        updatedCareer,
        match,
        isTournamentDecider: isTournamentDecider,
        includeSeasonMilestones: false,
      );
    }

    if (!mounted || updatedCareer == null) return;

    if (cupMatch.round == cup.totalRounds &&
        cupWinner == playerClub &&
        match.playerPlayed) {
      updatedCareer = updatedCareer.copyWith(
        agentCredits: updatedCareer.agentCredits + 10,
      );
    }

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

      final homeGoals = MatchSimulationService.simulateGoals(
        homeStrength,
        awayStrength,
        random,
        homeAdvantage: true,
      );

      final awayGoals = MatchSimulationService.simulateGoals(
        awayStrength,
        homeStrength,
        random,
      );

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

    if (playerWon && cupMatch.round < updatedCup.totalRounds) {
      updatedCup = updatedCup.advanceRound();
    }

    final resultCareer = updatedCareer.copyWith(domesticCup: updatedCup);

    setState(() {
      career = resultCareer;
    });

    await _saveCareer(resultCareer);
  }

  int _effectiveClubStrength(String clubName) {
    return Clubs.effectiveStrength(
      clubName: clubName,
      playerClub: career.player.club,
      playerOverall: career.player.overall,
    );
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

    // На случай старого сохранения восстанавливаем статистику по уже
    // сыгранным матчам календаря, не начисляя повторно обработанные матчи.
    final finalLeagueStats = LeaguePlayerStatsService.update(
      season: career.season,
      current: completedCareer.leaguePlayerStats,
      processedMatchKeys: completedCareer.leagueStatsProcessedMatchKeys,
      fixtures: completedCareer.leagueMatches,
    );
    completedCareer = completedCareer.copyWith(
      leaguePlayerStats: finalLeagueStats.players,
      leagueStatsProcessedMatchKeys: finalLeagueStats.processedMatchKeys,
    );

    // Проверяем полноту индивидуальных наград. Это также чинит сохранения,
    // где сезон уже был архивирован старой версией игры с неполным списком.
    final existingSeasonAwards = completedCareer.seasonAwards
        .where((item) => item.season == career.season)
        .toList();
    const requiredAwardCategories = [
      'Лучший бомбардир',
      'Лучший ассистент',
      'Золотой мяч',
    ];
    final hasAllMajorAwards = requiredAwardCategories.every(
      (category) =>
          existingSeasonAwards.any((award) => award.category == category),
    );
    var awardsUpdated = false;

    if (!alreadyArchived || !hasAllMajorAwards) {
      awardsUpdated = true;
      final leagueAppearances = career.seasonMatches
          .where(
            (item) =>
                item.isPlayed &&
                item.result != null &&
                item.result!.playerPlayed,
          )
          .toList();
      final leagueGoals = leagueAppearances.fold<int>(
        0,
        (sum, item) => sum + item.result!.playerGoals,
      );
      final leagueAssists = leagueAppearances.fold<int>(
        0,
        (sum, item) => sum + item.result!.playerAssists,
      );
      final leagueRating = leagueAppearances.isEmpty
          ? null
          : leagueAppearances.fold<double>(
                  0,
                  (sum, item) => sum + item.result!.playerRating,
                ) /
                leagueAppearances.length;

      final overallSeasonStats = completedCareer.history
          .where((stats) => stats.season == career.season)
          .toList();
      final seasonAwards = SeasonAwardService.create(
        season: career.season,
        player: career.player,
        // Для наград чемпионата берём только матчи лиги игрока:
        // кубки и сборная не смешиваются с национальным чемпионатом.
        seasonStats: SeasonStats(
          season: career.season,
          club: career.player.club,
          matches: leagueAppearances.length,
          goals: leagueGoals,
          assists: leagueAssists,
          yellowCards: 0,
          redCards: 0,
          averageRating: leagueRating,
        ),
        leaguePlayerStats: completedCareer.leaguePlayerStats,
        leagueTable: completedCareer.leagueTable,
        rivals: completedCareer.rivals,
        worldLeagueStandings: completedCareer.europeanLeagueStandings,
        overallSeasonStats: overallSeasonStats.isEmpty
            ? null
            : overallSeasonStats.last,
        additionalTrophyWinningClubs: [
          if (completedCareer.domesticCup?.champion != null)
            completedCareer.domesticCup!.champion!,
          if (completedCareer.championsLeague?.champion != null)
            completedCareer.championsLeague!.champion!,
          if (completedCareer.europaLeague?.champion != null)
            completedCareer.europaLeague!.champion!,
          if (completedCareer.worldCup?.isCompleted == true &&
              completedCareer.worldCup?.isPlayerCalledUp == true &&
              completedCareer.worldCup?.champion == career.player.nationality)
            career.player.club,
        ],
      );
      final wonGoldenBoot = seasonAwards.any(
        (award) =>
            award.category == 'Лучший бомбардир' &&
            award.isCareerPlayer &&
            award.playerName == career.player.name &&
            award.club == career.player.club,
      );
      final wonBestAssister = seasonAwards.any(
        (award) =>
            award.category == 'Лучший ассистент' &&
            award.isCareerPlayer &&
            award.playerName == career.player.name &&
            award.club == career.player.club,
      );
      final ballonDorAwards = seasonAwards
          .where((award) => award.category == 'Золотой мяч')
          .toList();
      final ballonDorAward = ballonDorAwards.isEmpty
          ? null
          : ballonDorAwards.first;
      final wonBallonDor =
          ballonDorAward != null &&
          ballonDorAward.isCareerPlayer &&
          ballonDorAward.playerName == career.player.name &&
          ballonDorAward.club == career.player.club;
      final careerAwards = seasonAwards.where(
        (award) =>
            award.isCareerPlayer &&
            award.playerName == career.player.name &&
            award.club == career.player.club,
      );
      final preservedNews = completedCareer.news.where((item) {
        if (item.id == 'ballon_dor_s${career.season}') return false;
        return !(item.id.startsWith('season_award_') &&
            item.id.endsWith('_s${career.season}'));
      }).toList();
      final awardNews = [
        ...preservedNews,
        if (ballonDorAward != null)
          CareerNews(
            id: 'ballon_dor_s${career.season}',
            season: career.season,
            matchNumber: 0,
            title: 'Золотой мяч: ${ballonDorAward.playerName}',
            description:
                '${ballonDorAward.club} · голы: ${ballonDorAward.goals}, ассисты: ${ballonDorAward.assists}, средняя оценка: ${ballonDorAward.averageRating.toStringAsFixed(2)}.',
            type: CareerNewsType.achievement,
          ),
        for (final award in careerAwards.where(
          (item) => item.category != 'Золотой мяч',
        ))
          CareerNews(
            id: 'season_award_${award.category.replaceAll(' ', '_')}_s${career.season}',
            season: career.season,
            matchNumber: 0,
            title: '${award.category}: ${career.player.name}',
            description:
                '${award.club} · матчи: ${award.matches}, голы: ${award.goals}, ассисты: ${award.assists}, средняя оценка: ${award.averageRating.toStringAsFixed(2)}.',
            type: CareerNewsType.achievement,
          ),
      ];
      completedCareer = completedCareer.copyWith(
        seasonAwards: [
          ...completedCareer.seasonAwards.where(
            (item) => item.season != career.season,
          ),
          ...seasonAwards,
        ],
        news: awardNews,
        agentCredits:
            completedCareer.agentCredits +
            (wonGoldenBoot &&
                    !existingSeasonAwards.any(
                      (item) =>
                          item.category == 'Лучший бомбардир' &&
                          item.isCareerPlayer,
                    )
                ? 10
                : 0) +
            (wonBestAssister &&
                    !existingSeasonAwards.any(
                      (item) =>
                          item.category == 'Лучший ассистент' &&
                          item.isCareerPlayer,
                    )
                ? 10
                : 0) +
            (wonBallonDor &&
                    !existingSeasonAwards.any(
                      (item) =>
                          item.category == 'Золотой мяч' && item.isCareerPlayer,
                    )
                ? 30
                : 0),
      );
    }

    // Зарплата и очки развития начисляются только один раз.
    if (!alreadyArchived) {
      final sponsorPayout =
          completedCareer.sponsorContract?.payoutForSeason(
            completedCareer.goals,
          ) ??
          0;
      completedCareer = completedCareer.copyWith(
        money:
            completedCareer.money +
            completedCareer.monthlySalary * 12 +
            sponsorPayout,
        news: sponsorPayout <= 0
            ? completedCareer.news
            : [
                ...completedCareer.news,
                CareerNews(
                  id: 'sponsor_payout_s${completedCareer.season}',
                  season: completedCareer.season,
                  matchNumber: 0,
                  title: 'Выплата от спонсора',
                  description:
                      '${completedCareer.sponsorContract!.brand} перечислил €$sponsorPayout за сезон с учётом бонусов.',
                  type: CareerNewsType.sponsor,
                ),
              ],
      );
    }

    final fcPointsEarned = await FCPointsService.awardSeason(completedCareer);

    setState(() {
      career = completedCareer;
    });

    await _saveCareer(completedCareer);

    if (!mounted) return;

    if (!alreadyArchived || awardsUpdated) {
      final awards = completedCareer.seasonAwards
          .where((item) => item.season == completedCareer.season)
          .toList();
      await _showSeasonAwards(awards);
      if (!mounted) return;
    }

    if (fcPointsEarned > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+ $fcPointsEarned FC Points за сезон'),
          backgroundColor: const Color(0xFF174A25),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    setState(() {
      isSaving = false;
    });

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

    await _openTransferWindowAndStartSeason();
  }

  Future<void> _openTransferWindowAndStartSeason() async {
    final previousClub = career.player.club;
    Career? transferResult;

    // В режиме пятилетнего ограничения не открываем трансферное окно,
    // пока не наступил разрешённый сезон смены клуба.
    if (career.canChangeClub) {
      transferResult = await Navigator.push<Career>(
        context,
        MaterialPageRoute(builder: (_) => TransferScreen(career: career)),
      );
    } else if (career.settings.limitTransfersToFiveYears &&
        career.contractYears <= 0) {
      // Пока переход запрещён, автоматически продлеваем контракт
      // в текущем клубе, чтобы игрок не остался без команды.
      career = career.copyWith(contractYears: 1);
    }

    if (!mounted) return;

    // Если игрок принял предложение, используем карьеру после трансфера.
    if (transferResult != null) {
      career = transferResult;
    }

    if (career.player.club != previousClub) {
      final transferConference = PressConferenceContentFactory.create(
        category: 'newClub',
        english: AppStrings.isEnglish,
        clubName: career.player.club,
      );
      final conferenceResult = await PressConferenceDialog.show(
        context: context,
        content: transferConference,
        title: AppStrings.pressConferenceTitle,
        skipLabel: AppStrings.skipPressConference,
      );
      if (!mounted) return;
      if (conferenceResult != null) {
        career = career.copyWith(
          coachTrust: (career.coachTrust + conferenceResult.trustChange)
              .clamp(0, 100)
              .toInt(),
          reputationModifier:
              career.reputationModifier + conferenceResult.reputationChange,
        );
      }
    }

    // После трансферов сразу начинаем следующий сезон.
    // История текущего сезона уже сохранена до смены клуба.
    var nextCareer = career.startNextSeason();

    // Если игрок остался в клубе, он может выбрать новый номер
    // в начале сезона. После трансфера номер уже выбран в окне переходов.
    if (nextCareer.player.club == previousClub) {
      final jerseyNumber = await JerseyNumberPicker.show(
        context: context,
        takenNumbers: nextCareer.rivals
            .map((rival) => rival.jerseyNumber)
            .toSet(),
        preferredNumber: nextCareer.player.jerseyNumber,
        playerOverall: nextCareer.player.overall,
        english: AppStrings.isEnglish,
      );
      if (!mounted) return;
      if (jerseyNumber != null) {
        nextCareer = nextCareer.copyWith(
          player: nextCareer.player.copyWith(jerseyNumber: jerseyNumber),
        );
      }
    }

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

  Future<Career> _maybeShowPressConference(
    Career updatedCareer,
    Match match, {
    bool isTournamentDecider = false,
    bool includeSeasonMilestones = true,
  }) async {
    if (!match.playerPlayed) return updatedCareer;

    PressConferenceContentFactory.beginSeason(updatedCareer.season);
    final cooldownReady = PressConferenceContentFactory.registerMatch();

    final playedBefore = career.seasonMatches
        .where((item) => item.isPlayed)
        .length;
    final totalMatches = career.seasonMatches.length;
    final seasonStart = includeSeasonMilestones && playedBefore == 0;
    final seasonEnd =
        includeSeasonMilestones &&
        totalMatches > 0 &&
        playedBefore >= totalMatches - 1;

    // Сезонные контрольные вопросы не должны блокироваться общей паузой.
    if (!cooldownReady && !isTournamentDecider && !seasonStart && !seasonEnd) {
      return updatedCareer;
    }
    final outstanding =
        match.playerRating >= 8.8 ||
        match.playerGoals >= 3 ||
        match.playerGoals + match.playerAssists >= 4;
    final poor = match.playerRating <= 5.5;
    final completedResults = updatedCareer.seasonMatches
        .where((item) => item.isPlayed && item.result != null)
        .map((item) => item.result!)
        .toList();
    final lastThree = completedResults.length >= 3
        ? completedResults.sublist(completedResults.length - 3)
        : <Match>[];
    final previousThree = completedResults.length >= 4
        ? completedResults.sublist(
            completedResults.length - 4,
            completedResults.length - 1,
          )
        : <Match>[];
    final previousWasLosingStreak =
        previousThree.length == 3 &&
        previousThree.every(
          (item) => item.isPlayerLoss(updatedCareer.player.club),
        );
    final losingStreak =
        lastThree.length == 3 &&
        lastThree.every(
          (item) => item.isPlayerLoss(updatedCareer.player.club),
        ) &&
        !previousWasLosingStreak;
    final lastFive = completedResults.length >= 5
        ? completedResults.sublist(completedResults.length - 5)
        : <Match>[];
    final previousFive = completedResults.length >= 6
        ? completedResults.sublist(
            completedResults.length - 6,
            completedResults.length - 1,
          )
        : <Match>[];
    final lossesInLastFive = lastFive
        .where((item) => item.isPlayerLoss(updatedCareer.player.club))
        .length;
    final lossesInPreviousFive = previousFive
        .where((item) => item.isPlayerLoss(updatedCareer.player.club))
        .length;
    final badRun =
        lastFive.length == 5 &&
        lossesInLastFive >= 4 &&
        (previousFive.length < 5 || lossesInPreviousFive < 4);
    final poorSeasonCheckpoint = max(6, (totalMatches * 0.65).round());
    final poorSeasonProgress = playedBefore + 1;
    final seasonLosses = completedResults
        .where((item) => item.isPlayerLoss(updatedCareer.player.club))
        .length;
    // Окно до восьми матчей учитывает общий лимит пресс-конференций
    // и не позволяет другим поводам полностью вытеснить этот вопрос.
    final poorSeason =
        poorSeasonProgress >= poorSeasonCheckpoint &&
        poorSeasonProgress <= poorSeasonCheckpoint + 7 &&
        ((updatedCareer.averageRating ?? 6.5) < 6.4 ||
            seasonLosses >= (completedResults.length * 0.45).ceil());

    String? category;
    final firstInterestCheckpoint = max(2, (totalMatches / 3).round());
    final secondInterestCheckpoint = max(4, (totalMatches * 2 / 3).round());
    if (isTournamentDecider) {
      category = match.isPlayerLoss(updatedCareer.player.club)
          ? 'elimination'
          : 'tournament';
    } else if (seasonStart) {
      category = 'seasonStart';
    } else if (seasonEnd) {
      category = 'seasonEnd';
    } else if (includeSeasonMilestones &&
        totalMatches >= 8 &&
        playedBefore + 1 == firstInterestCheckpoint) {
      category = 'transferInterest';
    } else if (includeSeasonMilestones &&
        totalMatches >= 8 &&
        playedBefore + 1 == secondInterestCheckpoint &&
        Random().nextDouble() < 0.25) {
      category = 'transferInterest';
    } else if (losingStreak) {
      category = 'losingStreak';
    } else if (badRun) {
      category = 'badRun';
    } else if (poorSeason) {
      category = 'poorSeason';
    } else if (includeSeasonMilestones &&
        totalMatches > 2 &&
        playedBefore == (totalMatches / 2).round() &&
        Random().nextDouble() < 0.15) {
      category = 'seasonMiddle';
    } else if (outstanding && Random().nextDouble() < 0.22) {
      category = 'great';
    } else if (poor && Random().nextDouble() < 0.30) {
      category = 'poor';
    } else if (Random().nextDouble() < 0.015) {
      category = 'normal';
    }

    if (category == null) return updatedCareer;

    final interestedClubs = Clubs.all
        .where(
          (club) =>
              club.name != updatedCareer.player.club &&
              club.strength >= updatedCareer.player.overall - 10,
        )
        .toList();
    final interestedClub =
        category == 'transferInterest' && interestedClubs.isNotEmpty
        ? interestedClubs[Random().nextInt(interestedClubs.length)].name
        : null;
    PressConferenceContentFactory.markConferenceShown();
    final content = PressConferenceContentFactory.create(
      category: category,
      english: AppStrings.isEnglish,
      interestedClub: interestedClub,
    );
    final conferenceResult = await PressConferenceDialog.show(
      context: context,
      content: content,
      title: AppStrings.pressConferenceTitle,
      skipLabel: AppStrings.skipPressConference,
    );
    if (conferenceResult == null) return updatedCareer;
    return updatedCareer.copyWith(
      coachTrust: (updatedCareer.coachTrust + conferenceResult.trustChange)
          .clamp(0, 100)
          .toInt(),
      reputationModifier:
          updatedCareer.reputationModifier + conferenceResult.reputationChange,
    );
  }

  Future<void> _showTournamentPreviewConference() async {
    if (!mounted) return;
    PressConferenceContentFactory.beginSeason(career.season);
    PressConferenceContentFactory.markConferenceShown();
    final content = PressConferenceContentFactory.create(
      category: 'tournament',
      english: AppStrings.isEnglish,
    );
    final conferenceResult = await PressConferenceDialog.show(
      context: context,
      content: content,
      title: AppStrings.pressConferenceTitle,
      skipLabel: AppStrings.skipPressConference,
    );
    if (!mounted || conferenceResult == null) return;
    final updated = career.copyWith(
      coachTrust: (career.coachTrust + conferenceResult.trustChange)
          .clamp(0, 100)
          .toInt(),
      reputationModifier:
          career.reputationModifier + conferenceResult.reputationChange,
    );
    setState(() => career = updated);
    await _saveCareer(updated);
  }

  Future<void> _openPlayerProfile() async {
    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(career: career)),
    );

    if (!mounted || updatedCareer == null) return;
    setState(() => career = updatedCareer);
    await _saveCareer(updatedCareer);
  }

  Future<void> _openShop() async {
    if (career.isCareerFinished) return;
    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(builder: (_) => ShopScreen(career: career)),
    );
    if (!mounted || updatedCareer == null) return;
    setState(() => career = updatedCareer);
    await _saveCareer(updatedCareer);
  }

  Future<void> _openTeam() async {
    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(builder: (_) => TeamScreen(career: career)),
    );

    if (!mounted || updatedCareer == null) return;
    setState(() => career = updatedCareer);
    await _saveCareer(updatedCareer);
  }

  Future<void> _openCoach() async {
    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(builder: (_) => CoachScreen(career: career)),
    );
    if (!mounted || updatedCareer == null) return;
    setState(() => career = updatedCareer);
    await _saveCareer(updatedCareer);
  }

  Future<void> _openAgent() async {
    final updatedCareer = await Navigator.push<Career>(
      context,
      MaterialPageRoute(builder: (_) => AgentScreen(career: career)),
    );
    if (!mounted || updatedCareer == null) return;
    setState(() => career = updatedCareer);
    await _saveCareer(updatedCareer);
  }

  Future<void> _openNews() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewsScreen(career: career)),
    );
  }

  Future<void> _returnToHome() async {
    await _saveCareer(career);
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      width: 300,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(30)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.24),
                  Colors.white.withValues(alpha: 0.12),
                  const Color(0xFF777777).withValues(alpha: 0.16),
                  Colors.black.withValues(alpha: 0.20),
                ],
                stops: const [0, 0.34, 0.72, 1],
              ),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withValues(alpha: 0.34),
                  width: 1.1,
                ),
                top: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(10, 0),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -100,
                  left: -70,
                  child: IgnorePointer(
                    child: Container(
                      width: 280,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.22),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 18),
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.24),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.08),
                              blurRadius: 18,
                              spreadRadius: -5,
                              offset: const Offset(-4, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/player.svg',
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                Colors.white.withValues(alpha: 0.92),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              career.player.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.35,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${career.player.club}  ·  OVR ${career.player.overall}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _drawerItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Игрок',
                        onTap: () {
                          Navigator.pop(context);
                          _openPlayerProfile();
                        },
                      ),
                      _drawerItem(
                        icon: Icons.storefront_outlined,
                        title: 'Магазин',
                        onTap: () {
                          Navigator.pop(context);
                          _openShop();
                        },
                      ),
                      _drawerItem(
                        icon: Icons.groups_2_outlined,
                        title: AppStrings.isEnglish ? 'Team' : 'Команда',
                        onTap: () {
                          Navigator.pop(context);
                          _openTeam();
                        },
                      ),
                      _drawerItem(
                        icon: Icons.sports,
                        title: AppStrings.coachMenu,
                        onTap: () {
                          Navigator.pop(context);
                          _openCoach();
                        },
                      ),
                      _drawerItem(
                        icon: Icons.handshake_outlined,
                        title: AppStrings.agentMenu,
                        onTap: () {
                          Navigator.pop(context);
                          _openAgent();
                        },
                      ),
                      _drawerItem(
                        icon: Icons.newspaper_outlined,
                        title: AppStrings.newsMenu,
                        onTap: () {
                          Navigator.pop(context);
                          _openNews();
                        },
                      ),
                      _drawerItem(
                        assetPath: 'assets/icons/table.svg',
                        title: 'Таблица',
                        onTap: () {
                          Navigator.pop(context);
                          _openLeagueTable();
                        },
                      ),
                      _drawerItem(
                        icon: Icons.calendar_month_rounded,
                        title: 'Календарь',
                        onTap: () {
                          Navigator.pop(context);
                          _openCalendar();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.22),
                          height: 1,
                        ),
                      ),
                      _drawerItem(
                        icon: Icons.home_outlined,
                        title: 'Главный экран',
                        onTap: () {
                          Navigator.pop(context);
                          _returnToHome();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({
    IconData? icon,
    String? assetPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minLeadingWidth: 28,
        leading: assetPath != null
            ? SvgPicture.asset(
                assetPath,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  Colors.white.withValues(alpha: 0.86),
                  BlendMode.srcIn,
                ),
              )
            : Icon(icon, color: Colors.white.withValues(alpha: 0.88), size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.94),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
        onTap: onTap,
        dense: true,
        visualDensity: const VisualDensity(vertical: -1),
        tileColor: Colors.white.withValues(alpha: 0.045),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.075)),
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

  // Widget _buildCalendarButton() {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: OutlinedButton.icon(
  //       onPressed: () => _openCalendar(),
  //       icon: const Icon(Icons.calendar_month_rounded),
  //       label: const Text('КАЛЕНДАРЬ СЕЗОНА'),
  //       style: OutlinedButton.styleFrom(
  //         foregroundColor: const Color.fromARGB(255, 3, 3, 3),
  //         backgroundColor: const Color.fromARGB(255, 189, 177, 177),
  //         side: const BorderSide(color: Color(0xFF24552C)),
  //         padding: const EdgeInsets.symmetric(vertical: 14),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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

    final showUcl =
        uclPosition <= leaguePosition &&
        uclPosition <= cupPosition &&
        uclPosition <= europaPosition;
    final showEuropa =
        !showUcl &&
        europaPosition <= leaguePosition &&
        europaPosition <= cupPosition;
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
        drawer: widget.calendarOnly ? null : _buildNavigationDrawer(),
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
          // actions: [
          //   if (!widget.calendarOnly)
          //     IconButton(
          //       tooltip: AppStrings.leagueTableTooltip,
          //       onPressed: _openLeagueTable,
          //       icon: SvgPicture.asset(
          //         'assets/icons/table.svg',
          //         width: 34,
          //         height: 34,
          //         colorFilter: const ColorFilter.mode(
          //           Colors.white,
          //           BlendMode.srcIn,
          //         ),
          //       ),
          //     ),
          // ],
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
                              if (!worldCupBlocksSeason) ...[
                                _buildSeasonMatches(),
                                const SizedBox(height: 12),
                                if (career.worldCup != null)
                                  _buildWorldCupCalendarSection(
                                    blocksSeason: false,
                                  ),
                                const SizedBox(height: 16),
                                _buildSeasonButton(),
                              ] else ...[
                                if (career.worldCup != null)
                                  _buildWorldCupCalendarSection(
                                    blocksSeason: true,
                                  ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  child: Text(
                                    'Календарь лиги будет доступен после завершения чемпионата мира.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ],
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              _buildProgressCard(),
                              if (career.friendlyMatches.any(
                                (item) => !item.isResolved,
                              )) ...[
                                const SizedBox(height: 10),
                                _buildFriendlyMatchesSection(),
                              ],
                              const SizedBox(height: 8),
                              if (isSaving)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF8BE07F),
                                    ),
                                  ),
                                ),
                              if (worldCupBlocksSeason &&
                                  career.worldCup != null)
                                _buildWorldCupCalendarSection(
                                  blocksSeason: true,
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
                              if (recentMonthlyAward != null &&
                                  !worldCupBlocksSeason)
                                _buildRecentMonthlyAwardCard(),
                              const SizedBox(height: 10),
                              if (!worldCupBlocksSeason) _buildSeasonButton(),
                              if (career.worldCup != null &&
                                  !worldCupBlocksSeason)
                                _buildWorldCupCalendarSection(
                                  blocksSeason: false,
                                ),
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
                child: Text(
                  career.player.club,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (league != null) ...[
                const SizedBox(width: 10),
                Image.asset(
                  league.logoAsset,
                  width: 35,
                  height: 35,
                  fit: BoxFit.contain,
                ),
              ],
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

  Widget _buildFatigueBar() {
    final english = AppStrings.isEnglish;
    final value = career.fatigue.clamp(0, FatigueService.max).toInt();
    final color = value < 40
        ? const Color(0xFF8BE07F)
        : value < 70
        ? Colors.orangeAccent
        : Colors.redAccent;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              english ? 'Fatigue' : 'Усталость',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${FatigueService.label(value, english: english)} · $value%',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value / FatigueService.max,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.075),
                Colors.black.withValues(alpha: 0.34),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.24),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -42,
                right: -24,
                child: IgnorePointer(
                  child: Container(
                    width: 150,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.white.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.seasonStats,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      _statItem(
                        AppStrings.matchesLabel,
                        '$_seasonMatchesForDisplay',
                      ),
                      _statItem(
                        AppStrings.goalsStat,
                        '$_seasonGoalsForDisplay',
                      ),
                      _statItem(
                        AppStrings.assistsStat,
                        '$_seasonAssistsForDisplay',
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.22),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statItem(AppStrings.yellowStat, '${career.yellowCards}'),
                      _statItem(AppStrings.redStat, '${career.redCards}'),
                      _statItem(
                        AppStrings.ratingStat,
                        _seasonAverageRatingForDisplay?.toStringAsFixed(1) ??
                            '—',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFatigueBar(),
                  if (seasonFinished) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.22),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTrophiesSection(),
                  ],
                ],
              ),
            ],
          ),
        ),
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

    final wonGoldenBoot = career.seasonAwards.any(
      (award) =>
          award.category == 'Лучший бомбардир' &&
          award.playerName == career.player.name &&
          award.club == career.player.club,
    );

    if (wonGoldenBoot) {
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
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
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

  // Widget _buildNextMatchCard(SeasonMatch match) {
  //   final playerColor = ClubColors.primary(career.player.club);
  //   final opponentColor = ClubColors.primary(match.opponent);
  //   final interactiveAvailable = _canPlayInteractiveMatch(
  //     opponent: match.opponent,
  //     isHome: match.isHome,
  //   );
  //   return _buildMatchGlassSurface(
  //     child: Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [
  //             playerColor.withValues(alpha: 0.72),
  //             Color.lerp(
  //               playerColor,
  //               opponentColor,
  //               0.45,
  //             )!.withValues(alpha: 0.70),
  //             const Color(0xFF102B17).withValues(alpha: 0.78),
  //           ],
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ),
  //         border: Border.all(color: opponentColor.withValues(alpha: 0.8)),
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             AppStrings.nextMatch,
  //             style: TextStyle(
  //               color: Color.fromARGB(255, 255, 255, 255),
  //               fontWeight: FontWeight.bold,
  //               fontSize: 12,
  //             ),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             match.isHome
  //                 ? '${career.player.club} — ${match.opponent}'
  //                 : '${match.opponent} — ${career.player.club}',
  //             style: const TextStyle(
  //               color: Colors.white,
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const SizedBox(height: 6),
  //           Text(
  //             '${AppStrings.round} ${match.number} • '
  //             '${match.isHome ? AppStrings.home : AppStrings.away}',
  //             style: const TextStyle(color: Colors.white, fontSize: 12),
  //           ),
  //           const SizedBox(height: 14),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: ElevatedButton.icon(
  //                   onPressed: isSaving || seasonFinishing
  //                       ? null
  //                       : () => _playMatch(match, interactive: false),
  //                   label: const Text('Симуляция'),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: const Color(0xFFE8EDE8),
  //                     foregroundColor: const Color(0xFF102B17),
  //                     padding: const EdgeInsets.symmetric(vertical: 12),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               if (interactiveAvailable) ...[
  //                 const SizedBox(width: 10),
  //                 Expanded(
  //                   child: ElevatedButton.icon(
  //                     onPressed: isSaving || seasonFinishing
  //                         ? null
  //                         : () => _playMatch(match, interactive: true),
  //                     icon: const Icon(Icons.sports_soccer, size: 18),
  //                     label: const Text('Играть'),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: const Color(0xFF22C55E),
  //                       foregroundColor: const Color(0xFF06210D),
  //                       padding: const EdgeInsets.symmetric(vertical: 12),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildNextMatchCard(SeasonMatch match) {
    final isElClasico =
        (career.player.club == 'Barcelona' &&
            match.opponent == 'Real Madrid') ||
        (career.player.club == 'Real Madrid' && match.opponent == 'Barcelona');
    final playerColor = ClubColors.primary(career.player.club);
    final opponentColor = ClubColors.primary(match.opponent);
    final interactiveAvailable = _canPlayInteractiveMatch(
      opponent: match.opponent,
      isHome: match.isHome,
    );
    final busy = isSaving || seasonFinishing;

    return LiquidGlass(
      radius: 25,
      tint: Color.lerp(playerColor, opponentColor, 0.5),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isElClasico ? AppStrings.elClasico : AppStrings.nextMatch,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            match.isHome
                ? '${career.player.club} — ${match.opponent}'
                : '${match.opponent} — ${career.player.club}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${AppStrings.round} ${match.number} • '
            '${match.isHome ? AppStrings.home : AppStrings.away}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _glassButton(
                  label: 'Симуляция',
                  onPressed: busy
                      ? null
                      : () => _playMatch(match, interactive: false),
                ),
              ),
              if (interactiveAvailable) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _glassButton(
                    label: 'Играть',
                    accent: const Color(0xFF22C55E),
                    icon: Icons.sports_soccer,
                    onPressed: busy
                        ? null
                        : () => _playMatch(match, interactive: true),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassButton({
    required String label,
    required VoidCallback? onPressed,
    Color? accent,
    IconData? icon,
  }) {
    final base = accent ?? Colors.white;
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: base.withValues(alpha: accent == null ? 0.16 : 0.55),
        shape: StadiumBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 17, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextCupMatchCard(CupMatch match) {
    final playerClub = career.player.club;
    final isHome = match.homeTeam == playerClub;
    final opponent = isHome ? match.awayTeam : match.homeTeam;

    final stage = career.domesticCup == null
        ? AppStrings.nationalCup
        : AppStrings.tournamentStageName(career.domesticCup!.roundName);

    final playerColor = ClubColors.primary(playerClub);
    final opponentColor = ClubColors.primary(opponent);
    final interactiveAvailable = _canPlayInteractiveMatch(
      opponent: opponent,
      isHome: isHome,
    );

    return _buildMatchGlassSurface(
      child: Container(
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
              '$stage · ${isHome ? AppStrings.homeVenue : AppStrings.awayVenue}',
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving || seasonFinishing
                        ? null
                        : () => _playCupMatch(match, interactive: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Симуляция'),
                  ),
                ),
                if (interactiveAvailable) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSaving || seasonFinishing
                          ? null
                          : () => _playCupMatch(match, interactive: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: const Color(0xFF06210D),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Играть'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
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

    final cupTotalRounds = cup?.totalRounds ?? 4;

    if (totalLeagueMatches > 0) {
      for (final match in cupMatches) {
        final progress = cupTotalRounds == 5
            ? 0.15 + (match.round - 1) * 0.20
            : switch (match.round) {
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
    final interactiveAvailable = _canPlayInteractiveMatch(
      opponent: opponent,
      isHome: isHome,
    );

    final matchTitle = isFinal
        ? AppStrings.finalStage
        : isFirstLeg
        ? AppStrings.firstLegLabel
        : AppStrings.secondLegLabel;

    return _buildMatchGlassSurface(
      child: Container(
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
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
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving || seasonFinishing
                                ? null
                                : () => _playChampionsLeagueMatch(
                                    interactive: false,
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8DB8FF),
                              foregroundColor: const Color(0xFF071526),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Симуляция'),
                          ),
                        ),
                        if (interactiveAvailable) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving || seasonFinishing
                                  ? null
                                  : () => _playChampionsLeagueMatch(
                                      interactive: true,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF22C55E),
                                foregroundColor: const Color(0xFF06210D),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Играть'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    final interactiveAvailable = _canPlayInteractiveMatch(
      opponent: opponent,
      isHome: isHome,
    );

    final matchTitle = isFinal
        ? AppStrings.finalStage
        : isFirstLeg
        ? AppStrings.firstLegLabel
        : AppStrings.secondLegLabel;

    return _buildMatchGlassSurface(
      child: Container(
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
                  child: Image.asset('assets/images/uelfon.png'),
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
                        SvgPicture.asset(
                          'assets/icons/europaleague.svg',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
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
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving || seasonFinishing
                                ? null
                                : () => _playEuropaLeagueMatch(
                                    interactive: false,
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC857),
                              foregroundColor: const Color(0xFF1A1204),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Симуляция'),
                          ),
                        ),
                        if (interactiveAvailable) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving || seasonFinishing
                                  ? null
                                  : () => _playEuropaLeagueMatch(
                                      interactive: true,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF22C55E),
                                foregroundColor: const Color(0xFF06210D),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Играть'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCupMatchRow(CupMatch cupMatch) {
    final playerClub = career.player.club;
    final isHome = cupMatch.homeTeam == playerClub;
    final opponent = isHome ? cupMatch.awayTeam : cupMatch.homeTeam;

    final stage = AppStrings.cupStageName(
      cupMatch.round,
      hasRoundOf32: career.domesticCup?.totalRounds == 5,
    );

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

    return _buildMatchGlassSurface(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFF0A2110),
            ClubColors.primary(opponent),
            0.12,
          )!.withValues(alpha: 0.68),
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
      ),
    );
  }

  Future<void> _playFriendlyMatch(FriendlyMatch friendly) async {
    if (worldCupBlocksSeason) {
      await _openWorldCup();
      return;
    }
    if (isSaving ||
        seasonFinishing ||
        friendly.isResolved ||
        career.isInjured) {
      if (career.isInjured && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Из-за травмы вы не можете сыграть товарищеский матч.',
            ),
          ),
        );
      }
      return;
    }

    final playedMatch = await Navigator.push<Match>(
      context,
      MaterialPageRoute(
        builder: (_) => InteractiveMatchScreen(
          career: career.copyWith(player: career.playerForMatch),
          opponent: friendly.opponent,
          isHome: friendly.isHome,
          playerWillPlay: true,
        ),
      ),
    );
    if (!mounted || playedMatch == null) return;

    final expectedHome = friendly.isHome
        ? career.player.club
        : friendly.opponent;
    final expectedAway = friendly.isHome
        ? friendly.opponent
        : career.player.club;
    if (playedMatch.homeTeam != expectedHome ||
        playedMatch.awayTeam != expectedAway) {
      return;
    }

    final updatedFriendlies = career.friendlyMatches
        .map(
          (item) => item.number == friendly.number
              ? item.copyWith(result: playedMatch)
              : item,
        )
        .toList();
    final trustChange = playedMatch.playerRating >= 8.0
        ? 2
        : playedMatch.playerRating <= 5.8
        ? -1
        : 0;
    final resultForPlayer = friendly.isHome
        ? '${playedMatch.homeGoals} : ${playedMatch.awayGoals}'
        : '${playedMatch.awayGoals} : ${playedMatch.homeGoals}';
    final friendlyNews = CareerNews(
      id: 'friendly_s${career.season}_${friendly.number}',
      season: career.season,
      matchNumber: -friendly.number,
      title: 'Предсезонный матч завершён',
      description:
          '${career.player.club} — ${friendly.opponent}: $resultForPlayer. Оценка игрока: ${playedMatch.playerRating.toStringAsFixed(1)}.',
      type: CareerNewsType.match,
    );

    final updatedCareer = career.copyWith(
      friendlyMatches: updatedFriendlies,
      coachTrust: (career.coachTrust + trustChange).clamp(0, 100).toInt(),
      news: [...career.news, friendlyNews],
    );
    setState(() => career = updatedCareer);
    await _saveCareer(updatedCareer);
  }

  Future<void> _skipFriendlyMatch(FriendlyMatch friendly) async {
    if (isSaving || seasonFinishing || friendly.isResolved) return;
    final updated = career.copyWith(
      friendlyMatches: career.friendlyMatches.map((item) {
        return item.number == friendly.number
            ? item.copyWith(isSkipped: true)
            : item;
      }).toList(),
    );
    setState(() {
      career = updated;
      isSaving = true;
    });
    await _saveCareer(updated);
    if (!mounted) return;
    setState(() => isSaving = false);
  }

  Widget _buildFriendlyMatchRow(FriendlyMatch friendly) {
    final result = friendly.result;
    final score = result == null
        ? '— : —'
        : friendly.isHome
        ? '${result.homeGoals} : ${result.awayGoals}'
        : '${result.awayGoals} : ${result.homeGoals}';
    final resultColor = result == null
        ? Colors.white54
        : (friendly.isHome
                  ? result.homeGoals.compareTo(result.awayGoals)
                  : result.awayGoals.compareTo(result.homeGoals)) >
              0
        ? const Color(0xFF8BE07F)
        : (friendly.isHome
                  ? result.homeGoals.compareTo(result.awayGoals)
                  : result.awayGoals.compareTo(result.homeGoals)) <
              0
        ? Colors.redAccent
        : Colors.orangeAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13291D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF54745C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ПРЕДСЕЗОННАЯ ПОДГОТОВКА',
            style: TextStyle(
              color: Color(0xFFB9C8BC),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${friendly.isHome ? career.player.club : friendly.opponent} — ${friendly.isHome ? friendly.opponent : career.player.club}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                friendly.isSkipped ? 'Пропущен' : score,
                style: TextStyle(
                  color: friendly.isSkipped ? Colors.white54 : resultColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (!friendly.isResolved) ...[
            const SizedBox(height: 9),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isSaving || seasonFinishing
                      ? null
                      : () => _skipFriendlyMatch(friendly),
                  child: const Text(
                    'Пропустить',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: isSaving || seasonFinishing
                      ? null
                      : () => _playFriendlyMatch(friendly),
                  icon: const Icon(Icons.sports_soccer, size: 15),
                  label: const Text('Сыграть'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BE07F),
                    foregroundColor: const Color(0xFF082A12),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ] else if (result != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Оценка игрока: ${result.playerRating.toStringAsFixed(1)} · В официальную статистику сезона не входит',
                style: const TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFriendlyMatchesSection() {
    final unresolved = career.friendlyMatches
        .where((friendly) => !friendly.isResolved)
        .toList();
    if (unresolved.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2113).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF54745C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ТОВАРИЩЕСКИЕ МАТЧИ',
            style: TextStyle(
              color: Color(0xFF8BE07F),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          // const SizedBox(height: 4),
          // const Text(
          //   'Перед началом официальных турниров можно сыграть матчи для подготовки или пропустить их.',
          //   style: TextStyle(color: Colors.white60, fontSize: 11),
          // ),
          const SizedBox(height: 9),
          ...unresolved.map(_buildFriendlyMatchRow),
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

    return _buildMatchGlassSurface(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFF0A2110),
            ClubColors.primary(match.opponent),
            0.12,
          )!.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(
              color: ClubColors.primary(match.opponent),
              width: 4,
            ),
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
