import 'dart:async';
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
  final String? playerTeamName;
  final int? playerTeamStrength;
  final int? opponentStrength;
  final bool forcePlayerParticipation;
  final bool? playerWillPlay;

  const InteractiveMatchScreen({
    super.key,
    required this.career,
    required this.opponent,
    required this.isHome,
    this.playerTeamName,
    this.playerTeamStrength,
    this.opponentStrength,
    this.forcePlayerParticipation = false,
    this.playerWillPlay,
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
  int _shots = 0;
  int _successfulActions = 0;
  int _nextMomentMinute = 8;
  Timer? _clockTimer;
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
  late double _homeXgRemaining;
  late double _awayXgRemaining;
  late final String _homeTeam;
  late final String _awayTeam;

  Player get _player => widget.career.player;
  // int get _playerTeamStrength => widget.isHome ? _homeStrength : _awayStrength;
  // int get _opponentTeamStrength =>
  //     widget.isHome ? _awayStrength : _homeStrength;

  @override
  void initState() {
    super.initState();
    final playerTeamName = widget.playerTeamName ?? _player.club;
    final playerStrength =
        widget.playerTeamStrength ??
        Clubs.effectiveStrength(
          clubName: _player.club,
          playerClub: _player.club,
          playerOverall: _player.overall,
        );
    final opponentStrength =
        widget.opponentStrength ?? Clubs.getByName(widget.opponent).strength;
    _homeTeam = widget.isHome ? playerTeamName : widget.opponent;
    _awayTeam = widget.isHome ? widget.opponent : playerTeamName;
    _homeStrength = widget.isHome ? playerStrength : opponentStrength;
    _awayStrength = widget.isHome ? opponentStrength : playerStrength;
    final status = PlayerStatusCalculator.calculate(
      overall: _player.overall,
      clubName: _player.club,
      rivals: career.rivals,
      rivals: widget.career.rivals,
    );
    _playerPlayed = widget.forcePlayerParticipation
        ? !widget.career.isInjured
        : (widget.playerWillPlay ??
              Match.willPlayerPlay(
                player: _player,
                career: widget.career,
                opponent: widget.opponent,
                isHome: widget.isHome,
              ));
    _playerOnPitch = _playerPlayed;
    _playerGoals = 0;
    _playerAssists = 0;
    _yellowCards = 0;
    _redCards = 0;
    _rating = 6.0;

    if (!_playerPlayed) {
      _minute = 90;
      _finished = true;
      _event = widget.career.isInjured
          ? 'Вы пропускаете матч из-за травмы.'
          : 'Тренер оставил вас в запасе. Интерактивный режим недоступен.';
      return;
    }

    if (status == PlayerStatus.rotation) {
      _minute = 55 + _random.nextInt(11);
    }

    final expectedGoals = Match.calculateExpectedGoals(
      player: _player,
      opponent: widget.opponent,
      isHome: widget.isHome,
      playerPlayed: true,
      playerTeamStrength: playerStrength,
      opponentStrength: opponentStrength,
    );
    final elapsedMinutes = _minute - 1;
    final remainingMinutes = 90 - elapsedMinutes;
    _homeGoals = _samplePoisson(
      expectedGoals.home * elapsedMinutes / 90,
    );
    _awayGoals = _samplePoisson(
      expectedGoals.away * elapsedMinutes / 90,
    );
    _homeXgRemaining = expectedGoals.home * remainingMinutes / 90;
    _awayXgRemaining = expectedGoals.away * remainingMinutes / 90;
    _nextMomentMinute = _minute + 6 + _random.nextInt(7);
    _clockTimer = Timer.periodic(
      const Duration(milliseconds: 400),
      _tickMatchClock,
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  int _samplePoisson(double lambda) {
    final limit = exp(-lambda);
    var product = 1.0;
    var count = 0;
    do {
      count++;
      product *= _random.nextDouble();
    } while (product > limit);
    return count - 1;
  }

  void _addGoal({required bool home}) {
    if (home) {
      _homeGoals++;
      _homeXgRemaining = (_homeXgRemaining - 1).clamp(0.0, 2.8).toDouble();
    } else {
      _awayGoals++;
      _awayXgRemaining = (_awayXgRemaining - 1).clamp(0.0, 2.8).toDouble();
    }
  }

  void _tickMatchClock(Timer timer) {
    if (!mounted || _finished || _momentReady) return;
    if (_minute < 90) _minute++;

    final minutesRemaining = 91 - _minute;
    final homeChance = Match.goalChancePerMinute(
      expectedGoalsRemaining: _homeXgRemaining,
      minutesRemaining: minutesRemaining,
    );
    final awayChance = Match.goalChancePerMinute(
      expectedGoalsRemaining: _awayXgRemaining,
      minutesRemaining: minutesRemaining,
    );
    // Распределяем оставшийся xG по оставшимся минутам,
    // чтобы интенсивность не росла искусственно к финальному свистку.
    _homeXgRemaining = (_homeXgRemaining -
            _homeXgRemaining / minutesRemaining)
        .clamp(0.0, 2.8)
        .toDouble();
    _awayXgRemaining = (_awayXgRemaining -
            _awayXgRemaining / minutesRemaining)
        .clamp(0.0, 2.8)
        .toDouble();
    final homeScored = _random.nextDouble() < homeChance;
    final awayScored = _random.nextDouble() < awayChance;
    if (homeScored) {
      _addGoal(home: true);
      _event = 'ГОЛ! $_homeTeam забивает после атаки.';
    }
    if (awayScored) {
      _addGoal(home: false);
      _event = 'ГОЛ! $_awayTeam забивает после быстрой атаки.';
    }
    if (!homeScored && !awayScored && _random.nextDouble() < 0.025) {

      _event = _random.nextBool()
          ? 'Соперник проводит атаку, но защита успевает вернуться.'
          : 'Ваша команда контролирует мяч и ищет свободные зоны.';
    }

    if (_minute >= 90) {
      _minute = 90;
      _finished = true;
      _rating = _rating.clamp(4.0, 10.0).toDouble();
      _event = 'Финальный свисток!';
      timer.cancel();
    } else if (_playerOnPitch && _minute >= _nextMomentMinute) {
      _createMoment();
      _nextMomentMinute = _minute + 6 + _random.nextInt(7);
    }
    setState(() {});
  }

  double _skill(String action) {
    final s = _player.skills;
    switch (action) {
      case 'dribble':
        return s.dribbling * 0.48 +
            s.pace * 0.30 +
            s.physical * 0.12 +
            s.vision * 0.10;
      case 'pass':
      case 'throughPass':
      case 'cross':
        return s.passing * 0.55 + s.vision * 0.30 + s.dribbling * 0.15;
      case 'shoot':
      case 'longShot':
        return s.shooting * 0.58 +
            s.dribbling * 0.12 +
            s.vision * 0.12 +
            s.physical * 0.10 +
            s.heading * 0.08;
      case 'header':
        return s.heading * 0.58 + s.physical * 0.18 + s.shooting * 0.24;
      case 'volley':
        return s.shooting * 0.55 +
            s.heading * 0.20 +
            s.dribbling * 0.15 +
            s.physical * 0.10;
      case 'intercept':
        return s.vision * 0.35 +
            s.defending * 0.40 +
            s.pace * 0.15 +
            s.passing * 0.10;
      case 'block':
        return s.physical * 0.35 + s.defending * 0.45 + s.heading * 0.20;
      case 'keeper':
        return s.defending * 0.42 +
            s.physical * 0.24 +
            s.vision * 0.22 +
            s.pace * 0.12;
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
      _momentTitle = 'Мяч в штрафной';
      _momentDescription =
          'Перед вами ворота, защитник сокращает дистанцию, партнёр предлагает вариант для передачи.';
      _momentReady = true;
      return;
    }
    if (_phase == 'aerialChance') {
      _momentTitle = 'Верховая борьба';
      _momentDescription =
          'Навес летит в вашу зону в штрафной. Нужно выбрать момент для игры в воздухе.';
      _momentReady = true;
      return;
    }
    if (_phase == 'finalThird') {
      _momentTitle = 'Атака у штрафной';
      _momentDescription =
          'Команда закрепилась на половине соперника. Можно обострить передачей, сместиться или подготовить удар.';
      _momentReady = true;
      return;
    }

    final position = _player.position;
    final setPieceRoll = _random.nextDouble();
    if (position != PlayerPosition.goalkeeper && setPieceRoll < 0.012) {
      _phase = 'penalty';
      _momentTitle = 'ПЕНАЛЬТИ!';
      _momentDescription =
          'Судья назначил пенальти. Вы штатный исполнитель и можете пробить с точки.';
      _event = '$_minute-я минута. Пенальти в пользу вашей команды!';
      _momentReady = true;
      return;
    }
    if ((position == PlayerPosition.forward ||
            position == PlayerPosition.midfielder) &&
        setPieceRoll < 0.035) {
      _phase = 'oneOnOne';
      _momentTitle = 'Выход один на один';
      _momentDescription =
          'Перед вами только вратарь. Можно пробить, обыграть его или отдать пас партнёру.';
      _event = '$_minute-я минута. Выход один на один!';
      _momentReady = true;
      return;
    }
    if (position != PlayerPosition.goalkeeper && setPieceRoll < 0.105) {
      _phase = 'corner';
      _momentTitle = 'Угловой';
      _momentDescription =
          'Вы у углового флажка. Партнёры занимают позиции в штрафной.';
      _event = '$_minute-я минута. Ваша команда подаёт угловой.';
      _momentReady = true;
      return;
    }
    if (position != PlayerPosition.goalkeeper && setPieceRoll < 0.175) {
      _phase = 'freeKick';
      _momentTitle = 'Штрафной';
      _momentDescription =
          'Команда заработала стандарт. Можно подать в штрафную или разыграть мяч.';
      _event = '$_minute-я минута. Штрафной удар.';
      _momentReady = true;
      return;
    }

    final roll = _random.nextDouble();

    // Дополнительные тактические эпизоды до обычного позиционного сценария.
    if ((position == PlayerPosition.forward ||
            position == PlayerPosition.midfielder) &&
        roll < 0.10) {
      _phase = 'twoOnOne';
      _momentTitle = 'Выход 2 в 1';
      _momentDescription =
          'Вы и партнёр выходите на двух защитников. Можно отдать пас на свободного игрока или взять завершение на себя.';
      _event = '$_minute-я минута. Быстрая атака 2 в 1!';
      _momentReady = true;
      return;
    }
    if (position == PlayerPosition.forward && roll >= 0.10 && roll < 0.20) {
      _phase = 'isolatedPress';
      _momentTitle = 'Выше всех линии атаки';
      _momentDescription =
          'Команда потеряла мяч, а вы остались впереди. Можно начать давление на защитника или вернуться и помочь команде сохранить компактность.';
      _event = '$_minute-я минута. Команда перестраивается после потери.';
      _momentReady = true;
      return;
    }
    if ((position == PlayerPosition.midfielder ||
            position == PlayerPosition.defender) &&
        roll >= 0.10 &&
        roll < 0.19) {
      _phase = 'secondBall';
      _momentTitle = 'Подбор мяча';
      _momentDescription =
          'После верховой борьбы мяч отскочил в свободную зону. Нужно первым добраться до него и решить, как продолжить атаку.';
      _event = '$_minute-я минута. Борьба за подбор.';
      _momentReady = true;
      return;
    }
    if (position == PlayerPosition.midfielder && roll >= 0.19 && roll < 0.29) {
      _phase = 'counterAttack';
      _momentTitle = 'Контратака';
      _momentDescription =
          'Вы перехватили мяч, соперник не успел вернуться. Можно ускорить атаку передачей вперёд или продвинуть мяч самостоятельно.';
      _event = '$_minute-я минута. Ваша команда убегает в контратаку.';
      _momentReady = true;
      return;
    }
    if (position == PlayerPosition.defender && roll >= 0.19 && roll < 0.29) {
      _phase = 'defensiveLine';
      _momentTitle = 'Линия обороны';
      _momentDescription =
          'Нападающий соперника пытается открыться за спину. Нужно выбрать: держать линию, отступить или сыграть на перехват.';
      _event = '$_minute-я минута. Опасное движение за спину.';
      _momentReady = true;
      return;
    }

    if ((position == PlayerPosition.forward ||
            position == PlayerPosition.midfielder) &&
        roll >= 0.29 &&
        roll < 0.37) {
      _phase = 'pressingTrap';
      _momentTitle = 'Командный прессинг';
      _momentDescription =
          'Соперник получил мяч у боковой линии. Вы можете закрыть ближайшую передачу или совместно с партнёром начать давление.';
      _event = '$_minute-я минута. Команда включает прессинг.';
      _momentReady = true;
      return;
    }

    if (position == PlayerPosition.goalkeeper) {
      if (roll < 0.58) {
        _phase = 'goalkeeper';
        _momentTitle = 'Удар соперника';
        _momentDescription =
            'Нападающий соперника наносит удар из штрафной. Выберите способ игры на линии ворот.';
        _event = '$_minute-я минута. Соперник завершает атаку.';
      } else if (roll < 0.78) {
        _phase = 'goalkeeperCross';
        _momentTitle = 'Навес в штрафную';
        _momentDescription =
            'Соперник подаёт с фланга. Нужно решить, выходить ли на перехват или остаться на линии.';
        _event = '$_minute-я минута. Опасный навес соперника.';
      } else {
        _phase = 'goalkeeperBuildUp';
        _momentTitle = 'Начало атаки';
        _momentDescription =
            'Вы поймали мяч. Выберите, как начать атаку своей команды.';
        _event = '$_minute-я минута. Мяч у вратаря.';
      }
      _momentReady = true;
      return;
    }

    switch (position) {
      case PlayerPosition.forward:
        if (roll < 0.42) {
          _phase = 'box';
          _momentTitle = 'Открывание в штрафной';
          _momentDescription =
              'Партнёр доставил мяч в штрафную. Защитник рядом, нужно завершить или продолжить комбинацию.';
        } else if (roll < 0.66) {
          _phase = 'wideAttack';
          _momentTitle = 'Атака по флангу';
          _momentDescription =
              'Вы получили мяч у боковой линии вблизи штрафной. Можно обыграть защитника, прострелить или отдать назад.';
        } else if (roll < 0.84) {
          _phase = 'midfield';
          _momentTitle = 'Получение между линиями';
          _momentDescription =
              'Вы опустились за мячом в средней трети поля. Нужно сохранить владение или ускорить атаку передачей.';
        } else {
          _phase = 'defend';
          _momentTitle = 'Прессинг';
          _momentDescription =
              'Защитник соперника контролирует мяч при начале атаки. Вы можете перекрыть передачу или начать прессинг.';
        }
        break;
      case PlayerPosition.midfielder:
        if (roll < 0.28) {
          _phase = 'finalThird';
          _momentTitle = 'Продвижение к штрафной';
          _momentDescription =
              'Вы получили мяч перед линией обороны соперника. Есть время оценить варианты и обострить атаку.';
        } else if (roll < 0.68) {
          _phase = 'midfield';
          _momentTitle = 'Борьба в центре поля';
          _momentDescription =
              'Вы контролируете мяч в средней трети. Партнёры открываются по флангам и между линиями.';
        } else if (roll < 0.82) {
          _phase = 'defend';
          _momentTitle = 'Возврат в оборону';
          _momentDescription =
              'Соперник начинает атаку через центр. Можно перекрыть линию паса или вступить в отбор.';
        } else {
          _phase = 'wideAttack';
          _momentTitle = 'Поддержка фланговой атаки';
          _momentDescription =
              'Партнёр продвинулся по флангу, а вы подключились к атаке и предлагаете вариант для передачи.';
        }
        break;
      case PlayerPosition.defender:
        if (roll < 0.55) {
          _phase = 'defend';
          _momentTitle = 'Оборона своей зоны';
          _momentDescription =
              'Соперник атакует вашу зону. Нужно выбрать позицию, момент для отбора или перехват передачи.';
        } else if (roll < 0.76) {
          _phase = 'buildUp';
          _momentTitle = 'Выход из обороны';
          _momentDescription =
              'Вы получили мяч у своей штрафной. Важно начать атаку без риска потери.';
        } else if (roll < 0.90) {
          _phase = 'overlapRun';
          _momentTitle = 'Подключение по внешнему флангу';
          _momentDescription =
              'Партнёр сместился с мячом в центр, а вы свободны на фланге. Можно сделать рывок, получить передачу и прострелить.';
        } else {
          _phase = 'midfield';
          _momentTitle = 'Продвижение с мячом';
          _momentDescription =
              'Перед вами свободное пространство в средней трети. Можно продвинуть мяч или перевести игру.';
        }
        break;
      case PlayerPosition.goalkeeper:
        break;
    }
    _event = '$_minute-я минута. ${_momentTitle.toLowerCase()}.';
    _momentReady = true;
  }

  List<Widget> _positionActions() {
    if (_phase == 'unavailable') {
      return [_actionButton('Продолжить матч', 'continue')];
    }
    if (_phase == 'penalty') {
      return [_actionButton('Пробить пенальти', 'penaltyShoot')];
    }
    if (_phase == 'twoOnOne') {
      return [
        _actionButton('Отдать пас свободному партнёру', 'twoOnOnePass'),
        _actionButton('Продолжить самому и пробить', 'twoOnOneShoot'),
      ];
    }
    if (_phase == 'isolatedPress') {
      return [
        _actionButton('Начать прессинг защитника', 'press'),
        _actionButton('Вернуться на свою позицию', 'recover'),
      ];
    }
    if (_phase == 'secondBall') {
      return [
        _actionButton('Выиграть подбор и сыграть в пас', 'pass'),
        _actionButton('Продвинуть мяч вперёд', 'dribble'),
        _actionButton('Сбросить партнёру рядом', 'contain'),
      ];
    }
    if (_phase == 'counterAttack') {
      return [
        _actionButton('Отдать передачу на ход', 'throughPass'),
        _actionButton('Пройти свободную зону с мячом', 'dribble'),
        _actionButton('Притормозить и сохранить владение', 'contain'),
      ];
    }
    if (_phase == 'defensiveLine') {
      return [
        _actionButton('Сохранить линию и держать позицию', 'contain'),
        _actionButton('Отступить за нападающим', 'recover'),
        _actionButton('Рискнуть и сыграть на перехват', 'intercept'),
      ];
    }
    if (_phase == 'oneOnOne') {
      return [
        _actionButton('Пробить в дальний угол', 'shoot'),
        _actionButton('Обвести вратаря', 'dribble'),
        _actionButton('Отдать пас на пустые ворота', 'throughPass'),
      ];
    }
    if (_phase == 'corner') {
      return [
        _actionButton('Навесить в штрафную', 'cross'),
        _actionButton('Короткий розыгрыш', 'pass'),
      ];
    }
    if (_phase == 'freeKick') {
      return [
        _actionButton('Подать в штрафную', 'cross'),
        _actionButton('Разыграть низом', 'pass'),
        if (_player.position == PlayerPosition.forward ||
            _player.position == PlayerPosition.midfielder)
          _actionButton('Пробить по воротам', 'shoot'),
      ];
    }
    if (_phase == 'box' || _phase == 'chance') {
      return [
        _actionButton('Пробить по воротам', 'shoot'),
        _actionButton('Сыграть на партнёра', 'throughPass'),
        _actionButton('Убрать мяч от защитника', 'dribble'),
      ];
    }
    if (_phase == 'aerialChance') {
      return [
        _actionButton('Удар головой', 'header'),
        _actionButton('Сбросить мяч партнёру', 'pass'),
      ];
    }
    if (_phase == 'overlapRun') {
      return [
        _actionButton('Рвануть по флангу и прострелить', 'cross'),
        _actionButton('Сыграть в короткую стенку', 'pass'),
        _actionButton('Продвинуть мяч самостоятельно', 'dribble'),
      ];
    }
    if (_phase == 'cutback') {
      return [
        _actionButton('Пробить с линии вратарской', 'shoot'),
        _actionButton('Отдать пас под удар партнёру', 'throughPass'),
        _actionButton('Скинуть мяч партнёру под удар', 'throughPass'),
      ];
    }
    if (_phase == 'pressingTrap') {
      return [
        _actionButton('Вместе с партнёром закрыть пас', 'intercept'),
        _actionButton('Атаковать игрока с мячом', 'press'),
        _actionButton('Сдержать соперника и закрыть центр', 'contain'),
      ];
    }
    if (_phase == 'wideAttack') {
      return [
        _actionButton('Прострелить вдоль ворот', 'cross'),
        _actionButton('Обыграть защитника', 'dribble'),
        _actionButton('Сыграть назад', 'pass'),
      ];
    }
    if (_phase == 'finalThird') {
      return [
        _actionButton('Отдать разрезающий пас', 'throughPass'),
        _actionButton('Сместиться с мячом', 'dribble'),
        _actionButton('Сыграть на фланг', 'pass'),
        if (_player.position == PlayerPosition.midfielder ||
            _player.position == PlayerPosition.forward)
          _actionButton('Удар с дальней дистанции', 'longShot'),
      ];
    }
    if (_phase == 'midfield') {
      if (_player.position == PlayerPosition.defender) {
        return [
          _actionButton('Короткий пас партнёру', 'pass'),
          _actionButton('Длинная передача на фланг', 'throughPass'),
          _actionButton('Продвинуть мяч вперёд', 'dribble'),
          _actionButton('Сохранить владение', 'contain'),
        ];
      }
      if (_player.position == PlayerPosition.forward) {
        return [
          _actionButton('Сыграть в стенку', 'pass'),
          _actionButton('Открыться за спину защитникам', 'throughPass'),
          _actionButton('Продвинуться с мячом', 'dribble'),
          _actionButton('Прессинговать при потере', 'contain'),
        ];
      }
      return [
        _actionButton('Отдать передачу между линиями', 'throughPass'),
        _actionButton('Перевести мяч на фланг', 'pass'),
        _actionButton('Продвинуться с мячом', 'dribble'),
        _actionButton('Сохранить владение', 'contain'),
      ];
    }
    if (_phase == 'buildUp') {
      return [
        _actionButton('Короткий пас защитнику', 'pass'),
        _actionButton('Длинная передача вперёд', 'throughPass'),
        _actionButton('Продвинуть мяч', 'dribble'),
      ];
    }
    if (_phase == 'goalkeeper') {
      return [
        _actionButton('Отразить удар', 'keeper'),
        _actionButton('Зафиксировать мяч', 'keeper'),
      ];
    }
    if (_phase == 'goalkeeperCross') {
      return [
        _actionButton('Выйти и перехватить навес', 'intercept'),
        _actionButton('Остаться на линии', 'keeper'),
      ];
    }
    if (_phase == 'goalkeeperBuildUp') {
      return [
        _actionButton('Ввести мяч рукой защитнику', 'pass'),
        _actionButton('Выбить мяч на фланг', 'throughPass'),
      ];
    }
    if (_phase == 'defend') {
      switch (_player.position) {
        case PlayerPosition.forward:
          return [
            _actionButton('Перекрыть передачу', 'contain'),
            _actionButton('Прессинговать защитника', 'defend'),
          ];
        case PlayerPosition.midfielder:
          return [
            _actionButton('Перекрыть линию паса', 'intercept'),
            _actionButton('Вступить в отбор', 'defend'),
            _actionButton('Сдерживать соперника', 'contain'),
          ];
        case PlayerPosition.defender:
          return [
            _actionButton('Выбрать позицию и сдерживать', 'contain'),
            _actionButton('Пойти в отбор', 'defend'),
            _actionButton('Перехватить передачу', 'intercept'),
            _actionButton('Заблокировать удар', 'block'),
          ];
        case PlayerPosition.goalkeeper:
          return [
            _actionButton('Отразить удар', 'keeper'),
            _actionButton('Перехватить навес', 'intercept'),
          ];
      }
    }
    return [_actionButton('Сыграть надёжно', 'pass')];
  }

  void _choose(String action) {
    if (_finished || !_momentReady) return;
    if (action == 'continue') {
      _playerOnPitch = false;
      _momentReady = false;
      _event = _injuryName == null
          ? 'Вы удалены. Команда продолжает матч в меньшинстве.'
          : 'Вы покинули поле из-за травмы. Матч продолжается.';
      setState(() {});
      return;
    }
    if (action == 'twoOnOnePass') {
      final passChance = (0.66 + (_player.skills.passing - 60) * 0.004).clamp(
        0.35,
        0.90,
      );
      if (_random.nextDouble() < passChance) {
        _rating += 0.32;
        final partnerScores = _random.nextDouble() < 0.48;
        _phase = 'buildUp';
        if (partnerScores) {
          _playerAssists++;
          if (widget.isHome) {
            _addGoal(home: true);
          } else {
            _addGoal(home: false);
          }
          _advanceClock(
            'Вы вывели партнёра на пустые ворота — ГОЛ! Отличная командная атака.',
          );
        } else {
          _advanceClock(
            'Пас прошёл! Партнёр пробил, но вратарь спас соперников.',
          );
        }
      } else {
        _phase = 'defend';
        _rating -= 0.18;
        _advanceClock('Защитник прочитал передачу и перехватил мяч.');
      }
      return;
    }
    if (action == 'twoOnOneShoot') {
      _phase = 'oneOnOne';
      action = 'shoot';
    }
    if (action == 'press' || action == 'recover') {
      final pressChance =
          (0.48 +
                  (_player.skills.pace - 60) * 0.004 +
                  (_player.skills.defending - 60) * 0.003)
              .clamp(0.20, 0.82);
      if (action == 'press' && _random.nextDouble() < pressChance) {
        _phase = 'midfield';
        _rating += 0.20;
        _advanceClock(
          'Прессинг сработал! Соперник ошибся под давлением, ваша команда вернула мяч.',
        );
      } else if (action == 'recover') {
        _phase = 'midfield';
        _rating += 0.12;
        _advanceClock(
          'Вы вернулись на позицию и помогли команде восстановить компактность.',
        );
      } else {
        _phase = 'defend';
        _rating -= 0.12;
        _advanceClock('Соперник вышел из-под давления и продвинул мяч вперёд.');
      }
      return;
    }
    if (action == 'penaltyShoot') {
      final penaltyChance =
          (0.68 +
                  (_player.skills.shooting - 60) * 0.006 +
                  (_player.skills.vision - 60) * 0.001)
              .clamp(0.42, 0.91);
      final scored = _random.nextDouble() < penaltyChance;
      String penaltyMessage;
      if (scored) {
        if (widget.isHome) {
          _addGoal(home: true);
        } else {
          _addGoal(home: false);
        }
        _playerGoals++;
        _rating += 1.0;
        penaltyMessage =
            'ГОЛ С ПЕНАЛЬТИ! Вы уверенно реализовали одиннадцатиметровый.';
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
      'shoot',
      'longShot',
      'header',
      'volley',
      'pass',
      'throughPass',
      'cross',
      'dribble',
    ].contains(action);
    final difficulty = action == 'longShot'
        ? 0.27
        : action == 'throughPass'
        ? 0.16
        : action == 'header' || action == 'volley'
        ? 0.12
        : action == 'shoot'
        ? 0.10
        : 0.04;
    final advantage = widget.isHome
        ? (_homeStrength - _awayStrength) * 0.003
        : (_awayStrength - _homeStrength) * 0.003;
    final chance = (0.49 + (skill - 60) * 0.0055 + advantage - difficulty)
        .clamp(0.16, 0.84);
    final success = _random.nextDouble() < chance;
    if (success) _successfulActions++;
    String message;

    if (action == 'shoot' ||
        action == 'longShot' ||
        action == 'header' ||
        action == 'volley') {
      _shots++;
      final isOneOnOne = _phase == 'oneOnOne';
      final isAerial = _phase == 'aerialChance';
      final finishingChance = isAerial
          ? action == 'header'
                ? 0.30
                : 0.22
          : isOneOnOne
          ? 0.48
          : action == 'longShot'
          ? 0.16
          : 0.27;
      if (success && _random.nextDouble() < finishingChance) {
        if (widget.isHome) {
          _addGoal(home: true);
        } else {
          _addGoal(home: false);
        }
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
      _phase = 'buildUp';
    } else if (action == 'keeper') {
      if (success) {
        _rating += 0.48;
        _phase = 'buildUp';
        message = _random.nextBool()
            ? 'СЕЙВ! Вы отбили сложный удар и спасли команду.'
            : 'Отличная реакция! Вы поймали мяч и быстро начали атаку.';
      } else {
        if (widget.isHome) {
          _addGoal(home: false);
        } else {
          _addGoal(home: true);
        }
        _rating -= 0.35;
        _phase = 'buildUp';
        message = 'Гол соперника. На этот раз удар оказался слишком точным.';
      }
    } else if (action == 'pass' ||
        action == 'throughPass' ||
        action == 'cross') {
      if (success) {
        _rating += 0.25;
        if (action == 'cross') {
          if (_phase == 'wideAttack' && _random.nextDouble() < 0.38) {
            _phase = 'cutback';
            message =
                'Вы прострелили назад под удар. Партнёр встречает мяч у линии вратарской!';
          } else {
            _phase = 'aerialChance';
            message =
                'Навес получился точным. Мяч летит в штрафную — готовьтесь к верховой борьбе.';
          }
        } else if (_phase == 'midfield' || _phase == 'buildUp') {
          _phase = action == 'throughPass' ? 'chance' : 'finalThird';
          message = action == 'throughPass'
              ? 'Передача разрезала линию полузащиты. Атака выходит к штрафной.'
              : 'Команда сохранила владение и продвинулась на половину соперника.';
        } else {
          _phase = 'chance';
          message = 'Точная передача вывела партнёра на ударную позицию.';
        }
      } else {
        _phase = 'defend';
        _rating -= 0.16;
        message = 'Передача перехвачена. Соперник начинает атаку.';
      }
    } else if (action == 'dribble') {
      if (success) {
        _phase = _phase == 'midfield' || _phase == 'buildUp'
            ? 'finalThird'
            : 'chance';
        _rating += 0.25;
        message = _phase == 'finalThird'
            ? 'Вы прошли соперника и продвинули команду к штрафной.'
            : 'Удачная обводка! Вы освободились от опеки вблизи ворот.';
        if (_phase == 'chance' && _random.nextDouble() < 0.08) {
          if (widget.isHome) {
            _addGoal(home: true);
          } else {
            _addGoal(home: false);
          }
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
          if (widget.isHome) {
            _addGoal(home: false);
          } else {
            _addGoal(home: true);
          }
          message += ' Соперник забивает!';
        }
      }
    }

    final committedFoul =
        ['defend', 'tackle', 'contain'].contains(action) &&
        _random.nextDouble() < 0.075;
    if (committedFoul) {
      if (_yellowCards >= 1 || _random.nextDouble() < 0.004) {
        _yellowCards = 2;
        _redCards = 1;
        _playerUnavailable = true;
        _playerOnPitch = false;
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
      const injuries = [
        'Растяжение мышц',
        'Ушиб',
        'Повреждение голеностопа',
        'Мышечная травма',
      ];
      _injuryName = injuries[_random.nextInt(injuries.length)];
      _injuryMatchesRemaining = 1 + _random.nextInt(4);
      _playerUnavailable = true;
      _playerOnPitch = false;
      _rating -= 0.25;
      message +=
          ' Вы почувствовали боль и не можете продолжить матч: $_injuryName.';
    }
    _advanceClock(message);
  }

  void _advanceClock(String message) {
    _event = message;
    _momentReady = false;
    if (_playerUnavailable) {
      _createMoment();
    } else {
      final isFollowUp =
          _phase == 'chance' ||
          _phase == 'aerialChance' ||
          _phase == 'finalThird' ||
          _phase == 'cutback';
      _nextMomentMinute = min(
        88,
        _minute + (isFollowUp ? 1 : 6 + _random.nextInt(7)),
      );
    }
    setState(() {});
  }

  void _finish() {
    final match = Match(
      homeTeam: _homeTeam,
      awayTeam: _awayTeam,
      homeGoals: _homeGoals,
      awayGoals: _awayGoals,
      playerGoals: _playerPlayed
          ? min(_playerGoals, widget.isHome ? _homeGoals : _awayGoals)
          : 0,
      playerAssists: _playerPlayed
          ? min(
              _playerAssists,
              max(0, (widget.isHome ? _homeGoals : _awayGoals) - _playerGoals),
            )
          : 0,
      yellowCards: _playerPlayed ? _yellowCards : 0,
      redCards: _playerPlayed ? _redCards : 0,
      playerRating: _playerPlayed
          ? double.parse(_rating.toStringAsFixed(1))
          : 0,
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'МАТЧ',
                  style: TextStyle(
                    color: Color(0xFF8BE07F),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_minute’',
                  style: const TextStyle(
                    color: Color(0xFF8BE07F),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_homeTeam  $_homeGoals : $_awayGoals  $_awayTeam',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._positionActions(),
                ],
                const Spacer(),
                if (_finished || !_playerPlayed)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _finish,
                      child: const Text('Завершить матч'),
                    ),
                  ),
                if (!_playerPlayed && !_finished) const SizedBox(height: 6),
                if (_playerPlayed)
                  Text(
                    'Ваш рейтинг: ${_rating.clamp(4.0, 10.0).toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.white60),
                  ),
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
