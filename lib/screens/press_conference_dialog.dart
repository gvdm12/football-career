import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class PressConferenceOption {
  final String text;
  final String detail;
  final int trustChange;
  final IconData icon;

  const PressConferenceOption({
    required this.text,
    required this.detail,
    required this.trustChange,
    required this.icon,
  });
}

class PressConferenceContent {
  final String question;
  final List<PressConferenceOption> options;
  final bool english;

  const PressConferenceContent({
    required this.question,
    required this.options,
    required this.english,
  });
}

class PressConferenceContentFactory {
  static final List<String> _recentQuestions = [];

  static PressConferenceContent create({
    required String category,
    required bool english,
  }) {
    String choose(String ru, String en) => english ? en : ru;
    final random = Random();

    final questions = switch (category) {
      'seasonStart' => [
        choose(
          'Какие задачи вы ставите перед собой на новый сезон?',
          'What goals have you set for the new season?',
        ),
        choose(
          'Чего болельщикам ждать от вас в этом году?',
          'What should the fans expect from you this year?',
        ),
        choose(
          'Готовы ли вы бороться за место в стартовом составе?',
          'Are you ready to fight for a starting place?',
        ),
      ],
      'seasonMiddle' => [
        choose(
          'Сезон уже прошёл наполовину. Довольны своим прогрессом?',
          'The season is halfway through. Are you happy with your progress?',
        ),
        choose(
          'Что сейчас важнее всего улучшить вашей команде?',
          'What is the most important thing for your team to improve?',
        ),
        choose(
          'Как оцениваете свою роль в команде на этом этапе?',
          'How do you assess your role in the team at this stage?',
        ),
      ],
      'seasonEnd' => [
        choose(
          'Сезон подходит к концу. Как оцените проделанную работу?',
          'The season is nearly over. How do you assess your work?',
        ),
        choose(
          'Какое главное впечатление оставил этот сезон?',
          'What is your biggest takeaway from this season?',
        ),
        choose(
          'Что хотите сказать болельщикам перед концом сезона?',
          'What would you like to tell the fans before the season ends?',
        ),
      ],
      'great' => [
        choose(
          'Вы провели отличный матч. В чём секрет такого выступления?',
          'You had a great match. What was the key to your performance?',
        ),
        choose(
          'Сегодня вы стали одним из героев встречи. Ваши эмоции?',
          'You were one of the stars today. How do you feel?',
        ),
        choose(
          'Можно ли назвать это вашим лучшим матчем в сезоне?',
          'Could this be your best performance of the season?',
        ),
      ],
      'poor' => [
        choose(
          'Вы провели слабый матч. Почему сегодня не получилось проявить себя?',
          'You had a poor match. Why could you not show your best today?',
        ),
        choose(
          'В чём главная причина поражения: тактика, настрой или исполнение?',
          'What caused the defeat: tactics, mentality or execution?',
        ),
        choose(
          'Можно ли сказать, что тренер ошибся с планом на игру?',
          'Did the coach get the game plan wrong?',
        ),
        choose(
          'Команда ждала от вас большего. Что помешало сыграть лучше?',
          'The team expected more from you. What stopped you performing better?',
        ),
        choose(
          'Какие оправдания можно найти этому результату — или их нет?',
          'Are there any excuses for this result, or are there none?',
        ),
      ],
      'losingStreak' => [
        choose(
          'Три поражения подряд. Кто должен взять ответственность за результаты?',
          'Three defeats in a row. Who must take responsibility for the results?',
        ),
        choose(
          'Команда переживает тяжёлую серию. В чём главная проблема?',
          'The team is going through a difficult run. What is the main problem?',
        ),
      ],
      'badRun' => [
        choose(
          'В последних матчах команда регулярно теряет очки. Что происходит?',
          'The team has been dropping points recently. What is happening?',
        ),
        choose(
          'Кажется, команда потеряла уверенность. Как это исправить?',
          'The team seems to have lost confidence. How can it be fixed?',
        ),
      ],
      'poorSeason' => [
        choose(
          'Сезон провален. В чём главная вина: игроков, тренера или руководства?',
          'The season has failed. Who is most responsible: players, coach or board?',
        ),
        choose(
          'Вы сами недовольны своей игрой. Почему не удалось показать лучший футбол?',
          'You are unhappy with your own season. Why could you not play better?',
        ),
        choose(
          'Тренерский штаб должен отвечать за этот провал?',
          'Should the coaching staff take responsibility for this failure?',
        ),
        choose(
          'Что вы скажете болельщикам, которые весь сезон ждали большего?',
          'What do you say to fans who expected much more this season?',
        ),
        choose(
          'Вы хотите играть в клубе, который регулярно борется за трофеи?',
          'Would you like to play for a club that regularly competes for trophies?',
        ),
      ],
      'elimination' => [
        choose(
          'Команда вылетела из турнира. Почему не удалось пройти дальше?',
          'Your team is out. Why could you not reach the next round?',
        ),
        choose(
          'Чего сегодня не хватило: характера, качества или правильной тактики?',
          'What was missing today: character, quality or the right tactics?',
        ),
        choose(
          'Можно ли винить тренера в таком вылете?',
          'Can the coach be blamed for this elimination?',
        ),
        choose(
          'Вы лично довольны тем, как проявили себя в этом турнире?',
          'Are you personally satisfied with your performances in this tournament?',
        ),
      ],
      'tournament' => [
        choose(
          'Впереди решающий этап турнира. Насколько верите в команду?',
          'A decisive stage of the tournament is ahead. How much do you believe in the team?',
        ),
        choose(
          'Соперник серьёзный. За счёт чего можно добиться успеха?',
          'The opponent is strong. What will it take to succeed?',
        ),
        choose(
          'Как команда должна подойти к следующему важному матчу?',
          'How should the team approach the next big match?',
        ),
      ],
      _ => [
        choose(
          'Как оцените сегодняшний матч и вклад команды?',
          'How do you assess today’s match and the team performance?',
        ),
        choose(
          'Что команда должна улучшить в ближайших матчах?',
          'What should the team improve in the coming matches?',
        ),
        choose(
          'Насколько важна поддержка болельщиков в такой момент?',
          'How important is the fans’ support at this moment?',
        ),
        choose(
          'Какой футбол вы хотели бы видеть от своей команды?',
          'What kind of football would you like your team to play?',
        ),
      ],
    };

    var options = switch (category) {
      'seasonStart' => [
        PressConferenceOption(
          text: choose(
            'Буду работать, чтобы закрепиться в составе',
            'I will work hard to earn my place',
          ),
          detail: choose(
            'Спокойный и профессиональный ответ',
            'Calm and professional',
          ),
          trustChange: 2,
          icon: Icons.fitness_center,
        ),
        PressConferenceOption(
          text: choose(
            'Хочу помочь команде бороться за трофеи',
            'I want to help the team win trophies',
          ),
          detail: choose('Командный настрой', 'Team-first attitude'),
          trustChange: 2,
          icon: Icons.emoji_events_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Главная цель — стабильная игра',
            'My main goal is consistency',
          ),
          detail: choose('Сдержанный ответ', 'Measured response'),
          trustChange: 1,
          icon: Icons.track_changes,
        ),
        PressConferenceOption(
          text: choose(
            'Пока не хочу давать обещаний',
            'I do not want to make promises yet',
          ),
          detail: choose('Осторожная позиция', 'Cautious approach'),
          trustChange: 0,
          icon: Icons.more_horiz,
        ),
      ],
      'seasonMiddle' => [
        PressConferenceOption(
          text: choose(
            'Доволен прогрессом, но могу больше',
            'I am happy with the progress, but I can do more',
          ),
          detail: choose('Позитивная оценка', 'Positive assessment'),
          trustChange: 2,
          icon: Icons.trending_up,
        ),
        PressConferenceOption(
          text: choose(
            'Нужно продолжать работать каждый день',
            'We must keep working every day',
          ),
          detail: choose('Профессиональный настрой', 'Professional attitude'),
          trustChange: 2,
          icon: Icons.fitness_center,
        ),
        PressConferenceOption(
          text: choose(
            'Хочу получать больше игрового времени',
            'I want more playing time',
          ),
          detail: choose('Прямое заявление', 'Direct statement'),
          trustChange: -1,
          icon: Icons.timer_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Сейчас важен только следующий матч',
            'Only the next match matters now',
          ),
          detail: choose('Фокус на результате', 'Focused on the result'),
          trustChange: 1,
          icon: Icons.sports_soccer,
        ),
      ],
      'seasonEnd' => [
        PressConferenceOption(
          text: choose(
            'Горжусь тем, чего добилась команда',
            'I am proud of what the team achieved',
          ),
          detail: choose('Командный ответ', 'Team-first response'),
          trustChange: 2,
          icon: Icons.groups_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Я стал опытнее и хочу прогрессировать дальше',
            'I have gained experience and want to keep improving',
          ),
          detail: choose('Взгляд в будущее', 'Looking ahead'),
          trustChange: 2,
          icon: Icons.trending_up,
        ),
        PressConferenceOption(
          text: choose(
            'Не всё получилось, но мы сделали выводы',
            'Not everything went well, but we learned from it',
          ),
          detail: choose('Честный ответ', 'Honest response'),
          trustChange: 1,
          icon: Icons.lightbulb_outline,
        ),
        PressConferenceOption(
          text: choose(
            'Личные цифры могли быть лучше',
            'My personal numbers could have been better',
          ),
          detail: choose('Самокритика', 'Self-critical response'),
          trustChange: 0,
          icon: Icons.analytics_outlined,
        ),
      ],
      'great' => [
        PressConferenceOption(
          text: choose(
            'Это результат работы всей команды',
            'This is the result of the whole team’s work',
          ),
          detail: choose(
            'Скромность и командный дух',
            'Humble and team-minded',
          ),
          trustChange: 2,
          icon: Icons.groups_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Я много тренировался ради таких матчей',
            'I have trained hard for matches like this',
          ),
          detail: choose(
            'Уверенность без лишних слов',
            'Confident but measured',
          ),
          trustChange: 1,
          icon: Icons.fitness_center,
        ),
        PressConferenceOption(
          text: choose(
            'Рад помочь клубу, но сезон ещё не окончен',
            'I am glad to help the club, but the season is not over',
          ),
          detail: choose(
            'Фокус на следующих играх',
            'Focused on what comes next',
          ),
          trustChange: 2,
          icon: Icons.flag_outlined,
        ),
        PressConferenceOption(
          text: choose('Сегодня всё получилось', 'Everything clicked today'),
          detail: choose(
            'Короткий уверенный ответ',
            'Short confident response',
          ),
          trustChange: 1,
          icon: Icons.bolt,
        ),
      ],
      'poor' => [
        PressConferenceOption(
          text: choose(
            'Я беру ответственность за свою игру',
            'I take responsibility for my performance',
          ),
          detail: choose('Ответственность', 'Taking responsibility'),
          trustChange: 2,
          icon: Icons.shield_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Разберём ошибки и станем сильнее',
            'We will review our mistakes and get stronger',
          ),
          detail: choose('Конструктивный настрой', 'Constructive attitude'),
          trustChange: 2,
          icon: Icons.build_outlined,
        ),
        PressConferenceOption(
          text: choose('Нам просто не повезло', 'We were simply unlucky'),
          detail: choose('Перекладывание причин', 'Deflecting responsibility'),
          trustChange: -1,
          icon: Icons.cloud_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Хочу как можно скорее исправить ситуацию',
            'I want to put things right as soon as possible',
          ),
          detail: choose('Настрой на реакцию', 'Determined response'),
          trustChange: 1,
          icon: Icons.refresh,
        ),
      ],
      'losingStreak' => [
        PressConferenceOption(
          text: choose(
            'Тренер должен пересмотреть тактику',
            'The coach must rethink the tactics',
          ),
          detail: choose(
            'Критика тренера: пресса может поддержать, но доверие тренера снизится',
            'Criticising the coach may appeal to the media but hurts the relationship',
          ),
          trustChange: -4,
          icon: Icons.warning_amber_rounded,
        ),
        PressConferenceOption(
          text: choose(
            'Каждый игрок должен отвечать за свою игру',
            'Every player must take responsibility',
          ),
          detail: choose(
            'Требовательный, но командный ответ',
            'Demanding but team-minded',
          ),
          trustChange: 2,
          icon: Icons.groups_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Нам не хватает характера в решающие моменты',
            'We lack character in decisive moments',
          ),
          detail: choose('Критика команды', 'Criticism of the team'),
          trustChange: -2,
          icon: Icons.bolt,
        ),
        PressConferenceOption(
          text: choose(
            'Я тоже должен играть лучше и вести команду за собой',
            'I must also play better and lead by example',
          ),
          detail: choose('Личная ответственность', 'Personal responsibility'),
          trustChange: 3,
          icon: Icons.shield_outlined,
        ),
      ],
      'badRun' => [
        PressConferenceOption(
          text: choose(
            'Тренерская схема не работает, нужны изменения',
            'The coach’s system is not working; changes are needed',
          ),
          detail: choose(
            'Резкая критика штаба',
            'Strong criticism of the staff',
          ),
          trustChange: -5,
          icon: Icons.warning_amber_rounded,
        ),
        PressConferenceOption(
          text: choose(
            'Команда должна прибавить, начиная с меня',
            'The team must improve, starting with me',
          ),
          detail: choose(
            'Берёте ответственность на себя',
            'You take responsibility',
          ),
          trustChange: 3,
          icon: Icons.shield_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Нам не хватает сыгранности',
            'We lack chemistry as a team',
          ),
          detail: choose(
            'Умеренная критика команды',
            'Measured criticism of the team',
          ),
          trustChange: -1,
          icon: Icons.groups_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Нужно спокойно разобрать ошибки и работать',
            'We need to review our mistakes and keep working',
          ),
          detail: choose('Конструктивный ответ', 'Constructive response'),
          trustChange: 2,
          icon: Icons.build_outlined,
        ),
      ],
      'poorSeason' => [
        PressConferenceOption(
          text: choose(
            'Ответственность лежит на тренере и его решениях',
            'The coach and his decisions are responsible',
          ),
          detail: choose(
            'Открытый конфликт с тренером',
            'Open conflict with the coach',
          ),
          trustChange: -7,
          icon: Icons.warning_amber_rounded,
        ),
        PressConferenceOption(
          text: choose(
            'Состав должен играть лучше, оправданий нет',
            'The squad must perform better; there are no excuses',
          ),
          detail: choose(
            'Жёсткая критика команды',
            'Harsh criticism of the team',
          ),
          trustChange: -3,
          icon: Icons.groups_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Виноваты все, и я в том числе',
            'Everyone is responsible, including me',
          ),
          detail: choose(
            'Честное признание общей ответственности',
            'Honest acceptance of shared responsibility',
          ),
          trustChange: 3,
          icon: Icons.handshake_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Нужно менять подход и исправлять ситуацию вместе',
            'We must change our approach and fix this together',
          ),
          detail: choose('Конструктивная позиция', 'Constructive approach'),
          trustChange: 2,
          icon: Icons.build_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Я хочу играть за клуб, который каждый сезон борется за трофеи',
            'I want to play for a club that fights for trophies every season',
          ),
          detail: choose(
            'Амбициозное заявление: тренер может воспринять это как сомнение в проекте клуба',
            'An ambitious statement that may be seen as doubt in the club project',
          ),
          trustChange: -3,
          icon: Icons.emoji_events_outlined,
        ),
      ],
      'elimination' => [
        PressConferenceOption(
          text: choose(
            'Мы все должны взять ответственность, включая меня',
            'We all must take responsibility, including me',
          ),
          detail: choose('Поддержка команды', 'Backing the team'),
          trustChange: 3,
          icon: Icons.groups_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Тренер должен объяснить выбранную тактику',
            'The coach must explain the chosen tactics',
          ),
          detail: choose('Публичная критика тренера', 'Public criticism of the coach'),
          trustChange: -5,
          icon: Icons.warning_amber_rounded,
        ),
        PressConferenceOption(
          text: choose(
            'Нам не хватило качества в решающие моменты',
            'We lacked quality in decisive moments',
          ),
          detail: choose('Критика командной игры', 'Criticism of team performance'),
          trustChange: -2,
          icon: Icons.groups_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Не ищу оправданий — мы должны были пройти дальше',
            'I will not make excuses — we should have gone through',
          ),
          detail: choose('Честная и требовательная позиция', 'Honest and demanding response'),
          trustChange: 2,
          icon: Icons.shield_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Я сделал всё, что мог, но команда подвела',
            'I did all I could, but the team let me down',
          ),
          detail: choose('Перекладывание ответственности на партнёров', 'Blaming teammates'),
          trustChange: -3,
          icon: Icons.person_outline,
        ),
      ],
      'tournament' => [
        PressConferenceOption(
          text: choose(
            'Мы верим в себя и идём за победой',
            'We believe in ourselves and are going for the win',
          ),
          detail: choose('Уверенность в команде', 'Belief in the team'),
          trustChange: 2,
          icon: Icons.emoji_events_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Нужно сохранять концентрацию до конца',
            'We must stay focused until the end',
          ),
          detail: choose('Зрелый подход', 'Mature approach'),
          trustChange: 2,
          icon: Icons.center_focus_strong,
        ),
        PressConferenceOption(
          text: choose(
            'Уважаем соперника, но не боимся его',
            'We respect the opponent, but we are not afraid',
          ),
          detail: choose('Уверенный ответ', 'Confident response'),
          trustChange: 1,
          icon: Icons.sports,
        ),
        PressConferenceOption(
          text: choose(
            'Пока рано говорить о результате',
            'It is too early to talk about the outcome',
          ),
          detail: choose('Осторожный прогноз', 'Cautious prediction'),
          trustChange: 0,
          icon: Icons.more_horiz,
        ),
      ],
      _ => [
        PressConferenceOption(
          text: choose(
            'Я всегда стараюсь приносить пользу команде',
            'I always try to contribute to the team',
          ),
          detail: choose('Командный настрой', 'Team-first attitude'),
          trustChange: 2,
          icon: Icons.groups_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Я хочу приносить команде ещё больше пользы',
            'I want to contribute even more to the team',
          ),
          detail: choose('Командный настрой', 'Team-first attitude'),
          trustChange: 2,
          icon: Icons.trending_up,
        ),
        PressConferenceOption(
          text: choose(
            'Я готов получать больше ответственности',
            'I am ready to take on more responsibility',
          ),
          detail: choose('Уверенное заявление', 'Confident statement'),
          trustChange: 1,
          icon: Icons.mic_none,
        ),
        PressConferenceOption(
          text: choose(
            'Решение о составе остаётся за тренером',
            'The coach makes the decisions about the line-up',
          ),
          detail: choose('Уважение к тренеру', 'Respect for the coach'),
          trustChange: 1,
          icon: Icons.handshake_outlined,
        ),
      ],
    };

    final availableQuestions = questions
        .where((question) => !_recentQuestions.contains(question))
        .toList();
    final pool = availableQuestions.isEmpty ? questions : availableQuestions;
    final selectedQuestion = pool[random.nextInt(pool.length)];
    _recentQuestions.add(selectedQuestion);
    if (_recentQuestions.length > 8) _recentQuestions.removeAt(0);

    final isFansSupportQuestion =
        selectedQuestion.contains('поддержка болельщиков') ||
        selectedQuestion.contains('fans’ support');

    if (isFansSupportQuestion) {
      options = [
        PressConferenceOption(
          text: choose(
            'Поддержка болельщиков даёт мне дополнительную мотивацию',
            'The fans’ support gives me extra motivation',
          ),
          detail: choose('Благодарность и связь с фанатами', 'Grateful and connected to the fans'),
          trustChange: 3,
          icon: Icons.favorite_outline,
        ),
        PressConferenceOption(
          text: choose(
            'Я всегда чувствую ответственность перед нашими болельщиками',
            'I always feel responsible to our supporters',
          ),
          detail: choose('Уважение к болельщикам', 'Respect for the supporters'),
          trustChange: 2,
          icon: Icons.groups_outlined,
        ),
        PressConferenceOption(
          text: choose(
            'Их поддержка важна, но на поле нужно сосредоточиться на игре',
            'Their support matters, but on the pitch I must focus on the game',
          ),
          detail: choose('Профессиональный и сдержанный ответ', 'Professional and measured response'),
          trustChange: 1,
          icon: Icons.sports_soccer,
        ),
        PressConferenceOption(
          text: choose(
            'Я стараюсь не обращать внимания на трибуны',
            'I try not to pay attention to the stands',
          ),
          detail: choose('Независимость от внешнего давления', 'Unaffected by outside pressure'),
          trustChange: 0,
          icon: Icons.hearing_disabled_outlined,
        ),
      ];
    }

    return PressConferenceContent(
      question: selectedQuestion,
      options: options,
      english: english,
    );
  }
}

class PressConferenceDialog {
  static const _accent = Color(0xFF8BE07F);
  static const _panel = Color(0xFF102B17);

  static Future<int?> show({
    required BuildContext context,
    required PressConferenceContent content,
    required String title,
    required String skipLabel,
  }) {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (dialogContext) => Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Colors.black.withValues(alpha: 0.12)),
            ),
          ),
          Center(
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF4B9A58),
                    width: 1.4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 17, 18, 15),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF174B25), Color(0xFF0D3218)],
                          ),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFF347644)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF245D31),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: const Color(0xFF68B875),
                                ),
                              ),
                              child: const Icon(
                                Icons.mic_none_rounded,
                                color: _accent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    content.english
                                        ? 'MEDIA ROOM  ·  POST-MATCH'
                                        : 'ПРЕСС-ЦЕНТР  ·  ПОСЛЕ МАТЧА',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.58,
                                      ),
                                      fontSize: 7,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // const Icon(
                            //   Icons.sports_soccer,
                            //   color: Color(0xFF70B77B),
                            //   size: 22,
                            // ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.format_quote_rounded,
                                  color: _accent,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  content.english
                                      ? 'JOURNALIST QUESTION'
                                      : 'ВОПРОС ЖУРНАЛИСТА',
                                  style: TextStyle(
                                    color: _accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A2110),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF315E39),
                                ),
                              ),
                              child: Text(
                                content.question,
                                style: const TextStyle(
                                  color: Color(0xFFF0F5F0),
                                  fontSize: 12,
                                  height: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // const Icon(
                                //   Icons.reply_rounded,
                                //   color: Color(0xFF9DB7A1),
                                //   size: 17,
                                // ),
                                const SizedBox(width: 6),
                                Text(
                                  content.english
                                      ? 'YOUR RESPONSE'
                                      : 'ВАШ ОТВЕТ',
                                  style: TextStyle(
                                    color: Color(0xFFB9CDBD),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...content.options.asMap().entries.map((entry) {
                              final index = entry.key;
                              final option = entry.value;
                              final accent = switch (index) {
                                0 => const Color(0xFF70B77B),
                                1 => const Color(0xFF76AFA4),
                                2 => const Color(0xFFC3A66B),
                                _ => const Color(0xFF8EAA91),
                              };
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(13),
                                    onTap: () => Navigator.pop(
                                      dialogContext,
                                      option.trustChange,
                                    ),
                                    child: Ink(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 11,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.075),
                                        borderRadius: BorderRadius.circular(13),
                                        border: Border.all(
                                          color: accent.withValues(alpha: 0.48),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 31,
                                            height: 31,
                                            decoration: BoxDecoration(
                                              color: accent.withValues(
                                                alpha: 0.16,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                            ),
                                            child: Icon(
                                              option.icon,
                                              color: accent,
                                              size: 17,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  option.text,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.25,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  option.detail,
                                                  style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 7),
                                          Text(
                                            option.trustChange > 0
                                                ? '+${option.trustChange}'
                                                : '${option.trustChange}',
                                            style: TextStyle(
                                              color: accent,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, 0),
                                // icon: const Icon(
                                //   Icons.chat_bubble_outline,
                                //   size: 15,
                                // ),
                                label: Text(skipLabel),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
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
            ),
          ),
        ],
      ),
    );
  }
}
