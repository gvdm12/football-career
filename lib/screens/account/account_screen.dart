import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_football/services/account_service.dart';
import 'package:flutter_football/services/app_strings.dart';
import 'package:flutter_football/services/firebase_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const Color _green = Color(0xFF8BE07F);
  static const Color _background = Color(0xFF04160A);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  User? _user;
  String? _role;
  bool _isLogin = true;
  bool _loading = false;
  bool _checkingRole = false;
  bool _obscurePassword = true;

  bool get _en => AppStrings.isEnglish;

  @override
  void initState() {
    super.initState();
    _user = AccountService.currentUser;
    _refreshAccount();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _refreshAccount() async {
    if (!FirebaseService.isInitialized) {
      if (mounted) setState(() {
        _user = null;
        _role = null;
        _checkingRole = false;
      });
      return;
    }

    final user = AccountService.currentUser;
    if (user == null) {
      if (mounted) setState(() {
        _user = null;
        _role = null;
        _checkingRole = false;
      });
      return;
    }

    setState(() {
      _user = user;
      _checkingRole = true;
    });
    try {
      final role = await AccountService.accountRole();
      if (!mounted) return;
      setState(() {
        _role = role;
        _checkingRole = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _role = 'player';
        _checkingRole = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _loading) return;
    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await AccountService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await AccountService.register(
          displayName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      await _refreshAccount();
      if (mounted) {
        _showMessage(
          _isLogin
              ? (_en ? 'Signed in successfully' : 'Вы вошли в аккаунт')
              : (_en ? 'Account created successfully' : 'Аккаунт создан'),
        );
      }
    } on FirebaseAuthException catch (error) {
      _showMessage(_authError(error.code));
    } catch (error) {
      _showMessage(
        error is StateError
            ? error.message ?? (_en ? 'Account error' : 'Ошибка аккаунта')
            : (_en
                ? 'Could not complete the request. Check Firebase setup.'
                : 'Не удалось выполнить запрос. Проверь настройку Firebase.'),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showMessage(
        _en ? 'Enter your email first' : 'Сначала введи свою почту',
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AccountService.sendPasswordReset(email);
      _showMessage(
        _en
            ? 'Password reset email sent'
            : 'Письмо для сброса пароля отправлено',
      );
    } on FirebaseAuthException catch (error) {
      _showMessage(_authError(error.code));
    } catch (_) {
      _showMessage(_en ? 'Could not send email' : 'Не удалось отправить письмо');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _loading = true);
    try {
      await AccountService.signOut();
      await _refreshAccount();
      if (mounted) _showMessage(_en ? 'Signed out' : 'Вы вышли из аккаунта');
    } catch (_) {
      _showMessage(_en ? 'Could not sign out' : 'Не удалось выйти из аккаунта');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _authError(String code) {
    if (_en) {
      return switch (code) {
        'email-already-in-use' => 'An account already exists for this email',
        'invalid-email' => 'Enter a valid email address',
        'weak-password' => 'Choose a stronger password',
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'Incorrect email or password',
        'too-many-requests' => 'Too many attempts. Try again later',
        'network-request-failed' => 'Check your internet connection',
        _ => 'Authentication failed. Please try again',
      };
    }
    return switch (code) {
      'email-already-in-use' => 'Аккаунт с такой почтой уже существует',
      'invalid-email' => 'Введи корректный адрес электронной почты',
      'weak-password' => 'Пароль слишком простой',
      'user-not-found' || 'wrong-password' || 'invalid-credential' =>
        'Неверная почта или пароль',
      'too-many-requests' => 'Слишком много попыток. Попробуй позже',
      'network-request-failed' => 'Проверь подключение к интернету',
      _ => 'Не удалось выполнить вход. Попробуй ещё раз',
    };
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF174A25),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDeveloper = AccountService.isDeveloperRole(_role);
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_en ? 'Account' : 'Аккаунт'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF164A27), Color(0xFF071D10), _background],
                ),
              ),
            ),
          ),
          Positioned(
            top: 90,
            right: -90,
            child: _glow(220, _green.withValues(alpha: 0.08)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              child: Column(
                children: [
                  _header(),
                  const SizedBox(height: 24),
                  if (!FirebaseService.isInitialized)
                    _configurationCard()
                  else if (_user != null)
                    _profileCard(isDeveloper)
                  else
                    _authCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: 85, spreadRadius: 30)],
    ),
  );

  Widget _glass({required Widget child}) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.075),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: child,
      ),
    ),
  );

  Widget _header() => Column(
    children: [
      Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _green.withValues(alpha: 0.12),
          border: Border.all(color: _green.withValues(alpha: 0.35)),
        ),
        child: const Icon(Icons.person_outline_rounded, color: _green, size: 39),
      ),
      const SizedBox(height: 14),
      Text(
        _en ? 'FOOTBALL CAREER' : 'FOOTBALL CAREER',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        _en ? 'Your game profile' : 'Твой игровой профиль',
        style: const TextStyle(color: Colors.white60, fontSize: 13),
      ),
    ],
  );

  Widget _configurationCard() => _glass(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.cloud_off_outlined, color: _green, size: 30),
        const SizedBox(height: 14),
        Text(
          _en ? 'Firebase is not configured' : 'Firebase ещё не настроен',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          _en
              ? 'To create an account, connect the Firebase project. Follow FIREBASE_SETUP.md in the project repository.'
              : 'Чтобы создать аккаунт, подключи проект Firebase. Пошаговая инструкция находится в файле FIREBASE_SETUP.md в репозитории игры.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        if (FirebaseService.initializationFailed) ...[
          const SizedBox(height: 12),
          Text(
            _en
                ? 'Firebase initialization failed. Check the project values.'
                : 'Не удалось подключить Firebase. Проверь значения проекта.',
            style: const TextStyle(color: Color(0xFFFFC078), fontSize: 12),
          ),
        ],
      ],
    ),
  );

  Widget _profileCard(bool isDeveloper) => _glass(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0x3322C55E),
              child: Icon(Icons.person, color: _green, size: 28),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user?.displayName?.isNotEmpty == true
                        ? _user!.displayName!
                        : (_en ? 'Player' : 'Игрок'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _user?.email ?? '',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: isDeveloper
                ? _green.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDeveloper
                  ? _green.withValues(alpha: 0.38)
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isDeveloper ? Icons.verified_user_rounded : Icons.person_outline,
                color: isDeveloper ? _green : Colors.white60,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _checkingRole
                      ? (_en ? 'Checking account...' : 'Проверка аккаунта...')
                      : isDeveloper
                          ? (_en ? 'Developer account · all modes unlocked' : 'Аккаунт разработчика · все режимы открыты')
                          : (_en ? 'Player account' : 'Обычный аккаунт игрока'),
                  style: TextStyle(
                    color: isDeveloper ? _green : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'UID',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                _user?.uid ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
            IconButton(
              tooltip: _en ? 'Copy UID' : 'Скопировать UID',
              onPressed: _user == null
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(text: _user!.uid));
                      _showMessage(_en ? 'UID copied' : 'UID скопирован');
                    },
              icon: const Icon(Icons.copy_rounded, color: Colors.white60, size: 19),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _checkingRole ? null : _refreshAccount,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(_en ? 'Refresh status' : 'Обновить статус'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: _green.withValues(alpha: 0.45)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _loading ? null : _signOut,
            icon: const Icon(Icons.logout_rounded),
            label: Text(_en ? 'Sign out' : 'Выйти из аккаунта'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _authCard() => _glass(
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isLogin
                ? (_en ? 'SIGN IN' : 'ВХОД В АККАУНТ')
                : (_en ? 'CREATE ACCOUNT' : 'СОЗДАНИЕ АККАУНТА'),
            style: const TextStyle(
              color: _green,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          if (!_isLogin) ...[
            _fieldLabel(_en ? 'Display name' : 'Имя игрока'),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(_en ? 'Your name' : 'Твоё имя'),
              validator: (value) {
                if (!_isLogin && (value == null || value.trim().length < 2)) {
                  return _en ? 'Enter at least 2 characters' : 'Минимум 2 символа';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
          ],
          _fieldLabel(_en ? 'Email' : 'Электронная почта'),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('name@example.com'),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (!email.contains('@') || email.startsWith('@') || email.endsWith('@')) {
                return _en ? 'Enter a valid email' : 'Введи корректную почту';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _fieldLabel(_en ? 'Password' : 'Пароль'),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              _en ? 'At least 6 characters' : 'Минимум 6 символов',
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white54,
                ),
              ),
            ),
            validator: (value) {
              if ((value ?? '').length < 6) {
                return _en ? 'Password must be at least 6 characters' : 'Пароль должен быть не короче 6 символов';
              }
              return null;
            },
          ),
          if (_isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading ? null : _resetPassword,
                child: Text(
                  _en ? 'Forgot password?' : 'Забыли пароль?',
                  style: const TextStyle(color: _green, fontSize: 12),
                ),
              ),
            )
          else
            const SizedBox(height: 16),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: const Color(0xFF082A12),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _isLogin
                          ? (_en ? 'SIGN IN' : 'ВОЙТИ')
                          : (_en ? 'REGISTER' : 'ЗАРЕГИСТРИРОВАТЬСЯ'),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _loading
                  ? null
                  : () => setState(() {
                        _isLogin = !_isLogin;
                        _formKey.currentState?.reset();
                      }),
              child: Text(
                _isLogin
                    ? (_en ? 'Create a new account' : 'Создать новый аккаунт')
                    : (_en ? 'Already have an account? Sign in' : 'Уже есть аккаунт? Войти'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
    filled: true,
    fillColor: Colors.black.withValues(alpha: 0.16),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _green),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFFFF7777)),
    ),
  );
}
