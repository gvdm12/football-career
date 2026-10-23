import 'package:flutter/material.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_football/models/super_league_career.dart';
import 'package:flutter_football/screens/super_league/super_league_table_screen.dart';
import 'package:flutter_football/services/super_league_storage.dart';
import 'package:flutter_football/screens/super_league/super_league_development_screen.dart';
import 'package:flutter_football/screens/super_league/super_league_transfers_screen.dart';

class SuperLeagueSeasonScreen extends StatefulWidget {
  final SuperLeagueCareer career;
  const SuperLeagueSeasonScreen({super.key, required this.career});

  @override
  State<SuperLeagueSeasonScreen> createState() => _SuperLeagueSeasonScreenState();
}

class _SuperLeagueSeasonScreenState extends State<SuperLeagueSeasonScreen> {
  late SuperLeagueCareer _career = widget.career;
  bool _isPlaying = false;
  bool _showLastResult = false;
  SuperLeagueFixture? _lastPlayedFixture;
  String? _error;

  static const Color _bg = Color(0xFF061B0C);
  static const Color _panel = Color(0xFF0B2813);
  static const Color _green = Color(0xFF22C55E);

  Future<void> _playNext() async {
    if (_isPlaying || _career.nextFixture == null) return;
    setState(() { _isPlaying = true; _error = null; });
    try {
      final before = _career.nextFixture;
      final updated = _career.playNextMatch();
      await SuperLeagueStorage.saveCareer(updated);
      if (!mounted) return;
      setState(() {
        _career = updated;
        _lastPlayedFixture = before == null ? null : updated.fixtures.firstWhere(
          (fixture) => fixture.round == before.round && fixture.homeTeam == before.homeTeam && fixture.awayTeam == before.awayTeam,
        );
        _showLastResult = _lastPlayedFixture != null;
        _isPlaying = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _isPlaying = false; _error = 'Не удалось сохранить результат матча.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final next = _career.nextFixture;
    final showResult = _showLastResult && _lastPlayedFixture != null;
    final played = _career.fixtures.where((f) => f.isPlayed && (f.homeTeam == _career.player.club || f.awayTeam == _career.player.club)).length;
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
        title: Text('СЕЗОН ${_career.season}',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        actions: [
          IconButton(
            tooltip: 'Таблица',
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => SuperLeagueTableScreen(career: _career))),
            icon: SvgPicture.asset('assets/icons/table.svg', width: 32, height: 32, color: Colors.white),
          ),
        ],
      ),
      body: Stack(children: [
        Positioned.fill(child: Opacity(opacity: 0.20,
          child: Image.asset('assets/images/fon2.png', fit: BoxFit.cover))),
        SafeArea(child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  ClubColors.primary(_career.player.club).withValues(alpha: 0.82),
                  Color.lerp(ClubColors.primary(_career.player.club), const Color(0xFF071B0D), 0.65)!,
                  const Color(0xFF071B0D),
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22), topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                border: Border.all(color: ClubColors.primary(_career.player.club).withValues(alpha: 0.8)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ПРОГРЕСС ЧЕМПИОНАТА', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_career.player.club, style: const TextStyle(
                      color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A2110).withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF14401E)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Image.asset('assets/icons/cup.png', width: 22, height: 22, fit: BoxFit.contain),
                        const SizedBox(width: 6),
                        const Text('СУПЕРЛИГА', style: TextStyle(
                          color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.7)),
                      ]),
                    ),
                  ])),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('$played/$total', style: const TextStyle(color: _green, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('СЕЗОН ${_career.season}/10', style: const TextStyle(
                      color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800)),
                  ]),
                ]),
                const SizedBox(height: 12),
                ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
                  value: played / total, minHeight: 8, backgroundColor: const Color(0xFF12381B),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BE07F)))),
              ]),
            ),
            const SizedBox(height: 18),
            _panelCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('СТАТИСТИКА СЕЗОНА', style: TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _seasonStat('Матчи', '${_career.playedMatches}')),
                Expanded(child: _seasonStat('Голы', '${_career.goals}')),
                Expanded(child: _seasonStat('Ассисты', '${_career.assists}')),
                Expanded(child: _seasonStat('Оценка', _career.averageRating == 0 ? '—' : _career.averageRating.toStringAsFixed(1))),
              ]),
            ])),
            const SizedBox(height: 18),
            if (showResult) ...[
              _resultCard(_lastPlayedFixture!),
              const SizedBox(height: 12),
              SizedBox(height: 50, child: ElevatedButton.icon(
                onPressed: () => setState(() => _showLastResult = false),
                icon: const Icon(Icons.skip_next_rounded),
                label: const Text('СЛЕДУЮЩИЙ МАТЧ', style: TextStyle(fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: const Color(0xFF082A12)),
              )),
            ] else ...[
            const Text('СЛЕДУЮЩИЙ МАТЧ', style: TextStyle(
              color: Color(0xFF8BE07F), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
            const SizedBox(height: 10),
            if (next == null)
              _panelCard(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Сезон завершён!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('Все матчи твоей команды сыграны.', style: TextStyle(color: Colors.white70)),
                if (_career.season < 10) ...[
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
                    onPressed: _startNextSeason,
                    style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
                    child: const Text('НАЧАТЬ СЛЕДУЮЩИЙ СЕЗОН', style: TextStyle(fontWeight: FontWeight.w900)),
                  )),
                ] else ...[
                  const SizedBox(height: 12),
                  const Text('Карьера Суперлиги завершена! Ты прошёл все 10 сезонов.',
                    style: TextStyle(color: Color(0xFF8BE07F), fontWeight: FontWeight.w800)),
                ],
              ]))
            else ...[
              _panelCard(Column(children: [
                Text('ТУР ${next.round}', style: const TextStyle(
                  color: Color(0xFF8BE07F), fontWeight: FontWeight.w900, fontSize: 11)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _teamName(next.homeTeam, next.homeTeam == _career.player.club)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('VS', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900))),
                  Expanded(child: _teamName(next.awayTeam, next.awayTeam == _career.player.club, alignEnd: true)),
                ]),
              ])),
              const SizedBox(height: 12),
              SizedBox(height: 54, child: ElevatedButton.icon(
                onPressed: _isPlaying ? null : _playNext,
                icon: _isPlaying ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sports_soccer_rounded),
                label: Text(_isPlaying ? 'СИМУЛЯЦИЯ...' : 'СЫГРАТЬ МАТЧ',
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
              )),
            ],
            ],
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 10),
              child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
            const SizedBox(height: 22),
            Row(children: [
              const Expanded(child: Text('КАЛЕНДАРЬ', style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.6))),
              Text('${_career.fixtures.where((f) => f.isPlayed && (f.homeTeam == _career.player.club || f.awayTeam == _career.player.club)).length} сыграно',
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ]),
            const SizedBox(height: 10),
            ..._career.fixtures.where((f) => f.homeTeam == _career.player.club || f.awayTeam == _career.player.club).map((fixture) {
              final isHome = fixture.homeTeam == _career.player.club;
              final opponent = isHome ? fixture.awayTeam : fixture.homeTeam;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                decoration: BoxDecoration(
                  color: Color.lerp(const Color(0xFF0A2110), ClubColors.primary(opponent), 0.12)!, borderRadius: BorderRadius.circular(10),
                  border: Border(left: BorderSide(color: ClubColors.primary(opponent), width: 4))),
                child: Row(children: [
                  SizedBox(width: 38, child: Text('${fixture.round}.', style: const TextStyle(color: Colors.white54, fontSize: 12))),
                  Expanded(child: Text(isHome ? '${_career.player.club} — $opponent' : '$opponent — ${_career.player.club}',
                    style: TextStyle(color: fixture.isPlayed ? Colors.white70 : Colors.white, fontSize: 12, fontWeight: fixture.isPlayed ? FontWeight.w500 : FontWeight.w800))),
                  Text(fixture.isPlayed ? '${fixture.homeGoals} : ${fixture.awayGoals}' : '— : —',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                ]),
              );
            }),
            const SizedBox(height: 12),
          ],
        )),
      ]),
    ));
  }

  Future<void> _startNextSeason() async {
    if (_career.season >= 10 || _isPlaying) return;
    setState(() { _isPlaying = true; _error = null; });
    try {
      var completed = _career;
      if (completed.developmentPointsAwardedSeason < completed.season) {
        completed = completed.copyWith(
          developmentPoints: completed.developmentPoints + completed.developmentPointsForSeason,
          developmentPointsAwardedSeason: completed.season,
        );
      }
      await SuperLeagueStorage.saveCareer(completed);
      if (!mounted) return;
      setState(() { _career = completed; _isPlaying = false; });

      final developmentResult = await Navigator.push<SuperLeagueCareer>(
        context,
        MaterialPageRoute(builder: (_) => SuperLeagueDevelopmentScreen(career: _career)),
      );
      if (!mounted) return;
      if (developmentResult != null) {
        setState(() => _career = developmentResult);
        await SuperLeagueStorage.saveCareer(developmentResult);
      }

      final transferResult = await Navigator.push<SuperLeagueCareer>(
        context,
        MaterialPageRoute(builder: (_) => SuperLeagueTransfersScreen(career: _career)),
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
      setState(() { _isPlaying = false; _error = 'Не удалось сохранить новый сезон.'; });
    }
  }

  Widget _resultCard(SuperLeagueFixture fixture) {
    final isHome = fixture.homeTeam == _career.player.club;
    final goals = isHome ? fixture.playerGoals : fixture.playerGoals;
    final rating = fixture.playerPlayed ? fixture.playerRating.toStringAsFixed(1) : '—';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ClubColors.primary(_career.player.club).withValues(alpha: 0.55), const Color(0xFF0A2110)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ClubColors.primary(_career.player.club)),
      ),
      child: Column(children: [
        const Text('РЕЗУЛЬТАТ МАТЧА', style: TextStyle(
          color: Color(0xFF8BE07F), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _teamName(fixture.homeTeam, fixture.homeTeam == _career.player.club)),
          Column(children: [
            Text('${fixture.homeGoals} : ${fixture.awayGoals}',
              style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(fixture.homeGoals! > fixture.awayGoals! ? 'ПОБЕДА' :
              fixture.homeGoals! < fixture.awayGoals! ? 'ПОРАЖЕНИЕ' : 'НИЧЬЯ',
              style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w900)),
          ]),
          Expanded(child: _teamName(fixture.awayTeam, fixture.awayTeam == _career.player.club, alignEnd: true)),
        ]),
        const Divider(color: Color(0xFF24552C), height: 26),
        Row(children: [
          Expanded(child: _resultStat('ГОЛЫ', '${fixture.playerGoals}')),
          Expanded(child: _resultStat('АССИСТЫ', '${fixture.playerAssists}')),
          Expanded(child: _resultStat('ОЦЕНКА', rating)),
          Expanded(child: _resultStat('УЧАСТИЕ', fixture.playerPlayed ? 'Да' : 'Нет')),
        ]),
      ]),
    );
  }

  Widget _resultStat(String label, String value) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w800)),
  ]);

  Widget _seasonStat(String label, String value) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
    const SizedBox(height: 5),
    Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 10)),
  ]);

  Widget _teamName(String name, bool isPlayer, {bool alignEnd = false}) {
    return Column(crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
      Container(width: 42, height: 42, alignment: Alignment.center,
        decoration: BoxDecoration(color: ClubColors.primary(name).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12), border: Border.all(color: ClubColors.primary(name))),
        child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
      const SizedBox(height: 8),
      Text(name, textAlign: alignEnd ? TextAlign.end : TextAlign.start, maxLines: 2,
        style: TextStyle(color: Colors.white, fontWeight: isPlayer ? FontWeight.w900 : FontWeight.w700, fontSize: 13)),
    ]);
  }

  Widget _panelCard(Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFF14401E))),
    child: child,
  );
}
