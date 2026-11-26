import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/settings/settings_model.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_cache.dart';
import 'features/users/users_model.dart';

/// The order matters: the binding, then the disk, then runApp.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // before any plugin

  // Settings — read BEFORE the first frame, so there is no light flash.
  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool(SettingsModel.darkKey) ?? false;
  final city = await prefs.getString(SettingsModel.cityKey); // String?
  final avatar = await prefs.getString(SettingsModel.avatarKey); // String?

  // The token — from the Keychain / Keystore, not from prefs.
  const store = SecureStore();
  final token = await store.readToken(); // String?

  // The composition root: the ONLY place that chooses real or fake.
  // ApiClient.live(store) = ApiClient(http.Client(), store).
  final api = ApiClient.live(store);
  final UserRepository repo = HttpUserRepository(api, const UsersCache());
  // Demo mode (no network, two users) — swap the line above for:
  // final UserRepository repo = FakeUserRepository();
  // (and import 'features/users/fake_user_repository.dart')

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              SettingsModel(prefs, dark: dark, city: city, avatarPath: avatar),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token)),
        ChangeNotifierProvider(create: (_) => UsersModel(repo)..load()),
      ],
      child: const App(),
    ),
  );
}
