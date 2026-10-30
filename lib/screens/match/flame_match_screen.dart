import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_football/models/player.dart';

class FlameMatchScreen extends StatefulWidget {
  final String playerName;
  final String clubName;
  final String opponentName;
  final Player? player;

  const FlameMatchScreen({
    super.key,
    required this.playerName,
    required this.clubName,
    required this.opponentName,
    this.player,
  });

  @override
  State<FlameMatchScreen> createState() => _FlameMatchScreenState();
}

class _FlameMatchScreenState extends State<FlameMatchScreen> {
  late final BroadcastFootballGame game;

  @override
  void initState() {
    super.initState();
    game = BroadcastFootballGame(
      playerName: widget.playerName,
      clubName: widget.clubName,
      opponentName: widget.opponentName,
      player: widget.player,
    );
  }

  @override
  void dispose() {
    game.pauseEngine();
    game.scoreText.dispose();
    game.eventText.dispose();
    super.dispose();
  }

  Widget _moveButton(IconData icon, double x, double y) {
    return GestureDetector(
      onTapDown: (_) => game.setMovement(x, y),
      onTapUp: (_) => game.stopMovement(),
      onTapCancel: game.stopMovement,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xDD10291B),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: .55)),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Icon(icon, color: Colors.white, size: 25),
      ),
    );
  }

  Widget _action(String label, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: .8), width: 2),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 25),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06120B),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0C2D19), Color(0xFF071A10)]),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(widget.clubName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700))),
                  ValueListenableBuilder<String>(
                    valueListenable: game.scoreText,
                    builder: (_, score, __) => Text(score, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ),
                  Expanded(child: Text(widget.opponentName, textAlign: TextAlign.end, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700))),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: GameWidget(game: game)),
                  Positioned(
                    top: 10,
                    left: 12,
                    right: 12,
                    child: ValueListenableBuilder<String>(
                      valueListenable: game.eventText,
                      builder: (_, event, __) => Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: .55), borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            child: Text(event, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 18,
                    left: 18,
                    child: Column(
                      children: [
                        _moveButton(Icons.keyboard_arrow_up, 0, -1),
                        const SizedBox(height: 5),
                        Row(children: [
                          _moveButton(Icons.keyboard_arrow_left, -1, 0),
                          const SizedBox(width: 5),
                          _moveButton(Icons.keyboard_arrow_down, 0, 1),
                          const SizedBox(width: 5),
                          _moveButton(Icons.keyboard_arrow_right, 1, 0),
                        ]),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 28,
                    right: 22,
                    child: Column(
                      children: [
                        _action('УДАР', Icons.sports_soccer, game.shoot, const Color(0xFF168B49)),
                        const SizedBox(height: 12),
                        _action('ПАС', Icons.swap_horiz, game.pass, const Color(0xFF2765A8)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 52,
                    right: 12,
                    child: GestureDetector(
                      onLongPressStart: (_) => game.setSprint(true),
                      onLongPressEnd: (_) => game.setSprint(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xCC10291B), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white54)),
                        child: const Text('УСКОРЕНИЕ', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 10),
              child: Row(
                children: [
                  const Icon(Icons.sports_soccer, color: Color(0xFF8BE07F), size: 16),
                  const SizedBox(width: 6),
                  const Expanded(child: Text('Управляй своим футболистом • удерживай ускорение', style: TextStyle(color: Colors.white60, fontSize: 10))),
                  Text('OVR ${widget.player?.overall ?? 70}', style: const TextStyle(color: Color(0xFF8BE07F), fontWeight: FontWeight.w900)),
                  const SizedBox(width: 10),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footballer {
  _Footballer(this.x, this.y, this.home, {this.user = false, this.number = 0});
  double x;
  double y;
  final bool home;
  final bool user;
  final int number;
  double vx = 0;
  double vy = 0;
}

class BroadcastFootballGame extends FlameGame {
  BroadcastFootballGame({
    required this.playerName,
    required this.clubName,
    required this.opponentName,
    required this.player,
  });

  final String playerName;
  final String clubName;
  final String opponentName;
  final Player? player;

  final ValueNotifier<String> scoreText = ValueNotifier('0 : 0');
  final ValueNotifier<String> eventText = ValueNotifier('Матч начался • Найди свободное пространство');
  final List<_Footballer> _players = [];
  final math.Random _random = math.Random();

  double _playerX = .34;
  double _playerY = .52;
  double _ballX = .36;
  double _ballY = .52;
  double _ballVx = 0;
  double _ballVy = 0;
  double _moveX = 0;
  double _moveY = 0;
  double _eventTimer = 3;
  double _matchClock = 0;
  bool _sprinting = false;
  bool _ballOwned = true;
  int _homeGoals = 0;
  int _awayGoals = 0;
  int _lastMinute = 0;

  Color get _homeColor => const Color(0xFF20A85B);
  Color get _awayColor => const Color(0xFFE34D54);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 10 teammates + controlled player, 11 opponents.
    const homeFormation = [
      [.13, .50], [.27, .18], [.27, .38], [.27, .62], [.27, .82],
      [.43, .24], [.43, .50], [.43, .76], [.58, .28], [.58, .72],
    ];
    const awayFormation = [
      [.87, .50], [.73, .18], [.73, .38], [.73, .62], [.73, .82],
      [.57, .24], [.57, .50], [.57, .76], [.42, .28], [.42, .72], [.67, .50],
    ];
    for (var i = 0; i < homeFormation.length; i++) {
      _players.add(_Footballer(homeFormation[i][0], homeFormation[i][1], true, number: i + 2));
    }
    _players.add(_Footballer(_playerX, _playerY, true, user: true, number: 10));
    for (var i = 0; i < awayFormation.length; i++) {
      _players.add(_Footballer(awayFormation[i][0], awayFormation[i][1], false, number: i + 1));
    }
  }

  void setMovement(double x, double y) { _moveX = x; _moveY = y; }
  void stopMovement() { _moveX = 0; _moveY = 0; }
  void setSprint(bool value) { _sprinting = value; }

  double get _pace => (player?.skills.pace ?? 65) / 100;
  double get _dribbling => (player?.skills.dribbling ?? 65) / 100;
  double get _passing => (player?.skills.passing ?? 65) / 100;
  double get _shooting => (player?.skills.shooting ?? 65) / 100;

  void _notify(String text) {
    eventText.value = text;
    _eventTimer = 2.6;
  }

  void shoot() {
    if (!_nearBall()) { _notify('Подойди к мячу, чтобы пробить'); return; }
    final power = 1.0 + _shooting * .45;
    _ballOwned = false;
    _ballVx = power;
    _ballVy = (.5 - _ballY) * .42 + _moveY * .12;
    _notify('Удар по воротам!');
  }

  void pass() {
    if (!_nearBall()) { _notify('Сначала доберись до мяча'); return; }
    final teammate = _players.where((p) => p.home && !p.user)
      .reduce((a, b) => _distance(a.x, a.y, _ballX, _ballY) < _distance(b.x, b.y, _ballX, _ballY) ? a : b);
    final dx = teammate.x - _ballX;
    final dy = teammate.y - _ballY;
    final length = math.max(.001, math.sqrt(dx * dx + dy * dy));
    final accuracy = .82 + _passing * .16;
    _ballOwned = false;
    _ballVx = dx / length * .78 * accuracy;
    _ballVy = dy / length * .78 * accuracy;
    _notify('Передача партнёру');
  }

  double _distance(double ax, double ay, double bx, double by) {
    final dx = ax - bx, dy = ay - by;
    return math.sqrt(dx * dx + dy * dy);
  }

  bool _nearBall() => _distance(_playerX, _playerY, _ballX, _ballY) < .075;

  @override
  void update(double dt) {
    super.update(dt);
    final pace = (.32 + _pace * .22) * (_sprinting ? 1.42 : 1);
    final targetVx = _moveX * pace;
    final targetVy = _moveY * pace;
    final smoothing = math.min(1.0, dt * 8);
    final user = _players.firstWhere((p) => p.user);
    user.vx += (targetVx - user.vx) * smoothing;
    user.vy += (targetVy - user.vy) * smoothing;
    _playerX = (_playerX + user.vx * dt).clamp(.035, .965).toDouble();
    _playerY = (_playerY + user.vy * dt).clamp(.055, .945).toDouble();
    user.x = _playerX; user.y = _playerY;

    for (final p in _players.where((p) => !p.user)) {
      final targetX = p.home ? (_ballX < .55 ? p.x : math.max(.08, p.x - .08)) : (_ballX > .45 ? p.x : math.min(.92, p.x + .08));
      final targetY = p.y + (_ballY - p.y) * (p.home ? .12 : .2);
      final chase = (!p.home && _distance(p.x, p.y, _ballX, _ballY) < .22) ||
          (p.home && _distance(p.x, p.y, _ballX, _ballY) < .12);
      final tx = chase ? _ballX : targetX;
      final ty = chase ? _ballY : targetY;
      final dx = tx - p.x, dy = ty - p.y;
      final len = math.max(.001, math.sqrt(dx * dx + dy * dy));
      final speed = chase ? .24 : .07;
      p.x += (dx / len * math.min(len, speed * dt)).toDouble();
      p.y += (dy / len * math.min(len, speed * dt)).toDouble();
    }

    if (_nearBall() && _ballVx.abs() + _ballVy.abs() < .42) {
      _ballOwned = true;
    }
    if (_ballOwned && _nearBall()) {
      _ballX = _playerX + .035;
      _ballY = _playerY + .008;
      _ballVx = 0; _ballVy = 0;
    } else {
      _ballX += _ballVx * dt;
      _ballY += _ballVy * dt;
      final friction = math.pow(.18, dt).toDouble();
      _ballVx *= friction; _ballVy *= friction;
    }

    if (_ballX > .985 && _ballY > .39 && _ballY < .61) {
      _homeGoals++; scoreText.value = '$_homeGoals : $_awayGoals';
      _notify('ГОЛ! Отличная атака!');
      _resetAfterGoal();
    } else if (_ballX < .015 && _ballY > .39 && _ballY < .61) {
      _awayGoals++; scoreText.value = '$_homeGoals : $_awayGoals';
      _notify('Соперник забил');
      _resetAfterGoal();
    }
    if (_ballY < .045 || _ballY > .955) {
      _ballY = _ballY.clamp(.045, .955);
      _ballVy = -_ballVy * .55;
    }

    _matchClock += dt * 1.5;
    final minute = _matchClock.floor();
    if (minute > _lastMinute && minute % 5 == 0) {
      _lastMinute = minute;
      if (_random.nextDouble() < .3) _notify('$minute’ • Команды борются за контроль мяча');
    }
    if (_eventTimer > 0) _eventTimer -= dt;
  }

  void _resetAfterGoal() {
    _ballX = .5; _ballY = .5; _ballVx = 0; _ballVy = 0; _ballOwned = false;
    _playerX = .38; _playerY = .5;
    final user = _players.firstWhere((p) => p.user);
    user.x = _playerX; user.y = _playerY;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x, h = size.y;
    if (w <= 0 || h <= 0) return;
    canvas.save();
    // Broadcast framing: dark stadium apron around a vivid, perspective-lit pitch.
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(0xFF101C22), Color(0xFF263B31), Color(0xFF101C22)],
    ).createShader(Rect.fromLTWH(0, 0, w, h)));
    final field = Rect.fromLTWH(w * .025, h * .055, w * .95, h * .89);
    canvas.drawRRect(RRect.fromRectAndRadius(field, const Radius.circular(8)), Paint()..color = const Color(0xFF176B3A));
    for (var i = 0; i < 12; i++) {
      final band = Rect.fromLTWH(field.left + field.width * i / 12, field.top, field.width / 12, field.height);
      canvas.drawRect(band, Paint()..color = i.isEven ? const Color(0xFF1C7843) : const Color(0xFF176B3A));
    }
    final line = Paint()..color = Colors.white.withValues(alpha: .82)..style = PaintingStyle.stroke..strokeWidth = math.max(1.2, h * .003);
    canvas.drawRect(field, line);
    canvas.drawLine(Offset(w * .5, field.top), Offset(w * .5, field.bottom), line);
    canvas.drawCircle(Offset(w * .5, h * .5), h * .115, line);
    canvas.drawCircle(Offset(w * .5, h * .5), h * .004, Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(field.left, h * .28, w * .145, h * .44), line);
    canvas.drawRect(Rect.fromLTWH(w * .83, h * .28, w * .145, h * .44), line);
    canvas.drawRect(Rect.fromLTWH(field.left, h * .39, w * .055, h * .22), line);
    canvas.drawRect(Rect.fromLTWH(w * .92, h * .39, w * .055, h * .22), line);
    canvas.drawArc(Rect.fromLTWH(w * .105, h * .39, w * .12, h * .22), -.9, 1.8, false, line);
    canvas.drawArc(Rect.fromLTWH(w * .775, h * .39, w * .12, h * .22), 2.24, 1.8, false, line);

    // Goals and subtle netting.
    final goalPaint = Paint()..color = const Color(0xFFE8F0EB)..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRect(Rect.fromLTWH(w * .006, h * .425, w * .022, h * .15), goalPaint);
    canvas.drawRect(Rect.fromLTWH(w * .972, h * .425, w * .022, h * .15), goalPaint);

    final ordered = [..._players]..sort((a, b) => a.y.compareTo(b.y));
    for (final p in ordered) {
      _drawPlayer(canvas, w * p.x, h * p.y, p);
    }
    _drawBall(canvas, w * _ballX, h * _ballY);
    canvas.restore();
  }

  void _drawPlayer(Canvas canvas, double x, double y, _Footballer player) {
    final scale = .72 + player.y * .55;
    final radius = size.y * .022 * scale;
    final color = player.home ? _homeColor : _awayColor;
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y + radius * 1.45), width: radius * 2.5, height: radius * .85),
        Paint()..color = Colors.black.withValues(alpha: .34));
    // Legs with a tiny stride offset.
    final leg = Paint()..color = const Color(0xFF18212A)..strokeWidth = radius * .38..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x - radius * .25, y + radius * .55), Offset(x - radius * .38, y + radius * 1.25), leg);
    canvas.drawLine(Offset(x + radius * .25, y + radius * .55), Offset(x + radius * .38, y + radius * 1.25), leg);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: radius * 1.75, height: radius * 1.5), Radius.circular(radius * .42)),
        Paint()..shader = LinearGradient(colors: [color.withValues(alpha: .75), color, color.withValues(alpha: .7)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Rect.fromCenter(center: Offset(x, y), width: radius * 1.75, height: radius * 1.5)));
    canvas.drawCircle(Offset(x, y - radius * .82), radius * .43, Paint()..color = const Color(0xFFE2B995));
    canvas.drawCircle(Offset(x, y - radius * .82), radius * .43, Paint()..color = Colors.black.withValues(alpha: .18)..style = PaintingStyle.stroke..strokeWidth = .7);
    if (player.user) {
      canvas.drawCircle(Offset(x, y), radius * 1.55, Paint()..color = const Color(0xFFB7FFCA)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      final name = TextPainter(text: TextSpan(text: playerName, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black, blurRadius: 4)])), textDirection: TextDirection.ltr)..layout(maxWidth: 90);
      name.paint(canvas, Offset(x - name.width / 2, y - radius * 2.1 - name.height));
    }
    final number = TextPainter(text: TextSpan(text: '${player.number}', style: TextStyle(color: Colors.white, fontSize: math.max(5, radius * .48), fontWeight: FontWeight.w900)), textDirection: TextDirection.ltr)..layout();
    number.paint(canvas, Offset(x - number.width / 2, y - number.height / 2));
  }

  void _drawBall(Canvas canvas, double x, double y) {
    final r = size.y * .012;
    canvas.drawOval(Rect.fromCenter(center: Offset(x + r * .5, y + r * 1.8), width: r * 3.2, height: r * 1.1), Paint()..color = Colors.black.withValues(alpha: .38));
    canvas.drawCircle(Offset(x, y), r, Paint()..shader = const RadialGradient(colors: [Colors.white, Color(0xFFD5D9D6), Color(0xFF858B88)], center: Alignment(-.3, -.4)).createShader(Rect.fromCircle(center: Offset(x, y), radius: r)));
    canvas.drawCircle(Offset(x, y), r, Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = .7);
    canvas.drawCircle(Offset(x, y), r * .28, Paint()..color = const Color(0xFF20252A));
  }
}
