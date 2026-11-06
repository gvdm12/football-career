import 'package:flutter/material.dart';

import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/career_settings.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_division_service.dart';
import 'package:flutter_football/models/position_rival.dart';
import 'package:flutter_football/widgets/jersey_number_picker.dart';
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
  bool _showCareerSettings = false;
  bool _allowAnyClub = false;
  bool _limitTransfersToFiveYears = false;
  bool _playWithoutInjuries = false;
  CareerDifficulty _difficulty = CareerDifficulty.normal;

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
    'Португалия': 'PT',
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
    'Швеция': 'SE',
    'Венесуэла': 'VE',
    'Палестина': 'PS',
    'Венгрия': 'HU',
    'Босния': 'BA',
    'Албания': 'AL',
    'Австралия': 'AU',
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
    'Португалия',
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
    'Швеция',
    'Венесуэла',
    'Палестина',
    'Венгрия',
    'Босния',
    'Албания',
    'Австралия',
  ];

  final Map<String, String> _nationalityNamesEn = {
    'Россия': 'Russia',
    'Бразилия': 'Brazil',
    'Германия': 'Germany',
    'Франция': 'France',
    'Испания': 'Spain',
    'Англия': 'England',
    'Италия': 'Italy',
    'Португалия': 'Portugal',
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
    'Швеция': 'Sweden',
    'Венесуэла': 'Venezuela',
    'Палестина': 'Palestine',
    'Венгрия': 'Hungary',
    'Босния': 'Bosnia',
    'Албания': 'Albania',
    'Австралия': 'Australia',
  };

  String _nationalityLabel(String nationality) {
    if (!LanguageService.isEnglish) return nationality;
    return _nationalityNamesEn[nationality] ?? nationality;
  }

  @override
  void initState() {
    super.initState();

    Clubs.resetCareerState();
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

    final previewRivals = PositionRival.generate(player: player, season: 1);
    final jerseyNumber = await JerseyNumberPicker.show(
      context: context,
      takenNumbers: previewRivals.map((rival) => rival.jerseyNumber).toSet(),
      preferredNumber: player.jerseyNumber,
      playerOverall: player.overall,
      english: AppStrings.isEnglish,
    );

    if (!mounted) return;
    if (jerseyNumber == null) {
      setState(() => _isCreating = false);
      return;
    }

    final career = Career.create(
      player.copyWith(jerseyNumber: jerseyNumber),
      settings: CareerSettings(
        allowAnyStartingClub: _allowAnyClub,
        difficulty: _difficulty,
        limitTransfersToFiveYears: _limitTransfersToFiveYears,
        playWithoutInjuries: _playWithoutInjuries,
        // Частота травм корректируется сложностью отдельно.
        injuryFrequency: 1.0,
        // Скорость развития оставлена прежней: лёгкая сложность ускоряет,
        // а сложная замедляет прокачку так же, как и раньше.
        developmentSpeed: _difficulty == CareerDifficulty.easy
            ? 1.15
            : _difficulty == CareerDifficulty.hard
            ? 0.85
            : 1.0,
      ),
    );

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
            colors: [
              Color.fromARGB(255, 15, 105, 39),
              Color(0xFF061A0C),
              Color(0xFF021107),
            ],
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

                const SizedBox(height: 10),

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

                _buildClubSelector(),

                const SizedBox(height: 20),

                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _showCareerSettings,
                    activeColor: green,
                    title: Text(
                      AppStrings.isEnglish
                          ? 'Career settings'
                          : 'Настройки карьеры',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      AppStrings.isEnglish
                          ? 'Enable additional career modes and difficulty options.'
                          : 'Сложность и режимы.',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _showCareerSettings = value),
                  ),
                ),

                if (_showCareerSettings) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _allowAnyClub,
                      activeColor: green,
                      title: Text(
                        AppStrings.isEnglish
                            ? 'Choose any club'
                            : 'Выбор любого клуба',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      // subtitle: Text(
                      //   AppStrings.isEnglish
                      //       ? 'Unlock every club in all available leagues.'
                      //       : 'Позволяет выбрать любой клуб из всех доступных лиг.',
                      //   style: const TextStyle(
                      //     color: Colors.white60,
                      //     fontSize: 11,
                      //   ),
                      // ),
                      onChanged: (value) {
                        setState(() {
                          _allowAnyClub = value;
                          if (!value &&
                              !startingClubs.any(
                                (club) => club.name == selectedClub,
                              )) {
                            selectedClub = startingClubs.first.name;
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 3),
                  DropdownButtonFormField<CareerDifficulty>(
                    value: _difficulty,
                    dropdownColor: const Color(0xFF0B3A1A),
                    decoration: InputDecoration(
                      labelText: AppStrings.isEnglish
                          ? 'Difficulty'
                          : 'Сложность карьеры',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF24552C)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    items: [
                      DropdownMenuItem(
                        value: CareerDifficulty.easy,
                        child: Text(AppStrings.isEnglish ? 'Easy' : 'Лёгкая'),
                      ),
                      DropdownMenuItem(
                        value: CareerDifficulty.normal,
                        child: Text(
                          AppStrings.isEnglish ? 'Normal' : 'Обычная',
                        ),
                      ),
                      DropdownMenuItem(
                        value: CareerDifficulty.hard,
                        child: Text(AppStrings.isEnglish ? 'Hard' : 'Сложная'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _difficulty = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    value: _limitTransfersToFiveYears,
                    activeColor: green,
                    title: Text(
                      AppStrings.isEnglish
                          ? 'Change club once every 5 seasons'
                          : 'Переход в другой клуб раз в 5 сезонов',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // subtitle: Text(
                    //   AppStrings.isEnglish
                    //       ? 'After a transfer, another club change is locked for five seasons.'
                    //       : 'После перехода следующий трансфер будет доступен через пять сезонов.',
                    //   style: const TextStyle(
                    //     color: Colors.white60,
                    //     fontSize: 11,
                    //   ),
                    // ),
                    onChanged: (value) =>
                        setState(() => _limitTransfersToFiveYears = value),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    value: _playWithoutInjuries,
                    activeColor: green,
                    title: Text(
                      AppStrings.isEnglish
                          ? 'Play without injuries'
                          : 'Игра без травм',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // subtitle: Text(
                    //   AppStrings.isEnglish
                    //       ? 'Your player will never receive an injury.'
                    //       : 'Игрок не будет получать травмы на протяжении карьеры.',
                    //   style: const TextStyle(
                    //     color: Colors.white60,
                    //     fontSize: 11,
                    //   ),
                    // ),
                    onChanged: (value) =>
                        setState(() => _playWithoutInjuries = value),
                  ),
                ],

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

  String _clubDetails(Club club) {
    final country = LanguageService.isEnglish
        ? club.league.displayName
        : club.league.countryName;
    final division = AppStrings.isEnglish
        ? 'Division ${club.division}'
        : '${club.division}-й дивизион';
    final strength = AppStrings.isEnglish
        ? 'Strength ${club.strength}'
        : 'Сила ${club.strength}';
    return '$country • $division • $strength';
  }

  Widget _buildClubSelector() {
    final club = Clubs.getByName(selectedClub!);

    return InkWell(
      onTap: _showClubPicker,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                club.league.logoAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.sports_soccer,
                  color: green,
                  size: 28,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_clubDetails(club)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                const Icon(Icons.edit_outlined, color: green, size: 20),
                const SizedBox(height: 3),
                Text(
                  AppStrings.isEnglish ? 'CHANGE' : 'ИЗМЕНИТЬ',
                  style: const TextStyle(
                    color: green,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClubPicker() async {
    final pickedClub = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        League? selectedLeague;
        var selectedDivision = 1;
        final allowAnyClub = _allowAnyClub;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isChoosingLeague = allowAnyClub && selectedLeague == null;
            final clubs = allowAnyClub
                ? (selectedLeague == null
                    ? <Club>[]
                    : Clubs.byLeagueDivision(selectedLeague!, selectedDivision))
                : startingClubs;
            final title = !allowAnyClub
                ? (AppStrings.isEnglish
                    ? 'Choose a starting club'
                    : 'Выбери стартовый клуб')
                : selectedLeague == null
                    ? (AppStrings.isEnglish ? 'Choose a league' : 'Выбери лигу')
                    : (LanguageService.isEnglish
                        ? selectedLeague!.displayName
                        : selectedLeague!.countryName);

            return SafeArea(
              top: false,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.84,
                decoration: const BoxDecoration(
                  color: Color(0xFF071B0D),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                      child: Row(
                        children: [
                          if (allowAnyClub && selectedLeague != null)
                            IconButton(
                              onPressed: () => setSheetState(() {
                                selectedLeague = null;
                                selectedDivision = 1;
                              }),
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 19,
                              ),
                            )
                          else
                            const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  isChoosingLeague
                                      ? (AppStrings.isEnglish
                                          ? 'Select a country to see its clubs'
                                          : 'Сначала выбери страну и лигу')
                                      : (AppStrings.isEnglish
                                          ? 'Select the club for your career'
                                          : 'Выбери команду для своей карьеры'),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isChoosingLeague)
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount: League.values.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.42,
                          ),
                          itemBuilder: (context, index) {
                            final league = League.values[index];
                            final hasTwoDivisions =
                                LeagueDivisionService.hasSecondDivision(league);
                            return Material(
                              color: Colors.white.withValues(alpha: 0.055),
                              borderRadius: BorderRadius.circular(15),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () => setSheetState(() {
                                  selectedLeague = league;
                                  selectedDivision = 1;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Image.asset(
                                          league.logoAsset,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) =>
                                              const Icon(
                                            Icons.emoji_events_outlined,
                                            color: green,
                                            size: 34,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        LanguageService.isEnglish
                                            ? league.displayName
                                            : league.countryName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        hasTwoDivisions
                                            ? (AppStrings.isEnglish
                                                ? '2 divisions'
                                                : '2 дивизиона')
                                            : (AppStrings.isEnglish
                                                ? '1 league'
                                                : '1 лига'),
                                        style: const TextStyle(
                                          color: green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else ...[
                      if (allowAnyClub &&
                          LeagueDivisionService.hasSecondDivision(selectedLeague!))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              for (final division in [1, 2])
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: division == 1 ? 8 : 0,
                                      left: division == 2 ? 8 : 0,
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => setSheetState(
                                        () => selectedDivision = division,
                                      ),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 160),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: selectedDivision == division
                                              ? const Color(0xFF1C5A2A)
                                              : Colors.white.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: selectedDivision == division
                                                ? green
                                                : Colors.white24,
                                          ),
                                        ),
                                        child: Text(
                                          division == 1
                                              ? (AppStrings.isEnglish
                                                  ? 'FIRST DIVISION'
                                                  : 'ПЕРВАЯ ЛИГА')
                                              : (AppStrings.isEnglish
                                                  ? 'SECOND DIVISION'
                                                  : 'ВТОРАЯ ЛИГА'),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppStrings.isEnglish ? 'AVAILABLE CLUBS' : 'ДОСТУПНЫЕ КЛУБЫ',
                              style: const TextStyle(
                                color: green,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          itemCount: clubs.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final club = clubs[index];
                            return Material(
                              color: Colors.white.withValues(alpha: 0.055),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => Navigator.pop(sheetContext, club.name),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: club.primaryColor.withValues(alpha: 0.22),
                                          borderRadius: BorderRadius.circular(11),
                                        ),
                                        child: const Icon(
                                          Icons.shield_outlined,
                                          color: Colors.white,
                                          size: 23,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              club.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_clubDetails(club)}',
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: green),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (pickedClub != null && mounted) {
      setState(() => selectedClub = pickedClub);
    }
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
