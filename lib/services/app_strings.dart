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
      _en ? 'Available points: $points' : 'Доступно очков: $points';

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
}
