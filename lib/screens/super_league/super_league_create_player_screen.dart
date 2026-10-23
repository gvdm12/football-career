import 'package:flutter/material.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/player.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  // Тот же список национальностей, что и в обычной карьере.
  static const _nationalities = [
    'Россия',
    'Бразилия',
    'Германия',
    'Франция',
    'Испания',
    'Англия',
    'Италия',
    'Нидерланды',
    'Бельгия',
    'Дания',
    'Аргентина',
    'Хорватия',
    'Швейцария',
    'Австрия',
    'Норвегия',
    'Польша',
    'Турция',
    'Украина',
    'Греция',
    'Шотландия',
    'Ирландия',
    'Колумбия',
    'Чили',
    'Уругвай',
    'Канада',
    'Мексика',
    'США',
    'Иран',
    'Южная Корея',
    'Япония',
    'Катар',
    'Саудовская Аравия',
    'Алжир',
    'Марокко',
    'Камерун',
    'Нигерия',
    'Сенегал',
    'Египет',
    'Тунис',
  ];

  static const Map<String, String> _nationalityCodes = {
    'Россия': 'RU',
    'Бразилия': 'BR',
    'Германия': 'DE',
    'Франция': 'FR',
    'Испания': 'ES',
    'Англия': 'GB',
    'Италия': 'IT',
    'Нидерланды': 'NL',
    'Бельгия': 'BE',
    'Дания': 'DK',
    'Аргентина': 'AR',
    'Хорватия': 'HR',
    'Швейцария': 'CH',
    'Австрия': 'AT',
    'Норвегия': 'NO',
    'Польша': 'PL',
    'Турция': 'TR',
    'Украина': 'UA',
    'Греция': 'GR',
    'Шотландия': 'GB',
    'Ирландия': 'IE',
    'Колумбия': 'CO',
    'Чили': 'CL',
    'Уругвай': 'UY',
    'Канада': 'CA',
    'Мексика': 'MX',
    'США': 'US',
    'Иран': 'IR',
    'Южная Корея': 'KR',
    'Япония': 'JP',
    'Катар': 'QA',
    'Саудовская Аравия': 'SA',
    'Алжир': 'DZ',
    'Марокко': 'MA',
    'Камерун': 'CM',
    'Нигерия': 'NG',
    'Сенегал': 'SN',
    'Египет': 'EG',
    'Тунис': 'TN',
  };

  Widget _buildNationalityFlag(String nationality) {
    if (nationality == 'Англия') {
      return SvgPicture.asset(
        'assets/flags/gb-eng.svg',
        width: 30,
        height: 20,
        fit: BoxFit.cover,
      );
    }

    if (nationality == 'Шотландия') {
      return SvgPicture.asset(
        'assets/flags/gb-sct.svg',
        width: 30,
        height: 20,
        fit: BoxFit.cover,
      );
    }

    return CountryFlag.fromCountryCode(
      _nationalityCodes[nationality] ?? 'UN',
      theme: const ImageTheme(height: 20, width: 30),
    );
  }

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

  Widget _buildPositionButton({
    required String shortName,
    required String fullName,
    required PlayerPosition position,
  }) {
    final selected = _position == position;

    return GestureDetector(
      onTap: () => setState(() => _position = position),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 72,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E5729) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected ? const Color(0xFF3E9950) : const Color(0xFF123C1D),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              shortName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
            Row(
              children:
                  [
                        _buildPositionButton(
                          shortName: 'ST',
                          fullName: 'Нападающий',
                          position: PlayerPosition.forward,
                        ),
                        _buildPositionButton(
                          shortName: 'CM',
                          fullName: 'Полузащитник',
                          position: PlayerPosition.midfielder,
                        ),
                        _buildPositionButton(
                          shortName: 'CB',
                          fullName: 'Защитник',
                          position: PlayerPosition.defender,
                        ),
                      ]
                      .map(
                        (button) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: button,
                          ),
                        ),
                      )
                      .toList(),
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
              isExpanded: true,
              dropdownColor: const Color(0xFF0B3A1A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
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
              selectedItemBuilder: (context) => _nationalities.map((
                nationality,
              ) {
                return Row(
                  children: [
                    _buildNationalityFlag(nationality),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(nationality, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                );
              }).toList(),
              items: _nationalities.map((nationality) {
                return DropdownMenuItem<String>(
                  value: nationality,
                  child: Row(
                    children: [
                      _buildNationalityFlag(nationality),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          nationality,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
