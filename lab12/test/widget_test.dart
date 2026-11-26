import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab12/core/api/api_client.dart';
import 'package:lab12/core/api/api_exception.dart';
import 'package:lab12/core/storage/secure_store.dart';
import 'package:lab12/features/users/user.dart';
import 'package:lab12/features/users/user_repository.dart';
import 'package:lab12/features/users/users_cache.dart';

const _json = {
  'id': 1,
  'name': 'Leanne Graham',
  'username': 'Bret',
  'email': 'Sincere@april.biz',
  'address': {
    'street': 'Kulas Light',
    'suite': 'Apt. 556',
    'city': 'Gwenborough',
    'zipcode': '92998-3874',
    'geo': {'lat': '-37.3159', 'lng': '81.1496'},
  },
  'phone': '1-770-736-8031 x56442',
  'website': 'hildegard.org',
  'company': {'name': 'Romaguera-Crona', 'catchPhrase': 'Multi-layered'},
};

/// A store in memory — no Keychain in a unit test.
class _MemoryStore implements SecureStore {
  _MemoryStore([this.value]);
  String? value;

  @override
  Future<void> saveToken(String token) async => value = token;
  @override
  Future<String?> readToken() async => value;
  @override
  Future<void> clear() async => value = null;
}

/// A cache in memory — no Documents folder in a unit test.
class _MemoryCache implements UsersCache {
  _MemoryCache([this.saved]);
  List<User>? saved;

  @override
  Future<void> save(List<User> users) async => saved = users;
  @override
  Future<List<User>?> load() async => saved;
}

UserRepository _repo(
  Future<http.Response> Function(http.Request r) answer, {
  String? token,
  List<User>? cached,
}) => UserRepository(
  ApiClient(MockClient(answer), _MemoryStore(token)),
  _MemoryCache(cached),
);

void main() {
  test('fromJson / toJson round-trip', () {
    final u = User.fromJson(_json);
    expect(u.address.geo.lat, -37.3159);
    expect(u.phoneDigits, '1770736803156442'); // "x56442" keeps its digits
    expect(User.fromJson(u.toJson()), u);
  });

  test('404 → NotFoundException', () {
    final repo = _repo((_) async => http.Response('{}', 404));
    expect(repo.getById(999), throwsA(isA<NotFoundException>()));
  });

  test('500 → ServerException', () {
    final repo = _repo((_) async => http.Response('oops', 500));
    expect(repo.getAll(), throwsA(isA<ServerException>()));
  });

  test('the token goes into the Authorization header', () async {
    String? header;
    final repo = _repo((r) async {
      header = r.headers['Authorization'];
      return http.Response(jsonEncode([_json]), 200);
    }, token: 'tok_1');
    await repo.getAll();
    expect(header, 'Bearer tok_1');
  });

  test('online → fresh list, not from cache', () async {
    final repo = _repo((_) async => http.Response(jsonEncode([_json]), 200));
    final r = await repo.getAll();
    expect(r.items.length, 1);
    expect(r.fromCache, isFalse);
  });

  test('offline with a saved list → the saved list, fromCache', () async {
    final repo = _repo(
      (_) async => throw const SocketException('down'),
      cached: [User.fromJson(_json)],
    );
    final r = await repo.getAll();
    expect(r.fromCache, isTrue);
    expect(r.items.single.name, 'Leanne Graham');
  });

  test('offline with nothing saved → NoConnectionException', () {
    final repo = _repo((_) async => throw const SocketException('down'));
    expect(repo.getAll(), throwsA(isA<NoConnectionException>()));
  });
}
