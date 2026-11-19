import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

/// Owns loading / error / items. Not a State (no mounted, no context)
/// and not a repository (no http).
class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;

  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool saving = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.getAll();
    } on ApiException catch (e) {
      error = e;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// POST. Returns null on success, or the ApiException so the form
  /// can show a SnackBar and stay open.
  Future<ApiException?> create(User draft) async {
    if (saving) return null; // a double tap sends one request
    saving = true;
    notifyListeners();
    try {
      final created = await _repo.create(draft);
      items = [created, ...items]; // the server's user, at the top
      return null;
    } on ApiException catch (e) {
      return e;
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
