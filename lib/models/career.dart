import 'dart:math';
import 'package:flutter_football/models/career_news.dart';
import 'package:flutter_football/models/career_objective.dart';
import 'package:flutter_football/models/sponsor_deal.dart';
import 'package:flutter_football/models/career_settings.dart';
import 'package:flutter_football/models/career_world_transfer.dart';
import 'package:flutter_football/models/career_coach_transfer.dart';
import 'package:flutter_football/models/real_club_coaches.dart';
import 'package:flutter_football/models/real_club_squads.dart';
import 'package:flutter_football/models/friendly_match.dart';
import 'package:flutter_football/services/pre_season_service.dart';
import 'package:flutter_football/services/world_transfer_service.dart';
import 'package:flutter_football/models/champions_league.dart';
import 'package:flutter_football/models/europa_league.dart';
import 'package:flutter_football/models/world_cup.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/club_strength_service.dart';
import 'package:flutter_football/models/league_division_service.dart';

import 'package:flutter_football/models/league_match.dart';
import 'package:flutter_football/models/league_season_simulator.dart';
import 'domestic_cup.dart';
import 'player.dart';
import 'match.dart';
import 'season_match.dart';
import 'season_stats.dart';
import 'player_of_month_award.dart';
import 'season_award.dart';
import 'position_rival.dart';
import 'player_status.dart';
import 'transfer_offer.dart';
import 'league_table.dart';
import 'league_player_season_stats.dart';

class Career {
  final Player player;
  final CareerSettings settings;
  final List<CareerWorldTransfer> worldTransfers;
  final List<CareerCoachTransfer> coachTransfers;
  final List<FriendlyMatch> friendlyMatches;
  final int lastConversationMatch;
  final int teamMatches;
  final int lastCoachNegotiationTeamMatch;
  final int lastAgentNegotiationTeamMatch;
  final int lastClubChangeSeason;
  final int season;
  final List<SeasonStats> history;
  final List<PlayerOfMonthAward> playerOfMonthAwards;
  final List<SeasonAward> seasonAwards;
  final List<LeaguePlayerSeasonStats> leaguePlayerStats;
  final List<String> leagueStatsProcessedMatchKeys;
  final List<CareerNews> news;
  final List<CareerObjective> objectives;
  final List<double> recentMatchRatings;
  final List<SponsorOffer> sponsorOffers;
  final int sponsorOffersSeason;
  final SponsorContract? sponsorContract;
  final List<PositionRival> rivals;
  final int coachTrust;
  final int reputationModifier;
  final int agentLevel;
  final String coachName;

  final int matches;
  final int goals;
  final int assists;
  final int yellowCards;
  final int redCards;
  final double? averageRating;

  final List<LeagueTableEntry> leagueTable;

  final int money;
  final int agentCredits;
  final List<String> agentInterestedClubs;
  final int lastTransferInterestConferenceSeason;
  final int monthlySalary; // Зарплата в месяц, евро
  final int contractYears;
  final int developmentPoints;
  final bool isCareerFinished;
  final DomesticCup? domesticCup;
  final ChampionsLeague? championsLeague;
  final EuropaLeague? europaLeague;
  final WorldCup? worldCup;
  final int injuryMatchesRemaining;
  final String? injuryName;
  final bool injuryRecoveryUsed;
  final Map<String, int> skillTrainingPurchases;
  final Map<String, int> temporarySkillBoosts;
  final Map<String, int> temporarySkillBoostMatches;
  final Map<String, int> clubStrengths;
  final Map<String, List<String>> leagueDivisions;

  int get currentLeagueDivision {
    final league = Clubs.leagueOf(player.club);
    if (league == null) return 1;
    return LeagueDivisionService.divisionForClub(player.club, leagueDivisions) ?? 1;
  }

  bool get isInjured =>
      !settings.playWithoutInjuries && injuryMatchesRemaining > 0;

  double get currentFormRating {
    if (recentMatchRatings.isEmpty) return averageRating ?? 6.0;
    return recentMatchRatings.reduce((a, b) => a + b) / recentMatchRatings.length;
  }

  int get currentFormLevel =>
      ((currentFormRating - 6.5) * 2).round().clamp(-3, 3).toInt();

  // Стартовый клуб считается первым клубом карьеры: при включённом
  // ограничении первая смена клуба доступна только в 5-м сезоне.
  // После каждого реального перехода отсчёт пяти сезонов начинается заново.
  bool get canChangeClub {
    if (!settings.limitTransfersToFiveYears) return true;
    if (lastClubChangeSeason <= 0) return season >= 5;
    return season - lastClubChangeSeason >= 5;
  }

  int get seasonsUntilClubChange {
    if (canChangeClub) return 0;
    final seasonsPassed = lastClubChangeSeason <= 0
        ? season
        : season - lastClubChangeSeason;
    return (5 - seasonsPassed).clamp(0, 5).toInt();
  }

  Player get playerForMatch {
    var skills = player.skills;
    for (final skill in SkillName.values) {
      final bonus = temporarySkillBoosts[skill.name] ?? 0;
      if (bonus <= 0) continue;
      final value = (skills.getSkill(skill) + bonus).clamp(0, 99).toInt();
      skills = switch (skill) {
        SkillName.pace => skills.copyWith(pace: value),
        SkillName.physical => skills.copyWith(physical: value),
        SkillName.shooting => skills.copyWith(shooting: value),
        SkillName.passing => skills.copyWith(passing: value),
        SkillName.dribbling => skills.copyWith(dribbling: value),
        SkillName.defending => skills.copyWith(defending: value),
        SkillName.heading => skills.copyWith(heading: value),
        SkillName.vision => skills.copyWith(vision: value),
      };
    }
    return player.copyWith(skills: skills);
  }

  /// Все матчи чемпионата, включая матчи других клубов.
  final List<LeagueMatch> leagueMatches;

  /// Матчи клуба игрока в текущем сезоне.
  final List<SeasonMatch> seasonMatches;

  final Map<League, List<LeagueTableEntry>> europeanLeagueStandings;

  const Career({
    required this.player,
    this.settings = const CareerSettings(),
    this.worldTransfers = const [],
    this.coachTransfers = const [],
    this.friendlyMatches = const [],
    this.lastConversationMatch = -4,
    this.teamMatches = 0,
    this.lastCoachNegotiationTeamMatch = -7,
    this.lastAgentNegotiationTeamMatch = -7,
    this.lastClubChangeSeason = 0,
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
    this.playerOfMonthAwards = const [],
    this.seasonAwards = const [],
    this.leaguePlayerStats = const [],
    this.leagueStatsProcessedMatchKeys = const [],
    required this.leagueTable,
    required this.leagueMatches,
    this.news = const [],
    this.objectives = const [],
    this.recentMatchRatings = const [],
    this.sponsorOffers = const [],
    this.sponsorOffersSeason = 0,
    this.sponsorContract,
    this.rivals = const [],
    this.coachTrust = 65,
    this.reputationModifier = 0,
    this.agentLevel = 1,
    this.agentCredits = 0,
    this.agentInterestedClubs = const [],
    this.lastTransferInterestConferenceSeason = 0,
    this.coachName = 'Главный тренер',
    required this.monthlySalary,
    required this.isCareerFinished,
    this.domesticCup,
    required this.europeanLeagueStandings,
    this.championsLeague,
    this.europaLeague,
    this.worldCup,
    this.injuryMatchesRemaining = 0,
    this.injuryName,
    this.injuryRecoveryUsed = false,
    this.skillTrainingPurchases = const {},
    this.temporarySkillBoosts = const {},
    this.temporarySkillBoostMatches = const {},
    this.clubStrengths = const {},
    this.leagueDivisions = const {},
  });

  // ============================================================
  // КАЛЕНДАРЬ ЧЕМПИОНАТА
  // ============================================================

  static List<LeagueMatch> _createLeagueMatches(
    String playerClub, {
    Map<String, List<String>>? leagueDivisions,
  }) {
    final league = Clubs.leagueOf(playerClub);
    if (league == null) return [];

    final divisions = leagueDivisions ??
        LeagueDivisionService.createInitialDivisions();
    final division =
        LeagueDivisionService.divisionForClub(playerClub, divisions) ?? 1;
    final clubs = LeagueDivisionService.clubsFor(league, division, divisions);
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
    List<SeasonMatch> seasonMatches, {
    Map<String, List<String>>? leagueDivisions,
  }) {
    final league = Clubs.leagueOf(playerClub);

    if (league != null) {
      final divisions = leagueDivisions ??
          LeagueDivisionService.createInitialDivisions();
      final division =
          LeagueDivisionService.divisionForClub(playerClub, divisions) ?? 1;
      final clubs =
          LeagueDivisionService.clubsFor(league, division, divisions);
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

  static List<CareerObjective> _createSeasonObjectives(Player player, int season) {
    final overall = player.overall;
    final appearancesTarget = (overall >= 85 ? 24 : overall >= 75 ? 21 : 18);
    final contributionTarget = player.position == PlayerPosition.forward
        ? (overall >= 85 ? 18 : overall >= 75 ? 14 : 10)
        : player.position == PlayerPosition.midfielder
            ? (overall >= 85 ? 13 : overall >= 75 ? 10 : 7)
            : (overall >= 85 ? 6 : overall >= 75 ? 4 : 2);
    final metric = player.position == PlayerPosition.forward
        ? CareerObjectiveMetric.goals
        : player.position == PlayerPosition.midfielder
            ? CareerObjectiveMetric.assists
            : CareerObjectiveMetric.goals;
    final contributionLabel = metric == CareerObjectiveMetric.goals
        ? 'Забить $contributionTarget голов'
        : 'Сделать $contributionTarget голевых передач';
    final contributionDescription = metric == CareerObjectiveMetric.goals
        ? 'Забить не менее $contributionTarget голов за сезон'
        : 'Отдать не менее $contributionTarget голевых передач за сезон';
    final defensiveLabel = 'Забить $contributionTarget голов';
    return [
      CareerObjective(
        id: 's${season}_contribution',
        season: season,
        metric: metric,
        title: player.position == PlayerPosition.defender ? defensiveLabel : contributionLabel,
        description: contributionDescription,
        target: contributionTarget,
        reward: 30000 + overall * 250,
      ),
      CareerObjective(
        id: 's${season}_appearances',
        season: season,
        metric: CareerObjectiveMetric.appearances,
        title: 'Провести $appearancesTarget матчей',
        description: 'Принять участие минимум в $appearancesTarget матчах сезона',
        target: appearancesTarget,
        reward: 25000 + overall * 180,
      ),
    ];
  }

  static List<SponsorOffer> _createSponsorOffers(Player player, int season) {
    final brands = <String>[
      'Nike',
      'Adidas',
      'Puma',
      'New Balance',
      'Under Armour',
      'Red Bull',
      'Coca-Cola',
      // Средний уровень: крупные технологические, спортивные и
      // международные компании, доступные игрокам с рейтингом 75+.
      if (player.overall >= 75) ...[
        'Samsung',
        'LG',
        'HP',
        'Lenovo',
        'Visa',
        'Pepsi',
        'Sony',
        'JBL',
        'Gatorade',
        'Spotify',
        'Mastercard',
        'DHL',
        'Uber',
        'PlayStation',
        'EA SPORTS',
        'Expedia',
      ],
      // Высокий уровень: глобальные технологические и премиальные бренды.
      if (player.overall >= 85) ...[
        'Apple',
        'Emirates',
        'Rolex',
        'Google',
        'Microsoft',
        'Amazon',
        'Mercedes-Benz',
        'BMW',
        'Audi',
        'Qatar Airways',
        'Marriott Bonvoy',
        'Porsche',
      ],
      // Элитные бренды становятся доступны только игрокам с рейтингом 90+.
      if (player.overall >= 90) ...[
        'Louis Vuitton',
        'Gucci',
        'Dior',
        'Prada',
        'TAG Heuer',
        'Hublot',
        'Cartier',
        'Bentley',
      ],
    ];
    final random = Random(season * 97 + player.overall * 13 + player.age);
    final count = player.overall >= 82 ? 2 : 1;
    final selected = [...brands]..shuffle(random);
    return List.generate(count, (index) {
      final brand = selected[index];
      final multiplier = index == 0 ? 1.0 : 0.72;
      final annual = ((player.overall * player.overall * 8) * multiplier).round();
      return SponsorOffer(
        id: 's${season}_sponsor_$index',
        brand: brand,
        paymentPerSeason: annual,
        signingBonus: (annual * 0.20).round(),
        contractYears: player.overall >= 85 && index == 0 ? 3 : 2,
      );
    });
  }

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

  static String _generateCoachName() {
    const names = [
      'Александр Волков',
      'Марк Петерсен',
      'Даниэль Морено',
      'Роберто Силва',
      'Томас Шнайдер',
      'Лукас Мартинес',
      'Антонио Росси',
      'Джеймс Уокер',
      'Михаил Орлов',
      'Карим Бенали',
    ];
    return names[Random().nextInt(names.length)];
  }

  factory Career.create(
    Player player, {
    CareerSettings settings = const CareerSettings(),
  }) {
    Clubs.resetCareerState();
    final leagueDivisions = LeagueDivisionService.createInitialDivisions();
    final leagueMatches = _createLeagueMatches(
      player.club,
      leagueDivisions: leagueDivisions,
    );

    final seasonMatches = _createSeasonMatches(player.club, leagueMatches);
    final friendlyMatches = PreSeasonService.create(
      playerClub: player.club,
      season: 1,
    );

    final leagueTable = _createLeagueTable(
      player.club,
      seasonMatches,
      leagueDivisions: leagueDivisions,
    );
    final startingSalary = _startingClubSalary(player.club);
    final startingObjectives = _createSeasonObjectives(player, 1);
    final startingSponsorOffers = _createSponsorOffers(player, 1);

    final clubLeague = Clubs.leagueOf(player.club);

    if (clubLeague == null) {
      throw StateError('Не удалось определить лигу клуба ${player.club}');
    }

    final cup = DomesticCup.create(
      league: clubLeague,
      season: 1,
      playerClub: player.club,
      leagueDivisions: leagueDivisions,
    );

    final europeanLeagueStandings = LeagueSeasonSimulator.simulateAll(
      season: 1,
      leagueDivisions: leagueDivisions,
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
      settings: settings,
      season: 1,
      rivals: PositionRival.generate(player: player, season: 1),
      coachName: RealClubCoaches.coachForClub(player.club, const []) ??
          _generateCoachName(),
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
      friendlyMatches: friendlyMatches,
      history: const [],
      leagueTable: leagueTable,
      leagueMatches: leagueMatches,
      monthlySalary: startingSalary,
      objectives: startingObjectives,
      sponsorOffers: startingSponsorOffers,
      sponsorOffersSeason: 1,
      news: startingSponsorOffers.map((offer) => CareerNews(
        id: 'sponsor_offer_${offer.id}', season: 1, matchNumber: -1,
        title: 'Спонсорское предложение от ${offer.brand}',
        description: '${offer.brand} предлагает контракт на ${offer.contractYears} сезона: €${offer.paymentPerSeason} за сезон и бонус €${offer.signingBonus} при подписании. Подробности доступны у агента.',
        type: CareerNewsType.sponsor,
      )).toList(),
      isCareerFinished: false,
      domesticCup: cup,
      leagueDivisions: leagueDivisions,
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
      'settings': settings.toJson(),
      'worldTransfers': worldTransfers.map((item) => item.toJson()).toList(),
      'coachTransfers': coachTransfers.map((item) => item.toJson()).toList(),
      'friendlyMatches': friendlyMatches.map((item) => item.toJson()).toList(),
      'lastConversationMatch': lastConversationMatch,
      'teamMatches': teamMatches,
      'lastCoachNegotiationTeamMatch': lastCoachNegotiationTeamMatch,
      'lastAgentNegotiationTeamMatch': lastAgentNegotiationTeamMatch,
      'lastClubChangeSeason': lastClubChangeSeason,
      'season': season,
      'history': history.map((item) => item.toJson()).toList(),
      'playerOfMonthAwards': playerOfMonthAwards
          .map((item) => item.toJson())
          .toList(),
      'seasonAwards': seasonAwards.map((item) => item.toJson()).toList(),
      'leaguePlayerStats': leaguePlayerStats
          .map((item) => item.toJson())
          .toList(),
      'leagueStatsProcessedMatchKeys': leagueStatsProcessedMatchKeys,
      'matches': matches,
      'goals': goals,
      'assists': assists,
      'yellowCards': yellowCards,
      'redCards': redCards,
      'averageRating': averageRating,
      'leagueTable': leagueTable.map((item) => item.toJson()).toList(),
      'money': money,
      'agentCredits': agentCredits,
      'agentInterestedClubs': agentInterestedClubs,
      'lastTransferInterestConferenceSeason':
          lastTransferInterestConferenceSeason,
      'contractYears': contractYears,
      'developmentPoints': developmentPoints,
      'seasonMatches': seasonMatches.map((item) => item.toJson()).toList(),
      'leagueMatches': leagueMatches.map((item) => item.toJson()).toList(),
      'news': news.map((item) => item.toJson()).toList(),
      'objectives': objectives.map((item) => item.toJson()).toList(),
      'recentMatchRatings': recentMatchRatings,
      'sponsorOffers': sponsorOffers.map((item) => item.toJson()).toList(),
      'sponsorOffersSeason': sponsorOffersSeason,
      'sponsorContract': sponsorContract?.toJson(),
      'rivals': rivals.map((item) => item.toJson()).toList(),
      'coachTrust': coachTrust,
      'reputationModifier': reputationModifier,
      'agentLevel': agentLevel,
      'coachName': coachName,
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
      'injuryMatchesRemaining': injuryMatchesRemaining,
      'injuryName': injuryName,
      'injuryRecoveryUsed': injuryRecoveryUsed,
      'skillTrainingPurchases': skillTrainingPurchases,
      'temporarySkillBoosts': temporarySkillBoosts,
      'temporarySkillBoostMatches': temporarySkillBoostMatches,
      'clubStrengths': clubStrengths,
      'leagueDivisions': leagueDivisions,
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
    final restoredLeagueDivisions =
        LeagueDivisionService.restoreDivisions(json['leagueDivisions']);
    final restoredWorldTransfers = readList(
      'worldTransfers',
      CareerWorldTransfer.fromJson,
    );
    RealClubSquads.applyCareerTransfers(restoredWorldTransfers);
    final restoredCoachTransfers = readList(
      'coachTransfers',
      CareerCoachTransfer.fromJson,
    );
    final rawClubStrengths = json['clubStrengths'];
    final restoredClubStrengths = rawClubStrengths is Map
        ? rawClubStrengths.map(
            (key, value) => MapEntry(key.toString(), (value as num).toInt()),
          )
        : <String, int>{};
    Clubs.applyStrengthOverrides(restoredClubStrengths);

    final currentSeason = (json['season'] as num?)?.toInt() ?? 1;
    final expectedLeagueMatches = _createLeagueMatches(
      loadedPlayer.club,
      leagueDivisions: restoredLeagueDivisions,
    );
    final savedLeagueMatches = readList('leagueMatches', LeagueMatch.fromJson);

    // Старые сохранения иногда содержат уже нового игрока, но календарь
    // предыдущего клуба. Сверяем именно пары и туры текущего клуба.
    String fixtureKey(LeagueMatch match) =>
        '${match.round}:${match.homeTeam}:${match.awayTeam}';
    final expectedPlayerFixtures = expectedLeagueMatches
        .where((match) =>
            match.homeTeam == loadedPlayer.club ||
            match.awayTeam == loadedPlayer.club)
        .map(fixtureKey)
        .toSet();
    final savedPlayerFixtures = savedLeagueMatches
        .where((match) =>
            match.homeTeam == loadedPlayer.club ||
            match.awayTeam == loadedPlayer.club)
        .map(fixtureKey)
        .toSet();
    final rebuildLeagueCalendar = savedLeagueMatches.isEmpty ||
        (expectedPlayerFixtures.isNotEmpty &&
            (expectedPlayerFixtures.length != savedPlayerFixtures.length ||
                !expectedPlayerFixtures.every(savedPlayerFixtures.contains)));
    final leagueMatches = rebuildLeagueCalendar
        ? expectedLeagueMatches
        : savedLeagueMatches;

    final expectedSeasonMatches =
        _createSeasonMatches(loadedPlayer.club, leagueMatches);
    final savedSeasonMatches = readList('seasonMatches', SeasonMatch.fromJson);
    final seasonCalendarMatches =
        savedSeasonMatches.length == expectedSeasonMatches.length &&
            List.generate(expectedSeasonMatches.length, (index) {
              final saved = savedSeasonMatches[index];
              final expected = expectedSeasonMatches[index];
              return saved.number == expected.number &&
                  saved.opponent == expected.opponent &&
                  saved.isHome == expected.isHome;
            }).every((matches) => matches);
    final rebuildSeasonCalendar =
        rebuildLeagueCalendar || !seasonCalendarMatches;
    final seasonMatches = rebuildSeasonCalendar
        ? expectedSeasonMatches
        : savedSeasonMatches;

    final savedTable = readList('leagueTable', LeagueTableEntry.fromJson);
    final leagueTable = rebuildSeasonCalendar ||
            savedTable.isEmpty ||
            !savedTable.any((entry) => entry.club == loadedPlayer.club)
        ? _createLeagueTable(
            loadedPlayer.club,
            seasonMatches,
            leagueDivisions: restoredLeagueDivisions,
          )
        : savedTable;

    final rawCup = json['domesticCup'];

    DomesticCup? restoredCup;

    if (rawCup is Map) {
      restoredCup = DomesticCup.fromJson(Map<String, dynamic>.from(rawCup));

      final clubLeague = Clubs.leagueOf(loadedPlayer.club);
      // После смены клуба старый кубок не должен оставаться в сохранении.
      // При несовпадении сезона, лиги или участников создаём кубок заново.
      if (clubLeague == null ||
          restoredCup.season != currentSeason ||
          restoredCup.league != clubLeague ||
          !restoredCup.teams.contains(loadedPlayer.club) ||
          (restoredCup.teams.length == 16 &&
              LeagueDivisionService.hasSecondDivision(restoredCup.league) &&
              restoredCup.matches.every((match) => !match.isPlayed))) {
        restoredCup = clubLeague == null
            ? null
            : DomesticCup.create(
                league: clubLeague,
                season: currentSeason,
                playerClub: loadedPlayer.club,
                leagueDivisions: restoredLeagueDivisions,
              );
      }
    } else {
      final clubLeague = Clubs.leagueOf(loadedPlayer.club);

      restoredCup = clubLeague == null
          ? null
          : DomesticCup.create(
              league: clubLeague,
              season: (json['season'] as num?)?.toInt() ?? 1,
              playerClub: loadedPlayer.club,
              leagueDivisions: restoredLeagueDivisions,
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
        leagueDivisions: restoredLeagueDivisions,
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

    final savedRivals = readList('rivals', PositionRival.fromJson);
    final rivalsToRestore = savedRivals.isNotEmpty
        ? savedRivals
        : PositionRival.generate(player: loadedPlayer, season: currentSeason);
    final usedJerseyNumbers = <int>{loadedPlayer.jerseyNumber};
    final normalizedRivals = rivalsToRestore.map((rival) {
      if (usedJerseyNumbers.add(rival.jerseyNumber)) return rival;
      final available = List<int>.generate(99, (index) => index + 1)
        ..removeWhere(usedJerseyNumbers.contains);
      if (available.isEmpty) return rival;
      final number = available.first;
      usedJerseyNumbers.add(number);
      return rival.copyWith(jerseyNumber: number);
    }).toList();
    final restoredRivals = PositionRival.ensureRealCompetitors(
      player: loadedPlayer,
      season: currentSeason,
      existing: normalizedRivals,
    );
    final restoredObjectives = readList('objectives', CareerObjective.fromJson);
    final restoredSponsorOffers = readList('sponsorOffers', SponsorOffer.fromJson);
    final rawSponsorContract = json['sponsorContract'];
    final restoredSponsorContract = rawSponsorContract is Map
        ? SponsorContract.fromJson(Map<String, dynamic>.from(rawSponsorContract))
        : null;
    final restoredAgentInterests = (json['agentInterestedClubs'] as List?)
        ?.whereType<String>().toList() ?? const <String>[];
    final restoredNews = readList('news', CareerNews.fromJson);
    final restoredSponsorOffersSeason = (json['sponsorOffersSeason'] as num?)?.toInt() ?? 0;
    final needsSponsorMigration = restoredSponsorOffersSeason <= 0 && restoredSponsorContract == null;
    final migratedSponsorOffers = needsSponsorMigration
        ? _createSponsorOffers(loadedPlayer, currentSeason)
        : restoredSponsorOffers;
    final migrationNews = <CareerNews>[
      if (needsSponsorMigration)
        for (final offer in migratedSponsorOffers)
          CareerNews(
            id: 'sponsor_offer_${offer.id}',
            season: currentSeason,
            matchNumber: -1,
            title: 'Новое предложение от ${offer.brand}',
            description: '${offer.brand} предлагает €${offer.paymentPerSeason} за сезон, бонус €${offer.signingBonus} и контракт на ${offer.contractYears} сезона. Обсудите предложение с агентом.',
            type: CareerNewsType.sponsor,
          ),
      for (final club in restoredAgentInterests.take(2))
        if (!restoredNews.any((item) => item.id == 'rumor_s${currentSeason}_${club.hashCode}'))
          CareerNews(
            id: 'rumor_s${currentSeason}_${club.hashCode}',
            season: currentSeason,
            matchNumber: -1,
            title: 'Трансферные слухи: интерес со стороны ${club}',
            description: 'Скауты клуба следят за вашими последними выступлениями. Официального предложения пока нет.',
            type: CareerNewsType.rumor,
          ),
    ];

    // Миграция старых сохранений: удаляем индивидуальные награды,
    // которые ранее могли выдаваться без реальных сезонных показателей.
    final savedSeasonAwards = readList('seasonAwards', SeasonAward.fromJson);
    final validSeasonAwards = savedSeasonAwards.where((award) {
      switch (award.category) {
        case 'Игрок сезона':
          return false;
        case 'Лучший бомбардир':
          return award.matches >= 10 && award.goals > 0;
        case 'Лучший ассистент':
          return award.matches >= 10 && award.assists > 0;
        case 'Лучший молодой игрок':
          return award.age <= 21 &&
              award.matches >= 15 &&
              award.averageRating >= 7.0;
        case 'Команда года':
          return award.matches >= 10 && award.averageRating >= 6.0;
        case 'Золотой мяч':
          // Поддерживаем и резервного победителя из fallback-гонки:
          // регулярные выходы на поле и нормальная оценка уже достаточны.
          return award.matches >= 10 && award.averageRating >= 6.0;
        default:
          return true;
      }
    }).toList();

    // Награды сезона хранятся отдельно в seasonAwards и не дублируются
    // в архиве статистики каждого сезона. Заодно очищаем их из старых сохранений.
    const seasonAwardAchievements = {
      'Золотая бутса',
      'Бомбардир сезона',
      'Лучший ассистент',
      'Лучший игрок сезона',
      'Лучший молодой игрок сезона',
      'В сборной сезона',
      'Золотой мяч',
    };
    final normalizedHistory = readList('history', SeasonStats.fromJson).map((
      stats,
    ) {
      final achievements = stats.achievements
          .where((achievement) => !seasonAwardAchievements.contains(achievement))
          .toList();

      return SeasonStats(
        season: stats.season,
        club: stats.club,
        matches: stats.matches,
        goals: stats.goals,
        assists: stats.assists,
        yellowCards: stats.yellowCards,
        redCards: stats.redCards,
        averageRating: stats.averageRating,
        achievements: achievements,
      );
    }).toList();

    return Career(
      player: loadedPlayer,
      settings: CareerSettings.fromJson(
        json['settings'] is Map
            ? Map<String, dynamic>.from(json['settings'] as Map)
            : null,
      ),
      worldTransfers: restoredWorldTransfers,
      coachTransfers: restoredCoachTransfers,
      friendlyMatches: readList(
        'friendlyMatches',
        FriendlyMatch.fromJson,
      ).take(2).toList(),
      lastConversationMatch:
          (json['lastConversationMatch'] as num?)?.toInt() ?? -4,
      teamMatches:
          (json['teamMatches'] as num?)?.toInt() ??
          (json['matches'] as num?)?.toInt() ??
          0,
      lastCoachNegotiationTeamMatch:
          (json['lastCoachNegotiationTeamMatch'] as num?)?.toInt() ??
          (json['lastConversationMatch'] as num?)?.toInt() ??
          -7,
      lastAgentNegotiationTeamMatch:
          (json['lastAgentNegotiationTeamMatch'] as num?)?.toInt() ??
          (json['lastConversationMatch'] as num?)?.toInt() ??
          -7,
      lastClubChangeSeason:
          (json['lastClubChangeSeason'] as num?)?.toInt() ?? 0,
      season: (json['season'] as num?)?.toInt() ?? 1,
      history: normalizedHistory,
      playerOfMonthAwards: readList(
        'playerOfMonthAwards',
        PlayerOfMonthAward.fromJson,
      ),
      seasonAwards: validSeasonAwards,
      leaguePlayerStats: readList(
        'leaguePlayerStats',
        LeaguePlayerSeasonStats.fromJson,
      ),
      leagueStatsProcessedMatchKeys:
          (json['leagueStatsProcessedMatchKeys'] as List?)
              ?.whereType<String>()
              .toList() ??
          const [],
      matches: (json['matches'] as num?)?.toInt() ?? 0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      assists: (json['assists'] as num?)?.toInt() ?? 0,
      yellowCards: (json['yellowCards'] as num?)?.toInt() ?? 0,
      redCards: (json['redCards'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      leagueTable: leagueTable,
      money: (json['money'] as num?)?.toInt() ?? 0,
      agentCredits: (json['agentCredits'] as num?)?.toInt() ?? 0,
      agentInterestedClubs: restoredAgentInterests,
      lastTransferInterestConferenceSeason:
          (json['lastTransferInterestConferenceSeason'] as num?)?.toInt() ?? 0,
      contractYears: (json['contractYears'] as num?)?.toInt() ?? 0,
      developmentPoints: (json['developmentPoints'] as num?)?.toInt() ?? 0,
      seasonMatches: seasonMatches,
      leagueMatches: leagueMatches,
      news: [...restoredNews, ...migrationNews],
      objectives: restoredObjectives.isNotEmpty
          ? restoredObjectives
          : _createSeasonObjectives(loadedPlayer, currentSeason),
      recentMatchRatings: ((json['recentMatchRatings'] as List?) ?? const [])
          .whereType<num>().map((value) => value.toDouble()).toList().take(5).toList(),
      sponsorOffers: migratedSponsorOffers,
      sponsorOffersSeason: restoredSponsorOffersSeason > 0 ? restoredSponsorOffersSeason : currentSeason,
      sponsorContract: restoredSponsorContract,
      rivals: restoredRivals,
      coachTrust: ((json['coachTrust'] as num?)?.toInt() ?? 65)
          .clamp(0, 100)
          .toInt(),
      reputationModifier: (json['reputationModifier'] as num?)?.toInt() ?? 0,
      agentLevel: ((json['agentLevel'] as num?)?.toInt() ?? 1)
          .clamp(1, 10)
          .toInt(),
      coachName: RealClubCoaches.coachForClub(
            loadedPlayer.club,
            restoredCoachTransfers,
          ) ??
          (json['coachName'] as String? ?? 'Главный тренер'),
      monthlySalary: (json['monthlySalary'] as num?)?.toInt() ?? 0,
      isCareerFinished: json['isCareerFinished'] as bool? ?? false,
      domesticCup: restoredCup,
      europeanLeagueStandings: europeanLeagueStandings,
      championsLeague: championsLeague,
      europaLeague: europaLeague,
      worldCup: rawWorldCup is Map
          ? WorldCup.fromJson(Map<String, dynamic>.from(rawWorldCup))
          : null,
      injuryMatchesRemaining:
          ((json['injuryMatchesRemaining'] as num?)?.toInt() ?? 0)
              .clamp(0, 10)
              .toInt(),
      injuryName: json['injuryName'] as String?,
      injuryRecoveryUsed: json['injuryRecoveryUsed'] as bool? ?? false,
      skillTrainingPurchases:
          (json['skillTrainingPurchases'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), (value as num).toInt()),
          ) ??
          const {},
      temporarySkillBoosts:
          (json['temporarySkillBoosts'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), (value as num).toInt()),
          ) ??
          const {},
      clubStrengths: restoredClubStrengths,
      leagueDivisions: restoredLeagueDivisions,
      temporarySkillBoostMatches:
          (json['temporarySkillBoostMatches'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), (value as num).toInt()),
          ) ??
          const {},
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  Career copyWith({
    Player? player,
    CareerSettings? settings,
    List<CareerWorldTransfer>? worldTransfers,
    List<CareerCoachTransfer>? coachTransfers,
    List<FriendlyMatch>? friendlyMatches,
    int? lastConversationMatch,
    int? teamMatches,
    int? lastCoachNegotiationTeamMatch,
    int? lastAgentNegotiationTeamMatch,
    int? lastClubChangeSeason,
    int? season,
    int? matches,
    int? goals,
    int? assists,
    int? yellowCards,
    int? redCards,
    double? averageRating,
    int? money,
    int? agentCredits,
    List<String>? agentInterestedClubs,
    int? lastTransferInterestConferenceSeason,
    int? contractYears,
    int? developmentPoints,
    List<SeasonMatch>? seasonMatches,
    List<SeasonStats>? history,
    List<PlayerOfMonthAward>? playerOfMonthAwards,
    List<SeasonAward>? seasonAwards,
    List<LeaguePlayerSeasonStats>? leaguePlayerStats,
    List<String>? leagueStatsProcessedMatchKeys,
    List<LeagueTableEntry>? leagueTable,
    List<LeagueMatch>? leagueMatches,
    List<CareerNews>? news,
    List<CareerObjective>? objectives,
    List<double>? recentMatchRatings,
    List<SponsorOffer>? sponsorOffers,
    int? sponsorOffersSeason,
    SponsorContract? sponsorContract,
    bool clearSponsorContract = false,
    List<PositionRival>? rivals,
    int? coachTrust,
    int? reputationModifier,
    int? agentLevel,
    String? coachName,
    int? monthlySalary,
    bool? isCareerFinished,
    DomesticCup? domesticCup,
    Map<League, List<LeagueTableEntry>>? europeanLeagueStandings,
    ChampionsLeague? championsLeague,
    EuropaLeague? europaLeague,
    WorldCup? worldCup,
    int? injuryMatchesRemaining,
    String? injuryName,
    bool? injuryRecoveryUsed,
    Map<String, int>? skillTrainingPurchases,
    Map<String, int>? temporarySkillBoosts,
    Map<String, int>? temporarySkillBoostMatches,
    Map<String, int>? clubStrengths,
    Map<String, List<String>>? leagueDivisions,
    bool clearInjury = false,
  }) {
    return Career(
      player: player ?? this.player,
      settings: settings ?? this.settings,
      worldTransfers: worldTransfers ?? this.worldTransfers,
      coachTransfers: coachTransfers ?? this.coachTransfers,
      friendlyMatches: friendlyMatches ?? this.friendlyMatches,
      lastConversationMatch:
          lastConversationMatch ?? this.lastConversationMatch,
      teamMatches: teamMatches ?? this.teamMatches,
      lastCoachNegotiationTeamMatch:
          lastCoachNegotiationTeamMatch ?? this.lastCoachNegotiationTeamMatch,
      lastAgentNegotiationTeamMatch:
          lastAgentNegotiationTeamMatch ?? this.lastAgentNegotiationTeamMatch,
      lastClubChangeSeason: lastClubChangeSeason ?? this.lastClubChangeSeason,
      season: season ?? this.season,
      matches: matches ?? this.matches,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      yellowCards: yellowCards ?? this.yellowCards,
      redCards: redCards ?? this.redCards,
      averageRating: averageRating ?? this.averageRating,
      money: money ?? this.money,
      agentCredits: agentCredits ?? this.agentCredits,
      agentInterestedClubs: agentInterestedClubs ?? this.agentInterestedClubs,
      lastTransferInterestConferenceSeason:
          lastTransferInterestConferenceSeason ??
          this.lastTransferInterestConferenceSeason,
      contractYears: contractYears ?? this.contractYears,
      developmentPoints: developmentPoints ?? this.developmentPoints,
      seasonMatches: seasonMatches ?? this.seasonMatches,
      history: history ?? this.history,
      playerOfMonthAwards: playerOfMonthAwards ?? this.playerOfMonthAwards,
      seasonAwards: seasonAwards ?? this.seasonAwards,
      leaguePlayerStats: leaguePlayerStats ?? this.leaguePlayerStats,
      leagueStatsProcessedMatchKeys:
          leagueStatsProcessedMatchKeys ?? this.leagueStatsProcessedMatchKeys,
      leagueTable: leagueTable ?? this.leagueTable,
      leagueMatches: leagueMatches ?? this.leagueMatches,
      news: news ?? this.news,
      objectives: objectives ?? this.objectives,
      recentMatchRatings: recentMatchRatings ?? this.recentMatchRatings,
      sponsorOffers: sponsorOffers ?? this.sponsorOffers,
      sponsorOffersSeason: sponsorOffersSeason ?? this.sponsorOffersSeason,
      sponsorContract: clearSponsorContract ? null : sponsorContract ?? this.sponsorContract,
      rivals: rivals ?? this.rivals,
      coachTrust: coachTrust ?? this.coachTrust,
      reputationModifier: reputationModifier ?? this.reputationModifier,
      agentLevel: agentLevel ?? this.agentLevel,
      coachName: coachName ?? this.coachName,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      isCareerFinished: isCareerFinished ?? this.isCareerFinished,
      domesticCup: domesticCup ?? this.domesticCup,
      europeanLeagueStandings:
          europeanLeagueStandings ?? this.europeanLeagueStandings,
      championsLeague: championsLeague ?? this.championsLeague,
      europaLeague: europaLeague ?? this.europaLeague,
      worldCup: worldCup ?? this.worldCup,
      injuryMatchesRemaining:
          injuryMatchesRemaining ?? this.injuryMatchesRemaining,
      injuryName: clearInjury ? null : injuryName ?? this.injuryName,
      injuryRecoveryUsed: injuryRecoveryUsed ?? this.injuryRecoveryUsed,
      skillTrainingPurchases:
          skillTrainingPurchases ?? this.skillTrainingPurchases,
      temporarySkillBoosts: temporarySkillBoosts ?? this.temporarySkillBoosts,
      temporarySkillBoostMatches:
          temporarySkillBoostMatches ?? this.temporarySkillBoostMatches,
      clubStrengths: clubStrengths ?? this.clubStrengths,
      leagueDivisions: leagueDivisions ?? this.leagueDivisions,
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
    // Тренерская оценка зависит от выступлений и накопленного доверия.
    else if (rating >= 7.8 && coachTrust >= 75) {
      title = 'Тренер доволен вашей формой';
      description =
          'После очередного сильного выступления тренер высоко оценил '
          'вашу игру. Доверие тренерского штаба растёт.';
    } else if (rating <= 6.0 && coachTrust <= 45) {
      title = 'Тренер ждёт реакции';
      description =
          'После неудачного матча тренерский штаб ожидает от вас '
          'более уверенной игры в следующих турах.';
    }
    // Борьба за место в составе.
    else if (matchNumber % 3 == 0 &&
        rivals.any((rival) => rival.overall + rival.form > player.overall)) {
      final rival = rivals.firstWhere(
        (item) => item.overall + item.form > player.overall,
      );
      title = 'Конкурент давит';
      description =
          '${rival.name} набирает форму и претендует на игровое время. '
          'Чтобы сохранить место, важно продолжать показывать результат.';
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

  /// Продвигает восстановление после любого матча игрока — клубного или сборной.
  /// Новая травма появляется только после матча, в котором игрок участвовал.
  Career advanceAfterCompetitionMatch({required bool playerParticipated}) {
    // Покупки психолога и персонального тренера перезаряжаются
    // по матчам команды, даже если игрок остался в запасе или травмирован.
    final staffCooldowns = Map<String, int>.from(temporarySkillBoostMatches);
    for (final key in ['psychologist', 'personalTrainer']) {
      final remaining = (staffCooldowns[key] ?? 0) - 1;
      if (remaining <= 0) {
        staffCooldowns.remove(key);
      } else {
        staffCooldowns[key] = remaining;
      }
    }

    if (isInjured) {
      final remaining = (injuryMatchesRemaining - 1).clamp(0, 10).toInt();
      return copyWith(
        injuryMatchesRemaining: remaining,
        clearInjury: remaining == 0,
        temporarySkillBoostMatches: staffCooldowns,
      );
    }

    var updatedCareer =
        settings.playWithoutInjuries &&
            (injuryMatchesRemaining > 0 || injuryName != null)
        ? copyWith(
            injuryMatchesRemaining: 0,
            injuryRecoveryUsed: false,
            clearInjury: true,
            temporarySkillBoostMatches: staffCooldowns,
          )
        : copyWith(temporarySkillBoostMatches: staffCooldowns);
    if (playerParticipated) {
      final nextBoosts = Map<String, int>.from(
        updatedCareer.temporarySkillBoosts,
      );
      final nextDurations = Map<String, int>.from(
        updatedCareer.temporarySkillBoostMatches,
      );
      for (final skillName in nextDurations.keys.toList()) {
        if (skillName == 'psychologist' || skillName == 'personalTrainer') {
          continue;
        }
        final remaining = (nextDurations[skillName] ?? 0) - 1;
        if (remaining <= 0) {
          nextDurations.remove(skillName);
          nextBoosts.remove(skillName);
        } else {
          nextDurations[skillName] = remaining;
        }
      }
      updatedCareer = updatedCareer.copyWith(
        temporarySkillBoosts: nextBoosts,
        temporarySkillBoostMatches: nextDurations,
      );
    }

    final injuryChance =
        0.030 * settings.injuryFrequency * settings.difficulty.injuryChanceMultiplier;
    if (settings.playWithoutInjuries ||
        !playerParticipated ||
        Random().nextDouble() >= injuryChance) {
      return updatedCareer;
    }
    const injuries = [
      'Растяжение мышц',
      'Ушиб',
      'Повреждение голеностопа',
      'Мышечная травма',
      'Повреждение колена',
    ];
    final random = Random();
    final duration = random.nextInt(10) + 1;
    return updatedCareer.copyWith(
      injuryName: injuries[random.nextInt(injuries.length)],
      injuryMatchesRemaining: duration,
      injuryRecoveryUsed: false,
    );
  }

  static int currencyRewardForMatch(Match match) {
    if (!match.playerPlayed) return 0;

    final performanceBonus = match.playerRating >= 9.0
        ? 2
        : match.playerRating >= 8.0
        ? 1
        : 0;

    return match.playerGoals * 2 + match.playerAssists + performanceBonus;
  }

  Career afterMatch(Match match) {
    // Конкуренты получают игровую практику даже тогда, когда игрок пропустил матч.
    // Месячная статистика хранится отдельно, чтобы награда не использовала
    // накопленные за весь сезон показатели конкурента.
    final rivalRound = seasonMatches.where((item) => item.isPlayed).length + 1;
    final rivalMonth = seasonMatches.isEmpty
        ? 1
        : (((rivalRound * 12) - 1) ~/ seasonMatches.length) + 1;
    final nextRatings = match.playerPlayed
        ? [...recentMatchRatings, match.playerRating].take(5).toList()
        : recentMatchRatings;
    final matchCareer = copyWith(
      teamMatches: teamMatches + 1,
      recentMatchRatings: nextRatings,
      rivals: PositionRival.advanceMatch(
        rivals,
        month: rivalMonth,
        clubStrength: Clubs.getByName(player.club).strength,
      ),
    );
    final trustChange = !match.playerPlayed
        ? 0
        : match.playerRating >= 8.0
        ? 3
        : match.playerRating >= 7.0
        ? 1
        : match.playerRating < 6.0
        ? -3
        : match.playerRating < 6.5
        ? -1
        : 0;
    final difficultyAdjustedTrustChange =
        (trustChange * settings.difficulty.coachTrustMultiplier).round();
    final updatedTrust = (coachTrust + difficultyAdjustedTrustChange)
        .clamp(0, 100)
        .toInt();
    final trustedCareer = matchCareer.copyWith(coachTrust: updatedTrust);

    // Травмированный игрок пропускает матч, но срок восстановления уменьшается.
    if (isInjured) {
      return trustedCareer.advanceAfterCompetitionMatch(
        playerParticipated: false,
      );
    }

    // Изменение роли в команде фиксируется в новостях карьеры.
    PlayerStatus roleFor(Career value) {
      final reputation = PlayerStatusCalculator.calculateReputation(
        overall: value.player.overall,
        averageRating: value.averageRating,
        coachTrust: value.coachTrust,
        reputationModifier: value.reputationModifier,
        trophies: value.history.fold<int>(
          0,
          (sum, item) => sum + item.achievements.length,
        ),
      );
      return PlayerStatusCalculator.calculate(
        overall: value.player.overall,
        clubName: value.player.club,
        rivals: value.rivals,
        coachTrust: value.coachTrust,
        reputation: reputation,
        averageRating: value.averageRating,
        formRating: value.currentFormRating,
      );
    }

    final oldRole = roleFor(this);
    final competitionNews = <CareerNews>[];
    final competitionRound =
        seasonMatches.where((item) => item.isPlayed).length + 1;

    // Команда сыграла, но игрок не участвовал: сохраняем причину в ленте,
    // чтобы пропуск матча не выглядел как незаметное случайное событие.
    if (!match.playerPlayed) {
      final newRole = roleFor(trustedCareer);
      if (oldRole != newRole) {
        final improved = newRole.index < oldRole.index;
        competitionNews.add(
          CareerNews(
            id: 's${season}_squad_role_${competitionRound}_${newRole.name}',
            season: season,
            matchNumber: competitionRound,
            title: improved
                ? 'Новый статус в команде'
                : 'Изменение роли в составе',
            description: improved
                ? 'Благодаря выступлениям и доверию тренера ваша роль изменилась: ${newRole.displayName.toLowerCase()}.'
                : 'Конкуренция за позицию усилилась. Теперь ваша роль: ${newRole.displayName.toLowerCase()}.',
            type: CareerNewsType.season,
          ),
        );
      }
      final strongestRival = trustedCareer.rivals.isEmpty
          ? null
          : trustedCareer.rivals.reduce((a, b) {
              final aScore = a.selectionStrength;
              final bScore = b.selectionStrength;
              return aScore >= bScore ? a : b;
            });
      final hasRecentCompetitionNews = news.any(
        (item) =>
            item.season == season &&
            item.title == 'Борьба за игровое время' &&
            item.matchNumber >= competitionRound - 2,
      );
      if (!hasRecentCompetitionNews) {
        final rivalIsAhead =
            strongestRival != null &&
            strongestRival.selectionStrength > player.overall;
        final rivalId = strongestRival?.id ?? 'rotation';
        final rivalName = strongestRival?.name ?? 'Конкурент';
        competitionNews.add(
          CareerNews(
            id: 's${season}_bench_${competitionRound}_$rivalId',
            season: season,
            matchNumber: competitionRound,
            title: rivalIsAhead ? 'Борьба за игровое время' : 'Ротация состава',
            description: rivalIsAhead
                ? '$rivalName сейчас опережает вас в борьбе за позицию. '
                      'Тренировки и сильные выступления помогут вернуть место в составе.'
                : 'Тренер провёл ротацию состава. Следующие матчи — возможность '
                      'укрепить своё положение в команде.',
            type: CareerNewsType.match,
          ),
        );
      }
      return trustedCareer
          .copyWith(news: [...trustedCareer.news, ...competitionNews])
          .advanceAfterCompetitionMatch(playerParticipated: false);
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

    final updatedCareer = trustedCareer
        .copyWith(
          agentCredits:
              trustedCareer.agentCredits + currencyRewardForMatch(match),
          matches: newMatches,
          goals: newGoals,
          assists: newAssists,
          yellowCards: newYellowCards,
          redCards: newRedCards,
          averageRating: double.parse(newAverageRating.toStringAsFixed(2)),
          news: [...trustedCareer.news, ...matchNews, ...competitionNews],
        )
        .advanceAfterCompetitionMatch(playerParticipated: true);

    final newRole = roleFor(updatedCareer);
    var careerWithCompetitionNews = updatedCareer;
    if (oldRole != newRole) {
      final improved = newRole.index < oldRole.index;
      careerWithCompetitionNews = updatedCareer.copyWith(
        news: [
          ...updatedCareer.news,
          CareerNews(
            id: 's${season}_squad_role_${competitionRound}_${newRole.name}',
            season: season,
            matchNumber: competitionRound,
            title: improved
                ? 'Новый статус в команде'
                : 'Изменение роли в составе',
            description: improved
                ? 'Благодаря выступлениям и доверию тренера ваша роль изменилась: ${newRole.displayName.toLowerCase()}.'
                : 'Конкуренция за позицию усилилась. Теперь ваша роль: ${newRole.displayName.toLowerCase()}.',
            type: CareerNewsType.season,
          ),
        ],
      );
    }

    // Обновляем задачи тренера по накопленной статистике сезона.
    final objectiveNews = <CareerNews>[];
    var objectiveReward = 0;
    final updatedObjectives = careerWithCompetitionNews.objectives.map((objective) {
      if (objective.season != season || objective.completed) return objective;
      final value = switch (objective.metric) {
        CareerObjectiveMetric.goals => newGoals,
        CareerObjectiveMetric.assists => newAssists,
        CareerObjectiveMetric.appearances => newMatches,
      };
      final updated = objective.updateProgress(value);
      if (!objective.completed && updated.completed) {
        objectiveReward += objective.reward;
        objectiveNews.add(CareerNews(
          id: 'objective_${objective.id}_completed',
          season: season,
          matchNumber: competitionRound,
          title: 'Цель тренера выполнена!',
          description: 'Задача «${objective.title}» выполнена. Премия: €${objective.reward}.',
          type: CareerNewsType.objective,
        ));
      }
      return updated;
    }).toList();

    var finalCareer = careerWithCompetitionNews.copyWith(
      objectives: updatedObjectives,
      money: careerWithCompetitionNews.money + objectiveReward,
      news: [...careerWithCompetitionNews.news, ...objectiveNews],
    );

    // Изменение формы фиксируем после трёх выступлений подряд.
    if (nextRatings.length >= 3) {
      final previousBand = currentFormRating >= 7.2 ? 1 : currentFormRating <= 5.9 ? -1 : 0;
      final nextForm = finalCareer.currentFormRating;
      final nextBand = nextForm >= 7.2 ? 1 : nextForm <= 5.9 ? -1 : 0;
      if (previousBand != nextBand) {
        final rising = nextBand > previousBand;
        final formNews = CareerNews(
          id: 'form_s${season}_m${competitionRound}_${nextBand}',
          season: season,
          matchNumber: competitionRound,
          title: rising ? 'Форма игрока улучшается' : 'Спад игровой формы',
          description: rising
              ? 'Последние матчи показывают прогресс: средняя оценка за последние выступления — ${nextForm.toStringAsFixed(1)}.'
              : 'Последние выступления получились менее удачными. Средняя оценка за последние матчи — ${nextForm.toStringAsFixed(1)}.',
          type: CareerNewsType.form,
        );
        finalCareer = finalCareer.copyWith(news: [...finalCareer.news, formNews]);
      }
    }

    if (!settings.playWithoutInjuries &&
        match.injuryName != null &&
        match.injuryMatchesRemaining > 0) {
      return finalCareer.copyWith(
        injuryName: match.injuryName,
        injuryMatchesRemaining: match.injuryMatchesRemaining,
      );
    }
    return finalCareer;
  }

  // ============================================================
  // ТРАНСФЕР
  // ============================================================

  Career acceptTransfer(TransferOffer offer) {
    if (!offer.isRenewal && !canChangeClub) return this;
    final newPlayer = player.copyWith(club: offer.club.name);

    return copyWith(
      player: newPlayer,
      rivals: offer.isRenewal
          ? rivals
          : PositionRival.generate(player: newPlayer, season: season),
      monthlySalary: offer.salary,
      contractYears: offer.contractYears,
      coachTrust: offer.isRenewal ? coachTrust : 65,
      agentLevel: agentLevel,
      coachName: offer.isRenewal ? coachName : _generateCoachName(),
      lastClubChangeSeason: offer.isRenewal ? lastClubChangeSeason : season,
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

    // «Золотая бутса» добавляется после расчёта общей таблицы бомбардиров
    // в SeasonAwardService, а не по произвольному порогу голов.

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

    final seasonRating = totalSeasonRating ?? 0;
    if (player.age <= 21 && totalSeasonMatches >= 15 && seasonRating >= 7.0) {
      achievements.add('Лучший молодой игрок сезона');
    }
    if (totalSeasonMatches >= 20 && seasonRating >= 7.2) {
      achievements.add('В сборной сезона');
    }
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

    final awardNews = achievements
        .where(
          (item) =>
              item == 'Лучший молодой игрок сезона' ||
              item == 'В сборной сезона' ||
              item == 'Лучший ассистент' ||
              item == 'Золотая бутса',
        )
        .map(
          (award) => CareerNews(
            id: 's${season}_award_${award.hashCode}',
            season: season,
            matchNumber: seasonMatches.length + 1,
            title: award,
            description:
                '${player.name} получил награду «$award» по итогам сезона.',
            type: CareerNewsType.achievement,
          ),
        )
        .toList();

    const teamTrophies = {
      'Чемпион страны',
      'Обладатель кубка страны',
      'Победитель Лиги чемпионов',
      'Победитель Лиги Европы',
      'Чемпион мира',
    };
    final trophyReward =
        achievements.where(teamTrophies.contains).length * 20 +
        (achievements.contains('Золотая бутса') ? 10 : 0);

    var updatedCareer = copyWith(
      agentCredits: agentCredits + trophyReward,
      history: [...history, seasonStats],
      news: [...news, ...awardNews],
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

        if (goals >= 15) {
          addBonus(SkillName.heading, 1);
        }

        if (goals >= 34) {
          addBonus(SkillName.shooting, 1);
        }

        if (assists >= 14 || contributions >= 20) {
          addBonus(SkillName.dribbling, 1);
        }

        if (isGoodSeason && goals >= 14) {
          addBonus(SkillName.pace, 1);
          addBonus(SkillName.vision, 1);
        }

        if (contributions >= 18) {
          addBonus(SkillName.vision, 1);
          addBonus(SkillName.passing, 1);
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
          break;
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

    // Начиная с 16-го сезона начинается более заметный спад.
    // Снижаются шесть основных навыков; профильные навыки позиции
    // дополнительно теряют несколько пунктов.

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
          skills = skills.copyWith(
            shooting: _declineSkill(skills.shooting, 1),
            pace: _declineSkill(skills.pace, 1),
            dribbling: _declineSkill(skills.dribbling, 2),
          );
          break;

        case PlayerPosition.midfielder:
          skills = skills.copyWith(
            passing: _declineSkill(skills.passing, 2),
            pace: _declineSkill(skills.pace, 2),
            dribbling: _declineSkill(skills.dribbling, 1),
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
          skills = skills.copyWith(
            shooting: _lowerSkill(skills.shooting),
            pace: _lowerSkill(skills.pace),
          );
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

    // Подготавливаем итоговые таблицы обоих дивизионов и меняем
    // участников местами перед созданием календаря нового сезона.
    final finalDivisionTables = LeagueDivisionService.simulateAllDivisions(
      divisions: leagueDivisions.isEmpty
          ? LeagueDivisionService.createInitialDivisions()
          : leagueDivisions,
      season: season,
    );
    // Таблица относится к клубу, за который игрок завершил предыдущий
    // сезон, а не к новому клубу после трансфера.
    final archivedCurrentSeason = newHistory
        .where((stats) => stats.season == season)
        .toList();
    final seasonClub = archivedCurrentSeason.isEmpty
        ? player.club
        : archivedCurrentSeason.last.club;
    final currentLeague = Clubs.leagueOf(seasonClub);
    final currentDivision = currentLeague == null
        ? 1
        : LeagueDivisionService.divisionForClub(
              seasonClub,
              leagueDivisions,
            ) ??
            1;
    if (currentLeague != null && leagueTable.isNotEmpty) {
      finalDivisionTables[
        LeagueDivisionService.key(currentLeague, currentDivision)
      ] = List<LeagueTableEntry>.from(leagueTable);
    }
    final newLeagueDivisions = LeagueDivisionService.advanceSeason(
      divisions: leagueDivisions.isEmpty
          ? LeagueDivisionService.createInitialDivisions()
          : leagueDivisions,
      finalTables: finalDivisionTables,
    );

    // Сила клубов меняется только один раз при переходе в новый сезон.
    final performanceStandings = <League, List<LeagueTableEntry>>{
      for (final entry in europeanLeagueStandings.entries)
        entry.key: List<LeagueTableEntry>.from(entry.value),
    };
    final previousClub = archivedCurrentSeason.isEmpty
        ? null
        : archivedCurrentSeason.last;
    final previousLeague = previousClub == null
        ? null
        : Clubs.leagueOf(previousClub.club);
    final previousDivision = previousClub == null
        ? 1
        : LeagueDivisionService.divisionForClub(
                previousClub.club,
                leagueDivisions,
              ) ??
              1;
    if (previousLeague != null && previousDivision == 1 && leagueTable.isNotEmpty) {
      performanceStandings[previousLeague] = List<LeagueTableEntry>.from(
        leagueTable,
      );
    }
    final updatedClubStrengths = ClubStrengthService.update(
      currentStrengths: clubStrengths,
      standings: performanceStandings,
      domesticCupWinner: domesticCup?.champion,
      championsLeagueWinner: championsLeague?.champion,
      europaLeagueWinner: europaLeague?.champion,
      divisionStandings: finalDivisionTables,
      leagueDivisions: leagueDivisions,
    );
    Clubs.applyStrengthOverrides(updatedClubStrengths);

    final newSeason = season + 1;
    final newWorldTransfers = WorldTransferService.simulateSeason(
      season: newSeason,
      previousTransfers: worldTransfers,
      realistic: true,
    );
    final allWorldTransfers = [...worldTransfers, ...newWorldTransfers];
    RealClubSquads.applyCareerTransfers(allWorldTransfers);

    final newCoachTransfers = RealClubCoaches.simulateSeason(
      season: newSeason,
      previousTransfers: coachTransfers,
    );
    final allCoachTransfers = [...coachTransfers, ...newCoachTransfers];
    final updatedPlayerCoach = RealClubCoaches.coachForClub(
      player.club,
      allCoachTransfers,
    );
    final coachTransferNews = newCoachTransfers
        .map(
          (transfer) => CareerNews(
            id: 'coach_transfer_s${newSeason}_${transfer.coachName.hashCode}',
            season: newSeason,
            matchNumber: 0,
            title: 'Managerial change: ${transfer.coachName}',
            description:
                '${transfer.coachName} moved from ${transfer.fromClub} to ${transfer.toClub}. '
                '${transfer.replacementCoachName} moved to ${transfer.fromClub}.',
            type: CareerNewsType.season,
          ),
        )
        .toList();
    final worldTransferNews = newWorldTransfers
        .map(
          (transfer) => CareerNews(
            id: 'world_transfer_s${newSeason}_${transfer.playerName.hashCode}',
            season: newSeason,
            matchNumber: 0,
            title: 'Трансфер: ${transfer.playerName}',
            description:
                '${transfer.playerName} (${transfer.overall}) перешёл из ${transfer.fromClub} в ${transfer.toClub}.',
            type: CareerNewsType.transfer,
          ),
        )
        .toList();

    final newAge = player.age + 1;
    final nextSponsorContract = sponsorContract?.copyWith(
      seasonsRemaining: sponsorContract!.seasonsRemaining - 1,
    );
    final activeSponsor = nextSponsorContract != null && nextSponsorContract.seasonsRemaining > 0
        ? nextSponsorContract
        : null;
    final nextObjectives = _createSeasonObjectives(
      player.copyWith(age: newAge),
      newSeason,
    );
    final nextSponsorOffers = activeSponsor == null
        ? _createSponsorOffers(player.copyWith(age: newAge), newSeason)
        : <SponsorOffer>[];
    final sponsorOfferNews = nextSponsorOffers.map((offer) => CareerNews(
      id: 'sponsor_offer_${offer.id}', season: newSeason, matchNumber: -1,
      title: 'Новое предложение от ${offer.brand}',
      description: '${offer.brand} предлагает €${offer.paymentPerSeason} за сезон, бонус €${offer.signingBonus} и контракт на ${offer.contractYears} сезона. Обсудите предложение с агентом.',
      type: CareerNewsType.sponsor,
    )).toList();
    final transferRumorNews = agentInterestedClubs
        .where((club) => club != player.club)
        .take(2)
        .map((club) => CareerNews(
          id: 'rumor_s${newSeason}_${club.hashCode}',
          season: newSeason,
          matchNumber: -1,
          title: 'Трансферные слухи: интерес к игроку',
          description: 'По информации из окружения клуба, $club следит за выступлениями ${player.name}. Пока речь идёт только о предварительном интересе, официального предложения нет.',
          type: CareerNewsType.rumor,
        )).toList();

    final agedPlayer = _applyAgeDecline(player, newAge, newSeason);
    final newPlayer = agedPlayer.copyWith(season: newSeason);
    final newFriendlyMatches = PreSeasonService.create(
      playerClub: newPlayer.club,
      season: newSeason,
    );
    // Клуб берётся после трансферного окна.
    final newLeagueMatches = _createLeagueMatches(
      newPlayer.club,
      leagueDivisions: newLeagueDivisions,
    );

    final newSeasonMatches = _createSeasonMatches(
      newPlayer.club,
      newLeagueMatches,
    );

    final newLeagueTable = _createLeagueTable(
      newPlayer.club,
      newSeasonMatches,
      leagueDivisions: newLeagueDivisions,
    );

    final newClubLeague = Clubs.leagueOf(newPlayer.club);

    final DomesticCup? newDomesticCup;

    if (newClubLeague != null) {
      newDomesticCup = DomesticCup.create(
        league: newClubLeague,
        season: newSeason,
        playerClub: newPlayer.club,
        leagueDivisions: newLeagueDivisions,
      );
    } else {
      newDomesticCup = null;
    }

    final baseDevelopmentPoints = season < 5
        ? 3
        : season == 5
        ? 5
        : 6;
    final newDevelopmentPoints = alreadyArchived
        ? developmentPoints
        : developmentPoints +
              (baseDevelopmentPoints * settings.developmentSpeed).round();

    // Берём результаты чемпионатов текущего сезона.
    // Они используются для определения участников следующей ЛЧ.
    // Используем именно новую историю: она учитывает и старые
    // сохранения, в которых текущий сезон ещё не был архивирован.
    final previousSeasonStats = newHistory
        .where((stats) => stats.season == season)
        .toList();
    final previousClubName = previousSeasonStats.isEmpty
        ? null
        : previousSeasonStats.last.club;

    // Реальная таблица игрока заменяет симуляцию только для высшего
    // дивизиона. Результат во втором дивизионе не является квалификацией в еврокубки.
    final qualificationStandings = LeagueSeasonSimulator.standingsForQualification(
      simulatedStandings: europeanLeagueStandings,
      playerClub: previousClubName ?? '',
      playerLeagueStandings: leagueTable,
      leagueDivisions: leagueDivisions,
    );

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
      leagueDivisions: newLeagueDivisions,
    );

    // Новости должны брать таблицу именно того дивизиона,
    // в котором клуб провёл завершившийся сезон. qualificationStandings
    // содержит только высшие дивизионы и не подходит для Serie B / Ligue 2.
    final currentPlayerLeague = Clubs.leagueOf(newPlayer.club);
    final otherLeagues =
        League.values.where((league) => league != currentPlayerLeague).toList()
          ..shuffle(Random(newSeason * 97 + newPlayer.overall));
    final newsLeagues = <League>[
      if (currentPlayerLeague != null) currentPlayerLeague,
      ...otherLeagues.take(3),
    ];

    String divisionDisplayName(League league, int division) {
      if (division == 1) return league.displayName;
      return switch (league) {
        League.england => 'Championship',
        League.spain => 'Segunda División',
        League.germany => '2. Bundesliga',
        League.italy => 'Serie B',
        League.france => 'Ligue 2',
        League.russia => 'Первая лига',
        _ => '${league.displayName} — второй дивизион',
      };
    }

    final leagueNews = <CareerNews>[];
    for (final league in newsLeagues) {
      final playerLeague = league == currentPlayerLeague;
      final divisionsToCover = playerLeague &&
              LeagueDivisionService.hasSecondDivision(league)
          ? const [1, 2]
          : const [1];

      for (final division in divisionsToCover) {
        final table = [
          ...(finalDivisionTables[
                  LeagueDivisionService.key(league, division)] ??
              const <LeagueTableEntry>[]),
        ]..sort(
            (a, b) => b.points != a.points
                ? b.points.compareTo(a.points)
                : b.goalDifference.compareTo(a.goalDifference),
          );
        if (table.isEmpty) continue;

        final champion = table.first.club;
        final competitionName = divisionDisplayName(league, division);
        leagueNews.add(
          CareerNews(
            id: 'league_result_s${newSeason}_${league.name}_d$division',
            season: newSeason,
            matchNumber: 0,
            title: 'Итоги сезона в $competitionName',
            description:
                '$champion завершил предыдущий сезон на первом месте и стал чемпионом $competitionName.',
            type: CareerNewsType.season,
          ),
        );
      }
    }

    final divisionNews = <CareerNews>[];
    for (final league in LeagueDivisionService.twoTierLeagues) {
      final previousTop =
          leagueDivisions[LeagueDivisionService.key(league, 1)] ?? const [];
      final nextTop =
          newLeagueDivisions[LeagueDivisionService.key(league, 1)] ?? const [];
      final promoted =
          nextTop.where((club) => !previousTop.contains(club)).toList();
      final relegated =
          previousTop.where((club) => !nextTop.contains(club)).toList();
      if (promoted.isEmpty || relegated.isEmpty) continue;

      final playerWasPromoted = promoted.contains(newPlayer.club);
      final playerWasRelegated = relegated.contains(newPlayer.club);
      final topName = divisionDisplayName(league, 1);
      final secondName = divisionDisplayName(league, 2);
      divisionNews.add(
        CareerNews(
          id: 'division_movement_s${newSeason}_${league.name}',
          season: newSeason,
          matchNumber: 0,
          title: playerWasPromoted
              ? 'Повышение в $topName!'
              : playerWasRelegated
                  ? 'Клуб вылетел в $secondName'
                  : 'Повышение и вылет: $topName',
          description:
              'В $topName вышли из $secondName: ${promoted.join(', ')}. '
              'Из $topName во $secondName вылетели: ${relegated.join(', ')}.',
          type: CareerNewsType.season,
        ),
      );
    }

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
      settings: settings,
      worldTransfers: allWorldTransfers,
      coachTransfers: allCoachTransfers,
      friendlyMatches: newFriendlyMatches,
      lastConversationMatch: -4,
      // Не сбрасываем сезон последнего перехода при создании новой карьеры.
      lastClubChangeSeason: lastClubChangeSeason,
      season: newSeason,
      clubStrengths: updatedClubStrengths,
      matches: 0,
      goals: 0,
      assists: 0,
      yellowCards: 0,
      redCards: 0,
      averageRating: null,
      money: money,
      // Игровая валюта агента должна сохраняться между сезонами.
      agentCredits: agentCredits,
      contractYears: contractYears,
      developmentPoints: newDevelopmentPoints,
      seasonMatches: newSeasonMatches,
      history: newHistory,
      leagueTable: newLeagueTable,
      leagueMatches: newLeagueMatches,
      news: [...news, ...worldTransferNews, ...coachTransferNews, ...leagueNews, ...divisionNews, ...transferRumorNews, ...sponsorOfferNews],
      objectives: nextObjectives,
      recentMatchRatings: const [],
      sponsorOffers: nextSponsorOffers,
      sponsorOffersSeason: newSeason,
      sponsorContract: activeSponsor,
      rivals: PositionRival.nextSeason(rivals, newSeason, player: newPlayer),
      coachTrust: coachTrust,
      agentLevel: agentLevel,
      agentInterestedClubs: const [],
      // В новом сезоне разрешаем снова показать интерес клубов на пресс-конференции.
      lastTransferInterestConferenceSeason: 0,
      coachName: updatedPlayerCoach ?? coachName,
      monthlySalary: monthlySalary,
      isCareerFinished: false,
      domesticCup: newDomesticCup,
      leagueDivisions: newLeagueDivisions,
      europeanLeagueStandings: newEuropeanLeagueStandings,
      championsLeague: newChampionsLeague,
      europaLeague: newEuropaLeague,
      worldCup: newWorldCup,
      // Травма сохраняется при переходе на новый сезон,
      // независимо от того, остался игрок в клубе или сменил его.
      injuryMatchesRemaining: injuryMatchesRemaining,
      injuryName: injuryName,
      injuryRecoveryUsed: injuryRecoveryUsed,
      skillTrainingPurchases: skillTrainingPurchases,
      temporarySkillBoosts: temporarySkillBoosts,
      temporarySkillBoostMatches: temporarySkillBoostMatches,
    );
  }
}
