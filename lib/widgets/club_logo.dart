import 'package:flutter/material.dart';

/// Отображение эмблемы клуба.
///
/// Пока локальные эмблемы не добавлены, показывается нейтральная заглушка.
/// Новые SVG можно постепенно добавлять в assets/clubs/ и карту _logoAssets.
class ClubLogo extends StatelessWidget {
  final String clubName;
  final double size;
  final Color fallbackColor;
  final double borderRadius;

  const ClubLogo({
    super.key,
    required this.clubName,
    this.size = 40,
    this.fallbackColor = const Color(0xFF14401E),
    this.borderRadius = 10,
  });

  /// Карта будет заполняться по мере добавления проверенных эмблем.
  static const Map<String, String> _logoAssets = {};

  static int get mappedClubCount => _logoAssets.length;

  static String? assetPathFor(String clubName) => _logoAssets[clubName];

  Widget _fallback() => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: fallbackColor.withValues(alpha: .22),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withValues(alpha: .12)),
    ),
    child: Icon(
      Icons.shield_outlined,
      color: Colors.white.withValues(alpha: .9),
      size: size * .58,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size, child: _fallback());
  }
}
