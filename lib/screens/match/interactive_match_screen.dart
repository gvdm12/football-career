import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_colors.dart';
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
  final bool isKnockout;
  final int homeAggregateGoalsBeforeMatch;
  final int awayAggregateGoalsBeforeMatch;

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
    this.isKnockout = false,
    this.homeAggregateGoalsBeforeMatch = 0,
    this.awayAggregateGoalsBeforeMatch = 0,
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
  int? _homePenalties;
  int? _awayPenalties;
  String? _injuryName;
  int _injuryMatchesRemaining = 0;
  String _event = 'Матч начинается! Ваша команда разыгрывает мяч.';
  final List<String> _chronicle = [];
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
      rivals: widget.career.rivals,
      coachTrust: widget.career.coachTrust,
      reputation: PlayerStatusCalculator.calculateReputation(
        overall: _player.overall,
        averageRating: widget.career.averageRating,
        coachTrust: widget.career.coachTrust,
        trophies: widget.career.history.fold<int>(
          0,
          (sum, item) => sum + item.achievements.length,
        ),
      ),
      averageRating: widget.career.averageRating,
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
    _homeGoals = _samplePoisson(expectedGoals.home * elapsedMinutes / 90);
    _awayGoals = _samplePoisson(expectedGoals.away * elapsedMinutes / 90);
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
    // xG задаёт ожидаемую результативность, но не ограничивает число голов.
    // Забитый мяч не должен обнулять оставшуюся вероятность следующих голов.
    if (home) {
      _homeGoals++;
    } else {
      _awayGoals++;
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
    _homeXgRemaining = (_homeXgRemaining - _homeXgRemaining / minutesRemaining)
        .clamp(0.0, 2.8)
        .toDouble();
    _awayXgRemaining = (_awayXgRemaining - _awayXgRemaining / minutesRemaining)
        .clamp(0.0, 2.8)
        .toDouble();
    final homeScored = _random.nextDouble() < homeChance;
    final awayScored = _random.nextDouble() < awayChance;
    if (homeScored) {
      _addGoal(home: true);
      _event = 'ГОЛ! $_homeTeam забивает после атаки.';
      _recordEvent(_event);
    }
    if (awayScored) {
      _addGoal(home: false);
      _event = 'ГОЛ! $_awayTeam забивает после быстрой атаки.';
      _recordEvent(_event);
    }
    if (!homeScored && !awayScored && _random.nextDouble() < 0.17) {
      final homePressing =
          _random.nextDouble() <
          (_homeXgRemaining / max(0.1, _homeXgRemaining + _awayXgRemaining));
      final attackingTeam = homePressing ? _homeTeam : _awayTeam;
      final defendingTeam = homePressing ? _awayTeam : _homeTeam;
      _event = switch (_random.nextInt(7)) {
        0 =>
          '$attackingTeam разыгрывает мяч короткими передачами и пытается пройти первую линию прессинга.',
        1 =>
          '$attackingTeam переводит атаку на фланг, крайний защитник подключается вперёд.',
        2 =>
          '$defendingTeam перехватывает передачу и начинает быструю контратаку.',
        3 =>
          '$attackingTeam играет в стенку у штрафной, но защитник успевает накрыть продолжение.',
        4 =>
          '$attackingTeam выходит из-под давления через короткий пас в центр.',
        5 =>
          '$defendingTeam выигрывает подбор после выноса и пытается развить атаку.',
        _ =>
          '$attackingTeam наносит удар издали, но мяч проходит рядом со штангой.',
      };
      _recordEvent(_event);
    }

    if (_minute >= 90) {
      _minute = 90;
      _finished = true;
      _rating = _rating.clamp(4.0, 10.0).toDouble();
      final homeAggregate = _homeGoals + widget.homeAggregateGoalsBeforeMatch;
      final awayAggregate = _awayGoals + widget.awayAggregateGoalsBeforeMatch;
      if (widget.isKnockout && homeAggregate == awayAggregate) {
        _homePenalties = 3 + _random.nextInt(3);
        _awayPenalties = 3 + _random.nextInt(3);
        while (_homePenalties == _awayPenalties) {
          _awayPenalties = 3 + _random.nextInt(3);
        }
        final winner = _homePenalties! > _awayPenalties!
            ? _homeTeam
            : _awayTeam;
        _event =
            'Ничья после основного времени. Серия пенальти: '
            '$_homePenalties : $_awayPenalties. Победитель — $winner!';
      } else {
        _event = 'Финальный свисток!';
      }
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
      case 'turnAndRun':
      case 'receiveReturn':
      case 'attackNearPost':
      case 'attackFarPost':
      case 'dribble':
        return s.dribbling * 0.48 +
            s.pace * 0.30 +
            s.physical * 0.12 +
            s.vision * 0.10;
      case 'playCenter':
      case 'playRight':
      case 'playLeft':
      case 'switchPlay':
      case 'wallPass':
      case 'pass':
      case 'backPass':
      case 'throughPass':
      case 'longPass':
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
      case 'twoOnOnePass':
      case 'throughPass':
        return s.passing * 0.55 + s.vision * 0.35 + s.dribbling * 0.10;
      case 'twoOnOneShoot':
        return s.shooting * 0.65 + s.vision * 0.15 + s.dribbling * 0.20;
      case 'press':
      case 'intercept':
        return s.defending * 0.40 + s.pace * 0.30 + s.vision * 0.20 + s.physical * 0.10;
      case 'recover':
        return s.pace * 0.40 + s.physical * 0.35 + s.defending * 0.25;
      case 'checkBack':
        return s.vision * 0.45 + s.passing * 0.35 + s.physical * 0.20;
      case 'defend':
      case 'tackle':
      case 'contain':
        return s.defending * 0.55 + s.physical * 0.25 + s.pace * 0.20;
      default:
        return _player.overall.toDouble();
    }
  }

  // Бонусы за высокий профильный навык растут ступенчато после 80, 85, 90 и 95.
  double _skillTierBonus(double skill) {
    if (skill < 80) return 0;
    if (skill < 85) return 0.04 + (skill - 80) * 0.01;
    if (skill < 90) return 0.09 + (skill - 85) * 0.012;
    if (skill < 95) return 0.15 + (skill - 90) * 0.014;
    return 0.22 + (skill - 95) * 0.015;
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
    if (_phase == 'offBallRun') {
      _momentTitle = 'Открывание под обратный пас';
      _momentDescription =
          'Вы уже перевели мяч на другой участок поля и ускорились без мяча. Можно рвануть за спину, ворваться в штрафную или предложить короткий пас.';
      _momentReady = true;
      return;
    }
    if (_phase == 'keeperBeaten') {
      _momentTitle = 'Вратарь обыгран!';
      _momentDescription =
          'Вы обошли голкипера. Перед вами почти пустые ворота, но защитник возвращается. Можно пробить или отдать пас партнёру.';
      _momentReady = true;
      return;
    }
    if (_phase == 'midfieldBuildUp') {
      _momentTitle = 'Решение в центре поля';
      _momentDescription =
          'Вы контролируете мяч в центре. Можно сыграть назад для сохранения владения, отдать длинную передачу вперёд, перевести мяч на фланг или продвинуться самому.';
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

    if (position == PlayerPosition.midfielder && roll < 0.14) {
      _phase = 'midfieldBuildUp';
      _momentTitle = 'Розыгрыш в центре поля';
      _momentDescription =
          'Вы получили мяч между линиями и видите несколько вариантов продолжения атаки.';
      _event = '$_minute-я минута. Команда начинает атаку через центр.';
      _momentReady = true;
      return;
    }

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
        roll >= 0.37 &&
        roll < 0.47) {
      _phase = 'wideCombination';
      _momentTitle = 'Комбинация через фланг';
      _momentDescription =
          'Вы получили мяч в полуфланге. Можно перевести атаку в центр или на любой фланг, а затем открыться под обратную передачу.';
      _event = '$_minute-я минута. Вы начинаете комбинацию через фланг.';
      _momentReady = true;
      return;
    }
    if (position == PlayerPosition.midfielder && roll >= 0.47 && roll < 0.55) {
      _phase = 'receiveBetweenLines';
      _momentTitle = 'Получение между линиями';
      _momentDescription =
          'Вы нашли свободное пространство за полузащитой соперника. Можно развернуться, сыграть в стенку или вывести партнёра передачей.';
      _event = '$_minute-я минута. Передача проходит между линиями.';
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
        } else if (roll < 0.92) {
          _phase = 'oneOnOne';
          _momentTitle = 'Рывок за спину защитникам';
          _momentDescription =
              'Полузащитник поднял голову и готовит передачу за линию обороны. Вы можете открыться на ход, принять мяч и выйти на ударную позицию.';
        } else {
          _phase = 'secondBall';
          _momentTitle = 'Борьба за отскок';
          _momentDescription =
              'После единоборства мяч отскочил к вам у границы штрафной. Нужно быстрее соперника обработать мяч и продолжить атаку.';
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
        } else if (roll < 0.92) {
          _phase = 'counterAttack';
          _momentTitle = 'Перехват и быстрый выход';
          _momentDescription =
              'Вы выиграли мяч в центре, соперник ещё не успел перестроиться. Можно ускорить контратаку передачей или пройти вперёд самостоятельно.';
        } else {
          _phase = 'pressingTrap';
          _momentTitle = 'Выход из-под прессинга';
          _momentDescription =
              'Соперник перекрыл центральные зоны и давит на мяч. Нужно найти свободного партнёра или обыграть первую линию давления.';
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
        } else if (roll < 0.96) {
          _phase = 'defensiveLine';
          _momentTitle = 'Страховка партнёра';
          _momentDescription =
              'Партнёр по обороне выдвинулся на соперника, а за его спиной появилась зона. Нужно решить, подстраховать его или удержать линию.';
        } else {
          _phase = 'secondBall';
          _momentTitle = 'Подбор после выноса';
          _momentDescription =
              'Соперник вынес мяч из штрафной, и он направляется в вашу зону. Можно выиграть подбор и сразу начать новую атаку.';
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
    if (_phase == 'wideCombination') {
      return [
        _actionButton(
          'Сыграть в центр и открыться под обратный пас',
          'playCenter',
        ),
        _actionButton('Перевести мяч на правый фланг', 'playRight'),
        _actionButton('Перевести мяч на левый фланг', 'playLeft'),
        _actionButton('Сыграть в стенку', 'wallPass'),
        _actionButton('Продолжить атаку самому', 'dribble'),
      ];
    }
    if (_phase == 'receiveBetweenLines') {
      return [
        _actionButton('Развернуться и ворваться вперёд', 'turnAndRun'),
        _actionButton('Отдать разрезающую передачу', 'throughPass'),
        _actionButton('Сыграть в стенку и открыться', 'wallPass'),
        _actionButton('Перевести атаку на фланг', 'switchPlay'),
      ];
    }
    if (_phase == 'offBallRun') {
      return [
        _actionButton(
          'Открыться за спину и принять обратный пас',
          'receiveReturn',
        ),
        _actionButton('Рвануть в штрафную под передачу', 'attackNearPost'),
        _actionButton('Сместиться на дальнюю штангу', 'attackFarPost'),
        _actionButton('Остановиться и сохранить позицию', 'checkBack'),
      ];
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
    if (_phase == 'keeperBeaten') {
      return [
        _actionButton('Пробить по почти пустым воротам', 'shoot'),
        _actionButton('Отдать пас партнёру', 'throughPass'),
      ];
    }
    if (_phase == 'midfieldBuildUp') {
      return [
        _actionButton('Сыграть назад и сохранить мяч', 'backPass'),
        _actionButton('Длинная передача вперёд', 'longPass'),
        _actionButton('Отдать разрезающий пас вперёд', 'throughPass'),
        _actionButton('Продвинуться с мячом', 'dribble'),
        _actionButton('Пробить издали', 'longShot'),
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
    if ([
      'playCenter',
      'playRight',
      'playLeft',
      'switchPlay',
    ].contains(action)) {
      final passChance =
          (0.72 +
                  (_player.skills.passing - 60) * 0.0042 +
                  (_player.skills.vision - 60) * 0.0022 +
                  (_player.skills.dribbling - 60) * 0.001 +
                  _skillTierBonus(_skill(action)) * 0.55 +
                  (widget.isHome
                          ? (_homeStrength - _awayStrength)
                          : (_awayStrength - _homeStrength)) *
                      0.0015)
              .clamp(0.46, 0.99);
      if (_random.nextDouble() < passChance) {
        _phase = 'offBallRun';
        _rating += 0.22;
        final direction = action == 'playCenter'
            ? 'в центр'
            : action == 'playRight'
            ? 'на правый фланг'
            : action == 'playLeft'
            ? 'на левый фланг'
            : 'на противоположный фланг';
        _advanceClock(
          'Вы перевели мяч $direction и сразу сделали рывок в свободную зону. Партнёры ищут обратную передачу.',
        );
      } else {
        _phase = 'defend';
        _rating -= 0.12;
        _advanceClock(
          'Соперник прочитал направление перевода и накрыл адресата. Команда вынуждена отойти назад.',
        );
      }
      return;
    }
    if (action == 'wallPass') {
      final wallChance =
          (0.73 +
                  (_player.skills.passing - 60) * 0.0035 +
                  (_player.skills.dribbling - 60) * 0.0025 +
                  (_player.skills.vision - 60) * 0.0015 +
                  _skillTierBonus(_skill(action)) * 0.55)
              .clamp(0.45, 0.98);
      if (_random.nextDouble() < wallChance) {
        _phase = 'chance';
        _rating += 0.30;
        _advanceClock(
          'Игра в стенку прошла! Вы отдали пас, ускорились между защитниками и получили мяч обратно у штрафной.',
        );
      } else {
        _phase = 'midfield';
        _rating -= 0.10;
        _advanceClock(
          'Защитник успел перекрыть обратную передачу. Партнёр сохранил мяч, но темп атаки сбит.',
        );
      }
      return;
    }
    if (action == 'turnAndRun' || action == 'receiveReturn') {
      final teamAdvantage = widget.isHome
          ? _homeStrength - _awayStrength
          : _awayStrength - _homeStrength;
      final runChance =
          (0.64 +
                  (_player.skills.pace - 60) * 0.0028 +
                  (_player.skills.dribbling - 60) * 0.0022 +
                  (_player.skills.vision - 60) * 0.0012 +
                  teamAdvantage * 0.001 +
                  _skillTierBonus(_skill(action)) * 0.55)
              .clamp(0.40, 0.97);
      if (_random.nextDouble() < runChance) {
        _phase = 'chance';
        _rating += 0.28;
        _advanceClock(
          'Вы вовремя ускорились, избавились от опеки и получили передачу на ход. Появилась возможность создать голевой момент.',
        );
      } else {
        _phase = 'midfield';
        _rating -= 0.08;
        _advanceClock(
          'Защитник прочитал рывок и не дал принять мяч на скорости. Команда продолжает владеть мячом.',
        );
      }
      return;
    }
    if (action == 'attackNearPost' || action == 'attackFarPost') {
      final teamAdvantage = widget.isHome
          ? _homeStrength - _awayStrength
          : _awayStrength - _homeStrength;
      final movementChance =
          (0.66 +
                  (_player.skills.pace - 60) * 0.002 +
                  (_player.skills.vision - 60) * 0.002 +
                  (_player.overall - 70) * 0.001 +
                  teamAdvantage * 0.0008 +
                  _skillTierBonus(_skill(action)) * 0.45)
              .clamp(0.42, 0.96);
      if (_random.nextDouble() < movementChance) {
        _phase = 'aerialChance';
        _rating += 0.18;
        _advanceClock(
          action == 'attackNearPost'
              ? 'Вы опередили защитника на ближней штанге. Партнёр готовит прострел или навес.'
              : 'Вы ушли от опеки и заняли позицию у дальней штанги. Подача может найти вас.',
        );
      } else {
        _phase = 'finalThird';
        _advanceClock(
          'Защитник удержал позицию и не позволил вам открыться. Атака продолжается перед штрафной.',
        );
      }
      return;
    }
    if (action == 'checkBack') {
      _phase = 'midfield';
      _rating += 0.10;
      _advanceClock(
        'Вы показали короткий вариант и помогли команде сохранить владение.',
      );
      return;
    }
    if (action == 'twoOnOnePass') {
      final passChance =
          (0.76 +
                  (_player.skills.passing - 60) * 0.005 +
                  (_player.skills.vision - 60) * 0.002 +
                  _skillTierBonus(_skill(action)) * 0.65)
              .clamp(0.48, 0.99);
      if (_random.nextDouble() < passChance) {
        _rating += 0.32;
        final attackXg = widget.isHome ? _homeXgRemaining : _awayXgRemaining;
        final partnerScoreChance =
            (0.20 +
                    _skillTierBonus(_skill('pass')) * 0.45 +
                    (attackXg / 1.1).clamp(0.0, 1.0) * 0.12)
                .clamp(0.12, 0.42);
        final partnerScores = _random.nextDouble() < partnerScoreChance;
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
                  (_player.skills.defending - 60) * 0.003 +
                  _skillTierBonus(_skill('defend')) * 0.55)
              .clamp(0.20, 0.94);
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
          (0.76 +
                  (_player.skills.shooting - 70) * 0.0035 +
                  (_player.skills.vision - 70) * 0.001 +
                  _skillTierBonus(_skill('shoot')) * 0.45)
              .clamp(0.62, 0.97);
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
      'backPass',
      'throughPass',
      'longPass',
      'cross',
      'playCenter',
      'playRight',
      'playLeft',
      'switchPlay',
      'wallPass',
      'turnAndRun',
      'receiveReturn',
      'attackNearPost',
      'attackFarPost',
      'checkBack',
      'dribble',
    ].contains(action);
    final advantage = widget.isHome
        ? (_homeStrength - _awayStrength) * 0.003
        : (_awayStrength - _homeStrength) * 0.003;
    final opponentDefence = widget.isHome ? _awayStrength : _homeStrength;
    // Сила обороны соперника — доступный в текущей модели командный proxy:
    // сильная команда лучше закрывает линии передач и пространство для дриблинга.
    final defensivePressure = (opponentDefence - 70) * 0.0018;

    // Для каждого действия используется профильный навык.
    // Удар головой зависит прежде всего от heading, а не от shooting.
    final double chance;
    if (action == 'shoot') {
      chance =
          (0.74 +
                  (_player.skills.shooting - 60) * 0.0045 +
                  _skillTierBonus(skill) +
                  advantage * 0.7 -
                  defensivePressure * 0.45 +
                  (_phase == 'oneOnOne' ? 0.08 : 0.0))
              .clamp(0.48, 0.96);
    } else if (action == 'longShot') {
      chance =
          (0.52 +
                  (_player.skills.shooting - 60) * 0.0038 +
                  _skillTierBonus(skill) +
                  advantage * 0.5 -
                  defensivePressure * 0.35)
              .clamp(0.30, 0.84);
    } else if (action == 'header') {
      chance =
          (0.74 +
                  (_player.skills.heading - 60) * 0.005 +
                  _skillTierBonus(skill) +
                  (_player.skills.physical - 60) * 0.0015 +
                  advantage * 0.6 -
                  defensivePressure * 0.35)
              .clamp(0.46, 0.95);
    } else if (action == 'volley') {
      chance =
          (0.66 +
                  (_player.skills.shooting - 60) * 0.0035 +
                  _skillTierBonus(skill) +
                  (_player.skills.heading - 60) * 0.0015 +
                  advantage * 0.5 -
                  defensivePressure * 0.35)
              .clamp(0.38, 0.91);
    } else if (action == 'backPass') {
      chance =
          (0.91 +
                  (_player.skills.passing - 60) * 0.0025 +
                  _skillTierBonus(skill) * 0.5 +
                  (_player.skills.vision - 60) * 0.001 +
                  advantage * 0.2 -
                  defensivePressure * 0.2)
              .clamp(0.72, 0.99);
    } else if (action == 'pass') {
      chance =
          (0.80 +
                  (_player.skills.passing - 60) * 0.0045 +
                  _skillTierBonus(skill) * 0.65 +
                  (_player.skills.vision - 60) * 0.0015 +
                  advantage * 0.4 -
                  defensivePressure)
              .clamp(0.54, 0.97);
    } else if (action == 'longPass') {
      chance =
          (0.67 +
                  (_player.skills.passing - 60) * 0.0048 +
                  _skillTierBonus(skill) * 0.65 +
                  (_player.skills.vision - 60) * 0.002 +
                  advantage * 0.3 -
                  defensivePressure * 0.8)
              .clamp(0.40, 0.94);
    } else if (action == 'throughPass') {
      chance =
          (0.71 +
                  (_player.skills.passing - 60) * 0.0045 +
                  _skillTierBonus(skill) * 0.65 +
                  (_player.skills.vision - 60) * 0.002 +
                  advantage * 0.4 -
                  defensivePressure)
              .clamp(0.43, 0.94);
    } else if (action == 'cross') {
      chance =
          (0.76 +
                  (_player.skills.passing - 60) * 0.0038 +
                  _skillTierBonus(skill) * 0.65 +
                  (_player.skills.vision - 60) * 0.0015 +
                  advantage * 0.35 -
                  defensivePressure * 0.9)
              .clamp(0.46, 0.95);
    } else if (action == 'keeper') {
      final opponentXg = widget.isHome ? _awayXgRemaining : _homeXgRemaining;
      final shotThreat = (opponentXg / 1.2).clamp(0.0, 1.0);
      chance = (0.88 + (skill - 70) * 0.003 + _skillTierBonus(skill) * 0.65 - shotThreat * 0.18).clamp(
        0.55,
        0.96,
      );
    } else if (action == 'dribble') {
      chance =
          (0.70 +
                  (_player.skills.dribbling - 60) * 0.0045 +
                  _skillTierBonus(skill) * 0.65 +
                  (_player.skills.pace - 60) * 0.0015 +
                  advantage * 0.4 -
                  defensivePressure)
              .clamp(0.42, 0.94);
    } else {
      chance = (0.66 + (skill - 60) * 0.0045 + _skillTierBonus(skill) + advantage * 0.4).clamp(
        0.38,
        0.92,
      );
    }
    // Во второй половине матча усталость постепенно снижает точность.
    // Высокая физическая подготовка помогает дольше сохранять качество действий.
    final matchProgress = ((_minute - 45).clamp(0, 45) / 45).toDouble();
    final fatiguePenalty =
        matchProgress * (0.105 - _player.skills.physical * 0.00075)
            .clamp(0.025, 0.075)
            .toDouble();
    final adjustedChance = (chance - fatiguePenalty).clamp(0.20, 0.98).toDouble();
    final success = _random.nextDouble() < adjustedChance;
    if (success) _successfulActions++;
    String message;

    if (action == 'shoot' ||
        action == 'longShot' ||
        action == 'header' ||
        action == 'volley') {
      _shots++;

      final isOneOnOne = _phase == 'oneOnOne' || _phase == 'keeperBeaten';
      final isAerial = _phase == 'aerialChance';

      final double baseFinishingChance;
      final double skillFinishingBonus;

      // Бонус за общий рейтинг игрока.
      final overallBonus = (_player.overall - 70) * 0.0015;

      if (action == 'header') {
        // Удар головой: основной бонус зависит от heading.
        baseFinishingChance = isAerial ? 0.27 : 0.22;

        skillFinishingBonus =
            (_player.skills.heading - 70) * 0.006 +
            (_player.skills.shooting - 70) * 0.0015 -
            defensivePressure * 0.35;
      } else if (action == 'longShot') {
        // Дальний удар.
        baseFinishingChance = 0.20;

        skillFinishingBonus = (_player.skills.shooting - 70) * 0.002;
      } else if (action == 'volley') {
        // Удар с лёта.
        baseFinishingChance = 0.20;

        skillFinishingBonus =
            (_player.skills.shooting - 70) * 0.002 +
            (_player.skills.heading - 70) * 0.001;
      } else {
        // Обычный удар.
        baseFinishingChance = isOneOnOne ? 0.43 : 0.37;

        skillFinishingBonus = (_player.skills.shooting - 70) * 0.0026667;
      }

      final finishingSkill = action == 'header'
          ? _player.skills.heading.toDouble()
          : _player.skills.shooting.toDouble();
      final finishingChance =
          (baseFinishingChance +
                  skillFinishingBonus +
                  overallBonus +
                  advantage * 0.35 +
                  _skillTierBonus(finishingSkill) * 0.45)
              .clamp(0.05, 0.85);

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
        action == 'backPass' ||
        action == 'longPass' ||
        action == 'throughPass' ||
        action == 'cross') {
      if (success) {
        _rating += action == 'backPass' ? 0.16 : 0.25;
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
        } else if (action == 'backPass') {
          _phase = 'midfield';
          message =
              'Вы сыграли назад. Команда сохранила владение и перестроила атаку.';
        } else if (_phase == 'midfield' ||
            _phase == 'midfieldBuildUp' ||
            _phase == 'buildUp') {
          _phase = action == 'throughPass' || action == 'longPass'
              ? 'chance'
              : 'finalThird';
          message = action == 'throughPass'
              ? 'Передача разрезала линию полузащиты. Атака выходит к штрафной.'
              : action == 'longPass'
              ? 'Длинная передача достигла партнёра. Команда быстро продвинулась вперёд.'
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
        final previousPhase = _phase;
        if (previousPhase == 'oneOnOne') {
          _phase = 'keeperBeaten';
        } else {
          _phase =
              previousPhase == 'midfield' ||
                  previousPhase == 'midfieldBuildUp' ||
                  previousPhase == 'buildUp'
              ? 'finalThird'
              : 'chance';
        }
        _rating += 0.25;
        message = _phase == 'keeperBeaten'
            ? 'Вы обыграли вратаря! Перед вами почти пустые ворота — можно завершить атаку.'
            : _phase == 'finalThird'
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

  void _recordEvent(String message) {
    final entry = "$_minute' · $message";
    if (_chronicle.isNotEmpty && _chronicle.first == entry) return;
    _chronicle.insert(0, entry);
    if (_chronicle.length > 6) _chronicle.removeLast();
  }

  void _advanceClock(String message) {
    _event = message;
    _recordEvent(message);
    _momentReady = false;
    if (_playerUnavailable) {
      _createMoment();
    } else {
      final isFollowUp =
          _phase == 'chance' ||
          _phase == 'aerialChance' ||
          _phase == 'finalThird' ||
          _phase == 'cutback' ||
          _phase == 'keeperBeaten' ||
          _phase == 'offBallRun';
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
      homePenalties: _homePenalties,
      awayPenalties: _awayPenalties,
    );
    Navigator.pop(context, match);
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF123D2A).withOpacity(0.68),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Match>(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF061B12),
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF174A32),
                      Color(0xFF0A2D20),
                      Color(0xFF04170F),
                    ],
                    stops: [0, 0.52, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4ADE80).withOpacity(0.08),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.09),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.13),
                            ),
                          ),
                          child: const Icon(
                            Icons.sports_soccer_rounded,
                            color: Color(0xFF9AE6B4),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 11),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'МАТЧ',
                                style: TextStyle(
                                  color: Color(0xFF9AB7A5),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_playerPlayed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14532D).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(
                                  0xFF4ADE80,
                                ).withOpacity(0.25),
                              ),
                            ),
                            child: Text(
                              'ОЦЕНКА ${_rating.clamp(4.0, 10.0).toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Color(0xFFBBF7D0),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _scoreboardGlass(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      color: Color(0xFF4ADE80),
                                      size: 8,
                                    ),
                                    const SizedBox(width: 7),
                                    const Text(
                                      'LIVE MATCH',
                                      style: TextStyle(
                                        color: Color(0xFF9AE6B4),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.6,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.09),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _finished ? 'ФИНАЛ' : '$_minute’',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _teamBadge(_homeTeam, true),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                      ),
                                      child: Text(
                                        '$_homeGoals : $_awayGoals',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: _teamBadge(_awayTeam, false),
                                    ),
                                  ],
                                ),
                                if (_homePenalties != null &&
                                    _awayPenalties != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'ПЕНАЛЬТИ  $_homePenalties : $_awayPenalties',
                                    style: const TextStyle(
                                      color: Color(0xFFBBF7D0),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 18),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: (_minute / 90).clamp(0.0, 1.0),
                                    minHeight: 5,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.10,
                                    ),
                                    valueColor: const AlwaysStoppedAnimation(
                                      Color(0xFF4ADE80),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _scoreboardGlass(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bolt_rounded,
                                      color: Color(0xFF86EFAC),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _momentReady && !_finished
                                          ? 'ИГРОВОЙ МОМЕНТ'
                                          : _finished
                                          ? 'МАТЧ ЗАВЕРШЁН'
                                          : 'ХРОНИКА МАТЧА',
                                      style: const TextStyle(
                                        color: Color(0xFF9AE6B4),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_momentReady && !_finished)
                                      Text(
                                        '$_minute’',
                                        style: const TextStyle(
                                          color: Color(0xFFBBF7D0),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _momentReady && !_finished
                                      ? _momentTitle
                                      : _finished
                                      ? 'Финальный свисток'
                                      : 'События',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _momentReady && !_finished
                                      ? _momentDescription
                                      : _event,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.78),
                                    fontSize: 13,
                                    height: 1.2,
                                  ),
                                ),
                                if (_chronicle.isNotEmpty) ...[
                                  const SizedBox(height: 9),
                                  ..._chronicle
                                      .take(2)
                                      .map(
                                        (entry) => Padding(
                                          padding: const EdgeInsets.only(
                                            top: 3,
                                          ),
                                          child: Text(
                                            entry,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 10,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (!_playerPlayed)
                            _glassCard(
                              child: const Text(
                                'Вы не попали в стартовый состав. Матч проходит без вашего участия.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  height: 1.2,
                                ),
                              ),
                            )
                          else if (_finished)
                            _buildMatchSummary()
                          else if (_momentReady) ...[
                            const Padding(
                              padding: EdgeInsets.fromLTRB(3, 2, 3, 10),
                              child: Text(
                                'ВАШЕ РЕШЕНИЕ',
                                style: TextStyle(
                                  color: Color(0xFF9AE6B4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ),
                            ..._positionActions(),
                          ] else
                            _glassCard(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.hourglass_bottom_rounded,
                                    color: Color(0xFF86EFAC),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Матч продолжается. Следующий игровой эпизод скоро...',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.72),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_finished || !_playerPlayed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 19),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _finish,
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text(
                            'Завершить матч',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4ADE80),
                            foregroundColor: const Color(0xFF052012),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreboardGlass({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.19),
                const Color(0xFF4ADE80).withOpacity(0.12),
                const Color(0xFF082B1C).withOpacity(0.58),
                Colors.white.withOpacity(0.07),
              ],
              stops: const [0, 0.32, 0.72, 1],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ADE80).withOpacity(0.16),
                blurRadius: 30,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.07),
                blurRadius: 2,
                spreadRadius: -1,
                offset: const Offset(-1, -1),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 12,
                right: 12,
                child: IgnorePointer(
                  child: Container(
                    height: 0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.42),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamBadge(String name, bool home) {
    final primaryColor = ClubColors.primary(name);
    final secondaryColor = ClubColors.secondary(name);
    final foregroundColor =
        ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Text(
            name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: foregroundColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        // const SizedBox(height: 3),
        // Text(
        //   home ? 'ХОЗЯЕВА' : 'ГОСТИ',
        //   style: TextStyle(
        //     color: Colors.white.withOpacity(0.45),
        //     fontSize: 8,
        //     letterSpacing: 1,
        //     fontWeight: FontWeight.w800,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildMatchSummary() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: const Color(0xFF123D2A).withOpacity(0.68),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  // Icon(
                  //   Icons.query_stats_rounded,
                  //   color: Color(0xFF86EFAC),
                  //   size: 19,
                  // ),
                  // SizedBox(width: 9),
                  Text(
                    'ВАША СТАТИСТИКА',
                    style: TextStyle(
                      color: Color(0xFF9AE6B4),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _summaryMetric('ГОЛЫ', '$_playerGoals')),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryMetric('АССИСТЫ', '$_playerAssists')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _summaryMetric(
                      'ОЦЕНКА',
                      _rating.clamp(4.0, 10.0).toStringAsFixed(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              _summaryRow('Удары', '$_shots'),
              _summaryRow('Успешные действия', '$_successfulActions'),
              _summaryRow('Жёлтые карточки', '$_yellowCards'),
              _summaryRow('Красные карточки', '$_redCards'),
              if (_homePenalties != null && _awayPenalties != null)
                _summaryRow('Пенальти', '$_homePenalties : $_awayPenalties'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF86EFAC),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.59),
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
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

  Widget _actionButton(String label, String action) {
    IconData icon;
    switch (action) {
      case 'shoot':
      case 'longShot':
      case 'header':
      case 'volley':
      case 'penaltyShoot':
        icon = Icons.sports_soccer_rounded;
        break;
      case 'pass':
      case 'backPass':
      case 'throughPass':
      case 'longPass':
      case 'cross':
        icon = Icons.compare_arrows_rounded;
        break;
      case 'dribble':
        icon = Icons.directions_run_rounded;
        break;
      case 'keeper':
      case 'block':
        icon = Icons.pan_tool_alt_rounded;
        break;
      case 'intercept':
      case 'defend':
      case 'tackle':
      case 'press':
        icon = Icons.shield_outlined;
        break;
      default:
        icon = Icons.flash_on_rounded;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.white.withOpacity(0.075),
            child: InkWell(
              onTap: () => _choose(action),
              borderRadius: BorderRadius.circular(17),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: const Color(0xFF86EFAC).withOpacity(0.16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 37,
                      height: 37,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80).withOpacity(0.13),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF86EFAC),
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Colors.white.withOpacity(0.42),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
