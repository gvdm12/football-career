import 'package:flutter/material.dart';

import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/screens/account/account_screen.dart';
import 'package:flutter_football/screens/create%20player/create_player_screen.dart';
import 'package:flutter_football/screens/player/player_screen.dart';
import 'package:flutter_football/screens/super_league/super_league_screen.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/career_storage.dart';
import 'package:flutter_football/services/fc_points_service.dart';
import 'package:flutter_football/screens/shop/fc_points_shop_screen.dart';
import 'package:flutter_football/settings/settings_screen.dart';
import 'package:flutter_football/widgets/save_slot_sheet.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color green = Color(0xFF22C55E);

  bool _hasSavedCareer = false;
  bool _isLoading = true;
  int _fcPointsBalance = 0;

  @override
  void initState() {
    super.initState();
    _checkSavedCareer();
  }

  Future<void> _checkSavedCareer() async {
    try {
      await CareerStorage.prepareAccount();
      final results = await Future.wait([
        CareerStorage.hasSavedCareer(),
        FCPointsService.balance(),
      ]);
      final hasSave = results[0] as bool;
      final pointsBalance = results[1] as int;

      if (!mounted) return;

      setState(() {
        _hasSavedCareer = hasSave;
        _fcPointsBalance = pointsBalance;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _hasSavedCareer = false;
        _fcPointsBalance = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewCareer() async {
    final slot = await SaveSlotSheet.show(
      context,
      mode: SaveSlotMode.newCareer,
    );

    if (!mounted) return;

    if (slot == null) {
      // Слоты могли быть удалены в панели выбора.
      await _checkSavedCareer();
      return;
    }

    await CareerStorage.setActiveSlot(slot);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePlayerScreen()),
    );

    if (!mounted) return;

    await _checkSavedCareer();
  }

  Future<void> _continueCareer() async {
    if (_isLoading) return;

    // Если сохранение одно, продолжаем его сразу, иначе даём выбрать слот.
    final summaries = await CareerStorage.slotSummaries();
    final occupied = summaries.where((item) => !item.isEmpty).toList();

    if (!mounted) return;

    final int? slot = occupied.length == 1
        ? occupied.first.slot
        : await SaveSlotSheet.show(
            context,
            mode: SaveSlotMode.continueCareer,
          );

    if (!mounted) return;

    if (slot == null) {
      await _checkSavedCareer();
      return;
    }

    await CareerStorage.setActiveSlot(slot);

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Career? career = await CareerStorage.load();

      if (!mounted) return;

      if (career == null) {
        setState(() {
          _hasSavedCareer = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppStrings.noSavedCareer)));

        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlayerScreen(career: career)),
      );

      if (!mounted) return;

      await _checkSavedCareer();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.loadCareerError('$e'))));
    }
  }

  Future<void> _openShop() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FCPointsShopScreen()),
    );
    if (mounted) await _checkSavedCareer();
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
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
              Color.fromARGB(255, 34, 138, 68),
              Color.fromARGB(216, 27, 93, 37),
              Color.fromARGB(56, 33, 62, 38),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 640;
              final logoSize = compact ? 100.0 : 120.0;
              return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD9B65C).withValues(alpha: 0.55)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: Color(0xFFD9B65C), size: 20),
                          const SizedBox(width: 7),
                          Text(
                            '$_fcPointsBalance FCP',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountScreen(),
                              ),
                            );
                            if (mounted) await _checkSavedCareer();
                          },
                          icon: const Icon(
                            Icons.account_circle_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          tooltip: AppStrings.isEnglish ? 'Account' : 'Аккаунт',
                        ),
                        IconButton(
                          onPressed: _openShop,
                          icon: const Icon(
                            Icons.storefront_outlined,
                            color: Color(0xFFD9B65C),
                            size: 29,
                          ),
                          tooltip: AppStrings.isEnglish ? 'FC Points Shop' : 'Магазин FC Points',
                        ),
                        IconButton(
                          onPressed: _openSettings,
                          icon: SvgPicture.asset(
                            'assets/icons/settings.svg',
                            width: 38,
                            height: 38,
                            fit: BoxFit.contain,
                          ),
                          tooltip: AppStrings.settingsTooltip,
                        ),
                      ],
                    ),
                  ],
                ),

                if (CareerStorage.isCloudAccount)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CareerStorage.lastSyncSucceeded
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_off_outlined,
                          size: 14,
                          color: CareerStorage.lastSyncSucceeded
                              ? const Color(0xFF8BE07F)
                              : const Color(0xFFFFC078),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            CareerStorage.lastSyncSucceeded
                                ? (AppStrings.isEnglish
                                    ? 'Cloud sync enabled'
                                    : 'Облачная синхронизация включена')
                                : (AppStrings.isEnglish
                                    ? 'Saved locally · cloud sync unavailable'
                                    : 'Сохранено локально · облако недоступно'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CareerStorage.lastSyncSucceeded
                                  ? const Color(0xFFBDEDB6)
                                  : const Color(0xFFFFD39A),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: green.withValues(alpha: 0.10),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        109,
                        109,
                        109,
                      ).withValues(alpha: 0.55),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/iconic.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: compact ? 16 : 28),

                Text(
                  'FOOTBALL',
                  style: TextStyle(
                    fontSize: compact ? 28 : 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: Color.fromARGB(255, 28, 255, 111),
                  ),
                ),

                Text(
                  'Journey',
                  style: TextStyle(
                    fontSize: compact ? 28 : 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 7,
                    color: green,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  AppStrings.startCareer,
                  style: TextStyle(
                    color: const Color.fromARGB(
                      255,
                      251,
                      251,
                      251,
                    ).withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _createNewCareer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppStrings.newCareer,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading || !_hasSavedCareer
                        ? null
                        : _continueCareer,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white.withValues(
                        alpha: 0.30,
                      ),
                      side: BorderSide(
                        color: _hasSavedCareer
                            ? green.withValues(alpha: 0.65)
                            : Colors.white.withValues(alpha: 0.18),
                      ),
                      backgroundColor: const Color.fromARGB(136, 68, 122, 77),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 7),
                          )
                        : Text(
                            AppStrings.continueCareer,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SuperLeagueScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.emoji_events_outlined),
                    label: Text(
                      AppStrings.superLeague,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: green.withValues(alpha: 0.8)),
                      backgroundColor: const Color(0xFF10351B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: compact ? 20 : 60),

                Text(
                  'Football Journey • 1.0',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 12,
                  ),
                ),

                SizedBox(height: compact ? 8 : 12),
              ],
            ),
              );
            },
          ),
        ),
      ),
    );
  }
}
