# POUYANLY — Flutter Android MVP

Persian-first, RTL, offline-first English learning prototype.

## Implemented in this source snapshot
- Persian welcome and 4-step onboarding (goal, self-assessed level, daily time, preferred time)
- 12-item placement flow with skill labels, feedback, and a basic difficulty progression across CEFR-tagged items
- Separate skill score summary; speaking is explicitly marked unavailable and listening is transcript-based
- CEFR learning-path screen, first interactive lesson, vocabulary review cards, XP/coins, profile and dark mode
- Local persistence of onboarding, scores, progress, preferences and vocabulary through `shared_preferences`

## Explicit MVP limitations
- Placement test is a small diagnostic sample, not a validated CEFR exam. The current scoring is provisional.
- Speaking recognition is not implemented. Listening currently uses a transcript, not audio.
- Reminder preference is stored, but Android scheduled notifications are not yet wired up.
- The included course content is seed content for the MVP, not a complete A1–C2 curriculum.
- No backend, account sync, leaderboard or generative AI is included. Core learning screens are designed to work offline after installation.

## Requirements
- Flutter stable (Dart 3.4+)
- Android SDK / Android Studio command-line tools
- Android device or emulator

## Run
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Build APK
```bash
flutter build apk --release
```
APK output: `build/app/outputs/flutter-apk/app-release.apk`

## Android project scaffolding
This delivery contains the Flutter application source and package manifest. Generate the platform scaffolding with:
```bash
flutter create --platforms=android --org com.pouyanly .
flutter pub get
flutter build apk --release
```
If Flutter is installed on macOS, run these commands from this directory. The build requires the Android SDK and an installed Android platform/build-tools version.
