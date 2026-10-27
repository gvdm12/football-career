import 'package:flutter_football/models/career_news.dart';
import 'package:flutter_football/models/champions_league.dart';
import 'package:flutter_football/models/europa_league.dart';
import 'package:flutter_football/models/world_cup.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_match.dart';
import 'package:flutter_football/models/league_season_simulator.dart';
import 'domestic_cup.dart';
import 'player.dart';
import 'match.dart';
import 'season_match.dart';
import 'season_stats.dart';
import 'transfer_offer.dart';
import 'league_table.dart';

class Career {
  final Player player;
  final int season;
  final List<SeasonStats> history;
  final List<CareerNews> news;

  final int matches;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;
  final double? averageRating;

  final List<LeagueTableEntry> leagueTable;

  final int money;
  final int monthlySalary; // Зарплата в месяц, евро
  final int contractYears;
  final int developmentPoints;
  final bool isCareerFinished;
  final DomesticCup? domesticCup;
  final ChampionsLeague? championsLeague;
  final EuropaLeague? europaLeague;
  final WorldCup? worldCup;

  /// Все матчи чемпионата, включая матчи других клубов.
  final List<LeagueMatch> leagueMatches;

  /// Матчи клуба игрока в текущем сезоне.
  final List<SeasonMatch> seasonMatches;

  final Map<League, List<LeagueTableEntry>> europeanLeagueStandings;

  const Career({
    required this.player,
    required this.season,
    required this.matches,
    required this.goals,
    required this.assists,
    required this.yellowCards,
    required this.redCards,
    required this.averageRating,
    required this.money,
    required this.contractYears,
    required this.developmentPoints,
    required this.seasonMatches,
    required this.history,
    required this.leagueTable,
    required this.leagueMatches,
    this.news = const [],
    required this.monthlySalary,
    required this.isCareerFinished,
    this.domesticCup,
    required this.europeanLeagueStandings,
    this.championsLeague,
    this.europaLeague,
    this.worldCup,
  });

  // ============================================================
  // КАЛЕНДАРЬ ЧЕМПИОНАТА
  // ============================================================

  static List<LeagueMatch> _createLeagueMatches(String playerClub) {
    final league = Clubs.leagueOf(playerClub);

    if (league == null) {
      return [];
    }

    final clubs = Clubs.byLeague(league);

    return LeagueCalendar.generate(clubs);
  }

  /// Формирует календарь игрока из общего расписания лиги.
  static List<SeasonMatch> _createSeasonMatches(
    String playerClub,
    List<LeagueMatch> leagueMatches,
  ) {
    final fixtures =
        leagueMatches
            .where(
              (match) =>
                  match.homeTeam == playerClub || match.awayTeam == playerClub,
            )
            .toList()
          ..sort((a, b) => a.round.compareTo(b.round));

    if (fixtures.isNotEmpty) {
      return fixtures.map((fixture) {
        final isHome = fixture.homeTeam == playerClub;

        return SeasonMatch(
          number: fixture.round,
          opponent: isHome ? fixture.awayTeam : fixture.homeTeam,
          isHome: isHome,
          result: null,
        );
      }).toList();
    }

    // Запасной вариант для клуба, которого нет в списке лиг.
    return _createLegacySeasonMatches(playerClub);
  }

  /// Старый тестовый календарь на 10 матчей.
  static List<SeasonMatch> _createLegacySeasonMatches(String playerClub) {
    final opponents =
        Clubs.all.where((club) => club.name != playerClub).toList()..shuffle();

    final selected = opponents.take(10).toList();

    return List.generate(selected.length, (index) {
      return SeasonMatch(
        number: index + 1,
        opponent: selected[index].name,
        isHome: index.isEven,
      );
    });
  }

  static List<LeagueTableEntry> _createLeagueTable(
    String playerClub,
    List<SeasonMatch> seasonMatches,
  ) {
    final league = Clubs.leagueOf(playerClub);

    if (league != null) {
      final clubs = Clubs.byLeague(league);

      final opponents = clubs
          .where((club) => club.name != playerClub)
          .map((club) => club.name)
          .toList();

      return LeagueTable.create(playerClub, opponents);
    }

    final opponents = seasonMatches
        .map((match) => match.opponent)
        .toSet()
        .where((name) => name != playerClub)
        .toList();

    return LeagueTable.create(playerClub, opponents);
  }

  // ============================================================
  // НОВАЯ КАРЬЕРА
  // ============================================================

  static int _startingClubSalary(String clubName) {
    final club = Clubs.all.firstWhere(
      (club) => club.name == clubName,
      orElse: () => Clubs.all.first,
    );

    if (club.strength >= 80) return 15000;
    if (club.strength >= 75) return 10000;
    if (club.strength >= 70) return 7000;
    if (club.strength >= 65) return 5000;
    if (club.strength >= 60) return 3000;
    return 1500;
  }

  factory Career.create(Player player) {
    final leagueMatches = _createLeagueMatches(player.club);

    final seasonMatches = _createSeasonMatches(player.club, leagueMatches);

    final leagueTable = _createLeagueTable(player.club, seasonMatches);
    final startingSalary = _startingClubSalary(player.club);

    final clubLeague = Clubs.leagueOf(player.club);

    if (clubLeague == null) {
      throw StateError('Не удалось определить лигу клуба ${player.club}');
    }

    final cup = DomesticCup.create(
      league: clubLeague,
      season: 1,
      playerClub: player.club,
    );

    final europeanLeagueStandings = LeagueSeasonSimulator.simulateAll(
      season: 1,
    );

    final qualifiedClubs = LeagueSeasonSimulator.getQualifiedClubs(
      europeanLeagueStandings,
    );

    final championsLeague = ChampionsLeague.create(
      season: 1,
      participants: qualifiedClubs,
    );
    final europaLeague = EuropaLeague.create(
      season: 1,
      participants: LeagueSeasonSimulator.getEuropaLeagueClubs(
        europeanLeagueStandings,
      ),
    );

    return Career(
      player: player,
      season: 1,
      matches: 0,
      goals: 0,
      assists: 0,
      yellowCards: 0,
      redCards: 0,
      averageRating: null,
      money: 0,
      contractYears: 3,
      developmentPoints: 0,
      seasonMatches: seasonMatches,
      history: const [],
      leagueTable: leagueTable,
      leagueMatches: leagueMatches,
      monthlySalary: startingSalary,
      isCareerFinished: false,
      domesticCup: cup,
      europeanLeagueStandings: europeanLeagueStandings,
      championsLeague: championsLeague,
      europaLeague: europaLeague,
    );
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'player': player.toJson(),
      'season': season,
      'history': history.map((item) => item.toJson()).toList(),
      'matches': matches,
      'goals': goals,
      'assists': assists,
      'yellowCards': yellowCards,
      'redCards': redCards,
      'averageRating': averageRating,
      'leagueTable': leagueTable.map((item) => item.toJson()).toList(),
      'money': money,
      'contractYears': contractYears,
      'developmentPoints': developmentPoints,
      'seasonMatches': seasonMatches.map((item) => item.toJson()).toList(),
      'leagueMatches': leagueMatches.map((item) => item.toJson()).toList(),
      'news': news.map((item) => item.toJson()).toList(),
      'monthlySalary': monthlySalary,
      'isCareerFinished': isCareerFinished,
      'domesticCup': domesticCup?.toJson(),
      'europeanLeagueStandings': {
        for (final entry in europeanLeagueStandings.entries)
          entry.key.name: entry.value.map((club) => club.toJson()).toList(),
      },
      'championsLeague': championsLeague?.toJson(),
      'europaLeague': europaLeague?.toJson(),
      'worldCup': worldCup?.toJson(),
    };
  }

  factory Career.fromJson(Map<String, dynamic> json) {
    final rawPlayer = json['player'];

    if (rawPlayer is! Map) {
      throw const FormatException('В сохранении отсутствует игрок');
    }

    List<T> readList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final rawList = json[key];

      if (rawList is! List) {
        return <T>[];
      }

      return rawList
          .whereType<Map>()
          .map((item) => fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    final loadedPlayer = Player.fromJson(Map<String, dynamic>.from(rawPlayer));

    final savedLeagueMatches = readList('leagueMatches', LeagueMatch.fromJson);

    final leagueMatches = savedLeagueMatches.isNotEmpty
        ? savedLeagueMatches
        : _createLeagueMatches(loadedPlayer.club);

    // Сохраняем календарь и результаты старых карьер.
    // Если календаря игрока нет в сохранении, создаём его.
    final savedSeasonMatches = readList('seasonMatches', SeasonMatch.fromJson);

    final seasonMatches = savedSeasonMatches.isNotEmpty
        ? savedSeasonMatches
        : _createSeasonMatches(loadedPlayer.club, leagueMatches);

    final savedTable = readList('leagueTable', LeagueTableEntry.fromJson);

    final leagueTable = savedTable.isNotEmpty
        ? savedTable
        : _createLeagueTable(loadedPlayer.club, seasonMatches);

    final rawCup = json['domesticCup'];

    final DomesticCup? restoredCup;

    if (rawCup is Map) {
      restoredCup = DomesticCup.fromJson(Map<String, dynamic>.from(rawCup));
    } else {
      final clubLeague = Clubs.leagueOf(loadedPlayer.club);

      restoredCup = clubLeague == null
          ? null
          : DomesticCup.create(
              league: clubLeague,
              season: (json['season'] as num?)?.toInt() ?? 1,
              playerClub: loadedPlayer.club,
            );
    }

    final rawEuropeanStandings = json['europeanLeagueStandings'];

    final Map<League, List<LeagueTableEntry>> europeanLeagueStandings;

    if (rawEuropeanStandings is Map) {
      europeanLeagueStandings = {
        for (final entry in rawEuropeanStandings.entries)
          if (entry.key is String)
            for (final league in League.values)
              if (league.name == entry.key)
                league: (entry.value as List)
                    .whereType<Map>()
                    .map(
                      (item) => LeagueTableEntry.fromJson(
                        Map<String, dynamic>.from(item),
                      ),
                    )
                    .toList(),
      };
    } else {
      europeanLeagueStandings = LeagueSeasonSimulator.simulateAll(
        season: (json['season'] as num?)?.toInt() ?? 1,
      );
    }

    final rawChampionsLeague = json['championsLeague'];

    final championsLeague = rawChampionsLeague is Map
        ? ChampionsLeague.fromJson(
            Map<String, dynamic>.from(rawChampionsLeague),
          )
        : null;

    final rawEuropaLeague = json['europaLeague'];
    final rawWorldCup = json['worldCup'];
    final currentSeason = (json['season'] as num?)?.toInt() ?? 1;
    final europaStandings =
        LeagueSeasonSimulator.europaLeagueSlots.keys.every(
          europeanLeagueStandings.containsKey,
        )
        ? europeanLeagueStandings
        : LeagueSeasonSimulator.simulateAll(season: currentSeason);
    final europaLeague = rawEuropaLeague is Map
        ? EuropaLeague.fromJson(Map<String, dynamic>.from(rawEuropaLeague))
        : EuropaLeague.create(
            season: currentSeason,
            participants: LeagueSeasonSimulator.getEuropaLeagueClubs(
              europaStandings,
            ),
          );

    return Career(
      player: loadedPlayer,
      season: (json['season'] as num?)?.toInt() ?? 1,
      history: readList('history', SeasonStats.fromJson),
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      yellowCards: (json['yellowCards'] as num?)?.toInt() ?? 0,
      redCards: (json['redCards'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      leagueTable: leagueTable,
      money: (json['money'] as num?)?.toInt() ?? 0,
      contractYears: (json['contractYears'] as num?)?.toInt() ?? 0,
      developmentPoints: (json['developmentPoints'] as num?)?.toInt() ?? 0,
      seasonMatches: seasonMatches,
      leagueMatches: leagueMatches,
      news: readList('news', CareerNews.fromJson),
      monthlySalary: (json['monthlySalary'] as num?)?.toInt() ?? 0,
      isCareerFinished: json['isCareerFinished'] as bool? ?? false,
      domesticCup: restoredCup,
      europeanLeagueStandings: europeanLeagueStandings,
      championsLeague: championsLeague,
      europaLeague: europaLeague,
      worldCup: rawWorldCup is Map
          ? WorldCup.fromJson(Map<String, dynamic>.from(rawWorldCup))
          : null,
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  Career copyWith({
    Player? player,
    int? season,
    int? matches,
    int? goals,
    int? assists,
    int? yellowCards,
    int? redCards,
    double? averageRating,
    int? money,
    int? contractYears,
    int? developmentPoints,
    List<SeasonMatch>? seasonMatches,
    List<SeasonStats>? history,
    List<LeagueTableEntry>? leagueTable,
    List<LeagueMatch>? leagueMatches,
    List<CareerNews>? news,
    int? monthlySalary,
    bool? isCareerFinished,
    DomesticCup? domesticCup,
    Map<League, List<LeagueTableEntry>>? europeanLeagueStandings,
    ChampionsLeague? championsLeague,
    EuropaLeague? europaLeague,
    WorldCup? worldCup,
  }) {
    return Career(
      player: player ?? this.player,
      season: season ?? this.season,
      matches: matches ?? this.matches,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      yellowCards: yellowCards ?? this.yellowCards,
      redCards: redCards ?? this.redCards,
      averageRating: averageRating ?? this.averageRating,
      money: money ?? this.money,
      contractYears: contractYears ?? this.contractYears,
      developmentPoints: developmentPoints ?? this.developmentPoints,
      seasonMatches: seasonMatches ?? this.seasonMatches,
      history: history ?? this.history,
      leagueTable: leagueTable ?? this.leagueTable,
      leagueMatches: leagueMatches ?? this.leagueMatches,
      news: news ?? this.news,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      isCareerFinished: isCareerFinished ?? this.isCareerFinished,
      domesticCup: domesticCup ?? this.domesticCup,
      europeanLeagueStandings:
          europeanLeagueStandings ?? this.europeanLeagueStandings,
      championsLeague: championsLeague ?? this.championsLeague,
      europaLeague: europaLeague ?? this.europaLeague,
      worldCup: worldCup ?? this.worldCup,
    );
  }

  List<CareerNews> _generateMatchNews(Match match, {required int matchNumber}) {
    final result = <CareerNews>[];

    final goals = match.playerGoals;
    final assists = match.playerAssists;
    final rating = match.playerRating;

    String? title;
    String? description;

    // Выдающийся матч.
    if (rating >= 8.5 || goals >= 2 || goals + assists >= 3) {
      title = 'Выдающийся матч!';
      description =
          '${player.name} провёл отличный матч: '
          'оценка ${rating.toStringAsFixed(1)}, '
          'голы — $goals, ассисты — $assists.';
    }
    // Очень плохой матч.
    else if (rating <= 5.5) {
      title = 'Неудачное выступление';
      description =
          '${player.name} получил оценку '
          '${rating.toStringAsFixed(1)}. '
          'Игроку предстоит реабилитироваться в следующих матчах.';
    }
    // Краткая сводка после каждых пяти матчей.
    else if (matchNumber % 5 == 0) {
      title = 'Промежуточные итоги';
      description =
          'Сыгран $matchNumber-й матч сезона. '
          'Оценка в последней игре — ${rating.toStringAsFixed(1)}, '
          'голы — $goals, ассисты — $assists.';
    }

    // Если матч обычный, новость не создаём.
    if (title == null || description == null) {
      return result;
    }

    result.add(
      CareerNews(
        id: 's${season}_m${matchNumber}_${news.length}',
        season: season,
        matchNumber: matchNumber,
        title: title,
        description: description,
        type: CareerNewsType.match,
      ),
    );

    return result;
  }

  // ============================================================
  // ЗАВЕРШЕНИЕ МАТЧА
  // ============================================================

  Career afterMatch(Match match) {
    // Команда сыграла, но игрок не участвовал.
    // Личная статистика игрока не меняется.
    if (!match.playerPlayed) {
      return this;
    }

    final newMatches = matches + 1;

    final seasonMatchNumber =
        seasonMatches.where((item) => item.isPlayed).length + 1;

    final matchNews = _generateMatchNews(match, matchNumber: seasonMatchNumber);

    final newGoals = goals + match.playerGoals;
    final newAssists = assists + match.playerAssists;
    final newYellowCards = yellowCards + match.yellowCards;
    final newRedCards = redCards + match.redCards;

    final double newAverageRating;

    if (averageRating == null || matches == 0) {
      newAverageRating = match.playerRating;
    } else {
      newAverageRating =
          ((averageRating! * matches) + match.playerRating) / newMatches;
    }

    return copyWith(
      matches: newMatches,
      goals: newGoals,
      assists: newAssists,
      yellowCards: newYellowCards,
      redCards: newRedCards,
      averageRating: double.parse(newAverageRating.toStringAsFixed(2)),
      news: [...news, ...matchNews],
    );
  }

  // ============================================================
  // ТРАНСФЕР
  // ============================================================

  Career acceptTransfer(TransferOffer offer) {
    final newPlayer = player.copyWith(club: offer.club.name);

    return copyWith(
      player: newPlayer,
      monthlySalary: offer.salary,
      contractYears: offer.contractYears,
    );
  }

  /// Сохраняет статистику завершённого сезона.
  /// Автоматический бонус начисляется только один раз.

  Career archiveCurrentSeason() {
    final alreadyArchived = history.any((stats) => stats.season == season);

    if (alreadyArchived) {
      return this;
    }

    final achievements = <String>[];

    // Индивидуальные достижения игрока.
    if (matches >= 5 && goals >= 25) {
      achievements.add('Бомбардир сезона');
    }

    if (matches >= 5 && assists >= 10) {
      achievements.add('Мастер передач');
    }

    if (matches >= 5 && yellowCards <= 2 && redCards == 0) {
      achievements.add('Честная игра');
    }

    if (matches >= 5 &&
        goals >= 5 &&
        history.every((stats) => stats.goals < goals)) {
      achievements.add('Лучший сезон по голам');
    }

    if (matches >= 5 && goals + assists >= 20) {
      achievements.add('Голевой сезон');
    }

    if (matches >= 5 && averageRating != null && averageRating! >= 7.5) {
      achievements.add('Высокий уровень игры');
    }

    // Чемпион страны.
    final table = leagueTable;

    if (table.isNotEmpty) {
      final sortedEntries = [...table]
        ..sort((a, b) {
          final pointsComparison = b.points.compareTo(a.points);

          if (pointsComparison != 0) {
            return pointsComparison;
          }

          return b.goalDifference.compareTo(a.goalDifference);
        });

      if (sortedEntries.first.club == player.club) {
        achievements.add('Чемпион страны');
      }
    }

    // Победитель кубка страны.
    final cup = domesticCup;
    if (cup != null && cup.isFinished && cup.champion == player.club) {
      achievements.add('Обладатель кубка страны');
    }

    final championsLeague = this.championsLeague;

    if (championsLeague != null &&
        championsLeague.stage == ChampionsLeagueStage.completed &&
        championsLeague.champion == player.club) {
      achievements.add('Победитель Лиги чемпионов');
    }

    final europaLeague = this.europaLeague;
    if (europaLeague != null &&
        europaLeague.stage == EuropaLeagueStage.completed &&
        europaLeague.champion == player.club) {
      achievements.add('Победитель Лиги Европы');
    }

    final worldCup = this.worldCup;
    if (worldCup != null &&
        worldCup.isCompleted &&
        worldCup.isPlayerCalledUp &&
        worldCup.champion == player.nationality) {
      achievements.add('Чемпион мира');
    } else if (worldCup != null &&
        worldCup.isCompleted &&
        worldCup.isPlayerCalledUp &&
        worldCup.matches.isNotEmpty &&
        worldCup.matches.first.winner != player.nationality &&
        (worldCup.matches.first.homeTeam == player.nationality ||
            worldCup.matches.first.awayTeam == player.nationality)) {
      achievements.add('Финалист чемпионата мира');
    }

    final league = Clubs.leagueOf(player.club);

    if (league != null && goals >= league.goldenBootGoalThreshold) {
      achievements.add('Золотая бутса');
    }

    // В итогах сезона объединяем клубную статистику и личные показатели
    // игрока за сборную. Поля Career.matches/goals/assists остаются клубными,
    // чтобы матчи сборной не влияли на таблицу лиги и клубное развитие.
    final worldCupStats =
        worldCup != null &&
            worldCup.season == season &&
            worldCup.isPlayerCalledUp
        ? worldCup
        : null;
    final nationalMatches = worldCupStats?.playerMatches ?? 0;
    final nationalGoals = worldCupStats?.playerGoals ?? 0;
    final nationalAssists = worldCupStats?.playerAssists ?? 0;
    final totalSeasonMatches = matches + nationalMatches;
    final totalSeasonGoals = goals + nationalGoals;
    final totalSeasonAssists = assists + nationalAssists;
    final totalSeasonRating = totalSeasonMatches == 0
        ? null
        : ((averageRating ?? 0) * matches +
                  (worldCupStats?.playerAverageRating ?? 0) * nationalMatches) /
              totalSeasonMatches;

    final seasonStats = SeasonStats(
      season: season,
      club: player.club,
      matches: totalSeasonMatches,
      goals: totalSeasonGoals,
      assists: totalSeasonAssists,
      yellowCards: yellowCards,
      redCards: redCards,
      averageRating: totalSeasonRating == null
          ? null
          : double.parse(totalSeasonRating.toStringAsFixed(2)),
      achievements: achievements,
    );

    final pointsToAdd = season <= 4
        ? 3
        : season <= 12
        ? 6
        : 3;

    var updatedCareer = copyWith(
      history: [...history, seasonStats],
      developmentPoints: pointsToAdd,
    );
    // Развитие навыков только со 2-го по 13-й сезон
    // и при достаточном количестве матчей.
    if (matches < 5 || season > 13) {
      return updatedCareer;
    }

    final rating = averageRating ?? 0.0;
    final contributions = goals + assists;

    // Базовый бонус: +1 к одному профильному навыку.
    // Сильный сезон может дать ещё один бонус.
    final isGoodSeason = rating >= 7.0;
    final isExcellentSeason =
        rating >= 7.5 && (contributions >= 15 || matches >= 8);

    final bonuses = <SkillName, int>{};

    void addBonus(SkillName skill, int amount) {
      bonuses[skill] = (bonuses[skill] ?? 0) + amount;
    }

    switch (player.position) {
      case PlayerPosition.forward:
        if (goals >= 15) {
          addBonus(SkillName.shooting, 1);
        }

        if (goals >= 34) {
          addBonus(SkillName.shooting, 1);
        }

        if (assists >= 14 || contributions >= 20) {
          addBonus(SkillName.dribbling, 1);
        }

        if (isGoodSeason && goals >= 14) {
          addBonus(SkillName.pace, 1);
        }

        if (isExcellentSeason && goals >= 10) {
          addBonus(SkillName.physical, 1);
        }
        break;

      case PlayerPosition.midfielder:
        if (assists >= 15) {
          addBonus(SkillName.passing, 1);
        }

        if (assists >= 30) {
          addBonus(SkillName.passing, 1);
        }

        if (contributions >= 15) {
          addBonus(SkillName.dribbling, 1);
        }

        if (isGoodSeason) {
          addBonus(SkillName.physical, 1);
        }

        if (isExcellentSeason && goals >= 15) {
          addBonus(SkillName.shooting, 1);
        }

        if (isExcellentSeason && assists >= 12) {
          addBonus(SkillName.pace, 1);
        }
        break;

      case PlayerPosition.defender:
        if (matches >= 25) {
          addBonus(SkillName.defending, 1);
        }

        if (rating >= 7.0) {
          addBonus(SkillName.physical, 1);
        }

        if (isExcellentSeason) {
          addBonus(SkillName.passing, 1);
        }

        if (isExcellentSeason && assists >= 3) {
          addBonus(SkillName.dribbling, 1);
        }

        if (isExcellentSeason && goals >= 3) {
          addBonus(SkillName.shooting, 1);
        }
        break;

      case PlayerPosition.goalkeeper:
        if (matches >= 8) {
          addBonus(SkillName.defending, 1);
        }

        if (rating >= 7.0) {
          addBonus(SkillName.physical, 1);
        }

        if (isExcellentSeason) {
          addBonus(SkillName.passing, 1);
        }
        break;
    }

    var skills = player.skills;

    for (final entry in bonuses.entries) {
      final currentValue = skills.getSkill(entry.key);
      final newValue = (currentValue + entry.value).clamp(0, 99);

      switch (entry.key) {
        case SkillName.pace:
          skills = skills.copyWith(pace: newValue);
          break;
        case SkillName.physical:
          skills = skills.copyWith(physical: newValue);
          break;
        case SkillName.passing:
          skills = skills.copyWith(passing: newValue);
          break;
        case SkillName.shooting:
          skills = skills.copyWith(shooting: newValue);
          break;
        case SkillName.defending:
          skills = skills.copyWith(defending: newValue);
          break;
        case SkillName.dribbling:
          skills = skills.copyWith(dribbling: newValue);
          break;
        case SkillName.heading:
          skills = skills.copyWith(heading: newValue);
        case SkillName.vision:
          skills = skills.copyWith(vision: newValue);
      }
    }

    final updatedPlayer = player.copyWith(
      skills: skills,
      overall: calculateOverall(skills: skills, position: player.position),
    );

    updatedCareer = updatedCareer.copyWith(player: updatedPlayer);

    return updatedCareer;
  }

  // ============================================================
  // НОВЫЙ СЕЗОН
  // ============================================================

  int _declineSkill(int value, int amount) {
    return (value - amount).clamp(0, 99).toInt();
  }

  int _lowerSkill(int value) {
    return _declineSkill(value, 2);
  }

  Player _applyAgeDecline(Player currentPlayer, int newAge, int newSeason) {
    var skills = currentPlayer.skills;

    // Начиная с 16-го сезона начинается резкий спад.
    // Все навыки теряют 4 пункта, профильный навык — ещё 1.

    if (newSeason >= 16) {
      final decline = newSeason >= 18 ? 3 : 2;

      skills = skills.copyWith(
        pace: _declineSkill(skills.pace, decline),
        physical: _declineSkill(skills.physical, decline),
        passing: _declineSkill(skills.passing, decline),
        shooting: _declineSkill(skills.shooting, decline),
        defending: _declineSkill(skills.defending, decline),
        dribbling: _declineSkill(skills.dribbling, decline),
      );

      switch (currentPlayer.position) {
        case PlayerPosition.forward:
          skills = skills.copyWith(shooting: _declineSkill(skills.shooting, 1));
          skills = skills.copyWith(shooting: _declineSkill(skills.pace, 1));
          skills = skills.copyWith(
            shooting: _declineSkill(skills.dribbling, 2),
          );
          break;

        case PlayerPosition.midfielder:
          skills = skills.copyWith(passing: _declineSkill(skills.passing, 2));
          skills = skills.copyWith(shooting: _declineSkill(skills.pace, 2));
          skills = skills.copyWith(
            shooting: _declineSkill(skills.dribbling, 1),
          );
          break;

        case PlayerPosition.defender:
        case PlayerPosition.goalkeeper:
          skills = skills.copyWith(
            defending: _declineSkill(skills.defending, 1),
          );
          break;
      }

      return currentPlayer.copyWith(
        age: newAge,
        skills: skills,
        overall: calculateOverall(
          skills: skills,
          position: currentPlayer.position,
        ),
      );
    }

    // Прежнее постепенное возрастное снижение до 16-го сезона.
    if (newAge < 32) {
      return currentPlayer.copyWith(age: newAge);
    }

    skills = skills.copyWith(pace: _lowerSkill(skills.pace));

    if (newAge >= 33) {
      skills = skills.copyWith(physical: _lowerSkill(skills.physical));
      skills = skills.copyWith(shooting: _lowerSkill(skills.shooting));
    }

    if (newAge >= 34) {
      switch (currentPlayer.position) {
        case PlayerPosition.forward:
          skills = skills.copyWith(shooting: _lowerSkill(skills.shooting));
          skills = skills.copyWith(shooting: _lowerSkill(skills.pace));
          break;

        case PlayerPosition.midfielder:
          skills = skills.copyWith(passing: _lowerSkill(skills.passing));
          break;

        case PlayerPosition.defender:
        case PlayerPosition.goalkeeper:
          skills = skills.copyWith(defending: _lowerSkill(skills.defending));
          break;
      }
    }

    return currentPlayer.copyWith(
      age: newAge,
      skills: skills,
      overall: calculateOverall(
        skills: skills,
        position: currentPlayer.position,
      ),
    );
  }

  Career startNextSeason() {
    if (isCareerFinished || season >= 20) {
      return copyWith(isCareerFinished: true);
    } // Обычно сезон уже архивирован перед развитием и трансферами.
    // Проверка нужна, чтобы не потерять историю при старых сохранениях.
    final alreadyArchived = history.any((stats) => stats.season == season);

    final currentWorldCup = worldCup;

    final cup =
        currentWorldCup != null &&
            currentWorldCup.season == season &&
            currentWorldCup.isPlayerCalledUp
        ? currentWorldCup
        : null;

    final newHistory = alreadyArchived
        ? history
        : [
            ...history,
            SeasonStats(
              season: season,
              club: player.club,
              matches: matches + (cup?.playerMatches ?? 0),
              goals: goals + (cup?.playerGoals ?? 0),
              assists: assists + (cup?.playerAssists ?? 0),
              yellowCards: yellowCards,
              redCards: redCards,
              averageRating: (() {
                final cupMatches = cup?.playerMatches ?? 0;
                final totalMatches = matches + cupMatches;

                if (totalMatches == 0) return null;

                final totalRating =
                    (averageRating ?? 0) * matches +
                    (cup?.playerAverageRating ?? 0) * cupMatches;

                return double.parse(
                  (totalRating / totalMatches).toStringAsFixed(2),
                );
              })(),
            ),
          ];

    final newSeason = season + 1;

    final newAge = player.age + 1;

    final agedPlayer = _applyAgeDecline(player, newAge, newSeason);
    final newPlayer = agedPlayer.copyWith(season: newSeason);
    // Клуб берётся после трансферного окна.
    final newLeagueMatches = _createLeagueMatches(newPlayer.club);

    final newSeasonMatches = _createSeasonMatches(
      newPlayer.club,
      newLeagueMatches,
    );

    final newLeagueTable = _createLeagueTable(newPlayer.club, newSeasonMatches);

    final newClubLeague = Clubs.leagueOf(newPlayer.club);

    final DomesticCup? newDomesticCup;

    if (newClubLeague != null) {
      newDomesticCup = DomesticCup.create(
        league: newClubLeague,
        season: newSeason,
        playerClub: newPlayer.club,
      );
    } else {
      newDomesticCup = null;
    }

    final newDevelopmentPoints = alreadyArchived
        ? developmentPoints
        : developmentPoints +
              (season < 5
                  ? 3
                  : season == 5
                  ? 5
                  : 6);

    // Берём результаты чемпионатов текущего сезона.
    // Они используются для определения участников следующей ЛЧ.
    final qualificationStandings = <League, List<LeagueTableEntry>>{
      for (final entry in europeanLeagueStandings.entries)
        entry.key: List<LeagueTableEntry>.from(entry.value),
    };

    // Используем именно новую историю: она учитывает и старые
    // сохранения, в которых текущий сезон ещё не был архивирован.
    final previousSeasonStats = newHistory
        .where((stats) => stats.season == season)
        .toList();

    if (previousSeasonStats.isNotEmpty) {
      final previousClubName = previousSeasonStats.last.club;
      final previousLeague = Clubs.leagueOf(previousClubName);

      // Подменяем симуляцию реальными итогами чемпионата игрока.
      if (previousLeague != null && leagueTable.isNotEmpty) {
        qualificationStandings[previousLeague] = List<LeagueTableEntry>.from(
          leagueTable,
        );
      }
    }

    final qualifiedClubs = LeagueSeasonSimulator.getQualifiedClubs(
      qualificationStandings,
    );

    final newChampionsLeague = ChampionsLeague.create(
      season: newSeason,
      participants: qualifiedClubs,
    );
    final newEuropaLeague = EuropaLeague.create(
      season: newSeason,
      participants: LeagueSeasonSimulator.getEuropaLeagueClubs(
        qualificationStandings,
      ),
    );

    // Таблицы нового сезона создаются отдельно и не влияют
    // на квалификацию, которая уже определена по прошлому сезону.
    final newEuropeanLeagueStandings = LeagueSeasonSimulator.simulateAll(
      season: newSeason,
    );

    final previousStats = previousSeasonStats.isNotEmpty
        ? previousSeasonStats.last
        : null;
    final WorldCup? newWorldCup = newSeason % 4 == 0
        ? WorldCup.create(
            season: newSeason,
            nationality: newPlayer.nationality,
            overall: newPlayer.overall,
            age: newPlayer.age,
            goals: previousStats?.goals ?? 0,
            assists: previousStats?.assists ?? 0,
            averageRating: previousStats?.averageRating,
          )
        : null;

    return Career(
      player: newPlayer,
      season: newSeason,
      matches: 0,
      goals: 0,
      assists: 0,
      yellowCards: 0,
      redCards: 0,
      averageRating: null,
      money: money,
      contractYears: contractYears,
      developmentPoints: newDevelopmentPoints,
      seasonMatches: newSeasonMatches,
      history: newHistory,
      leagueTable: newLeagueTable,
      leagueMatches: newLeagueMatches,
      news: news,
      monthlySalary: monthlySalary,
      isCareerFinished: false,
      domesticCup: newDomesticCup,
      europeanLeagueStandings: newEuropeanLeagueStandings,
      championsLeague: newChampionsLeague,
      europaLeague: newEuropaLeague,
      worldCup: newWorldCup,
    );
  }
}
