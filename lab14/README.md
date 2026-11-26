# Users — a Flutter REST client (lab14)

A small Android/iOS app for the users of jsonplaceholder.typicode.com: sign in, browse and filter users, works offline from a saved copy, profile photo, signed release APK.

## Run it — four ways

```
flutter run                                              # defaults: env local, the public host
flutter run --dart-define=USE_FAKES=true                 # no network at all: two fake users
flutter run --dart-define-from-file=env/local.json       # the local environment file
flutter build apk --release --dart-define-from-file=env/prod.json   # the production build
```

The full release command (Practice 14):

```
flutter build apk --release --split-per-abi --obfuscate \
  --split-debug-info=build/symbols --dart-define-from-file=env/prod.json
```

Release APK (arm64): see **Releases → v1.0.1** — install on any Android phone.

## Architecture (five lines)

- `features/<name>/` — screen, ChangeNotifier, repository, per feature
- `core/api/` — ApiClient: Uri.https, 10 s timeout, sealed ApiException; `core/env.dart` — the only `fromEnvironment`
- repositories behind interfaces; fakes for tests and demo mode (`USE_FAKES`)
- storage: shared_preferences (settings), secure storage (token), file cache
- `flutter test`: 14 tests — models, error mapping, one widget test

## Pre-release checklist (14 boxes)

- [x] 1. **applicationId** is mine and final — `kz.dilnaz.users` (namespace the same)
- [x] 2. **Version** bumped, read from pubspec — `1.0.1+2`, `versionCode = flutter.versionCode`
- [ ] 3. **Signed with my upload key**, not the debug key — `keytool -printcert` in NOTES.md <!--sign-->
- [x] 4. **No secret ever committed** — `.gitignore` has `*.jks`, `*.keystore`, `android/key.properties`
- [ ] 5. **Key backed up** off this laptop — where: NOTES.md <!--backup-->
- [x] 6. **Production host baked in** at build time — `env/prod.json`, About shows `prod`
- [x] 7. **INTERNET** declared in the main AndroidManifest.xml
- [x] 8. **Name and icon** — "Users", adaptive icon (`flutter_launcher_icons.yaml`)
- [x] 9. **Splash** incl. Android 12 — `flutter_native_splash.yaml`
- [x] 10. **No debug UI in release** — dev host switch and "Copy token" behind `kDebugMode`
- [ ] 11. **Obfuscated, symbols archived** with the APK — `releases/1.0.1+2/symbols` <!--symbols-->
- [x] 12. **Quality** — `flutter analyze` 0, `dart format` clean, `flutter test` green, `tool/check_layers.sh` empty
- [ ] 13. **Installed from the file on a real phone**, over mobile data — `screenshot_about_release.png`
- [ ] 14. **GitHub Release v1.0.1** with the arm64 APK attached — `screenshot_release_page.png`
