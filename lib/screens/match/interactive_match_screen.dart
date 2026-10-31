import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/match.dart';
import 'package:flutter_football/models/player.dart';
import 'package:flutter_football/models/player_status.dart';

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
  int _shots = 0;
  int _successfulActions = 0;
  int _maxActions = 9;
  String _momentTitle = '';
  String _momentDescription = '';
  double _rating = 6.0;
  bool _finished = false;
  bool _momentReady = false;
  bool _playerUnavailable = false;
  bool _playerOnPitch = true;
  String? _injuryName;
  int _injuryMatchesRemaining = 0;
  String _event = 'Матч начинается! Ваша команда разыгрывает мяч.';
  String _phase = 'buildUp';

  late final bool _playerPlayed;
  late final int _homeStrength;
  late final int _awayStrength;
  late final String _homeTeam;
  late final String _awayTeam;

  Player get _player => widget.career.player;
  int get _playerTeamStrength => widget.isHome ? _homeStrength : _awayStrength;
  int get _opponentTeamStrength => widget.isHome ? _awayStrength : _homeStrength;

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
    final baseMatch = Match.generate(
      player: _player,
      career: widget.career,
      opponent: widget.opponent,
      isHome: widget.isHome,
    );
    _playerPlayed = baseMatch.playerPlayed;
    _playerOnPitch = baseMatch.playerPlayed;
    _playerAssists = 0;
    // Сохраняем командные голы обычной модели, но заменяем
    // заранее сгенерированные голы игрока интерактивными эпизодами.
    _homeGoals = baseMatch.homeGoals - (widget.isHome ? baseMatch.playerGoals : 0);
    _awayGoals = baseMatch.awayGoals - (widget.isHome ? 0 : baseMatch.playerGoals);
    _yellowCards = 0;
    _redCards = 0;
    _rating = 6.0;

    if (!_playerPlayed) {
      _minute = 90;
      _finished = true;
      _event = widget.career.isInjured
          ? 'Вы пропускаете матч из-за травмы.'
          : 'Тренер оставил вас в запасе. Матч проходит без вашего участия.';
      return;
    }

    final status = PlayerStatusCalculator.calculate(
      overall: _player.overall,
      clubName: _player.club,
    );
    if (status == PlayerStatus.substitute) _minute = 55 + _random.nextInt(11);
    _maxActions = status == PlayerStatus.substitute
        ? 5 + _random.nextInt(2)
        : 7 + _random.nextInt(3);
    _createMoment();
  }

  double _skill(String action) {
    final s = _player.skills;
    switch (action) {
      case 'dribble':
        return s.dribbling * 0.48 + s.pace * 0.30 + s.physical * 0.12 + s.vision * 0.10;
      case 'pass':
      case 'throughPass':
      case 'cross':
        return s.passing * 0.55 + s.vision * 0.30 + s.dribbling * 0.15;
      case 'shoot':
      case 'longShot':
        return s.shooting * 0.58 + s.dribbling * 0.12 + s.vision * 0.12 + s.physical * 0.10 + s.heading * 0.08;
      case 'header':
        return s.heading * 0.58 + s.physical * 0.18 + s.shooting * 0.24;
      case 'intercept':
        return s.vision * 0.35 + s.defending * 0.40 + s.pace * 0.15 + s.passing * 0.10;
      case 'block':
        return s.physical * 0.35 + s.defending * 0.45 + s.heading * 0.20;
      case 'keeper':
        return s.defending * 0.42 + s.physical * 0.24 + s.vision * 0.22 + s.pace * 0.12;
      case 'defend':
      case 'tackle':
      case 'contain':
        return s.defending * 0.55 + s.physical * 0.25 + s.pace * 0.20;
      default:
        return _player.overall.toDouble();
    }
  }

  void _createMoment() {
    if (!_playerOnPitch) {
      _phase = 'unavailable';
      _momentTitle = _injuryName == null ? 'Вы удалены' : 'Замена из-за травмы';
      _momentDescription = _injuryName == null
          ? 'Вы удалены. Команда доигрывает матч в меньшинстве.'
          : 'Вы покинули поле из-за травмы ($_injuryName). Команда продолжает матч.';
      _momentReady = true;
      return;
    }
    if (_phase == 'chance') {
      _momentTitle = 'Шанс забить!';
      _momentDescription = 'Вы прошли первую линию обороны. Можно пробить, обыграть вратаря или вывести партнёра на удар.';
      _momentReady = true;
      return;
    }
    final roll = _random.nextDouble();
    final position = _player.position;
    final setPieceRoll = _random.nextDouble();
    if (position != PlayerPosition.goalkeeper && setPieceRoll < 0.004) {
      _phase = 'penalty';
      _momentTitle = 'ПЕНАЛЬТИ!';
      _momentDescription = 'Судья указал на точку. Один удар может изменить ход матча.';
      _event = '$_minute-я минута. Ваша команда получает право на пенальти!';
      _momentReady = true;
      return;
    }
    if (position != PlayerPosition.goalkeeper && setPieceRoll < 0.020) {
      _phase = 'oneOnOne';
      _momentTitle = 'Выход один на один';
      _momentDescription = 'Вы прорвались за линию защиты. Вратарь выходит навстречу — решите, как завершить атаку.';
      _event = '$_minute-я минута. Опаснейший выход один на один!';
      _momentReady = true;
      return;
    }
    if (position != PlayerPosition.goalkeeper && setPieceRoll < 0.055) {
      _phase = 'corner';
      _momentTitle = 'Угловой удар';
      _momentDescription = 'Партнёры заняли позиции в штрафной. Можно подать на ближнюю/дальнюю штангу или разыграть коротко.';
      _event = '$_minute-я минута. Ваша команда подаёт угловой!';
      _momentReady = true;
      return;
    }
    if (position != PlayerPosition.goalkeeper && setPieceRoll < 0.095) {
      _phase = 'freeKick';
      _momentTitle = 'Штрафной удар';
      _momentDescription = 'Мяч установлен у штрафной. Выберите прямой удар или передачу партнёру.';
      _event = '$_minute-я минута. Ваша команда заработала штрафной!';
      _momentReady = true;
      return;
    }
    final attackChance = switch (position) {
      PlayerPosition.forward => 0.72,
      PlayerPosition.midfielder => 0.43,
      PlayerPosition.defender => 0.17,
      PlayerPosition.goalkeeper => 0.02,
    };
    final midfieldChance = switch (position) {
      PlayerPosition.forward => 0.14,
      PlayerPosition.midfielder => 0.34,
      PlayerPosition.defender => 0.13,
      PlayerPosition.goalkeeper => 0.08,
    };

    if (roll < attackChance) {
      _phase = 'attack';
      _momentTitle = 'Атака вашей команды';
      _momentDescription = switch (_random.nextInt(5)) {
        0 => 'Вы ворвались в штрафную с фланга. Защитник пытается закрыть прострел.',
        1 => 'Вы получили мяч у штрафной. Защитник закрывает удар, партнёр открывается справа.',
        2 => 'Команда быстро вышла из обороны. Вы получили мяч перед последней линией соперника.',
        3 => 'Защитник ошибся при приёме мяча. У вас есть время принять решение.',
        _ => 'Партнёр выполнил передачу за спину защитникам. Нужно открыться под мяч.',
      };
      _event = '$_minute-я минута. Ваша команда переходит в атаку!';
    } else if (roll < attackChance + midfieldChance) {
      _phase = 'midfield';
      _momentTitle = 'Борьба в центре поля';
      _momentDescription = switch (_random.nextInt(5)) {
        0 => 'Соперник не успел перестроиться. Можно начать быструю контратаку.',
        1 => 'Перед вами свободная зона. Решите, ускорить атаку или придержать мяч.',
        2 => 'Партнёры открываются между линиями. Один точный пас может создать голевой момент.',
        3 => 'Соперник оставил пространство на фланге. Можно перевести туда мяч.',
        _ => 'Команда соперника прессингует. Важно не потерять владение.',
      };
      _event = '$_minute-я минута. Мяч оказывается у вас в центре поля.';
    } else if (position == PlayerPosition.goalkeeper) {
      _phase = 'goalkeeper';
      _momentTitle = 'Опасный удар по воротам';
      _momentDescription = 'Соперник завершает атаку ударом. Нужно выбрать действие.';
      _event = '$_minute-я минута. Соперник наносит удар!';
    } else {
      _phase = 'defend';
      _momentTitle = 'Оборона';
      _momentDescription = 'Соперник развивает атаку. Вы можете вступить в отбор, перехватить пас или закрыть удар.';
      _event = '$_minute-я минута. Соперник атакует!';
    }
    _momentReady = true;
  }

  List<Widget> _positionActions() {
    if (_phase == 'unavailable') {
      return [_actionButton('Продолжить матч', 'continue')];
    }
    if (_phase == 'penalty') {
      return [_actionButton('Пробить пенальти', 'penaltyShoot')];
    }
    if (_phase == 'oneOnOne') {
      return [
        _actionButton('Пробить мимо вратаря', 'shoot'),
        _actionButton('Обвести вратаря', 'dribble'),
        _actionButton('Отдать пас партнёру', 'throughPass'),
      ];
    }
    if (_phase == 'corner') {
      return [
        _actionButton('Навесить на ближнюю штангу', 'cross'),
        _actionButton('Навесить на дальнюю штангу', 'header'),
        _actionButton('Разыграть коротко', 'pass'),
      ];
    }
    if (_phase == 'freeKick') {
      return [
        _actionButton('Пробить по воротам', 'shoot'),
        _actionButton('Отдать пас партнёру', 'pass'),
      ];
    }
    if (_phase == 'attack') {
      return [
        _actionButton('Пробить по воротам', 'shoot'),
        _actionButton('Отдать пас партнёру', 'pass'),
        _actionButton('Обыграть соперника', 'dribble'),
        _actionButton('Навесить в штрафную', 'cross'),
        if (_player.skills.heading >= 55)
          _actionButton('Сыграть головой', 'header'),
      ];
    }
    if (_phase == 'chance') {
      return [
        _actionButton('Пробить по воротам', 'shoot'),
        _actionButton('Попытаться обыграть вратаря', 'dribble'),
        _actionButton('Отдать пас свободному партнёру', 'throughPass'),
        _actionButton('Пробить головой', 'header'),
      ];
    }
    if (_phase == 'midfield') {
      return [
        _actionButton('Разрезающий пас', 'throughPass'),
        _actionButton('Продвинуться с мячом', 'dribble'),
        _actionButton('Удар издали', 'longShot'),
        _actionButton('Сохранить владение', 'pass'),
      ];
    }
    if (_phase == 'goalkeeper') {
      return [
        _actionButton('Отразить удар', 'keeper'),
        _actionButton('Перехватить навес', 'intercept'),
        _actionButton('Начать атаку передачей', 'pass'),
      ];
    }
    switch (_player.position) {
      case PlayerPosition.forward:
        return [
          _actionButton('Прессинговать соперника', 'contain'),
          _actionButton('Попытаться отобрать мяч', 'defend'),
        ];
      case PlayerPosition.midfielder:
        return [
          _actionButton('Перехватить передачу', 'intercept'),
          _actionButton('Пойти в отбор', 'defend'),
          _actionButton('Сдерживать соперника', 'contain'),
        ];
      case PlayerPosition.defender:
        return [
          _actionButton('Пойти в отбор', 'defend'),
          _actionButton('Перехватить передачу', 'intercept'),
          _actionButton('Заблокировать удар', 'block'),
          _actionButton('Сдерживать соперника', 'contain'),
        ];
      case PlayerPosition.goalkeeper:
        return [
          _actionButton('Отразить удар', 'keeper'),
          _actionButton('Перехватить навес', 'intercept'),
        ];
    }
  }

  void _choose(String action) {
    if (_finished || !_momentReady) return;
    if (action == 'continue') {
      _playerOnPitch = false;
      _finishRemainingMatch();
      return;
    }
    if (action == 'penaltyShoot') {
      final penaltyChance = (0.68 + (_player.skills.shooting - 60) * 0.006 +
              (_player.skills.vision - 60) * 0.001)
          .clamp(0.42, 0.91);
      final scored = _random.nextDouble() < penaltyChance;
      String penaltyMessage;
      if (scored) {
        if (widget.isHome) { _homeGoals++; } else { _awayGoals++; }
        _playerGoals++;
        _rating += 1.0;
        penaltyMessage = 'ГОЛ С ПЕНАЛЬТИ! Вы уверенно реализовали одиннадцатиметровый.';
      } else {
        _rating -= 0.18;
        penaltyMessage = _random.nextBool()
            ? 'Вратарь угадал направление и отразил пенальти!'
            : 'Промах с точки! Мяч прошёл мимо ворот.';
      }
      _phase = 'buildUp';
      _advanceClock(penaltyMessage);
      return;
    }
    final skill = _skill(action);
    final isAttackingAction = [
      'shoot', 'longShot', 'header', 'pass', 'throughPass', 'cross', 'dribble'
    ].contains(action);
    final difficulty = action == 'longShot' ? 0.27
        : action == 'throughPass' ? 0.16
        : action == 'shoot' || action == 'header' ? 0.10
        : 0.04;
    final advantage = widget.isHome
        ? (_homeStrength - _awayStrength) * 0.003
        : (_awayStrength - _homeStrength) * 0.003;
    final chance = (0.49 + (skill - 60) * 0.0055 + advantage - difficulty)
        .clamp(0.16, 0.84);
    final success = _random.nextDouble() < chance;
    if (success) _successfulActions++;
    String message;

    if (action == 'shoot' || action == 'longShot' || action == 'header') {
      _shots++;
      final isOneOnOne = _phase == 'oneOnOne';
      final finishingChance = isOneOnOne
          ? (action == 'header' ? 0.38 : 0.56)
          : action == 'header' ? 0.27 : action == 'longShot' ? 0.19 : 0.31;
      if (success && _random.nextDouble() < finishingChance) {
        if (widget.isHome) { _homeGoals++; } else { _awayGoals++; }
        _playerGoals++;
        _rating += 1.1;
        message = 'ГОЛ! Отличное завершение атаки!';
      } else if (success) {
        _rating += 0.12;
        message = 'Удар! Вратарь отбил мяч и спас свою команду.';
      } else {
        _rating -= 0.12;
        message = _random.nextBool()
            ? 'Промах! Мяч прошёл рядом со штангой.'
            : 'Защитник успел заблокировать удар.';
      }
    } else if (action == 'keeper') {
      if (success) {
        _rating += 0.48;
        _phase = 'buildUp';
        message = _random.nextBool()
            ? 'СЕЙВ! Вы отбили сложный удар и спасли команду.'
            : 'Отличная реакция! Вы поймали мяч и быстро начали атаку.';
      } else {
        if (widget.isHome) { _awayGoals++; } else { _homeGoals++; }
        _rating -= 0.35;
        _phase = 'buildUp';
        message = 'Гол соперника. На этот раз удар оказался слишком точным.';
      }
    } else if (action == 'pass' || action == 'throughPass' || action == 'cross') {
      if (success) {
        _phase = 'chance';
        _rating += 0.25;
        if (_random.nextDouble() < (action == 'cross' ? 0.22 : 0.32)) {
          if (widget.isHome) { _homeGoals++; } else { _awayGoals++; }
          _playerAssists++;
          message = 'ГОЛ ПАРТНЁРА! Ваша передача привела к голу.';
          _phase = 'buildUp';
        } else {
          message = action == 'cross'
              ? 'Отличный навес! Партнёр выиграл верховую борьбу и готовится пробить.'
              : 'Точная передача! Партнёр получил мяч в опасной позиции.';
        }
      } else {
        _phase = 'defend';
        _rating -= 0.16;
        message = 'Передача перехвачена. Соперник начинает атаку.';
      }
    } else if (action == 'dribble') {
      if (success) {
        _phase = 'chance';
        _rating += 0.25;
        message = 'Удачная обводка! Вы прошли соперника и приблизились к воротам.';
        if (_random.nextDouble() < 0.20) {
          if (widget.isHome) { _homeGoals++; } else { _awayGoals++; }
          _playerGoals++;
          message += ' Вы завершили проход голом!';
          _rating += 0.8;
        }
      } else {
        _phase = 'defend';
        _rating -= 0.20;
        message = 'Соперник прочитал движение и отобрал мяч.';
      }
    } else {
      if (success) {
        _phase = 'buildUp';
        _rating += 0.28;
        message = action == 'intercept'
            ? 'Перехват! Вы прочитали передачу и остановили атаку.'
            : action == 'block'
                ? 'Отличная блокировка! Вы закрыли направление удара.'
                : action == 'contain'
                    ? 'Вы сдержали соперника и заставили его отдать мяч назад.'
                    : 'Отличный отбор! Вы остановили опасную атаку.';
      } else {
        _phase = 'defend';
        _rating -= 0.18;
        message = 'Не удалось остановить атаку соперника.';
        if (_random.nextDouble() < 0.20) {
          if (widget.isHome) { _awayGoals++; } else { _homeGoals++; }
          message += ' Соперник забивает!';
        }
      }
    }

    final committedFoul = ['defend', 'tackle', 'contain'].contains(action) &&
        _random.nextDouble() < 0.075;
    if (committedFoul) {
      if (_yellowCards >= 1 || _random.nextDouble() < 0.004) {
        _yellowCards = 2;
        _redCards = 1;
        _playerUnavailable = true;
        _injuryName = null;
        message += ' Вторая жёлтая / прямая красная! Судья удаляет вас с поля.';
        _rating -= 0.65;
      } else {
        _yellowCards = min(2, _yellowCards + 1);
        message += ' Судья показывает жёлтую карточку за фол.';
        _rating -= 0.12;
      }
    } else if (!isAttackingAction && _random.nextDouble() < 0.018) {
      _yellowCards = min(2, _yellowCards + 1);
      message += ' Судья показывает жёлтую карточку.';
    }
    if (!_playerUnavailable && _random.nextDouble() < 0.007) {
      const injuries = ['Растяжение мышц', 'Ушиб', 'Повреждение голеностопа', 'Мышечная травма'];
      _injuryName = injuries[_random.nextInt(injuries.length)];
      _injuryMatchesRemaining = 1 + _random.nextInt(4);
      _playerUnavailable = true;
      _rating -= 0.25;
      message += ' Вы почувствовали боль и не можете продолжить матч: $_injuryName.';
    }
    _advanceClock(message);
  }

  void _finishRemainingMatch() {
    final remainingActions = max(1, ((_maxActions - _actions) * 0.65).round());
    for (var i = 0; i < remainingActions; i++) {
      final teamAttackChance = (0.16 +
              (_playerTeamStrength - _opponentTeamStrength) * 0.003)
          .clamp(0.08, 0.28);
      if (_random.nextDouble() < teamAttackChance) {
        if (widget.isHome) {
          _homeGoals++;
        } else {
          _awayGoals++;
        }
      }
      final opponentAttackChance = (0.17 +
              (_opponentTeamStrength - _playerTeamStrength) * 0.003)
          .clamp(0.08, 0.28);
      if (_random.nextDouble() < opponentAttackChance) {
        if (widget.isHome) {
          _awayGoals++;
        } else {
          _homeGoals++;
        }
      }
    }
    _minute = 90;
    _finished = true;
    _rating = _rating.clamp(4.0, 10.0).toDouble();
    setState(() {
      _event = _injuryName == null
          ? 'Матч завершён. Вы удалены, команда доиграла встречу в меньшинстве. Финальный свисток!'
          : 'Матч завершён. Вы покинули поле из-за травмы. Финальный свисток!';
      _momentReady = false;
    });
  }

  void _advanceClock(String message) {
    _actions++;
    _minute = min(90, _minute + 7 + _random.nextInt(4));
    if (_random.nextDouble() < 0.24) {
      final opponentChance =
          (0.22 + (_opponentTeamStrength - _playerTeamStrength) * 0.005).clamp(0.08, 0.55);
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
    if (_minute >= 90 || _actions >= _maxActions) {
      _minute = 90;
      _finished = true;
      _rating = _rating.clamp(4.0, 10.0).toDouble();
      message += '\nФинальный свисток!';
    }
    setState(() {
      _event = message;
      _momentReady = false;
    });
    if (!_finished) {
      Future<void>.delayed(const Duration(milliseconds: 950), () {
        if (!mounted || _finished) return;
        setState(_createMoment);
      });
    }
  }

  void _finish() {
    final match = Match(
      homeTeam: _homeTeam,
      awayTeam: _awayTeam,
      homeGoals: _homeGoals,
      awayGoals: _awayGoals,
      playerGoals: _playerPlayed ? min(_playerGoals, widget.isHome ? _homeGoals : _awayGoals) : 0,
      playerAssists: _playerPlayed ? min(_playerAssists, max(0, (widget.isHome ? _homeGoals : _awayGoals) - _playerGoals)) : 0,
      yellowCards: _playerPlayed ? _yellowCards : 0,
      redCards: _playerPlayed ? _redCards : 0,
      playerRating: _playerPlayed ? double.parse(_rating.toStringAsFixed(1)) : 0,
      playerPlayed: _playerPlayed,
      injuryName: _injuryName,
      injuryMatchesRemaining: _injuryMatchesRemaining,
    );
    Navigator.pop(context, match);
  }

  @override
  Widget build(BuildContext context) {
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF123A1D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF24552C)),
                  ),
                  child: Column(
                    children: [
                      if (_momentReady && !_finished) ...[
                        Text(
                          _momentTitle,
                          style: const TextStyle(
                            color: Color(0xFF8BE07F),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _momentDescription,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ] else
                        Text(
                          _event,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (!_playerPlayed)
                  const Text(
                    'Вы не попали в стартовый состав. Матч проходит без вашего участия.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  )
                else if (_finished) ...[
                  _buildMatchSummary(),
                ] else if (_momentReady) ...[
                  const Text(
                    'Выберите действие',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._positionActions(),
                ],
                const Spacer(),
                if (_finished || !_playerPlayed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _finish,
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

  Widget _buildMatchSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF102D19),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF24552C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'СТАТИСТИКА МАТЧА',
            style: TextStyle(
              color: Color(0xFF8BE07F),
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          _summaryRow('Голы', '$_playerGoals'),
          _summaryRow('Голевые передачи', '$_playerAssists'),
          _summaryRow('Удары', '$_shots'),
          _summaryRow('Успешные действия', '$_successfulActions'),
          _summaryRow('Жёлтые карточки', '$_yellowCards'),
          _summaryRow('Красные карточки', '$_redCards'),
          _summaryRow('Оценка', _rating.clamp(4.0, 10.0).toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
