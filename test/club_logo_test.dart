import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/widgets/club_logo.dart';

void main() {
  test('пока для всех клубов используется заглушка вместо эмблемы', () {
    expect(Clubs.all.length, 352);
    expect(ClubLogo.mappedClubCount, 0);

    for (final club in Clubs.all) {
      expect(ClubLogo.assetPathFor(club.name), isNull);
    }
  });

  test('неизвестный клуб также не получает чужую эмблему', () {
    expect(ClubLogo.assetPathFor('Unknown FC'), isNull);
  });
}
