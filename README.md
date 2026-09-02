# Data Portal Survey

Flutter mobile app for collecting and submitting survey data.

| | |
|---|---|
| **Platforms** | iOS · Android |
| **Package name** | `com.infocare.dataportalsurvey` |
| **Dart package** | `data_portal_survey` |
| **Framework** | Flutter (Dart SDK `^3.10`) |

## Architecture

Feature-first modules with shared infrastructure:

```text
lib/
├── main.dart
├── common/          # HTTP, theme, widgets, storage, wrappers
├── features/        # auth, onboard, home, survey, profile, notification, support
└── navigation/      # auto_route + AppNavigator
```

## Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Firebase configs currently still point at the previous project. Replace `google-services.json`, `GoogleService-Info.plist`, and `lib/firebase_options.dart` with a Firebase app registered as `com.infocare.dataportalsurvey` before enabling push notifications.
