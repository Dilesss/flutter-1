import 'package:shared_preferences/shared_preferences.dart';

/// Preferences that do nothing — enough for a widget test that never
/// changes a setting. Every call answers with an empty Future.
class FakePrefs implements SharedPreferencesAsync {
  const FakePrefs();

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}
