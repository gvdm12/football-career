import 'dart:math';

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
  static PressConferenceContent create({
    required String category,
    required bool english,
  }) {
    String choose(String ru, String en) => english ? en : ru;
    final random = Random();

    final questions = switch (category) {
      'seasonStart' => [
          choose('Какие задачи вы ставите перед собой на новый сезон?',
              'What goals have you set for the new season?'),
          choose('Чего болельщикам ждать от вас в этом году?',
              'What should the fans expect from you this year?'),
          choose('Готовы ли вы бороться за место в стартовом составе?',
              'Are you ready to fight for a starting place?'),
        ],
      'seasonMiddle' => [
          choose('Сезон уже прошёл наполовину. Довольны своим прогрессом?',
              'The season is halfway through. Are you happy with your progress?'),
          choose('Что сейчас важнее всего улучшить вашей команде?',
              'What is the most important thing for your team to improve?'),
          choose('Как оцениваете свою роль в команде на этом этапе?',
              'How do you assess your role in the team at this stage?'),
        ],
      'seasonEnd' => [
          choose('Сезон подходит к концу. Как оцените проделанную работу?',
              'The season is nearly over. How do you assess your work?'),
          choose('Какое главное впечатление оставил этот сезон?',
              'What is your biggest takeaway from this season?'),
          choose('Что хотите сказать болельщикам перед концом сезона?',
              'What would you like to tell the fans before the season ends?'),
        ],
      'great' => [
          choose('Вы провели отличный матч. В чём секрет такого выступления?',
              'You had a great match. What was the key to your performance?'),
          choose('Сегодня вы стали одним из героев встречи. Ваши эмоции?',
              'You were one of the stars today. How do you feel?'),
          choose('Можно ли назвать это вашим лучшим матчем в сезоне?',
              'Could this be your best performance of the season?'),
        ],
      'poor' => [
          choose('Сегодня команде было непросто. Что пошло не так?',
              'It was a difficult match for the team. What went wrong?'),
          choose('Как собираетесь реагировать на неудачный результат?',
              'How will you respond to this disappointing result?'),
          choose('Что нужно изменить перед следующей игрой?',
              'What needs to change before the next match?'),
        ],
      'tournament' => [
          choose('Впереди решающий этап турнира. Насколько верите в команду?',
              'A decisive stage of the tournament is ahead. How much do you believe in the team?'),
          choose('Соперник серьёзный. За счёт чего можно добиться успеха?',
              'The opponent is strong. What will it take to succeed?'),
          choose('Как команда должна подойти к следующему важному матчу?',
              'How should the team approach the next big match?'),
        ],
      _ => [
          choose('Как оцените сегодняшний матч и свою роль в команде?',
              'How do you assess today’s match and your role in the team?'),
          choose('Журналисты спрашивают о конкуренции за место в составе. Что ответите?',
              'Journalists ask about the competition for a place in the team. What is your response?'),
          choose('Что для вас сейчас важнее: личные показатели или успех команды?',
              'What matters more right now: personal stats or team success?'),
        ],
    };

    final options = switch (category) {
      'seasonStart' => [
          PressConferenceOption(text: choose('Буду работать, чтобы закрепиться в составе', 'I will work hard to earn my place'), detail: choose('Спокойный и профессиональный ответ', 'Calm and professional'), trustChange: 2, icon: Icons.fitness_center),
          PressConferenceOption(text: choose('Хочу помочь команде бороться за трофеи', 'I want to help the team win trophies'), detail: choose('Командный настрой', 'Team-first attitude'), trustChange: 2, icon: Icons.emoji_events_outlined),
          PressConferenceOption(text: choose('Главная цель — стабильная игра', 'My main goal is consistency'), detail: choose('Сдержанный ответ', 'Measured response'), trustChange: 1, icon: Icons.track_changes),
          PressConferenceOption(text: choose('Пока не хочу давать обещаний', 'I do not want to make promises yet'), detail: choose('Осторожная позиция', 'Cautious approach'), trustChange: 0, icon: Icons.more_horiz),
        ],
      'seasonMiddle' => [
          PressConferenceOption(text: choose('Доволен прогрессом, но могу больше', 'I am happy with the progress, but I can do more'), detail: choose('Позитивная оценка', 'Positive assessment'), trustChange: 2, icon: Icons.trending_up),
          PressConferenceOption(text: choose('Нужно продолжать работать каждый день', 'We must keep working every day'), detail: choose('Профессиональный настрой', 'Professional attitude'), trustChange: 2, icon: Icons.fitness_center),
          PressConferenceOption(text: choose('Хочу получать больше игрового времени', 'I want more playing time'), detail: choose('Прямое заявление', 'Direct statement'), trustChange: -1, icon: Icons.timer_outlined),
          PressConferenceOption(text: choose('Сейчас важен только следующий матч', 'Only the next match matters now'), detail: choose('Фокус на результате', 'Focused on the result'), trustChange: 1, icon: Icons.sports_soccer),
        ],
      'seasonEnd' => [
          PressConferenceOption(text: choose('Горжусь тем, чего добилась команда', 'I am proud of what the team achieved'), detail: choose('Командный ответ', 'Team-first response'), trustChange: 2, icon: Icons.groups_outlined),
          PressConferenceOption(text: choose('Я стал опытнее и хочу прогрессировать дальше', 'I have gained experience and want to keep improving'), detail: choose('Взгляд в будущее', 'Looking ahead'), trustChange: 2, icon: Icons.trending_up),
          PressConferenceOption(text: choose('Не всё получилось, но мы сделали выводы', 'Not everything went well, but we learned from it'), detail: choose('Честный ответ', 'Honest response'), trustChange: 1, icon: Icons.lightbulb_outline),
          PressConferenceOption(text: choose('Личные цифры могли быть лучше', 'My personal numbers could have been better'), detail: choose('Самокритика', 'Self-critical response'), trustChange: 0, icon: Icons.analytics_outlined),
        ],
      'great' => [
          PressConferenceOption(text: choose('Это результат работы всей команды', 'This is the result of the whole team’s work'), detail: choose('Скромность и командный дух', 'Humble and team-minded'), trustChange: 2, icon: Icons.groups_outlined),
          PressConferenceOption(text: choose('Я много тренировался ради таких матчей', 'I have trained hard for matches like this'), detail: choose('Уверенность без лишних слов', 'Confident but measured'), trustChange: 1, icon: Icons.fitness_center),
          PressConferenceOption(text: choose('Рад помочь клубу, но сезон ещё не окончен', 'I am glad to help the club, but the season is not over'), detail: choose('Фокус на следующих играх', 'Focused on what comes next'), trustChange: 2, icon: Icons.flag_outlined),
          PressConferenceOption(text: choose('Сегодня всё получилось', 'Everything clicked today'), detail: choose('Короткий уверенный ответ', 'Short confident response'), trustChange: 1, icon: Icons.bolt),
        ],
      'poor' => [
          PressConferenceOption(text: choose('Я беру ответственность за свою игру', 'I take responsibility for my performance'), detail: choose('Ответственность', 'Taking responsibility'), trustChange: 2, icon: Icons.shield_outlined),
          PressConferenceOption(text: choose('Разберём ошибки и станем сильнее', 'We will review our mistakes and get stronger'), detail: choose('Конструктивный настрой', 'Constructive attitude'), trustChange: 2, icon: Icons.build_outlined),
          PressConferenceOption(text: choose('Нам просто не повезло', 'We were simply unlucky'), detail: choose('Перекладывание причин', 'Deflecting responsibility'), trustChange: -1, icon: Icons.cloud_outlined),
          PressConferenceOption(text: choose('Хочу как можно скорее исправить ситуацию', 'I want to put things right as soon as possible'), detail: choose('Настрой на реакцию', 'Determined response'), trustChange: 1, icon: Icons.refresh),
        ],
      'tournament' => [
          PressConferenceOption(text: choose('Мы верим в себя и идём за победой', 'We believe in ourselves and are going for the win'), detail: choose('Уверенность в команде', 'Belief in the team'), trustChange: 2, icon: Icons.emoji_events_outlined),
          PressConferenceOption(text: choose('Нужно сохранять концентрацию до конца', 'We must stay focused until the end'), detail: choose('Зрелый подход', 'Mature approach'), trustChange: 2, icon: Icons.center_focus_strong),
          PressConferenceOption(text: choose('Уважаем соперника, но не боимся его', 'We respect the opponent, but we are not afraid'), detail: choose('Уверенный ответ', 'Confident response'), trustChange: 1, icon: Icons.sports),
          PressConferenceOption(text: choose('Пока рано говорить о результате', 'It is too early to talk about the outcome'), detail: choose('Осторожный прогноз', 'Cautious prediction'), trustChange: 0, icon: Icons.more_horiz),
        ],
      _ => [
          PressConferenceOption(text: choose('Я всегда стараюсь приносить пользу команде', 'I always try to contribute to the team'), detail: choose('Командный настрой', 'Team-first attitude'), trustChange: 2, icon: Icons.groups_outlined),
          PressConferenceOption(text: choose('Конкуренция мотивирует меня становиться лучше', 'Competition motivates me to improve'), detail: choose('Позитивный настрой', 'Positive attitude'), trustChange: 2, icon: Icons.trending_up),
          PressConferenceOption(text: choose('Я готов получать больше ответственности', 'I am ready to take on more responsibility'), detail: choose('Уверенное заявление', 'Confident statement'), trustChange: 1, icon: Icons.mic_none),
          PressConferenceOption(text: choose('Решение о составе остаётся за тренером', 'The coach makes the decisions about the line-up'), detail: choose('Уважение к тренеру', 'Respect for the coach'), trustChange: 1, icon: Icons.handshake_outlined),
        ],
    };

    return PressConferenceContent(
      question: questions[random.nextInt(questions.length)],
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
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF4B9A58), width: 1.4),
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
                    border: Border(bottom: BorderSide(color: Color(0xFF347644))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF245D31),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: const Color(0xFF68B875)),
                        ),
                        child: const Icon(Icons.mic_none_rounded, color: _accent, size: 24),
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
                                color: Colors.white.withValues(alpha: 0.58),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.sports_soccer, color: Color(0xFF70B77B), size: 22),
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
                          const Icon(Icons.format_quote_rounded, color: _accent, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            content.english ? 'JOURNALIST QUESTION' : 'ВОПРОС ЖУРНАЛИСТА',
                            style: TextStyle(
                              color: _accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A2110),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF315E39)),
                        ),
                        child: Text(
                          content.question,
                          style: const TextStyle(
                            color: Color(0xFFF0F5F0),
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.reply_rounded, color: Color(0xFF9DB7A1), size: 17),
                          const SizedBox(width: 6),
                          Text(
                            content.english ? 'YOUR RESPONSE' : 'ВАШ ОТВЕТ',
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
                              onTap: () => Navigator.pop(dialogContext, option.trustChange),
                              child: Ink(
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.075),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(color: accent.withValues(alpha: 0.48)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 31,
                                      height: 31,
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Icon(option.icon, color: accent, size: 17),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                      option.trustChange > 0 ? '+${option.trustChange}' : '${option.trustChange}',
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: 11,
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
                          onPressed: () => Navigator.pop(dialogContext, 0),
                          icon: const Icon(Icons.chat_bubble_outline, size: 15),
                          label: Text(skipLabel),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white54,
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
    );
  }
}
