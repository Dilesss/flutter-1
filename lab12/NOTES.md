# Practice 12 — Survive a Restart (lab12)

Three places to keep things:
**shared_preferences** — settings · **secure storage** — anything that lets someone be you · **a file in Documents** — data. Temporary is temporary.

## Level 1 — six package verdicts

Order: publisher · last release · platforms · pub points · issues vs commits · dependencies · licence. (Checked on pub.dev, 21 Nov 2026.)

| package | verdict |
|---|---|
| shared_preferences 2.5.6 | Verified publisher **flutter.dev**, Flutter Favorite, released **Oct 2026**, all six platforms, **160/160** points, maintained in flutter/packages with commits every month, depends only on its own platform implementations, **BSD-3-Clause**. |
| flutter_secure_storage 11.2.0 | Verified publisher **steenbakker.dev** (a community maintainer, not Google), released **Sep 2026**, all six platforms, **160/160** points, many open issues but regular releases, depends on its platform packages, **BSD-3-Clause**. |
| path_provider 2.1.6 | Verified publisher **flutter.dev**, Flutter Favorite, released **Jun 2026**, Android · iOS · Linux · macOS · Windows (no Web — a browser has no file system), **160/160** points, maintained by the Flutter team, no dependencies of note, **BSD-3-Clause**. |
| image_picker 1.2.4 | Verified publisher **flutter.dev**, released **Oct 2026**, all six platforms, **160/160** points, maintained by the Flutter team, depends on its platform packages, **Apache-2.0 + BSD-3-Clause** (multiple licences). |
| permission_handler 13.0.2 | Verified publisher **baseflow.com** (a company), released **Sep 2026**, Android · iOS · Web · Windows, **160/160** points, many open issues but active commits, depends on its platform packages, **MIT**. |
| url_launcher 6.3.3 | Verified publisher **flutter.dev**, Flutter Favorite, released **Oct 2026**, all six platforms, **160/160** points, maintained by the Flutter team, depends on its platform packages, **BSD-3-Clause**. |

### The caret and the lock

- `http: ^1.2.0` means `>=1.2.0 <2.0.0`. It **accepts** 1.2.0, 1.2.5, 1.6.0 (same major — no breaking changes by semver). It **refuses** 1.1.x (too old) and 2.0.0 (a new major may break my code).
- Exact version of http resolved in `pubspec.lock`: **http 1.6.0** (`^1.6.0` in pubspec.yaml after `flutter pub add`)
- **pubspec.lock is committed for an app** so that my laptop, a classmate and the CI build the *same* versions. (For a package/library it is not committed.)
- `flutter pub outdated`: **cross_file 0.3.5+5**, while **0.4.0** is available. It was not upgraded because it is not my direct dependency: image_picker needs `cross_file ^0.3.x`, and 0.4.0 is a new "major" for a 0.x package (the caret on 0.3 allows only 0.3.*). It will move when image_picker allows it.
- Break-it: `http: 1.2.0` without a caret → the lock pins exactly 1.2.0, pub outdated shows newer as unavailable. Caret put back.

## Level 2 — settings before runApp

`main()` reads `darkMode` and `cityFilter` with `SharedPreferencesAsync` **before** `runApp`, so the first frame already has the right theme. Moving the read into the model's constructor gives one light frame, then dark — the flash.
`setDark` calls `notifyListeners()` first and only then `await`s the disk: the screen does not wait for the disk.

## Level 3 — the token

- `prefs.setString('token', …)` would put the token in a **plain XML file** (Android: `shared_prefs/…xml`) or a **plist** (iOS) inside the app folder. Readable by: a device **backup**, anyone with **root** / a jailbroken phone, a debugger over a **USB cable**.
- flutter_secure_storage uses the **iOS Keychain** and **Android Keystore**-encrypted storage.
- Platform surprise 1 — **iOS**: Keychain items can **survive an uninstall**; after reinstalling, the "old" token may still be there.
- Platform surprise 2 — **Android**: if the user **removes the lock screen**, Keystore keys may be **invalidated**, and the stored value cannot be decrypted any more (read fails → treat as signed out).
- The token is never printed and never in shared_preferences; ApiClient adds `Authorization: Bearer …` itself.

## Level 4 — offline list

`users.json` in `getApplicationDocumentsDirectory()`. Online → save; NoConnection → saved list + banner; nothing saved → rethrow → honest Offline screen. With `getTemporaryDirectory()` + "Clear cache" the list disappears silently — the OS kept the promise of the name.

## Level 5 — permissions

- **Android**: Don't allow → Don't allow → the 3rd tap: no system dialog, status **permanentlyDenied**, my dialog → Open settings.
- **iOS**: the system asks **only once**; one "Don't Allow" → **permanentlyDenied** right away. The fourth Photos state is **limited** ("Selected Photos" access, iOS 14+).
- `launchUrl(Uri.parse('kbtu.edu.kz'))` without a scheme → **false**, nothing opens; with `https://` the browser opens.

Screenshots: `screenshot_offline_banner.png`, `screenshot_permission_dialog.png`.
