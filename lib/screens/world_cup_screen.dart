import 'package:flutter/material.dart';
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
    final playerCanPlay = tournament.isPlayerCalledUp &&
        tournament.participants.contains(career.player.nationality);
    final updatedTournament = playerCanPlay
        ? tournament.playCurrentRound(playerTeam: career.player.nationality)
        : tournament.simulateRemainingMatches();
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
    if (updatedTournament.isCompleted && mounted) {
      Navigator.pop(context, updatedCareer);
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

  @override
  Widget build(BuildContext context) {
    final playerCanPlay = tournament.isPlayerCalledUp &&
        tournament.participants.contains(career.player.nationality);
    final playerMatches = tournament.matches.where(
      (match) => match.homeTeam == career.player.nationality ||
          match.awayTeam == career.player.nationality,
    ).toList();
    final playerMatch = playerMatches.isEmpty ? null : playerMatches.first;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Чемпионат мира'),
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
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(_callUpMessage, style: const TextStyle(color: Color(0xFF8BE07F))),
                  const SizedBox(height: 8),
                  Text(
                    'В финальной части участвуют ${tournament.participants.length} из ${worldCupNationalTeams.length} сборных.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (playerCanPlay && playerMatch != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Матч сборной: ${playerMatch.homeTeam} '
                      '${playerMatch.isPlayed ? playerMatch.homeGoals : '-'} : '
                      '${playerMatch.isPlayed ? playerMatch.awayGoals : '-'} '
                      '${playerMatch.awayTeam}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (tournament.champion != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Чемпион мира: ${tournament.champion}',
                      style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(tournament.stage.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...tournament.matches.map((match) {
              final isPlayerTeam = match.homeTeam == career.player.nationality ||
                  match.awayTeam == career.player.nationality;
              return Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: isPlayerTeam ? const Color(0xFF123A1D) : const Color(0xFF0A2110),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isPlayerTeam ? green : Colors.white12),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(match.homeTeam, style: const TextStyle(color: Colors.white))),
                    Text(
                      match.isPlayed ? '${match.homeGoals} : ${match.awayGoals}' : '— : —',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text(match.awayTeam, textAlign: TextAlign.end, style: const TextStyle(color: Colors.white))),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            if (!tournament.isCompleted)
              FilledButton(
                onPressed: busy ? null : _continueTournament,
                style: FilledButton.styleFrom(backgroundColor: green, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(
                  busy ? 'Симуляция...' : playerCanPlay ? 'Сыграть матч сборной' : 'Симулировать чемпионат мира',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
