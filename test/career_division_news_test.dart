import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/career.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/models/league_division_service.dart';
import 'package:flutter_football/models/league_table.dart';
import 'package:flutter_football/models/player.dart';

void main() {
  test('season news reports a Serie B club in Serie B, not Serie A', () {
    const skills = PlayerSkills(
      pace: 70,
      physical: 70,
      passing: 70,
      shooting: 70,
      defending: 50,
      dribbling: 70,
      heading: 65,
      vision: 65,
    );
    final player = Player(
      name: 'Test Player',
      nationality: 'Италия',
      position: PlayerPosition.forward,
      age: 17,
      season: 1,
      club: 'Cremonese',
      overall: calculateOverall(
        skills: skills,
        position: PlayerPosition.forward,
      ),
      skills: skills,
    );

    final career = Career.create(player);
    final serieBClubs = LeagueDivisionService.clubsFor(
      League.italy,
      2,
      career.leagueDivisions,
    );
    final serieBTable = [
      for (var index = 0; index < serieBClubs.length; index++)
        LeagueTableEntry(
          club: serieBClubs[index].name,
          played: 38,
          wins: index == 0 ? 30 : 10,
          draws: index == 0 ? 5 : 5,
          losses: index == 0 ? 3 : 23,
          goalsFor: index == 0 ? 80 : 35,
          goalsAgainst: index == 0 ? 25 : 60,
        ),
    ];

    final nextSeason = career
        .copyWith(leagueTable: serieBTable)
        .startNextSeason();

    final serieBNews = nextSeason.news.firstWhere(
      (item) => item.id == 'league_result_s2_italy_d2',
    );
    final serieANews = nextSeason.news.firstWhere(
      (item) => item.id == 'league_result_s2_italy_d1',
    );

    expect(serieBNews.title, 'Итоги сезона в Serie B');
    expect(serieBNews.description, contains('Cremonese'));
    expect(serieBNews.description, contains('Serie B'));
    expect(serieANews.title, 'Итоги сезона в Serie A');
    expect(serieANews.description, isNot(contains('Cremonese')));
  });
}
