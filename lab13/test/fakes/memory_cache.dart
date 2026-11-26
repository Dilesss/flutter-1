import 'package:lab13/features/users/user.dart';
import 'package:lab13/features/users/users_cache.dart';

/// A UsersCache in memory — no Documents folder in a unit test.
class MemoryCache implements UsersCache {
  MemoryCache([this.saved]);

  List<User>? saved;

  @override
  Future<void> save(List<User> users) async => saved = users;

  @override
  Future<List<User>?> load() async => saved;
}
