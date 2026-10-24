import 'package:flutter/material.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_football/models/super_league_career.dart';
import 'package:flutter_football/screens/super_league/super_league_table_screen.dart';
import 'package:flutter_football/services/super_league_storage.dart';
import 'package:flutter_football/screens/super_league/super_league_development_screen.dart';
import 'package:flutter_football/screens/super_league/super_league_transfers_screen.dart';
import 'package:flutter_football/screens/super_league/super_league_end_screen.dart';
import 'package:flutter_football/screens/super_league/super_league_calendar_screen.dart';

class SuperLeagueSeasonScreen extends StatefulWidget {
  final SuperLeagueCareer career;
  const SuperLeagueSeasonScreen({super.key, required this.career});

  @override
  State<SuperLeagueSeasonScreen> createState() =>
      _SuperLeagueSeasonScreenState();
}

class _SuperLeagueSeasonScreenState extends State<SuperLeagueSeasonScreen> {
  late SuperLeagueCareer _career;
  bool _isPlaying = false;
  bool _showLastResult = false;
  SuperLeagueFixture? _lastPlayedFixture;
  String? _error;

  static const Color _bg = Color(0xFF061B0C);
  static const Color _panel = Color(0xFF0B2813);
  static const Color _green = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    _career = _normalizeCareer(widget.career);
    if (_career.player.club != widget.career.player.club) {
      Future.microtask(() => SuperLeagueStorage.saveCareer(_career));
    }
  }

  SuperLeagueCareer _normalizeCareer(SuperLeagueCareer career) {
    if (career.firstDivision.contains(career.player.club) ||
        career.secondDivision.contains(career.player.club)) {
      return career;
    }

    final oldClub = Clubs.getByName(career.player.club);
    final eligibleClubs = [
      ...career.firstDivision,
      ...career.secondDivision,
    ].map(Clubs.getByName).toList()..sort(
          (a, b) => (a.strength - oldClub.strength).abs().compareTo(
            (b.strength - oldClub.strength).abs(),
          ),
        );

    return career.copyWith(
      player: career.player.copyWith(club: eligibleClubs.first.name),
    );
  }

  Future<void> _playNext() async {
    if (_isPlaying || _career.nextFixture == null) return;
    setState(() {
      _isPlaying = true;
      _error = null;
    });
    try {
      final before = _career.nextFixture;
      var updated = _career.playNextMatch();
      if (updated.nextFixture == null &&
          updated.standings.isNotEmpty &&
          updated.standings.first.club == updated.player.club &&
          !updated.championSeasons.contains(updated.season)) {
        updated = updated.copyWith(
          championSeasons: [...updated.championSeasons, updated.season],
        );
      }
      await SuperLeagueStorage.saveCareer(updated);
      if (!mounted) return;
      setState(() {
        _career = updated;
        _lastPlayedFixture = before == null
            ? null
            : updated.fixtures.firstWhere(
                (fixture) =>
                    fixture.round == before.round &&
                    fixture.homeTeam == before.homeTeam &&
                    fixture.awayTeam == before.awayTeam,
              );
        _showLastResult = _lastPlayedFixture != null;
        _isPlaying = false;
      });
      if (updated.nextFixture == null && updated.season >= 10) {
        await _finishCareer();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _error = 'Не удалось сохранить результат матча.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final next = _career.nextFixture;
    final isChampion =
        next == null &&
        _career.standings.isNotEmpty &&
        _career.standings.first.club == _career.player.club;
    final showResult = _showLastResult && _lastPlayedFixture != null;
    final played = _career.fixtures
        .where(
          (f) =>
              f.isPlayed &&
              (f.homeTeam == _career.player.club ||
                  f.awayTeam == _career.player.club),
        )
        .length;
    const total = 38;
    return PopScope<SuperLeagueCareer>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && mounted) Navigator.pop(context, _career);
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(82, 81, 84, 82),
          foregroundColor: Colors.white,
          title: Text(
            'СЕЗОН ${_career.season}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          actions: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SuperLeagueTableScreen(career: _career),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/table.svg',
                      width: 32,
                      height: 32,
                      color: Colors.white,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ТАБЛИЦА',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SuperLeagueCalendarScreen(career: _career),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 5, right: 12, top: 5, bottom: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 32,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'КАЛЕНДАРЬ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset('assets/images/fon2.png', fit: BoxFit.cover),
              ),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ClubColors.primary(
                            _career.player.club,
                          ).withValues(alpha: 0.82),
                          Color.lerp(
                            ClubColors.primary(_career.player.club),
                            const Color(0xFF071B0D),
                            0.65,
                          )!,
                          const Color(0xFF071B0D),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(22),
                        bottomRight: Radius.circular(22),
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      border: Border.all(
                        color: ClubColors.primary(
                          _career.player.club,
                        ).withValues(alpha: 0.8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ПРОГРЕСС',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 8,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _career.player.club,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0A2110,
                                      ).withValues(alpha: 0.72),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF14401E),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/icons/cup.png',
                                          width: 22,
                                          height: 22,
                                          fit: BoxFit.contain,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'СУПЕРЛИГА',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.7,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$played/$total',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'СЕЗОН ${_career.season}/10',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: played / total,
                            minHeight: 8,
                            backgroundColor: const Color(0xFF12381B),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF8BE07F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(175, 91, 89, 87),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: const Color(0x66FFC857)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/cup.png',
                                width: 25,
                                height: 25,
                                fit: BoxFit.contain,
                                color: Color(0xFFFFD778),
                              ),
                              const SizedBox(width: 9),
                              const Expanded(
                                child: Text(
                                  'ТРОФЕИ СУПЕРЛИГИ',
                                  style: TextStyle(
                                    color: Color(0xFFFFD778),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text(
                                '${_career.championSeasons.length}',
                                style: const TextStyle(
                                  color: Color(0xFFFFD778),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  _panelCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'СТАТИСТИКА СЕЗОНА',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _seasonStat(
                                'Матчи',
                                '${_career.playedMatches}',
                              ),
                            ),
                            Expanded(
                              child: _seasonStat('Голы', '${_career.goals}'),
                            ),
                            Expanded(
                              child: _seasonStat(
                                'Ассисты',
                                '${_career.assists}',
                              ),
                            ),
                            Expanded(
                              child: _seasonStat(
                                'Оценка',
                                _career.averageRating == 0
                                    ? '—'
                                    : _career.averageRating.toStringAsFixed(1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (showResult) ...[
                    _resultCard(_lastPlayedFixture!),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            setState(() => _showLastResult = false),
                        label: const Text(
                          'СЛЕДУЮЩИЙ МАТЧ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: const Color(0xFF082A12),
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'СЛЕДУЮЩИЙ МАТЧ',
                      style: TextStyle(
                        color: Color(0xFF8BE07F),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (next == null)
                      _panelCard(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isChampion) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5A3B0A),
                                      Color(0xFF211707),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFFC857),
                                  ),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.emoji_events_rounded,
                                      color: Color(0xFFFFC857),
                                      size: 40,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'ЧЕМПИОН СУПЕРЛИГИ!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFFFD778),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const Text(
                              'Сезон завершён!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Все матчи твоей команды сыграны.',
                              style: TextStyle(color: Colors.white70),
                            ),
                            if (_career.season < 10) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: _startNextSeason,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'СЛЕДУЮЩИЙ СЕЗОН',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Карьера Суперлиги завершена! Ты прошёл все 10 сезонов.',
                                style: TextStyle(
                                  color: Color(0xFF8BE07F),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: _isPlaying ? null : _finishCareer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _green,
                                    foregroundColor: const Color(0xFF082A12),
                                  ),
                                  child: const Text(
                                    'ПОСМОТРЕТЬ ИТОГИ КАРЬЕРЫ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else ...[
                      _panelCard(
                        Column(
                          children: [
                            Text(
                              'ТУР ${next.round}',
                              style: const TextStyle(
                                color: Color(0xFF8BE07F),
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: _teamName(
                                    next.homeTeam,
                                    next.homeTeam == _career.player.club,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'VS',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _teamName(
                                    next.awayTeam,
                                    next.awayTeam == _career.player.club,
                                    alignEnd: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 13),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isPlaying ? null : _playNext,
                          icon: _isPlaying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.sports_soccer_rounded),
                          label: Text(
                            _isPlaying ? 'СИМУЛЯЦИЯ...' : 'СЫГРАТЬ МАТЧ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishCareer() async {
    if (_isPlaying) return;
    setState(() {
      _isPlaying = true;
      _error = null;
    });
    try {
      var completed = _recordSeasonSummary(
        _career.completeRemainingFixtures(),
      );
      final standings = completed.standings;
      final wonLeague =
          standings.isNotEmpty && standings.first.club == completed.player.club;
      if (wonLeague && !completed.championSeasons.contains(completed.season)) {
        completed = completed.copyWith(
          championSeasons: [...completed.championSeasons, completed.season],
        );
      }
      await SuperLeagueStorage.saveCareer(completed);
      if (!mounted) return;
      setState(() {
        _career = completed;
        _isPlaying = false;
      });
      await Navigator.push<SuperLeagueCareer>(
        context,
        MaterialPageRoute(
          builder: (_) => SuperLeagueEndScreen(career: _career),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _error = 'Не удалось сформировать итоги карьеры.';
      });
    }
  }

  SuperLeagueCareer _recordSeasonSummary(SuperLeagueCareer career) {
    if (career.history.any((item) => item.season == career.season)) {
      return career;
    }

    final playerFixtures = career.fixtures
        .where(
          (fixture) =>
              fixture.isPlayed &&
              (fixture.homeTeam == career.player.club ||
                  fixture.awayTeam == career.player.club),
        )
        .toList();
    final appearances = playerFixtures
        .where((fixture) => fixture.playerPlayed)
        .toList();
    final goals = playerFixtures.fold<int>(
      0,
      (sum, fixture) => sum + fixture.playerGoals,
    );
    final assists = playerFixtures.fold<int>(
      0,
      (sum, fixture) => sum + fixture.playerAssists,
    );
    final average = appearances.isEmpty
        ? 0.0
        : appearances.fold<double>(
                0,
                (sum, fixture) => sum + fixture.playerRating,
              ) /
              appearances.length;
    final standings = career.standings;
    final champion =
        standings.isNotEmpty && standings.first.club == career.player.club;
    final summary = SuperLeagueSeasonSummary(
      season: career.season,
      club: career.player.club,
      matches: appearances.length,
      goals: goals,
      assists: assists,
      averageRating: average,
      champion: champion,
    );
    return career.copyWith(history: [...career.history, summary]);
  }

  Future<void> _startNextSeason() async {
    if (_career.season >= 10 || _isPlaying) return;
    setState(() {
      _isPlaying = true;
      _error = null;
    });
    try {
      var completed = _recordSeasonSummary(
        _career.completeRemainingFixtures(),
      );
      final standings = completed.standings;
      final wonLeague =
          standings.isNotEmpty && standings.first.club == completed.player.club;
      if (wonLeague && !completed.championSeasons.contains(completed.season)) {
        completed = completed.copyWith(
          championSeasons: [...completed.championSeasons, completed.season],
        );
      }
      if (completed.developmentPointsAwardedSeason < completed.season) {
        completed = completed.copyWith(
          developmentPoints:
              completed.developmentPoints +
              completed.developmentPointsForSeason,
          developmentPointsAwardedSeason: completed.season,
        );
      }
      await SuperLeagueStorage.saveCareer(completed);
      if (!mounted) return;
      setState(() {
        _career = completed;
        _isPlaying = false;
      });

      final developmentResult = await Navigator.push<SuperLeagueCareer>(
        context,
        MaterialPageRoute(
          builder: (_) => SuperLeagueDevelopmentScreen(career: _career),
        ),
      );
      if (!mounted) return;
      if (developmentResult != null) {
        setState(() => _career = developmentResult);
        await SuperLeagueStorage.saveCareer(developmentResult);
      }

      final transferResult = await Navigator.push<SuperLeagueCareer>(
        context,
        MaterialPageRoute(
          builder: (_) => SuperLeagueTransfersScreen(career: _career),
        ),
      );
      if (!mounted) return;
      final afterTransfer = transferResult ?? _career;
      final nextCareer = afterTransfer.nextSeason();
      await SuperLeagueStorage.saveCareer(nextCareer);
      if (!mounted) return;
      setState(() {
        _career = nextCareer;
        _showLastResult = false;
        _lastPlayedFixture = null;
        _isPlaying = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _error = 'Не удалось сохранить новый сезон.';
      });
    }
  }

  Widget _resultCard(SuperLeagueFixture fixture) {
    final isHome = fixture.homeTeam == _career.player.club;
    final playerGoals = isHome ? fixture.homeGoals! : fixture.awayGoals!;
    final opponentGoals = isHome ? fixture.awayGoals! : fixture.homeGoals!;
    final resultLabel = playerGoals > opponentGoals
        ? 'ПОБЕДА'
        : playerGoals < opponentGoals
        ? 'ПОРАЖЕНИЕ'
        : 'НИЧЬЯ';
    final rating = fixture.playerPlayed
        ? fixture.playerRating.toStringAsFixed(1)
        : '—';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ClubColors.primary(_career.player.club).withValues(alpha: 0.55),
            const Color(0xFF0A2110),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ClubColors.primary(_career.player.club)),
      ),
      child: Column(
        children: [
          const Text(
            'РЕЗУЛЬТАТ МАТЧА',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _teamName(
                  fixture.homeTeam,
                  fixture.homeTeam == _career.player.club,
                ),
              ),
              SizedBox(width: 16),

              Column(
                children: [
                  Text(
                    '${fixture.homeGoals} : ${fixture.awayGoals}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resultLabel,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Expanded(
                child: _teamName(
                  fixture.awayTeam,
                  fixture.awayTeam == _career.player.club,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF24552C), height: 26),
          Row(
            children: [
              Expanded(child: _resultStat('ГОЛЫ', '${fixture.playerGoals}')),
              Expanded(
                child: _resultStat('АССИСТЫ', '${fixture.playerAssists}'),
              ),
              Expanded(child: _resultStat('ОЦЕНКА', rating)),
              // Expanded(
              //   child: _resultStat(
              //     'УЧАСТИЕ',
              //     fixture.playerPlayed ? 'Да' : 'Нет',
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultStat(String label, String value) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  Widget _seasonStat(String label, String value) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white60, fontSize: 10),
      ),
    ],
  );

  Widget _teamName(String name, bool isPlayer, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ClubColors.primary(name).withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ClubColors.primary(name)),
          ),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: alignEnd ? TextAlign.center : TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isPlayer ? FontWeight.w900 : FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _panelCard(Widget child) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color.fromARGB(215, 77, 80, 78),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFF14401E)),
    ),
    child: child,
  );
}
