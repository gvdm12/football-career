import 'package:flutter/material.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/career_storage.dart';

enum SaveSlotMode {
  /// Выбор слота для новой карьеры (занятый слот можно перезаписать).
  newCareer,

  /// Выбор карьеры для продолжения (пустые слоты недоступны).
  continueCareer,
}

/// Нижняя панель выбора слота сохранения.
/// Возвращает номер выбранного слота или null, если панель закрыли.
class SaveSlotSheet extends StatefulWidget {
  final SaveSlotMode mode;

  const SaveSlotSheet({super.key, required this.mode});

  static Future<int?> show(
    BuildContext context, {
    required SaveSlotMode mode,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: const Color(0xFF0B2414),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SaveSlotSheet(mode: mode),
    );
  }

  @override
  State<SaveSlotSheet> createState() => _SaveSlotSheetState();
}

class _SaveSlotSheetState extends State<SaveSlotSheet> {
  static const Color _green = Color(0xFF22C55E);

  late Future<List<CareerSlotSummary>> _future;

  bool get _en => AppStrings.isEnglish;

  @override
  void initState() {
    super.initState();
    _future = CareerStorage.slotSummaries();
  }

  void _reload() {
    setState(() {
      _future = CareerStorage.slotSummaries();
    });
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_en ? 'Cancel' : 'Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _select(CareerSlotSummary summary) async {
    if (widget.mode == SaveSlotMode.continueCareer) {
      if (summary.isEmpty) return;
      Navigator.pop(context, summary.slot);
      return;
    }

    if (!summary.isEmpty) {
      final ok = await _confirm(
        title: _en ? 'Overwrite save?' : 'Перезаписать сохранение?',
        message: _en
            ? 'The career in slot ${summary.slot} will be replaced by the new one.'
            : 'Карьера в слоте ${summary.slot} будет заменена новой.',
        action: _en ? 'Overwrite' : 'Перезаписать',
      );
      if (!ok || !mounted) return;
    }

    Navigator.pop(context, summary.slot);
  }

  Future<void> _delete(CareerSlotSummary summary) async {
    final ok = await _confirm(
      title: _en ? 'Delete save?' : 'Удалить сохранение?',
      message: _en
          ? 'The career in slot ${summary.slot} will be deleted for good.'
          : 'Карьера в слоте ${summary.slot} будет удалена безвозвратно.',
      action: _en ? 'Delete' : 'Удалить',
    );
    if (!ok || !mounted) return;

    await CareerStorage.deleteSlot(summary.slot);
    if (!mounted) return;
    _reload();
  }

  String _subtitle(CareerSlotSummary summary) {
    if (summary.isEmpty) return _en ? 'Empty slot' : 'Пустой слот';
    if (summary.isCorrupted) {
      return _en ? 'Save is damaged' : 'Сохранение повреждено';
    }

    final parts = <String>[
      if (summary.club != null) summary.club!,
      if (summary.season != null)
        _en ? 'Season ${summary.season}' : 'Сезон ${summary.season}',
      if (summary.overall != null) 'OVR ${summary.overall}',
    ];
    if (summary.isFinished) {
      parts.add(_en ? 'career finished' : 'карьера завершена');
    }
    return parts.join('  ·  ');
  }

  Widget _buildSlot(CareerSlotSummary summary) {
    final isNew = widget.mode == SaveSlotMode.newCareer;
    final enabled = isNew || !summary.isEmpty;

    final title = summary.hasCareer
        ? (summary.playerName ?? (_en ? 'Player' : 'Игрок'))
        : (_en ? 'Slot ${summary.slot}' : 'Слот ${summary.slot}');

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: summary.isEmpty && isNew
                ? _green.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.14),
          ),
        ),
        child: ListTile(
          onTap: enabled ? () => _select(summary) : null,
          contentPadding: const EdgeInsets.fromLTRB(16, 4, 6, 4),
          leading: CircleAvatar(
            backgroundColor: _green.withValues(alpha: 0.2),
            foregroundColor: _green,
            child: Text('${summary.slot}'),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            _subtitle(summary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          trailing: summary.isEmpty
              ? null
              : IconButton(
                  tooltip: _en ? 'Delete' : 'Удалить',
                  icon: const Icon(Icons.delete_outline, color: Colors.white54),
                  onPressed: () => _delete(summary),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mode == SaveSlotMode.newCareer
        ? (_en ? 'Choose a save slot' : 'Выберите слот')
        : (_en ? 'Choose a career' : 'Выберите карьеру');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            FutureBuilder<List<CareerSlotSummary>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: CircularProgressIndicator(color: _green),
                    ),
                  );
                }

                final slots = snapshot.data ?? const <CareerSlotSummary>[];
                return Column(children: slots.map(_buildSlot).toList());
              },
            ),
          ],
        ),
      ),
    );
  }
}
