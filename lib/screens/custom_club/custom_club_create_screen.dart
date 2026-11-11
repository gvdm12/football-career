import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/custom_club.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/custom_club_service.dart';
import 'package:flutter_football/widgets/club_logo.dart';
import 'package:flutter_football/widgets/custom_club_badge.dart';

/// Создание собственного клуба перед началом карьеры.
///
/// Возвращает [CustomClub] через Navigator.pop или null, если экран закрыли.
class CustomClubCreateScreen extends StatefulWidget {
  final CustomClub? initial;

  const CustomClubCreateScreen({super.key, this.initial});

  @override
  State<CustomClubCreateScreen> createState() => _CustomClubCreateScreenState();
}

class _CustomClubCreateScreenState extends State<CustomClubCreateScreen> {
  static const Color _background = Color(0xFF061B0C);
  static const Color _green = Color(0xFF22C55E);

  static const List<int> _palette = [
    0xFFD32F2F,
    0xFFE65100,
    0xFFF9A825,
    0xFF2E7D32,
    0xFF00897B,
    0xFF1565C0,
    0xFF283593,
    0xFF6A1B9A,
    0xFFAD1457,
    0xFF212121,
    0xFF607D8B,
    0xFFFFFFFF,
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _shortController;

  ClubBadgeShape _shape = ClubBadgeShape.shield;
  ClubBadgeSymbol _symbol = ClubBadgeSymbol.initials;
  int _primary = 0xFF1565C0;
  int _secondary = 0xFFFFFFFF;
  League? _league;
  int _division = 1;
  String? _replaced;
  bool _shortEdited = false;

  bool get _en => AppStrings.isEnglish;

  @override
  void initState() {
    super.initState();

    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _shortController = TextEditingController(text: initial?.shortName ?? '');

    if (initial != null) {
      _shape = initial.badgeShape;
      _symbol = initial.badgeSymbol;
      _primary = initial.primaryColor;
      _secondary = initial.secondaryColor;
      _league = initial.league;
      _division = initial.division;
      _replaced = initial.replacedClub;
      _shortEdited = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortController.dispose();
    super.dispose();
  }

  String get _cleanName => CustomClubService.cleanName(_nameController.text);

  String get _shortLabel {
    final text = CustomClubService.cleanName(_shortController.text);
    return text.isEmpty
        ? CustomClubService.defaultShortName(_cleanName)
        : text.toUpperCase();
  }

  ClubNameIssue? get _nameIssue {
    if (_nameController.text.trim().isEmpty) return null;
    return CustomClubService.validateName(
      _nameController.text,
      takenNames: Clubs.builtInNames,
    );
  }

  String _issueText(ClubNameIssue issue) {
    switch (issue) {
      case ClubNameIssue.tooShort:
        return _en
            ? 'At least ${CustomClubService.minNameLength} characters'
            : 'Минимум ${CustomClubService.minNameLength} символа';
      case ClubNameIssue.tooLong:
        return _en
            ? 'At most ${CustomClubService.maxNameLength} characters'
            : 'Максимум ${CustomClubService.maxNameLength} символа';
      case ClubNameIssue.badCharacters:
        return _en
            ? 'Use letters, digits, spaces, dots and hyphens'
            : 'Только буквы, цифры, пробел, точка и дефис';
      case ClubNameIssue.taken:
        return _en
            ? 'A club with this name already exists'
            : 'Клуб с таким названием уже есть в игре';
    }
  }

  List<int> get _availableDivisions {
    final league = _league;
    if (league == null) return const [];
    return [
      for (var division = 1; division <= 3; division++)
        if (Clubs.builtInByLeagueDivision(league, division).isNotEmpty)
          division,
    ];
  }

  void _selectLeague(League league) {
    setState(() {
      _league = league;
      final divisions = _availableDivisions;
      _division = divisions.isEmpty ? 1 : divisions.first;
      _replaced = null;
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit() async {
    final issue = CustomClubService.validateName(
      _nameController.text,
      takenNames: Clubs.builtInNames,
    );
    if (issue != null) {
      _showMessage(_issueText(issue));
      return;
    }

    final league = _league;
    final replaced = _replaced;
    if (league == null || replaced == null) {
      _showMessage(
        _en
            ? 'Choose a league and the club you will replace'
            : 'Выбери лигу и клуб, который ты заменишь',
      );
      return;
    }

    final initial = widget.initial;
    final CustomClub result;

    if (initial == null) {
      result = CustomClubService.create(
        name: _cleanName,
        shortName: _shortLabel,
        badgeShape: _shape,
        badgeSymbol: _symbol,
        primaryColor: _primary,
        secondaryColor: _secondary,
        league: league,
        division: _division,
        replacedClub: replaced,
        random: Random(),
      );
    } else {
      // При правке сила не перебрасывается, иначе её можно было бы
      // подбирать, пока не выпадет максимум.
      result = CustomClub(
        name: _cleanName,
        shortName: _shortLabel,
        badgeShape: _shape,
        badgeSymbol: _symbol,
        primaryColor: _primary,
        secondaryColor: _secondary,
        league: league,
        division: _division,
        replacedClub: replaced,
        baseStrength: initial.baseStrength,
        stadiumName: '$_cleanName Arena',
        funds: CustomClubService.startingFunds,
        fans: CustomClubService.startingFans,
      );
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0B2414),
        title: Text(
          _en ? 'Club created' : 'Клуб создан',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomClubBadge.fromClub(result, size: 84),
            const SizedBox(height: 12),
            Text(
              result.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _en
                  ? 'Takes the place of $replaced'
                  : 'Займёт место клуба $replaced',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              _en
                  ? 'Club strength: ${result.baseStrength}'
                  : 'Сила клуба: ${result.baseStrength}',
              style: const TextStyle(
                color: _green,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              _en ? 'Continue' : 'Продолжить',
              style: const TextStyle(color: _green),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, result);
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _tile({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected
              ? _green.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _green : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _colorPicker(int selected, ValueChanged<int> onPick) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final value in _palette)
          GestureDetector(
            onTap: () => onPick(value),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Color(value),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected == value ? _green : Colors.white30,
                  width: selected == value ? 3 : 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: _green,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      labelStyle: TextStyle(
        color: selected ? Colors.black : Colors.white,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: selected ? _green : Colors.white24),
    );
  }

  InputDecoration _inputDecoration(String label, {String? error}) {
    return InputDecoration(
      labelText: label,
      errorText: error,
      labelStyle: const TextStyle(color: Colors.white70),
      counterStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.07),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _green),
      ),
    );
  }

  Widget _clubTile(Club club) {
    final selected = _replaced == club.name;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected
            ? _green.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? _green : Colors.white12,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        dense: true,
        onTap: () => setState(() => _replaced = club.name),
        leading: ClubLogo(clubName: club.name, size: 32),
        title: Text(
          club.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: _green)
            : Text(
                '${club.strength}',
                style: const TextStyle(color: Colors.white54),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final league = _league;
    final divisions = _availableDivisions;
    final candidates = league == null
        ? const <Club>[]
        : Clubs.builtInByLeagueDivision(league, _division);
    final issue = _nameIssue;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2414),
        foregroundColor: Colors.white,
        title: Text(
          _en ? 'Create your club' : 'Создание клуба',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            const SizedBox(height: 8),
            Center(
              child: CustomClubBadge(
                shape: _shape,
                symbol: _symbol,
                primary: Color(_primary),
                secondary: Color(_secondary),
                label: _shortLabel,
                size: 120,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              maxLength: CustomClubService.maxNameLength,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                _en ? 'Club name' : 'Название клуба',
                error: issue == null ? null : _issueText(issue),
              ),
              onChanged: (_) => setState(() {
                if (!_shortEdited) {
                  _shortController.text = CustomClubService.defaultShortName(
                    _cleanName,
                  );
                }
              }),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _shortController,
              maxLength: 4,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.characters,
              decoration: _inputDecoration(
                _en ? 'Short name (for tables)' : 'Сокращение (для таблиц)',
              ),
              onChanged: (_) => setState(() => _shortEdited = true),
            ),
            _section(_en ? 'Badge shape' : 'Форма эмблемы'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final shape in ClubBadgeShape.values)
                  _tile(
                    selected: _shape == shape,
                    onTap: () => setState(() => _shape = shape),
                    child: CustomClubBadge(
                      shape: shape,
                      symbol: _symbol,
                      primary: Color(_primary),
                      secondary: Color(_secondary),
                      label: _shortLabel,
                      size: 48,
                    ),
                  ),
              ],
            ),
            _section(_en ? 'Symbol' : 'Символ'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final symbol in ClubBadgeSymbol.values)
                  _tile(
                    selected: _symbol == symbol,
                    onTap: () => setState(() => _symbol = symbol),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        CustomClubBadge.iconFor(symbol),
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
              ],
            ),
            _section(_en ? 'Main colour' : 'Основной цвет'),
            _colorPicker(_primary, (value) => setState(() => _primary = value)),
            _section(_en ? 'Second colour' : 'Второй цвет'),
            _colorPicker(
              _secondary,
              (value) => setState(() => _secondary = value),
            ),
            _section(_en ? 'League' : 'Лига'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in League.values)
                  _chip(item.displayName, _league == item, () {
                    _selectLeague(item);
                  }),
              ],
            ),
            if (league != null && divisions.length > 1) ...[
              _section(_en ? 'Division' : 'Дивизион'),
              Wrap(
                spacing: 8,
                children: [
                  for (final division in divisions)
                    _chip(
                      _en ? 'Division $division' : 'Дивизион $division',
                      _division == division,
                      () => setState(() {
                        _division = division;
                        _replaced = null;
                      }),
                    ),
                ],
              ),
            ],
            if (league != null) ...[
              _section(
                _en
                    ? 'Club to replace in the league'
                    : 'Какой клуб лиги заменить',
              ),
              ...candidates.map(_clubTile),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _en
                    ? 'Club strength is random: from ${CustomClubService.minStrength} to ${CustomClubService.maxStrength}. '
                          'The squad is formed from generated players of the league. '
                          'You can improve the club during the career.'
                    : 'Сила клуба определится случайно: от ${CustomClubService.minStrength} до ${CustomClubService.maxStrength}. '
                          'Состав создаётся из сгенерированных игроков лиги. '
                          'Клуб можно развивать по ходу карьеры.',
                style: const TextStyle(color: Colors.white70, height: 1.35),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  widget.initial == null
                      ? (_en ? 'Create club' : 'Создать клуб')
                      : (_en ? 'Save club' : 'Сохранить клуб'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
