class RealClubPlayer {
  final String name;
  final int age;
  final int overall;
  final int jerseyNumber;

  const RealClubPlayer(this.name, this.age, this.overall, this.jerseyNumber);
}

class RealClubSquads {
  const RealClubSquads._();

  // Составы топ-клубов сезона 2026/27. Рейтинги адаптированы под игру.
  static const Map<String, Map<String, List<RealClubPlayer>>> squads = {
    'Real Madrid': {
      'goalkeeper': [RealClubPlayer('Тибо Куртуа', 34, 90, 1), RealClubPlayer('Андрей Лунин', 27, 83, 13)],
      'defender': [RealClubPlayer('Дин Хёйсен', 21, 84, 4), RealClubPlayer('Эдер Милитао', 28, 86, 3), RealClubPlayer('Трент Александер-Арнольд', 28, 87, 12), RealClubPlayer('Антонио Рюдигер', 33, 84, 22)],
      'midfielder': [RealClubPlayer('Джуд Беллингем', 23, 91, 5), RealClubPlayer('Федерико Вальверде', 28, 90, 8), RealClubPlayer('Эдуардо Камавинга', 23, 87, 6), RealClubPlayer('Орельен Тчуамени', 26, 86, 14)],
      'forward': [RealClubPlayer('Килиан Мбаппе', 27, 94, 10), RealClubPlayer('Винисиус Жуниор', 26, 92, 7), RealClubPlayer('Родриго', 25, 88, 11), RealClubPlayer('Эндрик', 20, 82, 9)],
    },
    'Barcelona': {
      'goalkeeper': [RealClubPlayer('Жоан Гарсия', 25, 86, 1), RealClubPlayer('Войцех Щенсны', 36, 82, 13)],
      'defender': [RealClubPlayer('Пау Кубарси', 19, 87, 5), RealClubPlayer('Жюль Кунде', 28, 87, 23), RealClubPlayer('Алехандро Бальде', 23, 85, 3), RealClubPlayer('Жоау Канселу', 32, 83, 2)],
      'midfielder': [RealClubPlayer('Педри', 23, 92, 8), RealClubPlayer('Гави', 22, 87, 6), RealClubPlayer('Фермин Лопес', 23, 86, 7), RealClubPlayer('Френки де Йонг', 29, 87, 21)],
      'forward': [RealClubPlayer('Ламин Ямаль', 19, 94, 10), RealClubPlayer('Рафинья', 29, 89, 11), RealClubPlayer('Карим Адейеми', 24, 86, 14), RealClubPlayer('Энтони Гордон', 25, 86, 17)],
    },
    'PSG': {
      'goalkeeper': [RealClubPlayer('Люка Шевалье', 25, 87, 30), RealClubPlayer('Матвей Сафонов', 27, 84, 39)],
      'defender': [RealClubPlayer('Ашраф Хакими', 27, 88, 2), RealClubPlayer('Маркиньос', 32, 87, 5), RealClubPlayer('Нуну Мендеш', 24, 89, 25), RealClubPlayer('Виллиан Пачо', 24, 87, 51)],
      'midfielder': [RealClubPlayer('Витинья', 26, 90, 17), RealClubPlayer('Жоау Невеш', 22, 89, 87), RealClubPlayer('Фабиан Руис', 30, 86, 8), RealClubPlayer('Уоррен Заир-Эмери', 20, 86, 33)],
      'forward': [RealClubPlayer('Усман Дембеле', 29, 91, 10), RealClubPlayer('Хвича Кварацхелия', 25, 90, 7), RealClubPlayer('Дезире Дуэ', 21, 88, 14), RealClubPlayer('Ферран Торрес', 26, 85, 9)],
    },
    'Liverpool': {
      'goalkeeper': [RealClubPlayer('Алиссон Бекер', 34, 90, 1), RealClubPlayer('Гиорги Мамардашвили', 26, 86, 25)],
      'defender': [RealClubPlayer('Вирджил ван Дейк', 35, 89, 4), RealClubPlayer('Жереми Жаке', 21, 83, 5), RealClubPlayer('Милош Керкез', 22, 85, 6), RealClubPlayer('Жереми Фримпонг', 25, 87, 30)],
      'midfielder': [RealClubPlayer('Флориан Вирц', 23, 91, 7), RealClubPlayer('Доминик Собослаи', 25, 88, 8), RealClubPlayer('Алексис Мак Аллистер', 27, 88, 10), RealClubPlayer('Райан Гравенберх', 24, 87, 38)],
      'forward': [RealClubPlayer('Александр Исак', 27, 90, 9), RealClubPlayer('Хьюго Экитике', 24, 87, 22), RealClubPlayer('Коди Гакпо', 27, 86, 18), RealClubPlayer('Брэдли Баркола', 24, 88, 29)],
    },
    'Manchester City': {
      'goalkeeper': [RealClubPlayer('Джанлуиджи Доннарумма', 27, 90, 1), RealClubPlayer('Херонимо Рульи', 34, 82, 28)],
      'defender': [RealClubPlayer('Рубен Диаш', 29, 89, 3), RealClubPlayer('Марк Гехи', 26, 86, 6), RealClubPlayer('Йошко Гвардиол', 24, 89, 24), RealClubPlayer('Раян Аит-Нури', 25, 85, 21)],
      'midfielder': [RealClubPlayer('Фил Фоден', 26, 90, 47), RealClubPlayer('Раян Шерки', 23, 88, 10), RealClubPlayer('Энцо Фернандес', 25, 87, 17), RealClubPlayer('Эллиот Андерсон', 23, 87, 5)],
      'forward': [RealClubPlayer('Эрлинг Холанд', 26, 94, 9), RealClubPlayer('Жереми Доку', 24, 87, 11), RealClubPlayer('Антуан Семеньо', 26, 87, 42), RealClubPlayer('Илиман Ндиайе', 26, 85, 7)],
    },
    'Bayern Munich': {
      'goalkeeper': [RealClubPlayer('Мануэль Нойер', 40, 86, 1), RealClubPlayer('Йонас Урбиг', 23, 82, 40)],
      'defender': [RealClubPlayer('Дайо Упамекано', 28, 87, 2), RealClubPlayer('Ким Мин Джэ', 30, 85, 3), RealClubPlayer('Джонатан Та', 30, 87, 4), RealClubPlayer('Альфонсо Дэвис', 25, 89, 19)],
      'midfielder': [RealClubPlayer('Йозуа Киммих', 31, 89, 6), RealClubPlayer('Джамал Мусиала', 23, 92, 10), RealClubPlayer('Александар Павлович', 22, 85, 45), RealClubPlayer('Том Бишоф', 21, 82, 8)],
      'forward': [RealClubPlayer('Гарри Кейн', 33, 92, 9), RealClubPlayer('Майкл Олисе', 24, 90, 17), RealClubPlayer('Луис Диас', 29, 89, 14), RealClubPlayer('Серж Гнабри', 31, 85, 7)],
    },
    'Arsenal': {
      'goalkeeper': [RealClubPlayer('Давид Райя', 31, 89, 1), RealClubPlayer('Кепа Аррисабалага', 32, 82, 13)],
      'defender': [RealClubPlayer('Уильям Салиба', 25, 90, 2), RealClubPlayer('Габриэл Магальяйнс', 28, 88, 6), RealClubPlayer('Юрриен Тимбер', 25, 87, 12), RealClubPlayer('Риккардо Калафьори', 24, 85, 33)],
      'midfielder': [RealClubPlayer('Деклан Райс', 27, 91, 41), RealClubPlayer('Мартин Эдегор', 27, 89, 8), RealClubPlayer('Мартин Субименди', 27, 87, 36), RealClubPlayer('Эберечи Эзе', 28, 86, 10)],
      'forward': [RealClubPlayer('Букайо Сака', 25, 91, 7), RealClubPlayer('Виктор Дьёкереш', 28, 89, 14), RealClubPlayer('Кай Хаверц', 27, 87, 29), RealClubPlayer('Нони Мадуэке', 24, 85, 20)],
    },
    'Atletico Madrid': {
      'goalkeeper': [RealClubPlayer('Ян Облак', 33, 89, 13), RealClubPlayer('Хуан Муссо', 32, 83, 1)],
      'defender': [RealClubPlayer('Давид Ханцко', 28, 86, 17), RealClubPlayer('Робен Ле Норман', 30, 85, 24), RealClubPlayer('Марк Пубиль', 23, 83, 18), RealClubPlayer('Маркос Льоренте', 31, 86, 14)],
      'midfielder': [RealClubPlayer('Пабло Барриос', 23, 87, 8), RealClubPlayer('Коке', 34, 84, 6), RealClubPlayer('Джонни Кардозо', 25, 85, 5), RealClubPlayer('Конор Галлахер', 26, 85, 4)],
      'forward': [RealClubPlayer('Хулиан Альварес', 26, 91, 19), RealClubPlayer('Александр Сёрлот', 30, 87, 9), RealClubPlayer('Адемола Лукман', 28, 87, 11), RealClubPlayer('Джонатан Дэвид', 26, 85, 15)],
    },
    'Inter': {
      'goalkeeper': [RealClubPlayer('Жозеп Мартинес', 28, 84, 1), RealClubPlayer('Иван Проведель', 32, 83, 49)],
      'defender': [RealClubPlayer('Алессандро Бастони', 27, 89, 95), RealClubPlayer('Джон Стоунз', 32, 86, 6), RealClubPlayer('Мануэль Аканжи', 31, 86, 25), RealClubPlayer('Федерико Димарко', 28, 88, 32)],
      'midfielder': [RealClubPlayer('Николо Барелла', 29, 90, 23), RealClubPlayer('Хакан Чалханоглу', 32, 88, 20), RealClubPlayer('Пётр Зелиньски', 32, 85, 7), RealClubPlayer('Петр Сучич', 23, 84, 8)],
      'forward': [RealClubPlayer('Лаутаро Мартинес', 29, 91, 10), RealClubPlayer('Маркус Тюрам', 29, 89, 9), RealClubPlayer('Анже-Йоан Бонни', 23, 84, 14), RealClubPlayer('Луис Энрике', 24, 84, 11)],
    },
    'Napoli': {
      'goalkeeper': [RealClubPlayer('Алекс Мерет', 29, 85, 1), RealClubPlayer('Ваня Милинкович-Савич', 29, 84, 32)],
      'defender': [RealClubPlayer('Бенуа Бадиашиле', 25, 84, 5), RealClubPlayer('Амир Ррахмани', 32, 85, 13), RealClubPlayer('Джованни Ди Лоренцо', 33, 86, 22), RealClubPlayer('Сэм Бёкема', 27, 84, 31)],
      'midfielder': [RealClubPlayer('Кевин Де Брёйне', 35, 88, 11), RealClubPlayer('Скотт Мактоминей', 29, 87, 8), RealClubPlayer('Станислав Лоботка', 31, 86, 68), RealClubPlayer('Билли Гилмор', 25, 83, 6)],
      'forward': [RealClubPlayer('Расмус Хёйлунн', 23, 87, 19), RealClubPlayer('Давид Нерес', 29, 85, 7), RealClubPlayer('Маттео Политано', 33, 84, 21), RealClubPlayer('Ноа Ланг', 27, 85, 70)],
    },
  };
}
