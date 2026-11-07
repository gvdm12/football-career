import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Инициализация Firebase через параметры сборки.
///
/// Конфигурация намеренно не хранится в репозитории. Для локального запуска
/// значения передаются через --dart-define (см. FIREBASE_SETUP.md).
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static bool _initializationFailed = false;

  static bool get isInitialized => _initialized;
  static bool get initializationFailed => _initializationFailed;

  static Future<void> initialize() async {
    final options = _firebaseOptions();
    if (options == null) return;

    try {
      await Firebase.initializeApp(options: options);
      _initialized = true;
    } on FirebaseException {
      _initializationFailed = true;
    } catch (_) {
      _initializationFailed = true;
    }
  }

  static FirebaseOptions? _firebaseOptions() {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const messagingSenderId = String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
    );
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
    const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

    final appId = switch (defaultTargetPlatform) {
      TargetPlatform.android => const String.fromEnvironment(
        'FIREBASE_ANDROID_APP_ID',
      ),
      TargetPlatform.iOS => const String.fromEnvironment(
        'FIREBASE_IOS_APP_ID',
      ),
      TargetPlatform.macOS => const String.fromEnvironment(
        'FIREBASE_MACOS_APP_ID',
      ),
      TargetPlatform.windows || TargetPlatform.linux => const String.fromEnvironment(
        'FIREBASE_WEB_APP_ID',
      ),
      TargetPlatform.fuchsia => '',
    };

    if (apiKey.isEmpty ||
        appId.isEmpty ||
        messagingSenderId.isEmpty ||
        projectId.isEmpty) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain.isEmpty ? null : authDomain,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
    );
  }
}
