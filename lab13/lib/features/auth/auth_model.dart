import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

/// A fake login with a real secure store.
class AuthModel extends ChangeNotifier {
  /// [savedToken] is read from the secure store in main() before runApp.
  AuthModel(this._store, String? savedToken) : _currentToken = savedToken;

  final SecureStore _store;
  String? _currentToken;

  bool busy = false;
  String? error;

  bool get signedIn => _currentToken != null;

  /// Only for the debug "Copy token" button — never printed, never logged.
  String? get token => _currentToken;

  /// The fake server: any password of 8+ characters gives a token
  /// after one second.
  Future<void> login(String email, String password) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (password.length < 8) {
        error = 'Wrong email or password';
        return;
      }
      final token = 'tok_${email.hashCode}';
      await _store.saveToken(token);
      _currentToken = token;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _store.clear();
    _currentToken = null;
    notifyListeners();
  }
}
