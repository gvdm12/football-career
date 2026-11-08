import 'package:flutter/material.dart';
import 'package:flutter_football/models/club_colors.dart';

/// Компактное отображение клуба.
///
/// Пока локальные SVG-эмблемы не используются, показываем фирменный
/// градиент клуба и его первую букву вместо нейтрального щита.
class ClubLogo extends StatelessWidget {
  final String clubName;
  final double size;
  final Color? fallbackColor;
  final double borderRadius;

  const ClubLogo({
    super.key,
    required this.clubName,
    this.size = 40,
    this.fallbackColor,
    this.borderRadius = 10,
  });

  /// Локальные эмблемы можно будет подключать постепенно.
  static const Map<String, String> _logoAssets = {};

  static int get mappedClubCount => _logoAssets.length;

  static String? assetPathFor(String clubName) => _logoAssets[clubName];

  Widget _fallback() {
    final primary = fallbackColor ?? ClubColors.primary(clubName);
    final secondary = ClubColors.secondary(clubName);
    final middle = Color.lerp(primary, secondary, .32)!;
    final shade = Color.lerp(primary, Colors.black, .28)!;
    final letterColor = primary.computeLuminance() > .62
        ? const Color(0xFF101810)
        : Colors.white;
    final firstLetter = clubName.trim().isEmpty
        ? '?'
        : clubName.trim()[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, middle, shade],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: .28),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .28),
            blurRadius: size * .22,
            offset: Offset(0, size * .07),
          ),
        ],
      ),
      child: Text(
        firstLetter,
        style: TextStyle(
          color: letterColor,
          fontSize: size * .52,
          fontWeight: FontWeight.w900,
          height: 1,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: .22),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size, child: _fallback());
  }
}
