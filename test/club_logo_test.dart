import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/models/club.dart';
import 'package:flutter_football/widgets/club_logo.dart';

void main() {
  test('для всех клубов есть безопасный вариант эмблемы или fallback', () {
    expect(Clubs.all, isNotEmpty);
    for (final club in Clubs.all) {
      // null означает, что будет показан fallback, а не чужая эмблема.
      final url = ClubLogo.logoUrlFor(club.name);
      if (url != null) {
        expect(url, startsWith('https://raw.githubusercontent.com/JoseArroyave/football-logos/'));
        expect(url, endsWith('.svg'));
      }
    }
  });

  test('неизвестный клуб не получает случайную эмблему', () {
    expect(ClubLogo.logoUrlFor('Unknown FC'), isNull);
  });
}
