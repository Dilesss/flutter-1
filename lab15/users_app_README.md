# Users — a Flutter REST client

A small Android/iOS app for browsing the users of a REST API — with sign-in, a city filter, an offline copy and a profile photo — built as the semester project of the KBTU Mobile Development course.

| ![list](docs/list.png) | ![offline](docs/offline.png) |
|---|---|

## Run it

```
flutter pub get
flutter run --dart-define=USE_FAKES=true      # no network needed
flutter run --dart-define-from-file=env/prod.json
```

Release APK (arm64): see **Releases** → v1.0.1 — install on any Android phone.

## Architecture (five lines)

- `features/<name>/` — screen, ChangeNotifier, repository, per feature (users, auth, settings, profile, about)
- `core/api/` — ApiClient: Uri.https, 10 s timeout, sealed ApiException; `core/env.dart` — build-time environment
- repositories behind interfaces; fakes for tests and demo mode
- storage: shared_preferences (settings), secure storage (token), file cache (offline list)
- `flutter test`: 14 tests — models, error mapping, one widget test

## Team

| Area | Owner | Reviewer |
|---|---|---|
| users list, API, offline cache | Dilnaz Yessenkyzy | *(classmate)* |
| auth, settings, profile | Dilnaz Yessenkyzy | *(classmate)* |
| release, CI checks | Dilnaz Yessenkyzy | *(classmate)* |
