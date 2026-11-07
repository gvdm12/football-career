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

## 4. Запустить приложение

В PowerShell из корня проекта выполните команду, подставив значения своего
Firebase-проекта:

```powershell
flutter run `
  --dart-define=FIREBASE_API_KEY=ВАШ_API_KEY `
  --dart-define=FIREBASE_ANDROID_APP_ID=ВАШ_ANDROID_APP_ID `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=ВАШ_SENDER_ID `
  --dart-define=FIREBASE_PROJECT_ID=ВАШ_PROJECT_ID
```

Если Firebase Console показывает Auth Domain или Storage Bucket, их можно
дополнительно передать через `FIREBASE_AUTH_DOMAIN` и
`FIREBASE_STORAGE_BUCKET`.

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
