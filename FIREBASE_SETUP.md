# Настройка Firebase для Football Career

Firebase-конфигурация не хранится в Git. Значения передаются локально через
параметры `--dart-define`.

## 1. Создать проект и Android-приложение

1. Создайте проект в Firebase Console.
2. Добавьте Android-приложение с package name из `android/app/build.gradle.kts`:
   `com.example.flutter_football`.
3. В настройках приложения скопируйте значения Firebase:
   - Web API Key;
   - Project ID;
   - Messaging Sender ID;
   - App ID Android-приложения.

Firebase client config не является паролем или приватным ключом, но не нужно
добавлять локальные файлы конфигурации в Git.

## 2. Включить авторизацию

В Firebase Console откройте Authentication → Sign-in method и включите
провайдер Email/Password.

## 3. Создать Firestore

Создайте Cloud Firestore Database. Откройте Rules и опубликуйте содержимое
файла `firestore.rules` из репозитория.

Правила позволяют аккаунту читать только собственный профиль. Создать профиль
через приложение можно только с ролью `player`. Изменить роль на `developer`
может только владелец Firebase-проекта через консоль.

## 4. Запустить Android-приложение

1. Скачайте `google-services.json` из Firebase Console.
2. Положите его в `android/app/google-services.json`.
3. В Firebase Console убедитесь, что включён Authentication → Sign-in method →
   Email/Password, а также создана база Cloud Firestore.
4. Из корня проекта выполните:

```powershell
flutter clean
flutter pub get
flutter run
```

Для Android параметры Firebase читаются через Google Services Gradle plugin
из `google-services.json`. Вручную добавлять Firebase BoM или нативные
`implementation("com.google.firebase:...")` зависимости не нужно: FlutterFire
подключает SDK через зависимости Flutter.

Для других платформ можно передавать параметры Firebase через
`--dart-define`, как описано ниже. Android-конфигурация через JSON уже
поддерживается автоматически.

## 5. Назначить личный аккаунт разработчиком

1. Запустите игру с Firebase-конфигурацией и зарегистрируйте свой аккаунт.
2. Откройте экран аккаунта и скопируйте свой UID.
3. В Firebase Console откройте Firestore → коллекцию `users` → документ
   с этим UID.
4. Измените поле `role` с `player` на `developer` и сохраните документ.
5. В приложении нажмите «Обновить статус» или заново войдите в аккаунт.

После этого магазин и экран создания карьеры будут считать все доступные
режимы открытыми для этого UID. Остальные аккаунты останутся обычными.

## Примечание

На этом этапе добавляются регистрация, вход, восстановление пароля и
защищённая роль разработчика. Облачная синхронизация слотов карьеры и FC Points
будет следующим этапом. Текущие локальные сохранения не удаляются и не
переносятся автоматически.
