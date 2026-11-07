import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/widgets/club_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('все эмблемы из справочника загружаются из локальных assets', () async {
    expect(Clubs.all.length, 352);
    expect(ClubLogo.mappedClubCount, 349);

    for (final club in Clubs.all) {
      final assetPath = ClubLogo.assetPathFor(club.name);
      if (assetPath != null) {
        expect(assetPath, startsWith('assets/clubs/'));
        expect(assetPath, endsWith('.svg'));
        await rootBundle.load(assetPath);
      }
    }
  });

  test('неизвестный клуб не получает чужую эмблему', () {
    expect(ClubLogo.assetPathFor('Unknown FC'), isNull);
  });
}
