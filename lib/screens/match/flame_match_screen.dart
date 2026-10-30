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
                        const SizedBox(height: 10),
                        _action('ПАС', Icons.swap_horiz, game.pass, const Color(0xFF2765A8)),
                        const SizedBox(height: 10),
                        _action('ОТБОР', Icons.shield, game.tackle, const Color(0xFFB36A22)),
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
  _Footballer(this.x, this.y, this.home, {this.user = false, this.number = 0, this.isGoalkeeper = false})
      : homeX = x,
        homeY = y;
  double x;
  double y;
  final bool home;
  final bool user;
  final int number;
  final bool isGoalkeeper;
  double diveTimer = 0;
  double vx = 0;
  double vy = 0;
  double animationPhase = 0;
  double facingX = 1;
  double facingY = 0;
  double kickTimer = 0;
  double homeX;
  double homeY;
  double decisionTimer = 0;
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
  double _ballSpin = 0;
  double _ballBounce = 0;
  double _moveX = 0;
  double _moveY = 0;
  double _eventTimer = 3;
  bool _opponentHasBall = false;
  double _tackleCooldown = 0;
  double _aiDecisionTimer = 0;
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
      _players.add(_Footballer(homeFormation[i][0], homeFormation[i][1], true, number: i + 2, isGoalkeeper: i == 0));
    }
    _players.add(_Footballer(_playerX, _playerY, true, user: true, number: 10));
    for (var i = 0; i < awayFormation.length; i++) {
      _players.add(_Footballer(awayFormation[i][0], awayFormation[i][1], false, number: i + 1, isGoalkeeper: i == 0));
    }
  }

  void setMovement(double x, double y) { _moveX = x; _moveY = y; }
  void stopMovement() { _moveX = 0; _moveY = 0; }
  void setSprint(bool value) { _sprinting = value; }

  void tackle() {
    if (_tackleCooldown > 0) return;
    _tackleCooldown = .8;
    final opponent = _players.where((p) => !p.home && !p.isGoalkeeper).reduce((a, b) =>
      _distance(a.x, a.y, _playerX, _playerY) < _distance(b.x, b.y, _playerX, _playerY) ? a : b);
    if (_distance(opponent.x, opponent.y, _playerX, _playerY) < .095 && _opponentHasBall) {
      _opponentHasBall = false;
      _ballOwned = true;
      _ballX = _playerX + .035;
      _ballY = _playerY;
      _notify('Отбор! Мяч у тебя');
    } else {
      _notify('Подойди ближе к сопернику для отбора');
    }
  }

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
    _opponentHasBall = false;
    _players.firstWhere((p) => p.user).kickTimer = .32;
    final direction = _players.firstWhere((p) => p.user).facingX >= 0 ? 1.0 : -1.0;
    _ballVx = power * direction;
    _ballVy = (.5 - _ballY) * .42 + _moveY * .12;
    _ballSpin = (_moveY * .75 + _players.firstWhere((p) => p.user).facingY * .25) *
        (.25 + _dribbling * .55);
    _notify('Удар по воротам!');
  }

  void pass() {
    if (!_nearBall()) { _notify('Сначала доберись до мяча'); return; }
    final teammate = _players.where((p) => p.home && !p.user && !p.isGoalkeeper)
      .reduce((a, b) => _distance(a.x, a.y, _ballX, _ballY) < _distance(b.x, b.y, _ballX, _ballY) ? a : b);
    final dx = teammate.x - _ballX;
    final dy = teammate.y - _ballY;
    final length = math.max(.001, math.sqrt(dx * dx + dy * dy));
    final accuracy = .82 + _passing * .16;
    _ballOwned = false;
    _opponentHasBall = false;
    _players.firstWhere((p) => p.user).kickTimer = .2;
    _ballVx = dx / length * .78 * accuracy;
    _ballVy = dy / length * .78 * accuracy;
    _ballSpin = (dy / length) * .08 * (1 - _passing);
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
    _animateFootballer(user, dt);
    _playerX = (_playerX + user.vx * dt).clamp(.035, .965).toDouble();
    _playerY = (_playerY + user.vy * dt).clamp(.055, .945).toDouble();
    user.x = _playerX; user.y = _playerY;

    if (_tackleCooldown > 0) _tackleCooldown = math.max(0, _tackleCooldown - dt).toDouble();
    _aiDecisionTimer -= dt;

    // Find the nearest opponent and teammate to the ball.
    final opponents = _players.where((p) => !p.home && !p.isGoalkeeper).toList();
    final teammates = _players.where((p) => p.home && !p.user && !p.isGoalkeeper).toList();
    final nearestOpponent = opponents.reduce((a, b) =>
      _distance(a.x, a.y, _ballX, _ballY) < _distance(b.x, b.y, _ballX, _ballY) ? a : b);
    final nearestTeammate = teammates.reduce((a, b) =>
      _distance(a.x, a.y, _ballX, _ballY) < _distance(b.x, b.y, _ballX, _ballY) ? a : b);

    for (final p in _players.where((p) => !p.user)) {
      final oldX = p.x, oldY = p.y;
      double tx;
      double ty;
      double speed;

      if (p.isGoalkeeper) {
        // Keepers stay close to their goal line and shift laterally with the ball.
        tx = p.home ? .065 : .935;
        ty = (.5 + (_ballY - .5) * .72).clamp(.34, .66).toDouble();
        speed = .18;
      } else if (!p.home) {
        final hasBall = _opponentHasBall && identical(p, nearestOpponent);
        final isPressing = identical(p, nearestOpponent) && !_ballOwned;
        if (hasBall) {
          // Ball carrier attacks the left goal; nearby teammates spread for passing lanes.
          tx = .12;
          ty = .5 + (p.y - .5) * .35;
          speed = .13;
        } else if (isPressing || _opponentHasBall && _distance(p.x, p.y, _ballX, _ballY) < .25) {
          tx = _ballX;
          ty = _ballY;
          speed = .19;
        } else {
          tx = .72 + (p.homeY - .5) * .16;
          ty = p.homeY + (_ballY - .5) * .12;
          speed = .075;
        }
      } else {
        final support = identical(p, nearestTeammate) && !_ballOwned && !_opponentHasBall;
        if (_opponentHasBall) {
          // Team drops back and protects the central lane.
          tx = math.max(.12, p.homeX - .12);
          ty = p.homeY + (_ballY - p.homeY) * .35;
          speed = .10;
        } else if (_ballOwned) {
          // Teammates make forward runs and offer passing options.
          tx = math.min(.91, p.homeX + .10);
          ty = p.homeY + (_ballY - p.homeY) * .25;
          speed = .085;
        } else if (support) {
          tx = _ballX - .025;
          ty = _ballY + (p.homeY < .5 ? -.07 : .07);
          speed = .15;
        } else {
          tx = p.homeX + (_ballX - .5) * .10;
          ty = p.homeY + (_ballY - .5) * .18;
          speed = .065;
        }
      }

      final dx = tx - p.x, dy = ty - p.y;
      final len = math.max(.001, math.sqrt(dx * dx + dy * dy));
      p.x += (dx / len * math.min(len, speed * dt)).toDouble();
      p.y += (dy / len * math.min(len, speed * dt)).toDouble();
      p.vx = (p.x - oldX) / math.max(dt, .001);
      p.vy = (p.y - oldY) / math.max(dt, .001);
      if (p.diveTimer > 0) p.diveTimer = math.max(0, p.diveTimer - dt).toDouble();
      _animateFootballer(p, dt);
    }

    // Opponent wins loose balls and carries them toward the opposite goal.
    if (!_ballOwned && !_opponentHasBall &&
        _distance(nearestOpponent.x, nearestOpponent.y, _ballX, _ballY) < .045 &&
        _ballVx.abs() + _ballVy.abs() < .32) {
      _opponentHasBall = true;
      _notify('Соперник перехватил мяч!');
    }
    if (_opponentHasBall) {
      _ballX = nearestOpponent.x - .028;
      _ballY = nearestOpponent.y + .008;
      _ballVx = -.10;
      _ballVy = 0;
      _ballSpin = 0;
      // AI occasionally releases a shot toward goal.
      if (_aiDecisionTimer <= 0) {
        _aiDecisionTimer = 1.8 + _random.nextDouble() * 1.4;
        if (nearestOpponent.x < .32 && _random.nextDouble() < .35) {
          _opponentHasBall = false;
          _ballVx = -(.75 + _random.nextDouble() * .45);
          _ballVy = (.5 - _ballY) * .42 + (_random.nextDouble() - .5) * .12;
          _ballSpin = (_random.nextDouble() - .5) * .22;
          _notify('Соперник пробивает!');
        }
      }
    } else if (!_ballOwned) {
      // Spin bends the flight path; air resistance gradually reduces speed and curl.
      _ballVy += _ballSpin * _ballVx.abs() * dt;
      _ballX += _ballVx * dt;
      _ballY += _ballVy * dt;
      final friction = math.pow(.30, dt).toDouble();
      _ballVx *= friction;
      _ballVy *= friction;
      _ballSpin *= math.pow(.42, dt).toDouble();

      // Ball-to-player contact: controlled touches slow the ball, deflections keep it moving.
      for (final p in _players) {
        final d = _distance(p.x, p.y, _ballX, _ballY);
        if (d < .026 && _ballVx.abs() + _ballVy.abs() > .10) {
          final dx = _ballX - p.x;
          final dy = _ballY - p.y;
          final len = math.max(.001, math.sqrt(dx * dx + dy * dy));
          _ballVx = (dx / len * _ballVx.abs() * .48).toDouble();
          _ballVy = (dy / len * _ballVy.abs() * .48 + _ballVy * .25).toDouble();
          if (p.home && !p.isGoalkeeper && d < .022 && _ballVx.abs() + _ballVy.abs() < .55) {
            if (p.user) {
              _ballOwned = true;
            } else {
              _ballOwned = false;
              _opponentHasBall = false;
            }
          }
          break;
        }
      }
    }

    if (!_opponentHasBall && _nearBall() && !_ballOwned &&
        _ballVx.abs() + _ballVy.abs() < .42) {
      _ballOwned = true;
    }
    if (_ballOwned && _nearBall()) {
      _ballX = _playerX + .035;
      _ballY = _playerY + .008;
      _ballVx = 0;
      _ballVy = 0;
    }

    // Goalkeeper reactions: anticipate the shot, dive and parry it back into play.
    if (_ballVx < -0.18 && _ballX < .14 && _ballY > .30 && _ballY < .70) {
      final keeper = _players.firstWhere((p) => p.home && p.isGoalkeeper);
      if (_distance(keeper.x, keeper.y, .055, _ballY) < .105) {
        keeper.diveTimer = .55;
        _ballVx = _ballVx.abs() * .48;
        _ballVy += (keeper.y - _ballY) * 1.6;
        _ballX = .105;
        _notify('Вратарь отражает удар!');
      }
    } else if (_ballVx > 0.18 && _ballX > .86 && _ballY > .30 && _ballY < .70) {
      final keeper = _players.firstWhere((p) => !p.home && p.isGoalkeeper);
      if (_distance(keeper.x, keeper.y, .945, _ballY) < .105) {
        keeper.diveTimer = .55;
        _ballVx = -_ballVx.abs() * .48;
        _ballVy += (keeper.y - _ballY) * 1.6;
        _ballX = .895;
        _notify('Вратарь соперника спасает команду!');
      }
    }

    if (_ballX > .985 && _ballY > .39 && _ballY < .61) {
      _homeGoals++; scoreText.value = '$_homeGoals : $_awayGoals';
      _opponentHasBall = false; _ballOwned = false;
      _notify('ГОЛ! Отличная атака!');
      _resetAfterGoal();
    } else if (_ballX < .015 && _ballY > .39 && _ballY < .61) {
      _awayGoals++; scoreText.value = '$_homeGoals : $_awayGoals';
      _opponentHasBall = false; _ballOwned = false;
      _notify('Соперник забил');
      _resetAfterGoal();
    }
    // Touchline/end-line rebounds and goal-post collisions.
    if (_ballY < .045 || _ballY > .955) {
      _ballY = _ballY.clamp(.045, .955).toDouble();
      _ballVy = -_ballVy * .62;
      _ballSpin *= .55;
      _notify('Мяч отскакивает от боковой линии');
    }
    final inGoalMouth = _ballY > .425 && _ballY < .575;
    if ((_ballX > .972 && _ballY >= .405 && _ballY <= .425) ||
        (_ballX > .972 && _ballY >= .575 && _ballY <= .595) ||
        (_ballX < .028 && _ballY >= .405 && _ballY <= .425) ||
        (_ballX < .028 && _ballY >= .575 && _ballY <= .595)) {
      _ballVx = -_ballVx * .72;
      _ballVy = -_ballVy * .65;
      _ballX = _ballX > .5 ? .968 : .032;
      _notify('Штанга!');
    }
    if (!inGoalMouth && (_ballX < .025 || _ballX > .975)) {
      _ballX = _ballX.clamp(.025, .975).toDouble();
      _ballVx = -_ballVx * .58;
      _ballVy *= .82;
      _notify('Мяч ушёл за пределы поля');
    }

    _matchClock += dt * 1.5;
    final minute = _matchClock.floor();
    if (minute > _lastMinute && minute % 5 == 0) {
      _lastMinute = minute;
      if (_random.nextDouble() < .3) _notify('$minute’ • Команды борются за контроль мяча');
    }
    if (_eventTimer > 0) _eventTimer -= dt;
  }

  void _animateFootballer(_Footballer p, double dt) {
    final speed = math.sqrt(p.vx * p.vx + p.vy * p.vy);
    if (speed > .012) {
      p.facingX = p.vx / speed;
      p.facingY = p.vy / speed;
      p.animationPhase += dt * (7 + speed * 24);
    } else {
      p.animationPhase += dt * 1.4;
    }
    if (p.kickTimer > 0) p.kickTimer = math.max(0, p.kickTimer - dt).toDouble();
  }

  void _resetAfterGoal() {
    _ballX = .5; _ballY = .5; _ballVx = 0; _ballVy = 0; _ballSpin = 0; _ballBounce = 0; _ballOwned = false; _opponentHasBall = false;
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
    final color = player.isGoalkeeper ? const Color(0xFFF0C542) : (player.home ? _homeColor : _awayColor);
    final speed = math.sqrt(player.vx * player.vx + player.vy * player.vy);
    final running = (speed > .025 || player.user && (_moveX != 0 || _moveY != 0));
    final stride = running ? math.sin(player.animationPhase) : 0.0;
    final armSwing = running ? math.cos(player.animationPhase) * .28 : 0.0;
    final kick = player.kickTimer > 0 ? (player.kickTimer / .32) : 0.0;
    final bodyTilt = (player.facingX * .12).clamp(-.12, .12).toDouble();
    final diving = player.diveTimer > 0;
    final diveLean = diving ? (player.home ? -1.0 : 1.0) * .65 : 0.0;

    // Ground shadow and moving limbs make the footballer read as an animated figure.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + radius * 1.48), width: radius * (diving ? 3.8 : 2.8), height: radius * .9),
      Paint()..color = Colors.black.withValues(alpha: .38),
    );
    final limb = Paint()..color = const Color(0xFF202A32)..strokeWidth = radius * .34..strokeCap = StrokeCap.round;
    final leftHip = Offset(x - radius * .22, y + radius * .48);
    final rightHip = Offset(x + radius * .22, y + radius * .48);
    final leftFoot = Offset(x - radius * (.32 + stride * .42) + kick * radius * .8, y + radius * (1.28 - stride * .2 - kick * .12));
    final rightFoot = Offset(x + radius * (.32 - stride * .42), y + radius * (1.28 + stride * .2));
    canvas.drawLine(leftHip, leftFoot, limb);
    canvas.drawLine(rightHip, rightFoot, limb);

    final arm = Paint()..color = color.withValues(alpha: .95)..strokeWidth = radius * .3..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x - radius * .55, y - radius * .25), Offset(x - radius * (.78 + armSwing), y + radius * .35), arm);
    canvas.drawLine(Offset(x + radius * .55, y - radius * .25), Offset(x + radius * (.78 - armSwing), y + radius * .35), arm);

    final torso = Rect.fromCenter(center: Offset(x + (bodyTilt + diveLean) * radius, y + (diving ? radius * .25 : 0)), width: radius * (diving ? 2.05 : 1.72), height: radius * (diving ? 1.05 : 1.48));
    canvas.drawRRect(
      RRect.fromRectAndRadius(torso, Radius.circular(radius * .42)),
      Paint()..shader = LinearGradient(
        colors: [color.withValues(alpha: .72), color, color.withValues(alpha: .72)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ).createShader(torso),
    );
    canvas.drawLine(Offset(x, y - radius * .58), Offset(x, y + radius * .55),
      Paint()..color = Colors.white.withValues(alpha: .22)..strokeWidth = radius * .12);
    canvas.drawCircle(Offset(x + (diving ? diveLean * radius * 1.8 : -bodyTilt * radius), y - (diving ? radius * .25 : radius * .82)), radius * .43,
      Paint()..shader = const RadialGradient(colors: [Color(0xFFF3D2B2), Color(0xFFB98260)]).createShader(Rect.fromCircle(center: Offset(x, y - radius * .82), radius: radius * .43)));
    if (player.isGoalkeeper) {
      final gloves = Paint()..color = const Color(0xFFF5F5E8)..strokeWidth = radius * .38..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x - radius * .7, y + radius * .1), Offset(x - radius * 1.05, y + radius * .15), gloves);
      canvas.drawLine(Offset(x + radius * .7, y + radius * .1), Offset(x + radius * 1.05, y + radius * .15), gloves);
    }
    if (player.user) {
      canvas.drawCircle(Offset(x, y), radius * 1.58,
        Paint()..color = const Color(0xFFB7FFCA)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      final name = TextPainter(
        text: TextSpan(text: playerName, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 90);
      name.paint(canvas, Offset(x - name.width / 2, y - radius * 2.1 - name.height));
    }
    final number = TextPainter(
      text: TextSpan(text: '${player.number}', style: TextStyle(color: Colors.white, fontSize: math.max(5, radius * .48), fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    number.paint(canvas, Offset(x - number.width / 2, y - number.height / 2));
  }

  void _drawBall(Canvas canvas, double x, double y) {
    final r = size.y * .012;
    canvas.drawOval(Rect.fromCenter(center: Offset(x + r * .5, y + r * 1.8), width: r * 3.2, height: r * 1.1), Paint()..color = Colors.black.withValues(alpha: .38));
    canvas.drawCircle(Offset(x, y), r, Paint()..shader = const RadialGradient(colors: [Colors.white, Color(0xFFD5D9D6), Color(0xFF858B88)], center: Alignment(-.3, -.4)).createShader(Rect.fromCircle(center: Offset(x, y), radius: r)));
    canvas.drawCircle(Offset(x, y), r, Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = .7);
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(_matchClock * (_ballVx.abs() + _ballVy.abs()) * 3);
    canvas.drawCircle(Offset.zero, r * .28, Paint()..color = const Color(0xFF20252A));
    final panel = Paint()..color = const Color(0xFF252B30)..style = PaintingStyle.stroke..strokeWidth = r * .12;
    canvas.drawLine(Offset(x - r * .65, y), Offset(x + r * .65, y), panel);
    canvas.drawLine(Offset(0, -r * .65), Offset(0, r * .65), panel);
    canvas.restore();
  }
}
