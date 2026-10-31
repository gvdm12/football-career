import 'language_service.dart';

class AppStrings {
  static bool get _en => LanguageService.isEnglish;
  static bool get isEnglish => _en;

  static String get settings => _en ? 'SETTINGS' : 'НАСТРОЙКИ';
  static String get game => _en ? 'GAME' : 'ИГРА';
  static String get language => _en ? 'Game language' : 'Язык игры';
  static String get sounds => _en ? 'Sound effects' : 'Звуки';
  static String get soundDescription =>
      _en ? 'Game sound effects' : 'Звуковые эффекты игры';
  static String get notifications => _en ? 'Notifications' : 'Уведомления';
  static String get notificationsDescription =>
      _en ? 'Game notifications' : 'Игровые уведомления';
  static String get about => _en ? 'ABOUT THE GAME' : 'ОБ ИГРЕ';
  static String get version => _en ? 'Version 1.0' : 'Версия 1.0';

  static String get startCareer =>
      _en ? 'Start your career' : 'Начни свою карьеру';
  static String get newCareer => _en ? 'NEW CAREER' : 'НОВОЕ НАЧАЛО';
  static String get continueCareer => _en ? 'CONTINUE' : 'ПРОДОЛЖИТЬ';
  static String get settingsTooltip => _en ? 'Settings' : 'Настройки';

  static String get noSavedCareer =>
      _en ? 'No saved career found' : 'Сохранённая карьера не найдена';

  static String loadCareerError(String error) => _en
      ? 'Could not load career: $error'
      : 'Не удалось загрузить карьеру: $error';

  static String get createPlayerTitle =>
      _en ? 'CREATE YOUR\nPLAYER' : 'СОЗДАЙ\nИГРОКА';

  static String get playerName => _en ? 'PLAYER NAME' : 'ИМЯ ИГРОКА';
  static String get enterName => _en ? 'Enter your name' : 'Введи имя';
  static String get position => _en ? 'POSITION' : 'ПОЗИЦИЯ';
  static String get nationality => _en ? 'NATIONALITY' : 'НАЦИОНАЛЬНОСТЬ';
  static String get startingClub => _en ? 'STARTING CLUB' : 'СТАРТОВЫЙ КЛУБ';
  static String get createCareer => _en ? 'CREATE CAREER' : 'СОЗДАТЬ КАРЬЕРУ';
  static String get newCareerTitle => _en ? 'NEW CAREER' : 'НОВАЯ КАРЬЕРА';

  static String get striker => _en ? 'Striker' : 'Нападающий';
  static String get midfielder => _en ? 'Midfielder' : 'Полузащитник';
  static String get defender => _en ? 'Defender' : 'Защитник';

  static String saveCareerError(String error) => _en
      ? 'Could not save career: $error'
      : 'Не удалось сохранить карьеру: $error';

  static String get leagueTable => _en ? 'LEAGUE TABLE' : 'ТАБЛИЦА';
  static String get team => _en ? 'TEAM' : 'КОМАНДА';
  static String get playedShort => _en ? 'P' : 'И';
  static String get goalDifferenceShort => _en ? 'GD' : 'РАЗН';
  static String get pointsShort => _en ? 'PTS' : 'ОЧК';

  static String get matchTitle => _en ? 'MATCH' : 'МАТЧ';
  static String get victory => _en ? 'VICTORY' : 'ПОБЕДА';
  static String get draw => _en ? 'DRAW' : 'НИЧЬЯ';
  static String get defeat => _en ? 'DEFEAT' : 'ПОРАЖЕНИЕ';
  static String get finishMatch => _en ? 'FINISH MATCH' : 'ЗАКОНЧИТЬ МАТЧ';

  static String get playerStatistics =>
      _en ? 'PLAYER STATISTICS' : 'СТАТИСТИКА ИГРОКА';
  static String get rating => _en ? 'Rating' : 'Оценка';
  static String get goals => _en ? 'Goals' : 'Голы';
  static String get assists => _en ? 'Assists' : 'Ассисты';
  static String get yellowCards => _en ? 'Yellow cards' : 'Жёлтые';
  static String get redCards => _en ? 'Red cards' : 'Красные';

  static String get afterMatch => _en ? 'AFTER THE MATCH' : 'ПОСЛЕ МАТЧА';
  static String get totalMatches => _en ? 'Total matches' : 'Всего матчей';
  static String get totalGoals => _en ? 'Total goals' : 'Всего голов';
  static String get totalAssists => _en ? 'Total assists' : 'Всего ассистов';

  // История карьеры
  static String get careerHistory => _en ? 'CAREER HISTORY' : 'ИСТОРИЯ КАРЬЕРЫ';
  static String get back => _en ? 'Back' : 'Назад';
  static String get careerStatistics =>
      _en ? 'CAREER STATISTICS' : 'СТАТИСТИКА КАРЬЕРЫ';
  static String get matches => _en ? 'Matches' : 'Матчи';
  static String get goalsLabel => _en ? 'Goals' : 'Голы';
  static String get assistsLabel => _en ? 'Assists' : 'Ассисты';
  static String get clubs => _en ? 'Clubs' : 'Клубы';
  static String get seasons => _en ? 'Seasons' : 'Сезоны';
  static String get bestSeason => _en ? 'Best season' : 'Лучший сезон';
  static String seasonNumber(int number) =>
      _en ? 'Season $number' : 'Сезон $number';
  static String goalsShort(int number) =>
      _en ? '$number goals' : '$number гол.';
  static String get completedSeasons =>
      _en ? 'COMPLETED SEASONS' : 'ЗАВЕРШЁННЫЕ СЕЗОНЫ';
  static String get noCompletedSeasons =>
      _en ? 'No completed seasons yet.' : 'Завершённых сезонов пока нет.';
  static String get goalsColon => _en ? 'Goals' : 'Голы';
  static String get assistsColon => _en ? 'Assists' : 'Ассисты';
  static String get yellowCardsColon => _en ? 'Yellow cards' : 'Жёлтые';
  static String get redCardsColon => _en ? 'Red cards' : 'Красные';
  static String get averageRating => _en ? 'Average rating' : 'Средний рейтинг';
  static String get seasonAchievements =>
      _en ? 'SEASON ACHIEVEMENTS' : 'ДОСТИЖЕНИЯ СЕЗОНА';
  static String get noAchievements =>
      _en ? 'No special achievements' : 'Особых достижений нет';

  // Экран игрока
  static String get myPlayer => _en ? 'MY PLAYER' : 'МОЙ ИГРОК';
  static String get ratingLabel => _en ? 'Rating' : 'Рейтинг';
  static String get pace => _en ? 'Pace' : 'Скорость';
  static String get physical => _en ? 'Physical' : 'Физика';
  static String get passing => _en ? 'Passing' : 'Пас';
  static String get shooting => _en ? 'Shooting' : 'Удар';
  static String get defending => _en ? 'Defending' : 'Защита';
  static String get dribbling => _en ? 'Dribbling' : 'Дриблинг';
  static String get heading => _en ? 'Heading' : 'Игра головой';
  static String get vision => _en ? 'Vision' : 'Видение';
  static String get careerStats =>
      _en ? 'CAREER STATISTICS' : 'СТАТИСТИКА ЗА КАРЬЕРУ';
  static String get matchesUpper => _en ? 'MATCHES' : 'МАТЧИ';
  static String get goalsUpper => _en ? 'GOALS' : 'ГОЛЫ';
  static String get assistsUpper => _en ? 'ASSISTS' : 'АССИСТЫ';
  static String get averageUpper => _en ? 'AVERAGE' : 'СРЕДНЯЯ';
  static String get yellowUpper => _en ? 'YELLOW' : 'ЖЁЛТЫЕ';
  static String get redUpper => _en ? 'RED' : 'КРАСНЫЕ';
  static String get careerAndFinances =>
      _en ? 'CAREER & FINANCES' : 'КАРЬЕРА И ФИНАНСЫ';
  static String get club => _en ? 'Club' : 'Клуб';
  static String get teamStatus => _en ? 'Team status' : 'Статус в команде';
  static String get coachTrust => _en ? 'Coach trust' : 'Доверие тренера';
  static String get coachMenu => _en ? 'Coach' : 'Тренер';
  static String get agentMenu => _en ? 'Agent' : 'Агент';
  static String get newsMenu => _en ? 'News' : 'Новости';
  static String get coachProfileTitle => _en ? 'COACH & REPUTATION' : 'ТРЕНЕР И РЕПУТАЦИЯ';
  static String get headCoach => _en ? 'Head coach' : 'Главный тренер';
  static String get playerReputation => _en ? 'Player reputation' : 'Репутация игрока';
  static String get careerAwards => _en ? 'Career awards' : 'Награды за карьеру';
  static String get squadRole => _en ? 'Squad role' : 'Роль в команде';
  static String get currentForm => _en ? 'Current form' : 'Текущая форма';
  static String get coachRelationship => _en ? 'Relationship with coach' : 'Отношения с тренером';
  static String get agentProfileTitle => _en ? 'YOUR AGENT' : 'ВАШ АГЕНТ';
  static String get currentContract => _en ? 'Current contract' : 'Текущий контракт';
  static String get monthlyWage => _en ? 'Monthly salary' : 'Зарплата в месяц';
  static String get interestedClubs => _en ? 'Interested clubs' : 'Заинтересованные клубы';
  static String get noInterestedClubs => _en ? 'No clubs are interested right now' : 'Сейчас нет заинтересованных клубов';
  static String get estimatedOffer => _en ? 'Estimated offer' : 'Предлагаемая зарплата';
  static String get agentFee => _en ? 'Agent development' : 'Развитие агента';
  static String get gameCurrency => _en ? 'Game currency' : 'Игровая валюта';
  static String get currencyEarned => _en ? 'Coins earned' : 'Получено монет';
  static String get currencyRewardsHint => _en
      ? 'Earn coins for appearances, goals, assists, strong ratings and season trophies.'
      : 'Монеты начисляются за участие в матчах, голы, ассисты, высокие оценки и трофеи сезона.';
  static String get agentDescription => _en ? 'A stronger agent can negotiate better wages and attract more clubs.' : 'Более опытный агент помогает договариваться о зарплате и привлекать интерес клубов.';
  static String get skipPressConference => _en ? 'Skip' : 'Пропустить';
  static String get pressConferenceSeasonStart => _en ? 'The season has started. What are your goals?' : 'Сезон начался. Какие у вас цели?';
  static String get pressConferenceSeasonMiddle => _en ? 'The season is reaching its midpoint. How do you assess your progress?' : 'Сезон достиг середины. Как оцените свои результаты?';
  static String get pressConferenceSeasonEnd => _en ? 'The season is ending. What would you like to say?' : 'Сезон подходит к концу. Что скажете болельщикам?';
  static String get pressConferenceGreatMatch => _en ? 'You had an outstanding match. How do you feel?' : 'Вы провели выдающийся матч. Какие ощущения?';
  static String get pressConferenceBadMatch => _en ? 'After a difficult match, how will you respond?' : 'После неудачного матча как собираетесь ответить?';
  static String get pressConferenceTournament => _en ? 'The tournament has reached an important moment. What is your reaction?' : 'Турнир подошёл к важному моменту. Как прокомментируете?';
  static String get pressConferenceSkipMessage => _en ? 'No comment' : 'Без комментариев';

  static String get positionRivals => _en ? 'POSITION COMPETITORS' : 'КОНКУРЕНТЫ ЗА ПОЗИЦИЮ';
  static String get agent => _en ? 'PLAYER AGENT' : 'ФУТБОЛЬНЫЙ АГЕНТ';
  static String agentLevel(int level) => _en ? 'Agent level $level' : 'Уровень агента: $level';
  static String get upgradeAgent => _en ? 'UPGRADE AGENT' : 'УЛУЧШИТЬ АГЕНТА';
  static String agentBonus(int percent) => _en ? '+$percent% to contract offers' : '+$percent% к зарплате в предложениях';
  static String get agentMaxLevel => _en ? 'Maximum agent level reached' : 'Достигнут максимальный уровень агента';
  static String get agentNotEnoughMoney => _en ? 'Not enough game currency for agent upgrade' : 'Недостаточно игровой валюты для улучшения агента';
  static String get pressConferenceTitle => _en ? 'PRESS CONFERENCE' : 'ПРЕСС-КОНФЕРЕНЦИЯ';
  static String get pressConferenceQuestion => _en
      ? 'Journalists ask how you assess the match and your role in the team.'
      : 'Журналисты спрашивают, как вы оцениваете матч и свою роль в команде.';
  static String get pressConferenceTeamFirst => _en
      ? 'The team result comes first'
      : 'Главное — результат команды';
  static String get pressConferenceConfident => _en
      ? 'I am ready to fight for my place'
      : 'Я готов бороться за своё место';
  static String get pressConferenceDemand => _en
      ? 'I deserve more playing time'
      : 'Я заслуживаю больше игрового времени';
  static String get rivalForm => _en ? 'Form' : 'Форма';
  static String get careerRecords => _en ? 'CAREER RECORDS' : 'РЕКОРДЫ КАРЬЕРЫ';
  static String get mostGoalsSeason => _en ? 'Most goals in a season' : 'Больше всего голов за сезон';
  static String get mostAssistsSeason => _en ? 'Most assists in a season' : 'Больше всего ассистов за сезон';
  static String get bestSeasonRating => _en ? 'Best season rating' : 'Лучшая оценка за сезон';
  static String get bestContributionSeason => _en ? 'Most goal contributions' : 'Больше всего гол+пас за сезон';
  static String get clubStrength => _en ? 'Club strength' : 'Сила клуба';
  static String get age => _en ? 'Age' : 'Возраст';
  static String get yearsOld => _en ? 'years old' : 'лет';
  static String get season => _en ? 'Season' : 'Сезон';
  static String get contract => _en ? 'Contract' : 'Контракт';
  static String get years => _en ? 'years' : 'лет';
  static String get monthlySalary =>
      _en ? 'Monthly salary' : 'Зарплата в месяц';
  static String get savings => _en ? 'Savings' : 'Накопления';
  static String get development =>
      _en ? 'PLAYER DEVELOPMENT' : 'РАЗВИТИЕ ИГРОКА';
  static String get footballNews => _en ? ' NEWS' : 'НОВОСТИ';
  static String get seasonButton => _en ? 'SEASON' : 'СЕЗОН';

  // Названия национальностей для отображения
  static String nationalityName(String nationality) {
    if (!_en) return nationality;

    const names = <String, String>{
      'Россия': 'Russia',
      'Бразилия': 'Brazil',
      'Германия': 'Germany',
      'Франция': 'France',
      'Испания': 'Spain',
      'Англия': 'England',
      'Италия': 'Italy',
      'Нидерланды': 'Netherlands',
      'Бельгия': 'Belgium',
      'Дания': 'Denmark',
      'Аргентина': 'Argentina',
      'Хорватия': 'Croatia',
      'Швейцария': 'Switzerland',
      'Австрия': 'Austria',
      'Норвегия': 'Norway',
      'Польша': 'Poland',
      'Турция': 'Turkey',
      'Украина': 'Ukraine',
      'Греция': 'Greece',
      'Шотландия': 'Scotland',
      'Ирландия': 'Ireland',
      'Колумбия': 'Colombia',
      'Чили': 'Chile',
      'Уругвай': 'Uruguay',
      'Канада': 'Canada',
      'Мексика': 'Mexico',
      'США': 'USA',
      'Иран': 'Iran',
      'Южная Корея': 'South Korea',
      'Япония': 'Japan',
      'Катар': 'Qatar',
      'Саудовская Аравия': 'Saudi Arabia',
      'Алжир': 'Algeria',
      'Марокко': 'Morocco',
      'Камерун': 'Cameroon',
      'Нигерия': 'Nigeria',
      'Сенегал': 'Senegal',
      'Египет': 'Egypt',
      'Тунис': 'Tunisia',
    };

    return names[nationality] ?? nationality;
  }

  // Экран сезона
  static String get seasonTitle => _en ? 'Season' : 'Сезон';
  static String get leagueTableTooltip => _en ? 'League table' : 'Таблица лиги';
  static String get saveCareerErrorPrefix =>
      _en ? 'Could not save career:' : 'Ошибка сохранения карьеры:';
  static String get matchCalendarError => _en
      ? 'Error: match result does not match the calendar.'
      : 'Ошибка: результат матча не совпадает с календарём.';
  static String get seasonStarted => _en ? 'Season' : 'Сезон';
  static String get seasonStartedSuffix => _en ? 'started!' : 'начался!';
  static String get yourClub => _en ? 'YOUR CLUB' : 'ТВОЙ КЛУБ';
  static String get seasonStats =>
      _en ? 'Season statistics' : 'Статистика сезона';
  static String get nextMatch => _en ? 'NEXT MATCH' : 'СЛЕДУЮЩИЙ МАТЧ';
  static String get home => _en ? 'Home' : 'Дома';
  static String get away => _en ? 'Away' : 'В гостях';
  static String get playMatch => _en ? 'PLAY MATCH' : 'ИГРАТЬ МАТЧ';
  static String get seasonCalendar =>
      _en ? 'Season calendar' : 'Календарь сезона';
  static String get matchesNotCreated =>
      _en ? 'Matches have not been created yet' : 'Матчи пока не созданы';
  static String get didNotPlay => _en ? 'Did not play' : 'Не сыграл';
  static String get finishSeason => _en ? 'FINISH SEASON' : 'ЗАВЕРШИТЬ СЕЗОН';
  static String get round => _en ? 'Round' : 'Тур';
  static String get matchesLabel => _en ? 'Matches' : 'Матчи';
  static String get goalsStat => _en ? 'Goals' : 'Голы';
  static String get assistsStat => _en ? 'Assists' : 'Ассисты';
  static String get yellowStat => _en ? 'Yellow cards' : 'Жёлтые';
  static String get redStat => _en ? 'Red cards' : 'Красные';
  static String get ratingStat => _en ? 'Rating' : 'Рейтинг';
  static String get ageLabel => _en ? 'Age' : 'Возраст';
  static String get playedAtHome => _en ? 'Home' : 'Дома';
  static String get playedAway => _en ? 'Away' : 'В гостях';
  // Transfer screen
  static String get transferTitle => _en ? 'TRANSFERS' : 'ТРАНСФЕРЫ';

  static String get otherClubOffers =>
      _en ? 'OFFERS FROM OTHER CLUBS' : 'ПРЕДЛОЖЕНИЯ ДРУГИХ КЛУБОВ';

  static String get refreshOffers =>
      _en ? 'REFRESH OFFERS' : 'ОБНОВИТЬ ПРЕДЛОЖЕНИЯ';

  static String get stayAtCurrentClub =>
      _en ? 'STAY AT CURRENT CLUB' : 'ОСТАТЬСЯ В ТЕКУЩЕМ КЛУБЕ';

  static String get expiredContractMessage => _en
      ? 'Your contract has expired. To continue your career, accept a contract extension or choose another club.'
      : 'Контракт истёк. Чтобы продолжить карьеру, прими предложение о продлении или выбери другой клуб.';

  static String get renewalContract =>
      _en ? 'CONTRACT EXTENSION' : 'ПРОДЛЕНИЕ КОНТРАКТА';

  static String get newContract => _en ? 'New contract' : 'Новый контракт';

  static String get salaryPerMonth => _en ? 'Salary' : 'Зарплата';

  static String get extendContract =>
      _en ? 'EXTEND CONTRACT' : 'ПРОДЛИТЬ КОНТРАКТ';

  static String get transferWindow =>
      _en ? 'TRANSFER WINDOW' : 'ТРАНСФЕРНОЕ ОКНО';

  static String get currentClubLabel => _en ? 'Current club' : 'Текущий клуб';

  static String get overallLabel => 'Overall';

  static String get contractRemaining =>
      _en ? 'Contract remaining' : 'Осталось по контракту';

  static String get clubStrengthLabel => _en ? 'Club strength' : 'Сила клуба';

  static String get contractLabel => _en ? 'Contract' : 'Контракт';

  static String get acceptTransferOffer =>
      _en ? 'ACCEPT OFFER' : 'ПРИНЯТЬ ПРЕДЛОЖЕНИЕ';

  static String get noTransferOffers => _en
      ? 'There are no offers in this transfer window.'
      : 'В этом трансферном окне предложений нет.';

  static String transferContractDuration(int years) {
    if (_en) return years == 1 ? '1 year' : '$years years';
    if (years == 1) return '1 год';
    if (years >= 2 && years <= 4) return '$years года';
    return '$years лет';
  }

  static String get careerEndTitle => _en ? 'Career Summary' : 'Итоги карьеры';

  static String get careerFinished =>
      _en ? 'CAREER COMPLETED' : 'КАРЬЕРА ЗАВЕРШЕНА';

  static String careerFinishedDescription(String name, int seasons) => _en
      ? '$name ended his professional career after $seasons seasons.'
      : '$name завершил профессиональный путь после $seasons сезонов.';

  static String get overallStatistics =>
      _en ? 'Overall Statistics' : 'Общая статистика';

  static String get yellowCardsLabel =>
      _en ? 'Yellow cards' : 'Жёлтые карточки';

  static String get redCardsLabel => _en ? 'Red cards' : 'Красные карточки';

  static String get earnedAndRemainingMoney =>
      _en ? 'Total earnings and remaining money' : 'Заработанные деньги';

  static String get clubsDuringCareer =>
      _en ? 'Clubs during career' : 'Клубы за карьеру';

  static String clubNumber(int number) => _en ? 'Club $number' : 'Клуб $number';

  static String get seasonHistory => _en ? 'Season History' : 'История сезонов';

  static String seasonSummaryTitle(int season, String club) =>
      _en ? 'Season $season · $club' : 'Сезон $season · $club';

  static String seasonSummaryStats(int matches, int goals, int assists) => _en
      ? '$matches matches, $goals goals, $assists assists'
      : '$matches матчей, $goals голов, $assists ассистов';

  static String get returnButton => _en ? 'RETURN' : 'ВЕРНУТЬСЯ';

  static String get clubLabel => _en ? 'Club' : 'Клуб';

  static String get developmentScreenTitle =>
      _en ? 'PLAYER DEVELOPMENT' : 'РАЗВИТИЕ';

  static String availableDevelopmentPoints(int points) =>
      _en ? 'Points: $points' : 'Доступно: $points';

  static String upgradeThreeSkills(int amount) =>
      _en ? '+$amount TO THREE SKILLS' : '+$amount К ТРЁМ НАВЫКАМ';

  static String chooseOneSkillFor(int bonus) => _en
      ? 'Or choose one skill for +$bonus'
      : 'Или выбери один навык для +$bonus';

  static String get doneButton => _en ? 'DONE' : 'ГОТОВО';

  static String get footballNewsTitle =>
      _en ? 'FOOTBALL NEWS' : 'ФУТБОЛЬНЫЕ НОВОСТИ';

  static String get careerNewsHeader =>
      _en ? 'Your career news' : 'Новости твоей карьеры';

  static String seasonNewsCount(int season, int count) => _en
      ? 'Season $season • Total news: $count'
      : 'Сезон $season • Всего новостей: $count';

  static String get matchNewsCategory => _en ? 'MATCH' : 'МАТЧ';

  static String get achievementNewsCategory =>
      _en ? 'ACHIEVEMENT' : 'ДОСТИЖЕНИЕ';

  static String get transferNewsCategory => _en ? 'TRANSFERS' : 'ТРАНСФЕРЫ';

  static String get contractNewsCategory => _en ? 'CONTRACT' : 'КОНТРАКТ';

  static String get seasonNewsCategory => _en ? 'SEASON' : 'СЕЗОН';

  static String newsSeasonAndMatch(int season, int matchNumber) {
    if (_en) {
      return 'Season $season'
          '${matchNumber > 0 ? ' • Match $matchNumber' : ''}';
    }

    return 'Сезон $season'
        '${matchNumber > 0 ? ' • Матч $matchNumber' : ''}';
  }

  static String get noNewsYet => _en ? 'No news yet' : 'Пока новостей нет';

  static String get firstMatchNewsHint => _en
      ? 'Play your first match — news about your performances will appear here.'
      : 'Сыграй матчи — здесь появятся новости о твоих выступлениях.';

  // Super League
  static String get progress => _en ? 'PROGRESS' : 'ПРОГРЕСС';
  static String get superLeague => _en ? 'SUPER LEAGUE' : 'СУПЕРЛИГА';
  static String get superLeagueName => _en ? 'Super League' : 'Суперлига';
  static String get superLeagueDescription => _en
      ? 'Choose one of 20 top clubs, create a player rated 75, and lead your team to the title. Ten seasons of competition await you.'
      : 'Выбери один из 20 топ-клубов, создай футболиста с рейтингом 75 и постарайся привести свою команду к чемпионству. Тебя ждут 10 сезонов борьбы за титулы.';
  static String get clubsUpper => _en ? 'CLUBS' : 'КЛУБОВ';
  static String get seasonsUpper => _en ? 'SEASONS' : 'СЕЗОНОВ';
  static String get overallUpper => _en ? 'RATING' : 'РЕЙТИНГ';
  static String get newGame => _en ? 'NEW GAME' : 'НОВАЯ ИГРА';
  static String get checkingSave =>
      _en ? 'CHECKING SAVE' : 'ПРОВЕРКА СОХРАНЕНИЯ';
  static String get noSave => _en ? 'NO SAVE FOUND' : 'НЕТ СОХРАНЕНИЯ';
  static String get chooseClub => _en ? 'Choose your club' : 'Выбери свой клуб';
  static String get chooseClubButton => _en ? 'SELECT CLUB' : 'ВЫБРАТЬ КЛУБ';
  static String get superLeagueSaveError => _en
      ? 'Could not load Super League save.'
      : 'Не удалось загрузить сохранение Суперлиги.';
  static String get superLeagueSaveCareerError => _en
      ? 'Could not save Super League career.'
      : 'Не удалось сохранить карьеру Суперлиги.';
  static String get saveMatchError => _en
      ? 'Could not save match result.'
      : 'Не удалось сохранить результат матча.';
  static String get saveSeasonError => _en
      ? 'Could not save the new season.'
      : 'Не удалось сохранить новый сезон.';
  static String get careerSummaryError => _en
      ? 'Could not create career summary.'
      : 'Не удалось сформировать итоги карьеры.';
  static String get calendarTitle =>
      _en ? 'SEASON CALENDAR' : 'КАЛЕНДАРЬ СЕЗОНА';
  static String seasonUpper(int number) =>
      _en ? 'SEASON $number' : 'СЕЗОН $number';
  static String seasonOfTen(int number) =>
      _en ? 'SEASON $number/10' : 'СЕЗОН $number/10';
  static String get homeMatchUpper => _en ? 'HOME' : 'ДОМА';
  static String get awayMatchUpper => _en ? 'AWAY' : 'В ГОСТЯХ';
  static String get playedStatus => _en ? 'PLAYED' : 'СЫГРАН';
  static String get pendingStatus => _en ? 'UPCOMING' : 'ОЖИДАЕТСЯ';
  static String get clubSelectionStrength =>
      _en ? 'CLUB STRENGTH' : 'СИЛА КЛУБА';
  static String clubStrengthValue(int value) =>
      _en ? 'Club strength: $value' : 'Сила клуба: $value';
  static String get playerCreation => _en ? 'CREATE PLAYER' : 'СОЗДАНИЕ ИГРОКА';
  static String get yourClubUpper => _en ? 'YOUR CLUB' : 'ТВОЙ КЛУБ';
  static String get footballerName => _en ? 'PLAYER NAME' : 'ИМЯ ФУТБОЛИСТА';
  static String get enterNameHint => _en ? 'Enter a name' : 'Введи имя';
  static String get countryUpper => _en ? 'COUNTRY' : 'СТРАНА';
  static String get goalkeeper => _en ? 'Goalkeeper' : 'Вратарь';
  static String get shots => _en ? 'Shooting' : 'Удары';
  static String get passes => _en ? 'Passing' : 'Пасы';
  static String get developmentPointsTitle =>
      _en ? 'DEVELOPMENT POINTS' : 'ОЧКИ РАЗВИТИЯ';
  static String get spendPointsHint => _en
      ? 'Spend points to improve skills'
      : 'Трать очки на улучшение навыков';
  static String get plannedUpgrades =>
      _en ? 'Planned upgrades' : 'Запланировано улучшений';
  static String get skillsUpper => _en ? 'SKILLS' : 'НАВЫКИ';
  static String applyUpgrades(int points) =>
      _en ? 'APPLY ($points PTS)' : 'ПРИМЕНИТЬ ($points ОЧК.)';
  static String get continueToTransfers =>
      _en ? 'CONTINUE TO TRANSFERS' : 'ПРОДОЛЖИТЬ К ТРАНСФЕРАМ';
  static String get decreaseUpgrade =>
      _en ? 'Decrease upgrade' : 'Уменьшить улучшение';
  static String get upgradeOnePoint =>
      _en ? 'Upgrade by 1 point' : 'Улучшить на 1 пункт';
  static String get transfersWindow =>
      _en ? 'TRANSFER WINDOW' : 'ТРАНСФЕРНОЕ ОКНО';
  static String currentClubUpper(String club) =>
      _en ? 'CURRENT CLUB: $club' : 'ТЕКУЩИЙ КЛУБ: $club';
  static String playerRatingAge(int rating, int age) =>
      _en ? 'RATING $rating • AGE $age' : 'РЕЙТИНГ $rating • ВОЗРАСТ $age';
  static String get clubOffers => _en ? 'CLUB OFFERS' : 'ПРЕДЛОЖЕНИЯ КЛУБОВ';
  static String stayAtClub(String club) =>
      _en ? 'STAY AT $club' : 'ОСТАТЬСЯ В $club';
  static String get strengthUpper => _en ? 'STRENGTH' : 'СИЛА';
  static String get noOffersYet =>
      _en ? 'No offers yet' : 'Пока нет предложений';
  static String get refreshClubOffers =>
      _en ? 'REFRESH OFFERS' : 'ОБНОВИТЬ ПРЕДЛОЖЕНИЯ';
  static String get superLeagueCareerFinished =>
      _en ? 'SUPER LEAGUE CAREER COMPLETED!' : 'КАРЬЕРА СУПЕРЛИГИ ЗАВЕРШЕНА!';
  static String superLeagueSeasonsComplete(String name) =>
      _en ? '$name completed all 10 seasons' : '$name прошёл все 10 сезонов';
  static String get superLeagueTrophies =>
      _en ? 'SUPER LEAGUE TROPHIES' : 'ТРОФЕИ СУПЕРЛИГИ';
  static String get seasonStatisticsUpper =>
      _en ? 'SEASON STATISTICS' : 'СТАТИСТИКА СЕЗОНА';
  static String get nextMatchUpper => _en ? 'NEXT MATCH' : 'СЛЕДУЮЩИЙ МАТЧ';
  static String get superLeagueChampion =>
      _en ? 'SUPER LEAGUE CHAMPION!' : 'ЧЕМПИОН СУПЕРЛИГИ!';
  static String get seasonCompleted =>
      _en ? 'Season completed!' : 'Сезон завершён!';
  static String get allTeamMatchesPlayed => _en
      ? 'All your team matches have been played.'
      : 'Все матчи твоей команды сыграны.';
  static String get nextSeasonUpper => _en ? 'NEXT SEASON' : 'СЛЕДУЮЩИЙ СЕЗОН';
  static String get superLeagueCareerCompleteMessage => _en
      ? 'Super League career completed! You have played all 10 seasons.'
      : 'Карьера Суперлиги завершена! Ты прошёл все 10 сезонов.';
  static String get viewCareerSummary =>
      _en ? 'VIEW CAREER SUMMARY' : 'ПОСМОТРЕТЬ ИТОГИ КАРЬЕРЫ';
  static String roundUpper(int round) => _en ? 'ROUND $round' : 'ТУР $round';
  static String get simulating => _en ? 'SIMULATING...' : 'СИМУЛЯЦИЯ...';
  static String get playMatchUpper => _en ? 'PLAY MATCH' : 'СЫГРАТЬ МАТЧ';
  static String get matchResultUpper =>
      _en ? 'MATCH RESULT' : 'РЕЗУЛЬТАТ МАТЧА';
  static String get goalsUpperLabel => _en ? 'GOALS' : 'ГОЛЫ';
  static String get assistsUpperLabel => _en ? 'ASSISTS' : 'АССИСТЫ';
  static String get ratingUpperLabel => _en ? 'RATING' : 'ОЦЕНКА';
  static String get superLeagueTableTitle => _en ? 'TABLE' : 'ТАБЛИЦА';
  static String get clubColumn => _en ? 'CLUB' : 'КЛУБ';
  static String get playedColumn => _en ? 'P' : 'И';
  static String get goalDifferenceColumn => _en ? 'GD' : 'РМ';
  static String get pointsColumn => _en ? 'PTS' : 'О';
  static String get leagueChampionTrophy =>
      _en ? 'League champion' : 'Чемпион лиги';
  static String get nationalCupTrophy => _en ? 'National cup' : 'Кубок страны';
  static String get championsLeagueTrophy =>
      _en ? 'Champions League' : 'Лига чемпионов';
  static String get europaLeagueTrophy =>
      _en ? 'Europa League' : 'Лига Европы';
  static String get goldenBootTrophy => _en ? 'Golden Boot' : 'Золотая бутса';
  static String get seasonTrophies => _en ? 'SEASON TROPHIES' : 'ТРОФЕИ СЕЗОНА';
  static String get noSeasonTrophies =>
      _en ? 'No trophies this season' : 'В этом сезоне трофеев нет';
  static String get finalStage => _en ? 'Final' : 'Финал';
  static String get firstLeg => _en ? 'First leg' : 'Первый матч';
  static String get secondLeg => _en ? 'Second leg' : 'Ответный матч';
  static String get roundOf16 => _en ? 'Round of 16' : '1/8 финала';
  static String get quarterFinal => _en ? 'Quarter-final' : 'Четвертьфинал';
  static String get semiFinal => _en ? 'Semi-final' : 'Полуфинал';
  static String get nationalCup => _en ? 'National Cup' : 'Кубок страны';
  static String get championsLeague =>
      _en ? 'Champions League' : 'Лига чемпионов';
  static String get europaLeague => _en ? 'Europa League' : 'Лига Европы';
  static String get winnerOfTournament =>
      _en ? 'Tournament winner: ' : 'Победитель турнира: ';
  static String get progressedToNextRound =>
      _en ? 'You advanced to the next round' : 'Вы прошли дальше';
  static String winnerAdvanced(String winner) =>
      _en ? '$winner advanced to the next round' : '$winner прошёл дальше';
  static String matchVenue(String venue, String opponent) =>
      _en ? '$venue: $opponent' : '$venue: $opponent';
  static String get expectedResult => _en ? 'Pending' : 'Ожидается';
  static String penaltiesResult(int home, int away) =>
      _en ? '(pens. $home:$away)' : '(пен. $home:$away)';
  static String get seasonTrophyTitle =>
      _en ? 'SEASON TROPHIES' : 'ТРОФЕИ СЕЗОНА';
  static String get noOffers => _en ? 'No offers available' : 'Предложений нет';
  static String get totalTrophies => _en ? 'Total trophies' : 'Всего трофеев';
  static String get nationalChampionships =>
      _en ? 'National championships' : 'Чемпионаты страны';
  static String get nationalCups => _en ? 'National cups' : 'Кубки страны';
  static String get careerClubs =>
      _en ? 'Clubs during career' : 'Клубы за карьеру';
  static String get averageSeasonRating =>
      _en ? 'Average rating' : 'Средняя оценка';
  static String get totalMatchesPlayed =>
      _en ? 'Matches played' : 'Сыграно матчей';
  static String get totalGoalsScored => _en ? 'Goals scored' : 'Забито голов';
  static String get totalAssistsMade => _en ? 'Assists' : 'Голевых передач';
  static String get trophiesDuringCareer =>
      _en ? '🏆 Career trophies' : '🏆 Трофеи за карьеру';
  static String get errorTitle => _en ? 'Error' : 'Ошибка';
  static String get languageRussian => _en ? 'Russian' : 'Русский';

  // Achievements and tournament labels. Keep stored achievement values in Russian
  // so existing saves and trophy counters remain compatible.
  static String achievementName(String value) {
    if (!_en) return value;
    const names = <String, String>{
      'Чемпион страны': 'National League Champion',
      'Чемпион лиги': 'League Champion',
      'Обладатель кубка страны': 'National Cup Winner',
      'кубок страны': 'National Cup Winner',
      'Победитель Лиги чемпионов': 'Champions League Winner',
      'Победитель Лиги Европы': 'Europa League Winner',
      'Лига Европы': 'Europa League',
      'Лига чемпионов': 'Champions League',
      'Золотая бутса': 'Golden Boot',
      'Лучший бомбардир': 'Top Scorer',
      'Лучший ассистент': 'Top Assister',
      'Лучший игрок сезона': 'Player of the Season',
      'Лучший молодой игрок сезона': 'Best Young Player',
      'В сборной сезона': 'Team of the Season',
      'Лучший ассистент': 'Top Assister',
    };
    return names[value] ?? value;
  }

  static String cupStageName(int round) {
    switch (round) {
      case 1:
        return _en ? 'Round of 16' : '1/8 финала';
      case 2:
        return _en ? 'Quarter-final' : 'Четвертьфинал';
      case 3:
        return _en ? 'Semi-final' : 'Полуфинал';
      case 4:
        return _en ? 'Final' : 'Финал';
      default:
        return nationalCup;
    }
  }

  static String get firstLegLabel => _en ? 'First leg' : 'Первый матч';
  static String get secondLegLabel => _en ? 'Second leg' : 'Ответный матч';
  static String get penaltiesShort => _en ? 'Pens.' : 'П:';
  static String get languageSection => _en ? 'LANGUAGE' : 'ЯЗЫК';
  static String get englishLanguage => 'English';
  static String get russianLanguage => 'Русский';
  static String get appAuthor =>
      _en ? 'App by Gadjiev M' : 'Автор приложения — Gadjiev M';

  static String tournamentStageName(String value) {
    if (!_en) return value;
    const names = <String, String>{
      '1/16 финала': 'Round of 32',
      '1/8 финала': 'Round of 16',
      '1/4 финала': 'Quarter-final',
      '1/2 финала': 'Semi-final',
      'Четвертьфинал': 'Quarter-final',
      'Полуфинал': 'Semi-final',
      'Финал': 'Final',
      'Завершён': 'Completed',
      'Турнир завершён': 'Tournament completed',
    };
    return names[value] ?? value;
  }

  static String get homeVenue => _en ? 'Home' : 'Дома';
  static String get awayVenue => _en ? 'Away' : 'В гостях';
  static String get pendingResult => _en ? 'Pending' : 'Ожидается';
  static String tournamentWinner(String winner) =>
      _en ? 'Tournament winner: $winner' : 'Победитель турнира: $winner';
  static String get advancedToNextRound =>
      _en ? 'You advanced to the next round' : 'Вы прошли дальше';
  static String winnerAdvancedToNextRound(String winner) =>
      _en ? '$winner advanced to the next round' : '$winner прошёл дальше';
}
