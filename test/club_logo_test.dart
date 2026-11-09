import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/widgets/club_logo.dart';

void main() {
  test('эмблема есть у большинства клубов модели', () {
    expect(Clubs.all.length, 352);
    expect(ClubLogo.mappedClubCount, greaterThan(200));

    final withLogo = Clubs.all.where(
      (club) => ClubLogo.assetPathFor(club.name) != null,
    );
    expect(withLogo.length, greaterThan(200));
  });

  test('путь к эмблеме клуба совпадает с Club.logoAsset', () {
    for (final club in Clubs.all) {
      expect(club.logoAsset, ClubLogo.assetPathFor(club.name));
    }
  });

  test('неизвестный клуб также не получает чужую эмблему', () {
    expect(ClubLogo.assetPathFor('Unknown FC'), isNull);
  });
}
