# Practice 13 — Where Things Go (lab13)

One rule: **dependencies point down** — screens watch models, models use repositories, repositories touch the world — and never up.

## Level 1 — feature-first, one move per commit

```
lib/
  main.dart                     composition root: the only HttpUserRepository(…)
  app.dart                      MaterialApp, theme, Login vs Users
  core/api/                     api_client.dart, api_exception.dart (sealed)
  core/storage/secure_store.dart
  features/users/               user.dart, user_repository.dart (interface + Http…),
                                fake_user_repository.dart, users_cache.dart,
                                users_model.dart, users_screen.dart, user_detail_screen.dart,
                                new_user_screen.dart, widgets/ (one widget per file)
  features/auth/                auth_model.dart, login_screen.dart
  features/settings/            settings_model.dart, settings_screen.dart
  features/profile/             profile_screen.dart
test/                           mirrors lib/
  features/users/               user_test, user_repository_test, users_model_test, users_screen_test
  fakes/                        fake_user_repository (export), memory_store, memory_cache, fake_prefs, user1_json
tool/check_layers.sh            the layer rule — prints nothing
tool/planted_bug_test.dart      Level 5, red on purpose
```

- No `utils.dart` / `helpers.dart`. One class per file, named after the class — except where Dart needs them together: the **sealed** ApiException family must live in one library, and `user.dart` keeps Geo/Address/User (one JSON shape), `user_repository.dart` keeps the interface with its Http implementation.
- `git log --oneline -- lab13` reads like the plan: every commit is one named move.
- **Break-it:** `import 'package:http/http.dart' as http;` in users_screen.dart compiles and runs — but `tool/check_layers.sh` prints the file. *The compiler has no opinion about layers — the script does.*

## Level 2 — interfaces and fakes

- `abstract interface class UserRepository { getAll(); getById(id); create(draft); }`
- `HttpUserRepository implements UserRepository` (real), `FakeUserRepository implements UserRepository` (two users in Dart, `fail:` / `delay:`).
- `UsersModel(this._repo)` asks for the **interface**; `AuthModel(SecureStore, …)`, `SettingsModel(SharedPreferencesAsync, …)` — everything that touches the disk or the wire comes through the constructor.
- `grep -rn "HttpUserRepository(" lib/` → the call in **main.dart** (plus the constructor's own declaration line in user_repository.dart — that is the class, not a caller).
- Demo mode: swap the commented line in main.dart → two users, instantly, no network.
- **Why the old model could not be tested:** in Practice 11 the model was built in main as `UsersModel(UserRepository(ApiClient(http.Client())))` and the repository was a concrete class with no interface. **The first line I cannot write is the arrange step** — there is no way to give the model a repository that fails on demand without a real network.

## Level 3 — tests

`flutter test` — no network, no disk, no clock: MockClient for http, MemoryStore for the Keychain, MemoryCache for Documents, FakeUserRepository for the model.

- Break-it: `on ApiException catch (e) { error = e; }` → empty `catch (e) {}` → "NoConnection sets error" goes red: *Expected: <Instance of 'NoConnectionException'> Actual: <null>*. Restored → green.

## Level 4 — extract widgets

UsersScreen's states became widgets in `widgets/`: `UsersContent`, `CityFilterRow`, `EmptyView`, `OfflineBanner`, `UsersErrorView`, `OfflineView`, `ServerErrorView`, `NotAvailableView`, `GenericErrorView`, `LoadingView`, `MessageView`, `UserTile`. Every `build()` is under 60 lines.

**Why a widget and not a `_buildHeader()` method** (two lines):
A widget can be **const** (built once, skipped on rebuild), has **its own rebuild scope** and its own BuildContext, **appears by name in DevTools**, and can be **tested alone** with `pumpWidget`.
A method is just code inlined into the parent's build — it rebuilds every time the parent does and is invisible to all of those tools.

- Break-it: the Retry label → "Try again" → the widget test fails: *Expected: exactly one matching candidate, Actual: _TextWidgetFinder:<Found 0 widgets with text "Retry">*. Changed back.

## Level 5 — read a trace in thirty seconds

Planted: `"lat": -37.3159` (a number) in `tool/planted_bug_test.dart`, run with `flutter test tool/planted_bug_test.dart`.

The trace from my machine (also in `docs/planted_bug_trace.txt`):

```
type 'double' is not a subtype of type 'String' in type cast
  package:lab13/features/users/user.dart 8:35   new Geo.fromJson
  package:lab13/features/users/user.dart 32:14  new Address.fromJson
  package:lab13/features/users/user.dart 71:24  new User.fromJson
  tool/planted_bug_test.dart 30:34              PlantedBugRepository.getAll
```

Annotated:

1. **The message** — `type 'double' is not a subtype of type 'String' in type cast`: something promised a String and got a double.
2. **My first frame** — `Geo.fromJson (package:lab13/features/users/user.dart 8:35)` — **line 8, column 35** is the `as String` cast inside `double.parse(json['lat'] as String)`.
3. **The path down** — `Address.fromJson (user.dart:32)` → `User.fromJson (user.dart:71)` → `PlantedBugRepository.getAll (planted_bug_test.dart 30:34)` — then, after the `await` (`<asynchronous suspension>`), it surfaces in `UsersModel.load`, which catches only `ApiException`, so the TypeError escapes and the test goes red. (flutter test folds the frames after the first async gap.)
4. **The data that went in** — field `address.geo.lat` of user **1** (Leanne Graham): a JSON number instead of a string.

**Why #0 is the right place to throw and the wrong place to fix:** `Geo.fromJson` is where the broken promise is *noticed*, so it must throw there; but the *cause* is the server breaking the contract, so the fix belongs at the boundary — the repository maps the TypeError to `BadResponseException('users: …')` and the screen shows the generic error instead of crashing (test: `user_repository_test.dart` → "a numeric lat from the server → BadResponseException").

## Quality

`avoid_print` is enforced; lib/ uses `log(…, name: 'api' | 'cache')` and `debugPrint` only. The four commands and their output are at the end of README.md.
