import 'package:flutter/material.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/super_league_career.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuperLeagueTransfersScreen extends StatefulWidget {
  final SuperLeagueCareer career;
  const SuperLeagueTransfersScreen({super.key, required this.career});

  @override
  State<SuperLeagueTransfersScreen> createState() =>
      _SuperLeagueTransfersScreenState();
}

class _SuperLeagueTransfersScreenState
    extends State<SuperLeagueTransfersScreen> {
  late SuperLeagueCareer _career;
  late List<Club> _offers;

  @override
  void initState() {
    super.initState();
    _career = widget.career;
    _offers = _generateOffers();
  }

  List<Club> _generateOffers() {
    final current = Clubs.getByName(_career.player.club);
    final maxStrength = (_career.player.overall + 15).clamp(65, 99);
    final candidates = Clubs.all
        .where(
          (club) =>
              SuperLeagueCareer.clubNames.contains(club.name) &&
              club.name != _career.player.club &&
              club.strength <= maxStrength &&
              club.strength >= (current.strength - 12),
        )
        .toList();
    candidates.shuffle();
    return candidates.take(3).toList();
  }

  void _accept(Club club) {
    if (!SuperLeagueCareer.clubNames.contains(club.name)) return;
    final next = _career.copyWith(
      player: _career.player.copyWith(club: club.name),
    );
    Navigator.pop(context, next);
  }

  void _stay() {
    Navigator.pop(context, _career);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF061B0C),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(82, 81, 84, 82),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Text(
            'ТРАНСФЕРНОЕ ОКНО',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ClubColors.primary(
                        _career.player.club,
                      ).withValues(alpha: 0.6),
                      const Color(0xFF071B0D),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: ClubColors.primary(_career.player.club),
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/player.svg',
                      width: 54,
                      height: 54,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _career.player.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ТЕКУЩИЙ КЛУБ: ${_career.player.club}',
                            style: const TextStyle(
                              color: Color(0xFF8BE07F),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'РЕЙТИНГ ${_career.player.overall} • ВОЗРАСТ ${_career.player.age}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'ПРЕДЛОЖЕНИЯ КЛУБОВ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              if (_offers.isEmpty)
                _emptyOffers()
              else
                ..._offers.map(_offerCard),
              const SizedBox(height: 4),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: _stay,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF3C884A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    'ОСТАТЬСЯ В ${_career.player.club.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _offerCard(Club club) {
    final primary = ClubColors.primary(club.name);
    final secondary = ClubColors.secondary(club.name);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: primary.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [secondary, primary]),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  club.name[0],
                  style: TextStyle(
                    color: secondary.computeLuminance() > 0.45
                        ? Colors.black
                        : Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      club.league.displayName,
                      style: const TextStyle(
                        color: Color(0xFF8BE07F),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${club.strength}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'СИЛА',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              // Text(
              //   'Суперлига',
              //   style: TextStyle(color: Colors.white70, fontSize: 12),
              // ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => _accept(club),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BE07F),
                foregroundColor: const Color(0xFF082A12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'ПРИНЯТЬ ПРЕДЛОЖЕНИЕ',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyOffers() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0x14FFFFFF),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF14401E)),
    ),
    child: Column(
      children: [
        const Icon(Icons.hourglass_empty, color: Color(0xFF8BE07F), size: 34),
        const SizedBox(height: 8),
        const Text(
          'Пока нет предложений',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => setState(() => _offers = _generateOffers()),
          child: const Text('ОБНОВИТЬ ПРЕДЛОЖЕНИЯ'),
        ),
      ],
    ),
  );
}
