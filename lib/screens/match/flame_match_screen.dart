import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class FlameMatchScreen extends StatefulWidget {
  final String playerName;
  final String clubName;
  final String opponentName;

  const FlameMatchScreen({
    super.key,
    required this.playerName,
    required this.clubName,
    required this.opponentName,
  });

  @override
  State<FlameMatchScreen> createState() => _FlameMatchScreenState();
}

class _FlameMatchScreenState extends State<FlameMatchScreen> {
  late final PrototypeFootballGame game;

  @override
  void initState() {
    super.initState();
    game = PrototypeFootballGame(
      playerName: widget.playerName,
      clubName: widget.clubName,
      opponentName: widget.opponentName,
    );
  }

  @override
  void dispose() {
    game.pauseEngine();
    game.scoreText.dispose();
    super.dispose();
  }

  Widget _controlButton({
    required IconData icon,
    required double x,
    required double y,
  }) {
    return GestureDetector(
      onTapDown: (_) => game.setMovement(x, y),
      onTapUp: (_) => game.stopMovement(),
      onTapCancel: game.stopMovement,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xCC0B3A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF8BE07F), width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04160A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B3A1A),
        foregroundColor: Colors.white,
        title: const Text('Тестовый матч · Flame'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ValueListenableBuilder<String>(
                valueListenable: game.scoreText,
                builder: (context, score, _) => Text(
                  score,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GameWidget(game: game),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Удерживай стрелки, чтобы двигаться по полю',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _controlButton(
                          icon: Icons.keyboard_arrow_up,
                          x: 0,
                          y: -1,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _controlButton(
                              icon: Icons.keyboard_arrow_left,
                              x: -1,
                              y: 0,
                            ),
                            const SizedBox(width: 6),
                            _controlButton(
                              icon: Icons.keyboard_arrow_down,
                              x: 0,
                              y: 1,
                            ),
                            const SizedBox(width: 6),
                            _controlButton(
                              icon: Icons.keyboard_arrow_right,
                              x: 1,
                              y: 0,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _actionButton(
                          label: 'УДАР',
                          color: const Color(0xFF22C55E),
                          onPressed: game.shoot,
                        ),
                        const SizedBox(height: 10),
                        _actionButton(
                          label: 'ПАС',
                          color: const Color(0xFF4779C7),
                          onPressed: game.pass,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF8BE07F)),
                  ),
                  child: const Text('Завершить тест'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 92,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class PrototypeFootballGame extends FlameGame {
  PrototypeFootballGame({
    required this.playerName,
    required this.clubName,
    required this.opponentName,
  });

  final String playerName;
  final String clubName;
  final String opponentName;

  final ValueNotifier<String> scoreText = ValueNotifier('0 : 0');
  double playerX = 0.22;
  double playerY = 0.50;
  double opponentX = 0.72;
  double opponentY = 0.50;
  double ballX = 0.26;
  double ballY = 0.50;
  double ballVelocityX = 0;
  double ballVelocityY = 0;
  double moveX = 0;
  double moveY = 0;
  int homeGoals = 0;
  int awayGoals = 0;
  double messageTimer = 0;
  String message = 'Веди мяч к воротам соперника!';

  void setMovement(double x, double y) {
    moveX = x;
    moveY = y;
  }

  void stopMovement() {
    moveX = 0;
    moveY = 0;
  }

  void shoot() {
    final distance = math.sqrt(
      math.pow(ballX - playerX, 2) + math.pow(ballY - playerY, 2),
    );
    if (distance > 0.12) {
      message = 'Подойди ближе к мячу';
      messageTimer = 1.4;
      return;
    }
    ballVelocityX = 1.05;
    ballVelocityY = (0.5 - ballY) * 0.65;
    message = 'Удар по воротам!';
    messageTimer = 1.2;
  }

  void pass() {
    final distance = math.sqrt(
      math.pow(ballX - playerX, 2) + math.pow(ballY - playerY, 2),
    );
    if (distance > 0.12) {
      message = 'Сначала доберись до мяча';
      messageTimer = 1.4;
      return;
    }
    ballVelocityX = 0.65;
    ballVelocityY = (opponentY - ballY) * 0.25;
    message = 'Передача!';
    messageTimer = 1.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    playerX = (playerX + moveX * 0.42 * dt).clamp(0.06, 0.94).toDouble();
    playerY = (playerY + moveY * 0.42 * dt).clamp(0.08, 0.92).toDouble();

    final dx = ballX - opponentX;
    final dy = ballY - opponentY;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance > 0.025) {
      opponentX += dx / distance * 0.18 * dt;
      opponentY += dy / distance * 0.18 * dt;
    }

    ballX += ballVelocityX * dt;
    ballY += ballVelocityY * dt;
    ballVelocityX *= math.pow(0.985, dt * 60).toDouble();
    ballVelocityY *= math.pow(0.985, dt * 60).toDouble();

    if (ballX < 0.04 || ballX > 0.96) {
      if (ballX > 0.96 && ballY > 0.39 && ballY < 0.61) {
        homeGoals++;
        message = 'ГОЛ! Отличный удар!';
      } else if (ballX < 0.04 && ballY > 0.39 && ballY < 0.61) {
        awayGoals++;
        message = 'Соперник забил';
      } else {
        message = 'Мяч ушёл за линию';
      }
      scoreText.value = '$homeGoals : $awayGoals';
      messageTimer = 2;
      _resetBall();
    }

    if (ballY < 0.04 || ballY > 0.96) {
      ballY = ballY.clamp(0.04, 0.96).toDouble();
      ballVelocityY = -ballVelocityY * 0.55;
    }

    final playerDistance = math.sqrt(
      math.pow(ballX - playerX, 2) + math.pow(ballY - playerY, 2),
    );
    if (playerDistance < 0.055 && ballVelocityX.abs() < 0.35) {
      ballX = playerX + 0.035;
      ballY = playerY;
    }

    if (messageTimer > 0) {
      messageTimer -= dt;
    }
  }

  void _resetBall() {
    playerX = 0.22;
    playerY = 0.50;
    opponentX = 0.72;
    opponentY = 0.50;
    ballX = 0.26;
    ballY = 0.50;
    ballVelocityX = 0;
    ballVelocityY = 0;
    stopMovement();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;
    if (w <= 0 || h <= 0) return;

    final field = Paint()..color = const Color(0xFF167A3A);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), field);

    final stripe = Paint()..color = const Color(0xFF1B8542);
    for (var i = 0; i < 8; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(i * w / 8, 0, w / 8, h),
          stripe,
        );
      }
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(5, 5, w - 10, h - 10),
      line,
    );
    canvas.drawLine(Offset(w / 2, 5), Offset(w / 2, h - 5), line);
    canvas.drawCircle(Offset(w / 2, h / 2), h * 0.13, line);
    canvas.drawRect(Rect.fromLTWH(5, h * 0.28, w * 0.14, h * 0.44), line);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.86, h * 0.28, w * 0.14 - 5, h * 0.44),
      line,
    );

    final goalPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawLine(Offset(3, h * 0.40), Offset(3, h * 0.60), goalPaint);
    canvas.drawLine(
      Offset(w - 3, h * 0.40),
      Offset(w - 3, h * 0.60),
      goalPaint,
    );

    _drawPlayer(canvas, w * playerX, h * playerY, const Color(0xFF27C7FF));
    _drawPlayer(canvas, w * opponentX, h * opponentY, const Color(0xFFFF5757));
    canvas.drawCircle(
      Offset(w * ballX, h * ballY),
      h * 0.025,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * ballX, h * ballY),
      h * 0.025,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (messageTimer > 0) {
      final painter = TextPainter(
        text: TextSpan(
          text: message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 5)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: w - 20);
      painter.paint(canvas, Offset((w - painter.width) / 2, 10));
    }
  }

  void _drawPlayer(Canvas canvas, double x, double y, Color color) {
    canvas.drawCircle(
      Offset(x, y),
      size.y * 0.045,
      Paint()..color = color,
    );
    canvas.drawCircle(
      Offset(x, y),
      size.y * 0.045,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
}
