import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_football/models/custom_club.dart';

/// Эмблема клуба, созданного игроком: форма, цвета и символ рисуются
/// прямо в приложении, без картинок.
class CustomClubBadge extends StatelessWidget {
  final ClubBadgeShape shape;
  final ClubBadgeSymbol symbol;
  final Color primary;
  final Color secondary;
  final String label;
  final double size;

  const CustomClubBadge({
    super.key,
    required this.shape,
    required this.symbol,
    required this.primary,
    required this.secondary,
    required this.label,
    this.size = 40,
  });

  factory CustomClubBadge.fromClub(CustomClub club, {double size = 40}) {
    return CustomClubBadge(
      shape: club.badgeShape,
      symbol: club.badgeSymbol,
      primary: Color(club.primaryColor),
      secondary: Color(club.secondaryColor),
      label: club.shortName,
      size: size,
    );
  }

  /// Значок символа для выбора в редакторе.
  static IconData iconFor(ClubBadgeSymbol symbol) {
    switch (symbol) {
      case ClubBadgeSymbol.initials:
        return Icons.abc_rounded;
      case ClubBadgeSymbol.star:
        return Icons.star_rounded;
      case ClubBadgeSymbol.ball:
        return Icons.sports_soccer;
      case ClubBadgeSymbol.trophy:
        return Icons.emoji_events_rounded;
      case ClubBadgeSymbol.bolt:
        return Icons.bolt_rounded;
      case ClubBadgeSymbol.fire:
        return Icons.local_fire_department_rounded;
      case ClubBadgeSymbol.anchor:
        return Icons.anchor_rounded;
      case ClubBadgeSymbol.crown:
        return Icons.workspace_premium_rounded;
    }
  }

  /// Контур эмблемы в квадрате [size].
  static Path pathFor(ClubBadgeShape shape, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    Offset point(double x, double y) => Offset(w * x, h * y);

    void polygon(List<Offset> points) {
      path.moveTo(points.first.dx, points.first.dy);
      for (final item in points.skip(1)) {
        path.lineTo(item.dx, item.dy);
      }
      path.close();
    }

    switch (shape) {
      case ClubBadgeShape.shield:
        path.moveTo(w * 0.12, h * 0.08);
        path.lineTo(w * 0.88, h * 0.08);
        path.lineTo(w * 0.88, h * 0.55);
        path.quadraticBezierTo(w * 0.88, h * 0.82, w * 0.5, h * 0.96);
        path.quadraticBezierTo(w * 0.12, h * 0.82, w * 0.12, h * 0.55);
        path.close();
        break;
      case ClubBadgeShape.round:
        path.addOval(Rect.fromLTWH(w * 0.06, h * 0.06, w * 0.88, h * 0.88));
        break;
      case ClubBadgeShape.hexagon:
        polygon([
          for (var i = 0; i < 6; i++)
            Offset(
              w * (0.5 + 0.46 * cos(pi / 180 * (-90 + 60 * i))),
              h * (0.5 + 0.46 * sin(pi / 180 * (-90 + 60 * i))),
            ),
        ]);
        break;
      case ClubBadgeShape.diamond:
        polygon([
          point(0.5, 0.04),
          point(0.96, 0.5),
          point(0.5, 0.96),
          point(0.04, 0.5),
        ]);
        break;
      case ClubBadgeShape.pennant:
        polygon([
          point(0.1, 0.1),
          point(0.9, 0.1),
          point(0.9, 0.62),
          point(0.5, 0.95),
          point(0.1, 0.62),
        ]);
        break;
      case ClubBadgeShape.banner:
        polygon([
          point(0.14, 0.06),
          point(0.86, 0.06),
          point(0.86, 0.94),
          point(0.5, 0.78),
          point(0.14, 0.94),
        ]);
        break;
    }
    return path;
  }

  Color _contrastOn(Color color) =>
      color.computeLuminance() > 0.5 ? const Color(0xFF111111) : Colors.white;

  @override
  Widget build(BuildContext context) {
    // Символ берёт второй цвет клуба, но не сливается с основным.
    final lumDiff = (primary.computeLuminance() - secondary.computeLuminance())
        .abs();
    final symbolColor = lumDiff > 0.3 ? secondary : _contrastOn(primary);

    final Widget center;
    if (symbol == ClubBadgeSymbol.initials) {
      center = Padding(
        padding: EdgeInsets.symmetric(horizontal: size * 0.2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: symbolColor,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.30,
              letterSpacing: 0.4,
            ),
          ),
        ),
      );
    } else {
      center = Icon(iconFor(symbol), color: symbolColor, size: size * 0.44);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _BadgePainter(
              shape: shape,
              primary: primary,
              secondary: secondary,
            ),
          ),
          Align(alignment: const Alignment(0, -0.08), child: center),
        ],
      ),
    );
  }
}

class _BadgePainter extends CustomPainter {
  final ClubBadgeShape shape;
  final Color primary;
  final Color secondary;

  const _BadgePainter({
    required this.shape,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = CustomClubBadge.pathFor(shape, size);

    // Мягкая тень под эмблемой.
    canvas.drawShadow(path, Colors.black, size.width * 0.05, true);

    canvas.drawPath(path, Paint()..color = primary);

    // Горизонтальная полоса второго цвета.
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.12),
      Paint()..color = secondary.withValues(alpha: 0.55),
    );
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.05
        ..strokeJoin = StrokeJoin.round
        ..color = secondary,
    );
  }

  @override
  bool shouldRepaint(_BadgePainter old) =>
      old.shape != shape || old.primary != primary || old.secondary != secondary;
}
