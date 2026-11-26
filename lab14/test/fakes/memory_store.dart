import 'package:lab13/core/storage/secure_store.dart';

/// A SecureStore in memory — no Keychain in a unit test.
class MemoryStore implements SecureStore {
  MemoryStore([this.value]);

  String? value;

  @override
  Future<void> saveToken(String token) async => value = token;

  @override
  Future<String?> readToken() async => value;

  @override
  Future<void> clear() async => value = null;
}
