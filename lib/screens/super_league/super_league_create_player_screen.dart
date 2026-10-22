import 'package:flutter/material.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/player.dart';

class SuperLeagueCreatePlayerScreen extends StatefulWidget {
  final Club club;

  const SuperLeagueCreatePlayerScreen({super.key, required this.club});

  @override
  State<SuperLeagueCreatePlayerScreen> createState() =>
      _SuperLeagueCreatePlayerScreenState();
}

class _SuperLeagueCreatePlayerScreenState
    extends State<SuperLeagueCreatePlayerScreen> {
  static const Color _green = Color(0xFF22C55E);
  final _nameController = TextEditingController();

  PlayerPosition _position = PlayerPosition.forward;
  String _nationality = 'Россия';

  static const _nationalities = [
    'Россия',
    'Бразилия',
    'Германия',
    'Франция',
    'Испания',
    'Англия',
    'Италия',
    'Нидерланды',
    'Аргентина',
    'США',
    'Япония',
    'Португалия',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _positionLabel(PlayerPosition position) {
    switch (position) {
      case PlayerPosition.goalkeeper:
        return 'Вратарь';
      case PlayerPosition.defender:
        return 'Защитник';
      case PlayerPosition.midfielder:
        return 'Полузащитник';
      case PlayerPosition.forward:
        return 'Нападающий';
    }
  }

  void _createPlayer() {
    final name = _nameController.text.trim();
    final generatedPlayer = Player.create(
      name: name.isEmpty ? 'Player' : name,
      nationality: _nationality,
      position: _position,
      club: widget.club.name,
    );

    // В Суперлиге рейтинг на старте фиксирован, независимо от позиции.
    final player = generatedPlayer.copyWith(overall: 75);
    Navigator.pop(context, player);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: const Text(
          'СОЗДАНИЕ ИГРОКА',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0B2813),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: widget.club.primaryColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.club.primaryColor.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      widget.club.name
                          .split(' ')
                          .map((part) => part.isEmpty ? '' : part[0])
                          .take(2)
                          .join()
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ТВОЙ КЛУБ',
                          style: TextStyle(
                            color: Color(0xFF8BE07F),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.club.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Сила клуба: ${widget.club.strength}',
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '75',
                    style: TextStyle(
                      color: _green,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'ИМЯ ФУТБОЛИСТА',
              style: TextStyle(
                color: Color(0xFF8BE07F),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Введи имя',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF0B2813),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: Color(0xFF174324)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: Color(0xFF174324)),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'ПОЗИЦИЯ',
              style: TextStyle(
                color: Color(0xFF8BE07F),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PlayerPosition.values.map((position) {
                final selected = position == _position;
                return ChoiceChip(
                  label: Text(_positionLabel(position)),
                  selected: selected,
                  onSelected: (_) => setState(() => _position = position),
                  selectedColor: const Color(0xFF1D6330),
                  backgroundColor: const Color(0xFF0B2813),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: selected ? _green : const Color(0xFF174324),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            const Text(
              'НАЦИОНАЛЬНОСТЬ',
              style: TextStyle(
                color: Color(0xFF8BE07F),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _nationality,
              dropdownColor: const Color(0xFF0B3A1A),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0B2813),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: Color(0xFF174324)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(color: Color(0xFF174324)),
                ),
              ),
              items: _nationalities
                  .map((nationality) => DropdownMenuItem(
                        value: nationality,
                        child: Text(nationality),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _nationality = value);
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _createPlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'СОЗДАТЬ ИГРОКА',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Начальный рейтинг игрока в Суперлиге — 75',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
