import 'package:flutter/material.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_colors.dart';
import 'package:flutter_football/models/club_logos.dart';
import 'package:flutter_football/widgets/custom_club_badge.dart';

/// Отображает локальную эмблему клуба (PNG из assets/club_logos).
///
/// Если эмблемы нет или файл не удалось прочитать, показывается цветная
/// заглушка. Сетевые запросы не выполняются.
///
/// Эмблемы хранятся готовыми PNG, а не SVG: SVG разбирался во время работы
/// приложения, а сложные файлы (с вложенными картинками, масками, CSS) могли
/// вызвать вылет, чёрные пятна и искажения.
class ClubLogo extends StatelessWidget {
  final String clubName;
  final double size;
  final Color? fallbackColor;
  final double borderRadius;
  final bool useFallback;

  const ClubLogo({
    super.key,
    required this.clubName,
    this.size = 40,
    this.fallbackColor,
    this.borderRadius = 10,
    this.useFallback = false,
  });

  static int get mappedClubCount => ClubLogos.count;

  static String? assetPathFor(String clubName) => ClubLogos.assetFor(clubName);

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
    // Клуб, созданный игроком, рисуется своей эмблемой.
    final custom = Clubs.customClub;
    if (custom != null && custom.name == clubName) {
      return SizedBox(
        width: size,
        height: size,
        child: CustomClubBadge.fromClub(custom, size: size),
      );
    }

    final assetPath = assetPathFor(clubName);

    if (useFallback || assetPath == null) {
      return SizedBox(width: size, height: size, child: _fallback());
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        semanticLabel: '$clubName crest',
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Не удалось загрузить эмблему $clubName ($assetPath): $error');
          return _fallback();
        },
      ),
    );
  }
}
