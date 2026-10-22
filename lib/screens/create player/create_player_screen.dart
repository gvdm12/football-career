import 'package:flutter/material.dart';

import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/screens/player/player_screen.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/career_storage.dart';
import 'package:flutter_football/services/language_service.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter_svg/svg.dart';

class CreatePlayerScreen extends StatefulWidget {
  const CreatePlayerScreen({super.key});

  @override
  State<CreatePlayerScreen> createState() => _CreatePlayerScreenState();
}

class _CreatePlayerScreenState extends State<CreatePlayerScreen> {
  static const Color green = Color(0xFF8BE07F);

  final TextEditingController _nameController = TextEditingController();

  String selectedPosition = 'ST';
  late List<Club> startingClubs;
  String? selectedClub;
  String selectedNationality = 'Россия';

  bool _isCreating = false;

  List<Map<String, String>> get positions => [
    {'short': 'ST', 'name': AppStrings.striker},
    {'short': 'CM', 'name': AppStrings.midfielder},
    {'short': 'CB', 'name': AppStrings.defender},
  ];

  final Map<String, String> _nationalityCodes = {
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

  String _nationalityCode(String nationality) {
    return _nationalityCodes[nationality] ?? 'UN';
  }

  final List<String> nationalities = [
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

  final Map<String, String> _nationalityNamesEn = {
    'Россия': 'Russia',
    'Бразилия': 'Brazil',
    'Германия': 'Germany',
    'Франция': 'France',
    'Испания': 'Spain',
    'Англия': 'England',
    'Италия': 'Italy',
    'Нидерланды': 'Netherlands',
    'Бельгия': 'Belgium',
    'Дания': 'Denmark',
    'Аргентина': 'Argentina',
    'Хорватия': 'Croatia',
    'Швейцария': 'Switzerland',
    'Австрия': 'Austria',
    'Норвегия': 'Norway',
    'Польша': 'Poland',
    'Турция': 'Turkey',
    'Украина': 'Ukraine',
    'Греция': 'Greece',
    'Шотландия': 'Scotland',
    'Ирландия': 'Ireland',
    'Колумбия': 'Colombia',
    'Чили': 'Chile',
    'Уругвай': 'Uruguay',
    'Канада': 'Canada',
    'Мексика': 'Mexico',
    'США': 'USA',
    'Иран': 'Iran',
    'Южная Корея': 'South Korea',
    'Япония': 'Japan',
    'Катар': 'Qatar',
    'Саудовская Аравия': 'Saudi Arabia',
    'Алжир': 'Algeria',
    'Марокко': 'Morocco',
    'Камерун': 'Cameroon',
    'Нигерия': 'Nigeria',
    'Сенегал': 'Senegal',
    'Египет': 'Egypt',
    'Тунис': 'Tunisia',
  };

  String _nationalityLabel(String nationality) {
    if (!LanguageService.isEnglish) return nationality;
    return _nationalityNamesEn[nationality] ?? nationality;
  }

  @override
  void initState() {
    super.initState();

    startingClubs = Clubs.randomStartingClubs();
    selectedClub = startingClubs.first.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  PlayerPosition _convertPosition(String position) {
    switch (position) {
      case 'ST':
        return PlayerPosition.forward;
      case 'CM':
        return PlayerPosition.midfielder;
      case 'CB':
        return PlayerPosition.defender;
      default:
        return PlayerPosition.forward;
    }
  }

  Future<void> _createCareer() async {
    if (_isCreating || selectedClub == null) return;

    setState(() => _isCreating = true);

    final name = _nameController.text.trim().isEmpty
        ? 'Player'
        : _nameController.text.trim();

    final player = Player.create(
      name: name,
      nationality: selectedNationality,
      position: _convertPosition(selectedPosition),
      club: selectedClub!,
    );

    final career = Career.create(player);

    try {
      await CareerStorage.save(career);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PlayerScreen(career: career)),
      );

      if (mounted) {
        setState(() => _isCreating = false);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isCreating = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.saveCareerError('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF071D0D), Color(0xFF061A0C), Color(0xFF021107)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),

                const SizedBox(height: 28),

                Text(
                  AppStrings.createPlayerTitle,
                  style: const TextStyle(
                    fontSize: 36,
                    height: 0.92,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 20),

                _buildLabel(AppStrings.playerName),

                const SizedBox(height: 8),

                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: AppStrings.enterName,
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),

                const SizedBox(height: 18),

                _buildLabel(AppStrings.position),

                const SizedBox(height: 10),

                Row(
                  children: positions.map((position) {
                    final isSelected = selectedPosition == position['short'];

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _PositionButton(
                          shortName: position['short']!,
                          fullName: position['name']!,
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              selectedPosition = position['short']!;
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                _buildLabel(AppStrings.nationality),

                const SizedBox(height: 10),

                _buildNationalityDropdown(),

                const SizedBox(height: 18),

                Text(
                  AppStrings.startingClub,
                  style: const TextStyle(
                    color: green,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF14401E)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedClub,
                      dropdownColor: const Color(0xFF0B3A1A),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: green),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      items: startingClubs.map((club) {
                        final leagueName = LanguageService.isEnglish
                            ? club.league.displayName
                            : club.league.countryName;

                        return DropdownMenuItem<String>(
                          value: club.name,
                          child: Text(
                            '${club.name}-$leagueName-${club.strength}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedClub = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createCareer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 23, 119, 45),
                      disabledBackgroundColor: const Color(0xFF09200F),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: const Color(0xFF214B28),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            AppStrings.createCareer,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNationalityFlag(String nationality) {
    if (nationality == 'Англия') {
      return SvgPicture.asset(
        'assets/flags/gb-eng.svg',
        width: 20,
        height: 25,
        fit: BoxFit.cover,
      );
    }

    if (nationality == 'Шотландия') {
      return SvgPicture.asset(
        'assets/flags/gb-sct.svg',
        width: 20,
        height: 25,
        fit: BoxFit.cover,
      );
    }

    return CountryFlag.fromCountryCode(
      _nationalityCode(nationality),
      theme: const ImageTheme(height: 20, width: 30),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFF185526)),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Color(0xFF57A963),
              size: 30,
            ),
          ),
        ),

        const SizedBox(width: 16),

        Text(
          AppStrings.newCareerTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color.fromARGB(255, 106, 215, 126),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildNationalityDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedNationality,
      isExpanded: true,
      dropdownColor: const Color.fromARGB(255, 80, 81, 80),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      ),
      selectedItemBuilder: (context) {
        return nationalities.map((nationality) {
          return Row(
            children: [
              _buildNationalityFlag(nationality),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _nationalityLabel(nationality),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }).toList();
      },
      items: nationalities.map((nationality) {
        return DropdownMenuItem<String>(
          value: nationality,
          child: Row(
            children: [
              _buildNationalityFlag(nationality),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _nationalityLabel(nationality),
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          selectedNationality = value;
        });
      },
    );
  }
}

class _PositionButton extends StatelessWidget {
  final String shortName;
  final String fullName;
  final bool selected;
  final VoidCallback onTap;

  const _PositionButton({
    required this.shortName,
    required this.fullName,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
