import 'package:flutter/material.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/super_league_career.dart';

class SuperLeagueTableScreen extends StatelessWidget {
  final SuperLeagueCareer career;
  const SuperLeagueTableScreen({super.key, required this.career});

  static const Color _bg = Color(0xFF061B0C);
  static const Color _panel = Color(0xFF0B2813);
  static const Color _green = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final standings = career.standings;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: const Text('ТАБЛИЦА СУПЕРЛИГИ',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
      body: SafeArea(
        child: Column(children: [
          Container(
            margin: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF163C22), Color(0xFF0B2813)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF285438))),
            child: Row(children: [
              const Icon(Icons.emoji_events_rounded, color: Color(0xFF8BE07F), size: 30),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('СЕЗОН ${career.season}/10', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                const Text('20 клубов • 38 туров', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF12351D)),
                dataRowMinHeight: 54,
                dataRowMaxHeight: 60,
                columnSpacing: 16,
                horizontalMargin: 12,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('КЛУБ')),
                  DataColumn(label: Text('И')),
                  DataColumn(label: Text('В')),
                  DataColumn(label: Text('Н')),
                  DataColumn(label: Text('П')),
                  DataColumn(label: Text('МЯЧИ')),
                  DataColumn(label: Text('РМ')),
                  DataColumn(label: Text('О')),
                ],
                rows: [
                  for (var i = 0; i < standings.length; i++)
                    DataRow(
                      color: WidgetStateProperty.resolveWith((states) =>
                        standings[i].club == career.player.club
                          ? const Color(0x3322C55E)
                          : i.isEven ? _panel : const Color(0xFF081F10)),
                      cells: [
                        DataCell(Text('${i + 1}', style: TextStyle(
                          color: i < 3 ? const Color(0xFF8BE07F) : Colors.white70,
                          fontWeight: FontWeight.w900))),
                        DataCell(SizedBox(width: 160, child: Row(children: [
                          Container(width: 30, height: 30, alignment: Alignment.center,
                            decoration: BoxDecoration(color: Clubs.getByName(standings[i].club).primaryColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Clubs.getByName(standings[i].club).primaryColor)),
                            child: Text(standings[i].club.split(' ').map((p) => p.isEmpty ? '' : p[0]).take(2).join(),
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))),
                          const SizedBox(width: 9),
                          Expanded(child: Text(standings[i].club, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: standings[i].club == career.player.club ? _green : Colors.white,
                              fontWeight: standings[i].club == career.player.club ? FontWeight.w900 : FontWeight.w600))),
                        ]))),
                        DataCell(Text('${standings[i].played}')),
                        DataCell(Text('${standings[i].wins}')),
                        DataCell(Text('${standings[i].draws}')),
                        DataCell(Text('${standings[i].losses}')),
                        DataCell(Text('${standings[i].goalsFor}:${standings[i].goalsAgainst}')),
                        DataCell(Text('${standings[i].goalDifference > 0 ? '+' : ''}${standings[i].goalDifference}', style: TextStyle(
                          color: standings[i].goalDifference > 0 ? const Color(0xFF8BE07F) : Colors.white70,
                          fontWeight: FontWeight.w800))),
                        DataCell(Text('${standings[i].points}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                      ],
                    ),
                ],
              ),
            ),
          )),
        ]),
      ),
    );
  }
}
