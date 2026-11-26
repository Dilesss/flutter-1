import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab13/core/api/api_client.dart';
import 'package:lab13/core/api/api_exception.dart';
import 'package:lab13/features/users/user.dart';
import 'package:lab13/features/users/user_repository.dart';

import '../../fakes/memory_cache.dart';
import '../../fakes/memory_store.dart';
import '../../fakes/user1_json.dart';

/// The MockClient is why ApiClient takes an http.Client in its constructor.
HttpUserRepository _repo(
  Future<http.Response> Function(http.Request r) answer, {
  String? token,
  List<User>? cached,
}) => HttpUserRepository(
  ApiClient(MockClient(answer), MemoryStore(token)),
  MemoryCache(cached),
);

String get _listOfOne => '[$user1Json]';

void main() {
  group('status → exception', () {
    test('404 → NotFoundException', () {
      final repo = _repo((_) async => http.Response('{"error":"gone"}', 404));
      expect(repo.getById(99), throwsA(isA<NotFoundException>()));
    });

    test('500 → ServerException', () {
      final repo = _repo((_) async => http.Response('oops', 500));
      expect(repo.getAll(), throwsA(isA<ServerException>()));
    });

    test('SocketException → NoConnectionException (nothing cached)', () {
      final repo = _repo((_) async => throw const SocketException('down'));
      expect(repo.getAll(), throwsA(isA<NoConnectionException>()));
    });
  });

  group('the planted bug (Level 5)', () {
    test('a numeric lat from the server → BadResponseException, no crash', () {
      final broken = _listOfOne.replaceFirst('"-37.3159"', '-37.3159');
      final repo = _repo((_) async => http.Response(broken, 200));
      expect(
        repo.getAll(),
        throwsA(
          isA<BadResponseException>().having(
            (e) => e.detail,
            'detail',
            contains('users'),
          ),
        ),
      );
    });
  });

  group('cache and token', () {
    test('online → fresh list, not from cache', () async {
      final repo = _repo((_) async => http.Response(_listOfOne, 200));
      final result = await repo.getAll();
      expect(result.items.single.name, 'Leanne Graham');
      expect(result.fromCache, isFalse);
    });

    test('offline with a saved list → the saved list, fromCache', () async {
      final saved = User.fromJson(
        jsonDecode(user1Json) as Map<String, dynamic>,
      );
      final repo = _repo(
        (_) async => throw const SocketException('down'),
        cached: [saved],
      );
      final result = await repo.getAll();
      expect(result.fromCache, isTrue);
      expect(result.items.single, saved);
    });

    test('the token goes into the Authorization header', () async {
      String? header;
      final repo = _repo((r) async {
        header = r.headers['Authorization'];
        return http.Response(_listOfOne, 200);
      }, token: 'tok_1');
      await repo.getAll();
      expect(header, 'Bearer tok_1');
    });
  });
}
