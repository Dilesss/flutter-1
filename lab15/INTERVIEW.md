# INTERVIEW.md — twenty questions in three sentences

Format of every answer: **definition · where it lives in my code · one level deeper** — then stop.
Code paths are in the users app (`lab14/lib/…`). ⭐ = took more than 40 s or started with "it depends" in practice → rehearse again.

### 1. StatelessWidget vs StatefulWidget
A StatelessWidget is a pure function of its constructor arguments; a StatefulWidget keeps a `State` object that survives rebuilds and can call `setState`. `UserTile` (`features/users/widgets/user_tile.dart`) is stateless; `LoginScreen` is stateful because it owns two `TextEditingController`s and the `_hide` flag. The widget itself is still immutable and recreated on every build — only the `State` object lives on, which is why controllers go in the State.

### 2. What is BuildContext
It is the widget's position in the element tree, and every `.of(context)` / `context.watch` lookup walks **up** from that position. In `settings_screen.dart`, `context.watch<SettingsModel>()` finds the provider created in `main.dart` above `MaterialApp`. A context below a provider can see it, a context above cannot — that is the whole "ProviderNotFoundException" error in one sentence.

### 3. setState — what it does and when not to use it
`setState` marks this State dirty so its `build` runs again on the next frame. I use it for local UI state: `_busy` in `profile_screen.dart`, `_hide` in `login_screen.dart`. When two screens need the same data (users list, theme, sign-in) setState is the wrong tool — that goes into a ChangeNotifier above both; and the callback must not be `async`.

### 4. initState / dispose — why dispose controllers
`initState` runs once when the State is inserted, `dispose` once when it is removed for good. `LoginScreen.dispose()` disposes both `TextEditingController`s; in Practice 10 `dispose` cancelled the `StreamSubscription`. A controller or subscription that is not disposed keeps listeners alive — a memory leak and, for streams, "setState called after dispose".

### 5. Keys — GlobalKey<FormState>
A key gives a widget an identity across rebuilds; a GlobalKey additionally lets me reach its State from outside. `_formKey` in `login_screen.dart` / `new_user_screen.dart` → `_formKey.currentState?.validate()`. `currentState` is nullable (the form may not be mounted), so I null-check it instead of using `!`.

### 6. Layout: constraints go down, sizes go up
A parent gives the child constraints, the child picks a size inside them, the parent places it. `UsersContent` is a `Column` with `Expanded(child: UserList)` so the list takes the remaining height. A `ListView` inside a `Column` without `Expanded` gets unbounded height — the classic "Vertical viewport was given unbounded height" error.

### 7. Navigation: push / pop and returning a value
`Navigator.push` puts a route on the stack and returns a Future that completes with the value given to `pop`. `UserTile` pushes `UserDetailScreen`; `showDialog<bool>` in `profile_screen.dart` returns true/false from `Navigator.pop(ctx, true)`. The result is nullable — the user can close with Back — so it is `open ?? false`, never `open!`.

### 8. Forms and validation
`Form` + `TextFormField(validator:)` + `GlobalKey<FormState>`; `validate()` runs every validator and shows the messages. Email and 8-character password in `login_screen.dart`; name, username, email in `new_user_screen.dart`. A validator returns `null` for "valid" and a String for the error — and the rule itself is a plain function, so it can be unit-tested without a widget.

### 9. ChangeNotifier and notifyListeners
A ChangeNotifier is a plain Dart class that holds state and calls `notifyListeners()` when it changes; provider rebuilds the widgets that watch it. `UsersModel.load()` sets `loading = true` → notify → awaits the repository → sets items/error → notify in `finally`. The model has no BuildContext and no `mounted` — it is not a widget, which is exactly why it can be tested with a fake repository.

### 10. watch / read / select ⭐
`watch` subscribes (rebuild on every notify), `read` takes the object once without subscribing, `select` subscribes to one derived value. `UsersScreen.build` uses `context.watch<UsersModel>()`; button callbacks use `context.read<AuthModel>()`; `LoginScreen` uses `context.select<AuthModel, bool>((a) => a.busy)`. `read` inside `build` is a bug (the widget never updates), and `watch` inside `onPressed` throws — provider asserts it outside build.

### 11. Future vs Stream, async/await
A Future is one value later, a Stream is many values over time; `await` pauses the function, not the app — the event loop keeps drawing frames. Every repository call is a Future (`getAll()`); the Practice 10 countdown was an `async*` Stream with `yield`. Dart is single-threaded: code after `await` runs in a later event, so the world (including `mounted`) may have changed.

### 12. FutureBuilder — why the future is a field ⭐
FutureBuilder rebuilds from an `AsyncSnapshot` as the future completes. `AboutScreen` keeps `final Future<PackageInfo> _info = PackageInfo.fromPlatform();` as a field and passes `_info`. Creating the future inside `build` restarts it on every rebuild — an endless spinner or a request per frame.

### 13. mounted after await
After an `await` the State may already be disposed (the user pressed Back), and `context` must not be used. `LoginScreen._submit`: `await auth.login(...)` → `if (!mounted) return;` → SnackBar; in a StatelessWidget it is `context.mounted` (`user_detail_screen.dart`). The lint `use_build_context_synchronously` finds the missing check for me.

### 14. JSON int vs double ⭐
JSON has one "number" type; `jsonDecode` gives an `int` for `1` and a `double` for `1.5`, so `json['x'] as double` throws on `1`. Safe form: `(json['x'] as num).toDouble()`; in my API `lat` is even a **string**, so `Geo.fromJson` uses `double.parse(json['lat'] as String)` (`features/users/user.dart`, line 8). Deeper: on **Flutter web** all numbers are JS doubles, so `1 is double` is true in Chrome and false on a phone — the same code behaves differently.

### 15. HTTP errors — status, timeout, sealed exceptions
`ApiClient` (`core/api/api_client.dart`) sends with a 10-second timeout, checks the status **before** the body, and turns everything into my sealed `ApiException`. SocketException/Timeout → `NoConnectionException`, 404 → `NotFoundException`, 5xx → `ServerException(status)`, bad JSON → `BadResponseException`. Because the class is sealed, the `switch` in `UsersErrorView` has no `default` and the compiler refuses to build if a new kind is not handled.

### 16. Repository pattern and dependency injection ⭐
A repository is the only layer that touches the outside world and returns models or my exceptions. `abstract interface class UserRepository` with `HttpUserRepository` and `FakeUserRepository`; `UsersModel(this._repo)` asks for the interface; `main.dart` chooses (`Env.useFakes`). Injection through the constructor is what makes the arrange step of a test possible — `tool/check_layers.sh` proves `package:http` stays in the data layer.

### 17. Where to keep data on the device
shared_preferences for settings, secure storage (Keychain / Keystore) for anything that lets someone be you, a file in Documents for data. Dark mode/city → `SettingsModel`; token → `core/storage/secure_store.dart`; last users list → `users_cache.dart` (`users.json`). prefs is a plain XML/plist file — a backup or a rooted phone reads it — and Temporary can be wiped by the OS at any time.

### 18. Runtime permissions
Declare in the manifest/Info.plist, request **at the tap**, handle every status. `ProfileScreen._takePhoto`: `Permission.camera.request()` → switch: granted → camera, denied → SnackBar, permanentlyDenied → my dialog → `openAppSettings()`. On Android 11+ two "Don't allow" make it permanent; on iOS one — and without the plist string iOS kills the app.

### 19. Testing: unit vs widget, fakes and MockClient
A unit test checks a class with no network, disk or clock; a widget test pumps a widget tree without a device. `user_repository_test.dart` (MockClient: 404 → NotFound…), `users_model_test.dart` (FakeUserRepository), `users_screen_test.dart` (pumpWidget → "No connection" → tap Retry → spinner). 14 tests run in about a second in airplane mode — a test that needs Wi-Fi is not a unit test.

### 20. Release: version, signing, environments
`version: 1.0.1+2` — 1.0.1 is for people, 2 is the build number the store requires to go up; the APK is signed with **my** upload key. `build.gradle.kts` reads `key.properties` (gitignored); `--dart-define-from-file=env/prod.json` bakes in the host; `--obfuscate --split-debug-info` + archived symbols. Three things you cannot fix after install: the applicationId, the signing key, and a build number that did not go up.

---

## Three stories (one minute each)

### A bug in five beats
- **Symptom.** After Practice 12 one test went red: `fromJson / toJson round-trip` — "Which: is different … trailing characters: 56442".
- **Wrong first guess.** I thought the RegExp in `phoneDigits` was broken and was about to change the getter.
- **What actually found it.** Reading the matcher's *Which* line slowly: the actual value was `1770736803156442` — the digits of the extension `x56442`. The getter did exactly what the spec says ("keep digits and +"); the **expected** value in my test was wrong.
- **The fix.** One line in the test, not in the code: `expect(u.phoneDigits, '1770736803156442')` — and a comment why.
- **The habit.** When a test is red I first ask "is the code wrong or is the test wrong?" and read Expected / Actual / Which before touching anything.

### A design decision
Why does `ApiClient` take an `http.Client` in its constructor instead of creating one? The alternative was `final _client = http.Client();` inside the class — shorter, and it works in the app. The cost: no test could run without the internet, and 404 / 500 / no-network could not be produced on demand. With injection, `MockClient` returns any status in one line, and 14 tests run offline in a second.

### One thing I would do differently
I would write `FakeUserRepository` **first** and build every screen against it. The real API arrived in Practice 11 and the screens were shaped around it; the fake and the interface came two weeks later in Practice 13 and forced a refactor of eighteen commits. With the fake first, the loading / error / empty / data states would have existed from day one, and the tests too.
