import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_football/services/account_service.dart';
import 'package:flutter_football/services/firebase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('account role', () {
    test('only the exact developer role grants developer access', () {
      expect(AccountService.isDeveloperRole('developer'), isTrue);
      expect(AccountService.isDeveloperRole('player'), isFalse);
      expect(AccountService.isDeveloperRole('Developer'), isFalse);
      expect(AccountService.isDeveloperRole(null), isFalse);
      expect(AccountService.isDeveloperRole('admin'), isFalse);
    });

    test('guest mode is not treated as developer without Firebase', () async {
      expect(FirebaseService.isInitialized, isFalse);
      expect(await AccountService.isDeveloper(), isFalse);
    });
  });
}
