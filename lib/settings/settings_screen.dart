import 'package:flutter/material.dart';

import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/language_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color green = Color(0xFF22C55E);
  static const Color background = Color(0xFF001514);
  static const Color cardColor = Color(0xFF10271A);

  bool _soundEnabled = true;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          AppStrings.settings,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 44, 74, 54),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle(AppStrings.game),

          _buildSettingCard(
            icon: Icons.volume_up_outlined,
            title: AppStrings.sounds,
            subtitle: AppStrings.soundDescription,
            trailing: Switch(
              value: _soundEnabled,
              activeThumbColor: green,
              onChanged: (value) {
                setState(() => _soundEnabled = value);
              },
            ),
          ),

          const SizedBox(height: 12),

          _buildSettingCard(
            icon: Icons.notifications_outlined,
            title: AppStrings.notifications,
            subtitle: AppStrings.notificationsDescription,
            trailing: Switch(
              value: _notificationsEnabled,
              activeThumbColor: green,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
            ),
          ),

          const SizedBox(height: 28),

          _buildSectionTitle(AppStrings.languageSection),

          _buildSettingCard(
            icon: Icons.language,
            title: AppStrings.language,
            subtitle: LanguageService.isEnglish ? AppStrings.englishLanguage : AppStrings.russianLanguage,
            trailing: const Icon(Icons.chevron_right, color: green),
            onTap: _showLanguageSelector,
          ),

          const SizedBox(height: 28),

          _buildSectionTitle(AppStrings.about),

          _buildSettingCard(
            icon: Icons.sports_soccer,
            title: 'Football Journey',
            subtitle: AppStrings.version,
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(top: 1, left: 10),
            child: Text(
              AppStrings.appAuthor,
              style: TextStyle(
                color: green.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.language,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                ListTile(
                  leading: const Text('🇷🇺', style: TextStyle(fontSize: 24)),
                  title: Text(
                    AppStrings.russianLanguage,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: LanguageService.locale.value.languageCode == 'ru'
                      ? const Icon(Icons.check, color: green)
                      : null,
                  onTap: () async {
                    await LanguageService.setLanguage('ru');

                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }

                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),

                ListTile(
                  leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                  title: Text(
                    AppStrings.englishLanguage,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: LanguageService.locale.value.languageCode == 'en'
                      ? const Icon(Icons.check, color: green)
                      : null,
                  onTap: () async {
                    await LanguageService.setLanguage('en');

                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }

                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: green.withValues(alpha: 0.9),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: green.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(icon, color: green, size: 26),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 12,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
