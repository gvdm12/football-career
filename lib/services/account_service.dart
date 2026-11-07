import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_service.dart';

/// Авторизация и роль аккаунта.
///
/// Роль developer читается только из Firestore. Клиент может создать профиль
/// только с ролью player; назначить developer можно только из Firebase Console
/// владельцем проекта.
class AccountService {
  AccountService._();

  static const String _usersCollection = 'users';

  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static User? get currentUser =>
      FirebaseService.isInitialized ? _auth.currentUser : null;

  static Stream<User?> get authStateChanges =>
      FirebaseService.isInitialized ? _auth.authStateChanges() : const Stream.empty();

  static void _ensureConfigured() {
    if (!FirebaseService.isInitialized) {
      throw StateError(
        'Firebase не настроен. Следуйте инструкции FIREBASE_SETUP.md.',
      );
    }
  }

  static bool isDeveloperRole(String? role) => role == 'developer';

  static Future<UserCredential> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    _ensureConfigured();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase не вернул созданный аккаунт.');
    }

    await user.updateDisplayName(displayName.trim());
    await _usersCollectionRef(user.uid).set({
      'displayName': displayName.trim(),
      'email': user.email ?? email.trim(),
      'role': 'player',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await user.reload();
    return credential;
  }

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    _ensureConfigured();
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user != null) await _ensureProfile(user);
    return credential;
  }

  static Future<void> _ensureProfile(User user) async {
    final reference = _usersCollectionRef(user.uid);
    final snapshot = await reference.get();
    if (snapshot.exists) return;

    await reference.set({
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'role': 'player',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<String?> accountRole() async {
    _ensureConfigured();
    final user = _auth.currentUser;
    if (user == null) return null;

    await _ensureProfile(user);
    final snapshot = await _usersCollectionRef(user.uid).get();
    return snapshot.data()?['role'] as String? ?? 'player';
  }

  static Future<bool> isDeveloper() async {
    // Гостевой режим продолжает работать без подключённого Firebase.
    if (!FirebaseService.isInitialized) return false;
    return isDeveloperRole(await accountRole());
  }

  static Future<void> sendPasswordReset(String email) async {
    _ensureConfigured();
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> updateDisplayName(String displayName) async {
    _ensureConfigured();
    final user = _auth.currentUser;
    if (user == null) throw StateError('Сначала войдите в аккаунт.');

    final value = displayName.trim();
    if (value.isEmpty) throw ArgumentError('Имя не может быть пустым.');

    await user.updateDisplayName(value);
    await _usersCollectionRef(user.uid).update({
      'displayName': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> signOut() async {
    _ensureConfigured();
    await _auth.signOut();
  }

  static DocumentReference<Map<String, dynamic>> _usersCollectionRef(
    String uid,
  ) => _firestore.collection(_usersCollection).doc(uid);
}
