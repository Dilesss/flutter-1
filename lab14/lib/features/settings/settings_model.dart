import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings that survive a restart. The first values are read in main()
/// BEFORE runApp and passed in here — so the first frame is already right.
class SettingsModel extends ChangeNotifier {
  SettingsModel(
    this._prefs, {
    required bool dark,
    String? city,
    String? avatarPath,
  }) : _isDark = dark,
       _cityFilter = city,
       _avatarFile = avatarPath;

  static const darkKey = 'darkMode';
  static const cityKey = 'cityFilter';
  static const avatarKey = 'avatarPath';

  final SharedPreferencesAsync _prefs;
  bool _isDark;
  String? _cityFilter;
  String? _avatarFile;

  bool get dark => _isDark;
  String? get city => _cityFilter;
  String? get avatarPath => _avatarFile;

  /// The screen first, the disk second: notifyListeners() before the await.
  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners();
    await _prefs.setBool(darkKey, value);
  }

  /// null = "All cities": the key is removed, not saved as an empty string.
  Future<void> setCity(String? city) async {
    _cityFilter = city;
    notifyListeners();
    if (city == null) {
      await _prefs.remove(cityKey);
    } else {
      await _prefs.setString(cityKey, city);
    }
  }

  Future<void> setAvatarPath(String path) async {
    _avatarFile = path;
    notifyListeners();
    await _prefs.setString(avatarKey, path);
  }
}
