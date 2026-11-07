import 'package:flutter_football/models/player.dart';

/// Описание момента: заголовок и текст для карточки эпизода.
typedef MomentText = ({String title, String description});

/// Результат указания тренера.
typedef CoachInstructionEffect = ({
  double ownXg,
  double opponentXg,
  double rating,
  String message,
});

/// Баланс и реализм интерактивного матча.
///
/// Всё здесь не зависит от UI и от случайных чисел (случайность
/// передаётся параметрами), поэтому легко тестируется:
///  * поправка к шансу действия: сила соперника, форма и уровень игрока,
///    адаптивная сложность (матч не превращается ни в прогулку, ни в тупик);
///  * выбор эпизода с учётом счёта, минуты и расклада сил;
///  * поправка к итоговой оценке за результат команды;
///  * указания тренера во втором тайме.
class InteractiveMatchBalance {
  const InteractiveMatchBalance._();

  // ---------------------------------------------------------------------
  // Шанс действия
  // ---------------------------------------------------------------------

  /// Влияние качества соперника: сильный соперник мешает сильнее,
  /// чем слабый помогает, чтобы победа над аутсайдером оставалась работой.
  static double opponentQualityModifier({
    required int teamStrength,
    required int opponentStrength,
  }) {
    return ((teamStrength - opponentStrength) * 0.0025)
        .clamp(-0.08, 0.05)
        .toDouble();
  }

  /// Игрок сильнее своей команды берёт на себя больше, слабее — меньше.
  static double playerLevelModifier({
    required int playerOverall,
    required int teamStrength,
  }) {
    return ((playerOverall - teamStrength) * 0.002).clamp(-0.04, 0.04).toDouble();
  }

  /// Уверенность от текущей формы (средняя оценка последних матчей).
  static double formModifier(double? formRating) {
    return (((formRating ?? 6.5) - 6.5) * 0.02).clamp(-0.04, 0.04).toDouble();
  }

  /// Адаптивная сложность. После нескольких попыток успехи слишком
  /// частые слегка усложняют матч, слишком редкие слегка облегчают.
  static double adaptiveModifier({
    required int attempts,
    required int successes,
  }) {
    if (attempts < 4) return 0;
    final rate = successes / attempts;
    final weight = ((attempts - 3) / 6).clamp(0.0, 1.0).toDouble();
    return ((0.64 - rate) * 0.14 * weight).clamp(-0.05, 0.05).toDouble();
  }

  /// Итоговая поправка к шансу любого действия игрока.
  static double successModifier({
    required int teamStrength,
    required int opponentStrength,
    required int playerOverall,
    required double? formRating,
    required int attempts,
    required int successes,
  }) {
    final total =
        opponentQualityModifier(
          teamStrength: teamStrength,
          opponentStrength: opponentStrength,
        ) +
        playerLevelModifier(
          playerOverall: playerOverall,
          teamStrength: teamStrength,
        ) +
        formModifier(formRating) +
        adaptiveModifier(attempts: attempts, successes: successes);
    return total.clamp(-0.14, 0.10).toDouble();
  }

  // ---------------------------------------------------------------------
  // Выбор эпизода
  // ---------------------------------------------------------------------

  /// Вероятность того, что эпизод будет атакующим.
  static double attackProbability({
    required int teamStrength,
    required int opponentStrength,
    required int minute,
    required int goalDifference,
  }) {
    var value = (0.10 + (teamStrength - opponentStrength) * 0.006)
        .clamp(0.0, 0.30)
        .toDouble();
    if (minute >= 65 && goalDifference < 0) value += 0.15;
    if (minute >= 70 && goalDifference > 0) value -= 0.08;
    return value.clamp(0.0, 0.45).toDouble();
  }

  /// Вероятность того, что эпизод будет оборонительным.
  static double defenceProbability({
    required int teamStrength,
    required int opponentStrength,
    required int minute,
    required int goalDifference,
  }) {
    var value = (0.10 - (teamStrength - opponentStrength) * 0.006)
        .clamp(0.0, 0.30)
        .toDouble();
    if (minute >= 70 && goalDifference > 0) value += 0.15;
    if (minute >= 65 && goalDifference < 0) value -= 0.08;
    return value.clamp(0.0, 0.45).toDouble();
  }

  /// Эпизод, подсказанный ходом матча, или null, если нужно использовать
  /// обычный выбор по позиции.
  ///
  /// Возвращает только те фазы, которые экран уже умеет обрабатывать
  /// для данной позиции. [roll] и [variantRoll] — числа из диапазона 0..1.
  static String? pickContextPhase({
    required PlayerPosition position,
    required int teamStrength,
    required int opponentStrength,
    required int minute,
    required int goalDifference,
    required double roll,
    required double variantRoll,
  }) {
    if (position == PlayerPosition.goalkeeper) return null;

    final attack = attackProbability(
      teamStrength: teamStrength,
      opponentStrength: opponentStrength,
      minute: minute,
      goalDifference: goalDifference,
    );
    final defence = defenceProbability(
      teamStrength: teamStrength,
      opponentStrength: opponentStrength,
      minute: minute,
      goalDifference: goalDifference,
    );

    if (roll < attack) {
      return switch (position) {
        PlayerPosition.forward => variantRoll < 0.55 ? 'box' : 'wideAttack',
        PlayerPosition.midfielder =>
          minute >= 70 && goalDifference > 0 ? 'counterAttack' : 'finalThird',
        PlayerPosition.defender => 'overlapRun',
        PlayerPosition.goalkeeper => null,
      };
    }

    if (roll < attack + defence) {
      return switch (position) {
        PlayerPosition.forward => 'isolatedPress',
        PlayerPosition.midfielder => variantRoll < 0.6 ? 'defend' : 'pressingTrap',
        PlayerPosition.defender => variantRoll < 0.65 ? 'defend' : 'defensiveLine',
        PlayerPosition.goalkeeper => null,
      };
    }

    return null;
  }

  /// Текст карточки для фаз, которые возвращает [pickContextPhase].
  static MomentText? momentText(String phase, PlayerPosition position) {
    switch (phase) {
      case 'box':
        return (
          title: 'Открывание в штрафной',
          description:
              'Партнёр доставил мяч в штрафную. Защитник рядом, нужно завершить или продолжить комбинацию.',
        );
      case 'wideAttack':
        return (
          title: 'Атака по флангу',
          description:
              'Вы получили мяч у боковой линии вблизи штрафной. Можно обыграть защитника, прострелить или отдать назад.',
        );
      case 'finalThird':
        return (
          title: 'Продвижение к штрафной',
          description:
              'Вы получили мяч перед линией обороны соперника. Есть время оценить варианты и обострить атаку.',
        );
      case 'overlapRun':
        return (
          title: 'Подключение по внешнему флангу',
          description:
              'Партнёр сместился с мячом в центр, а вы свободны на фланге. Можно сделать рывок, получить передачу и прострелить.',
        );
      case 'counterAttack':
        return (
          title: 'Перехват и быстрый выход',
          description:
              'Вы выиграли мяч в центре, соперник ещё не успел перестроиться. Можно ускорить контратаку передачей или пройти вперёд самостоятельно.',
        );
      case 'isolatedPress':
        return (
          title: 'Выше всех линии атаки',
          description:
              'Команда потеряла мяч, а вы остались впереди. Можно начать давление на защитника или вернуться и помочь команде сохранить компактность.',
        );
      case 'pressingTrap':
        return (
          title: 'Выход из-под прессинга',
          description:
              'Соперник перекрыл центральные зоны и давит на мяч. Нужно найти свободного партнёра или обыграть первую линию давления.',
        );
      case 'defensiveLine':
        return (
          title: 'Страховка партнёра',
          description:
              'Партнёр по обороне выдвинулся на соперника, а за его спиной появилась зона. Нужно решить, подстраховать его или удержать линию.',
        );
      case 'defend':
        return position == PlayerPosition.defender
            ? (
                title: 'Оборона своей зоны',
                description:
                    'Соперник атакует вашу зону. Нужно выбрать позицию, момент для отбора или перехват передачи.',
              )
            : (
                title: 'Возврат в оборону',
                description:
                    'Соперник начинает атаку через центр. Можно перекрыть линию паса или вступить в отбор.',
              );
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Оценка за матч
  // ---------------------------------------------------------------------

  /// Поправка к оценке за результат команды.
  ///
  /// Учитывается результат относительно ожиданий (победа над сильным
  /// соперником ценнее, поражение от слабого обиднее), разница мячей,
  /// а для вратаря и защитников ещё и «сухой» матч или пропущенные голы.
  static double teamResultRatingAdjustment({
    required PlayerPosition position,
    required int goalsFor,
    required int goalsAgainst,
    required int teamStrength,
    required int opponentStrength,
  }) {
    final difference = goalsFor - goalsAgainst;
    final resultScore = difference > 0 ? 1.0 : (difference < 0 ? -1.0 : 0.0);
    final expected = ((teamStrength - opponentStrength) / 20).clamp(-1.0, 1.0);

    var value = 0.12 * resultScore;
    value += (resultScore - expected) * 0.10;
    value += difference.clamp(-3, 3) * 0.04;

    switch (position) {
      case PlayerPosition.goalkeeper:
        value += goalsAgainst == 0 ? 0.45 : -0.10 * (goalsAgainst - 1).clamp(0, 4);
        break;
      case PlayerPosition.defender:
        value += goalsAgainst == 0 ? 0.30 : -0.08 * (goalsAgainst - 1).clamp(0, 4);
        break;
      case PlayerPosition.midfielder:
        value += goalsAgainst == 0 ? 0.10 : 0.0;
        break;
      case PlayerPosition.forward:
        value += goalsFor == 0 ? -0.08 : 0.0;
        break;
    }

    return value.clamp(-0.7, 0.9).toDouble();
  }

  // ---------------------------------------------------------------------
  // Указание тренера
  // ---------------------------------------------------------------------

  /// Описание эпизода с указанием тренера в зависимости от счёта.
  static MomentText coachInstructionText(int goalDifference) {
    if (goalDifference < 0) {
      return (
        title: 'Указание тренера',
        description:
            'Вы проигрываете. Тренер кричит с бровки и просит команду решить, как действовать дальше: идти вперёд всеми силами или не рисковать.',
      );
    }
    if (goalDifference > 0) {
      return (
        title: 'Указание тренера',
        description:
            'Вы ведёте в счёте. Тренер ждёт сигнала от игроков: удержать результат или продолжать давить, чтобы закрыть игру.',
      );
    }
    return (
      title: 'Указание тренера',
      description:
          'Счёт равный. Тренер спрашивает, стоит ли усилить давление или играть осторожно, чтобы не пропустить.',
    );
  }

  /// Последствия выбранного указания: множители ожидаемых голов команды
  /// и соперника, поправка к оценке и сообщение.
  static CoachInstructionEffect coachInstructionEffect({
    required String action,
    required int goalDifference,
  }) {
    switch (action) {
      case 'instrPress':
        return (
          ownXg: 1.15,
          opponentXg: 1.10,
          rating: goalDifference < 0 ? 0.12 : (goalDifference > 0 ? -0.04 : 0.04),
          message:
              'Команда прибавляет в давлении и сжимает соперника. Атак станет больше, но за спиной появляется свободное место.',
        );
      case 'instrHold':
        return (
          ownXg: 0.90,
          opponentXg: 0.80,
          rating: goalDifference > 0 ? 0.12 : (goalDifference < 0 ? -0.06 : 0.0),
          message:
              'Команда отходит глубже и экономит силы. Соперник получает мяч, но ему сложнее найти свободное пространство.',
        );
      default:
        return (
          ownXg: 1.0,
          opponentXg: 1.0,
          rating: 0.0,
          message: 'Вы продолжаете играть в прежнем ритме.',
        );
    }
  }
}
