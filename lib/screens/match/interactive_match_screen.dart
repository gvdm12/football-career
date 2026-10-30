import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/models/player.dart';

class InteractiveMatchScreen extends StatefulWidget {
  final Career career;
  final String opponent;
  final bool isHome;

  const InteractiveMatchScreen({
    super.key,
    required this.career,
    required this.opponent,
    required this.isHome,
  });

  @override
  State<InteractiveMatchScreen> createState() => _InteractiveMatchScreenState();
}

class _InteractiveMatchScreenState extends State<InteractiveMatchScreen> {
  final Random _random = Random();
  int _minute = 1;
  int _homeGoals = 0;
  int _awayGoals = 0;
  int _playerGoals = 0;
  int _playerAssists = 0;
  int _yellowCards = 0;
  int _redCards = 0;
  int _actions = 0;
  double _rating = 6.0;
  bool _finished = false;
  String _event = 'Матч начинается! Ваша команда разыгрывает мяч.';
  String _phase = 'buildUp';

  late final bool _playerPlayed;
  late final int _homeStrength;
  late final int _awayStrength;
  late final String _homeTeam;
  late final String _awayTeam;

  Player get _player => widget.career.player;

  @override
  void initState() {
    super.initState();
    _homeTeam = widget.isHome ? _player.club : widget.opponent;
    _awayTeam = widget.isHome ? widget.opponent : _player.club;
    _homeStrength = widget.isHome
        ? Clubs.effectiveStrength(
            clubName: _player.club,
            playerClub: _player.club,
            playerOverall: _player.overall,
          )
        : Clubs.getByName(widget.opponent).strength;
    _awayStrength = widget.isHome
        ? Clubs.getByName(widget.opponent).strength
        : Clubs.effectiveStrength(
            clubName: _player.club,
            playerClub: _player.club,
            playerOverall: _player.overall,
          );
    final statusBonus = _player.overall >= 75 ? 0.90 : 0.65;
    _playerPlayed = !widget.career.isInjured &&
        _random.nextDouble() < statusBonus;
  }

  double _skill(String action) {
    final skills = _player.skills;
    switch (action) {
      case 'dribble':
        return skills.dribbling * 0.65 + skills.pace * 0.35;
      case 'pass':
        return skills.passing * 0.65 + skills.vision * 0.35;
      case 'shoot':
        return skills.shooting * 0.75 + skills.heading * 0.25;
      case 'defend':
        return skills.defending * 0.65 + skills.physical * 0.35;
      default:
        return _player.overall.toDouble();
    }
  }

  void _choose(String action) {
    if (_finished) return;
    final skill = _skill(action);
    final successChance = (0.38 + (skill - 50) * 0.006 +
            (_homeStrength - _awayStrength) * 0.003)
        .clamp(0.18, 0.88);
    final success = _random.nextDouble() < successChance;
    final attackingTeamHome = widget.isHome;
    String message;

    if (action == 'shoot') {
      if (success && _random.nextDouble() < 0.58) {
        if (attackingTeamHome) {
          _homeGoals++;
        } else {
          _awayGoals++;
        }
        _playerGoals++;
        _rating += 1.1;
        message = 'ГОЛ! Отличный удар — вы отправляете мяч в сетку!';
      } else {
        message = success
            ? 'Удар! Вратарь соперника спасает команду.'
            : 'Удар не получился — защитник блокирует попытку.';
        _rating += success ? 0.15 : -0.1;
      }
    } else if (action == 'pass') {
      if (success) {
        _phase = 'chance';
        _rating += 0.2;
        message = 'Точная передача! Команда выходит на опасную позицию.';
        if (_random.nextDouble() < 0.22) _playerAssists++;
      } else {
        _phase = 'defend';
        message = 'Передача перехвачена. Соперник начинает контратаку!';
        _rating -= 0.15;
      }
    } else if (action == 'dribble') {
      if (success) {
        _phase = 'chance';
        _rating += 0.25;
        message = 'Удачная обводка! Вы обыграли соперника и продвинулись вперёд.';
      } else {
        _phase = 'defend';
        message = 'Соперник отобрал мяч. Нужно возвращаться в оборону.';
        _rating -= 0.2;
      }
    } else {
      if (success) {
        _phase = 'buildUp';
        _rating += 0.25;
        message = 'Отличный отбор! Вы остановили атаку соперника.';
      } else {
        _phase = 'defend';
        message = 'Неудачная попытка отбора. Соперник сохраняет мяч.';
        _rating -= 0.25;
      }
    }

    _advanceClock(message);
  }

  void _advanceClock(String message) {
    _actions++;
    _minute = min(90, _minute + 7 + _random.nextInt(4));
    if (_random.nextDouble() < 0.24) {
      final opponentChance =
          (0.28 + (_awayStrength - _homeStrength) * 0.004).clamp(0.12, 0.65);
      if (_random.nextDouble() < opponentChance) {
        if (_random.nextDouble() < 0.24) {
          if (widget.isHome) {
            _awayGoals++;
          } else {
            _homeGoals++;
          }
          message += '\nСоперник отвечает голом!';
        } else {
          message += '\nСоперник провёл опасную атаку.';
        }
      }
    }
    if (_minute >= 90 || _actions >= 14) {
      _minute = 90;
      _finished = true;
      _rating = _rating.clamp(4.0, 10.0);
      message += '\nФинальный свисток!';
    }
    setState(() => _event = message);
  }

  void _finish() {
    final match = Match(
      homeTeam: _homeTeam,
      awayTeam: _awayTeam,
      homeGoals: _homeGoals,
      awayGoals: _awayGoals,
      playerGoals: _playerPlayed ? min(_playerGoals, widget.isHome ? _homeGoals : _awayGoals) : 0,
      playerAssists: _playerPlayed ? min(_playerAssists, widget.isHome ? _homeGoals : _awayGoals) : 0,
      yellowCards: _playerPlayed ? _yellowCards : 0,
      redCards: _playerPlayed ? _redCards : 0,
      playerRating: _playerPlayed ? double.parse(_rating.toStringAsFixed(1)) : 0,
      playerPlayed: _playerPlayed,
    );
    Navigator.pop(context, match);
  }

  @override
  Widget build(BuildContext context) {
    final teamGoals = widget.isHome ? _homeGoals : _awayGoals;
    final opponentGoals = widget.isHome ? _awayGoals : _homeGoals;
    return PopScope<Match>(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF04160A),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0B3A1A),
          foregroundColor: Colors.white,
          title: const Text('Интерактивный матч'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('$_minute’', style: const TextStyle(color: Color(0xFF8BE07F), fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('$_homeTeam  $_homeGoals : $_awayGoals  $_awayTeam',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: const Color(0xFF123A1D), borderRadius: BorderRadius.circular(14)),
                  child: Text(_event, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 18),
                if (!_playerPlayed)
                  const Text('Вы не попали в стартовый состав. Матч проходит без вашего участия.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white70))
                else if (!_finished) ...[
                  const Text('Выберите действие', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _actionButton('Обвести соперника', 'dribble'),
                  _actionButton('Отдать передачу', 'pass'),
                  _actionButton('Пробить по воротам', 'shoot'),
                  _actionButton('Пойти в отбор', 'defend'),
                ],
                const Spacer(),
                if (_finished || !_playerPlayed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _finished ? _finish : () {
                        setState(() {
                          _minute = 90;
                          _finished = true;
                          _event = 'Матч завершён. Вы не участвовали во встрече.';
                        });
                      },
                      child: const Text('Завершить матч'),
                    ),
                  ),
                if (!_playerPlayed && !_finished)
                  const SizedBox(height: 4),
                if (_playerPlayed)
                  Text('Ваш рейтинг: ${_rating.clamp(4.0, 10.0).toStringAsFixed(1)}',
                      style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String label, String action) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _choose(action),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14532D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            child: Text(label),
          ),
        ),
      );
}
