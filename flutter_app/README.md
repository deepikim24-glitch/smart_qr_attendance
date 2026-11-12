# Flutter application location

This repository was already initialized as a Flutter project at the workspace root (`smart_qr_attendance/`), including `android/`, `ios/`, and `lib/`.

To avoid duplicating platform tooling, the Flutter app is implemented at:

- `../lib/`
- `../pubspec.yaml`
- `../test/`

Run the app from the repository root:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```
