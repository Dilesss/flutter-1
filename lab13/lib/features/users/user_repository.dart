import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

/// Where the list came from: the server, or the file from last time.
typedef UsersResult = ({List<User> items, bool fromCache});

/// Screens ask this class for Users and get Users — or an ApiException.
/// Never a Response, never a status code, never a Map.
class UserRepository {
  UserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  /// Fresh from the server (and saved), or — with no network — the saved
  /// list. Nothing saved and no network → NoConnectionException.
  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetchAll();
      await _cache.save(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<List<User>> _fetchAll() async {
    final body = await _api.run(
      (http.Client c, Map<String, String> h) =>
          c.get(_api.uri('/users'), headers: h),
    );
    return _parse('users', () {
      return (body as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<User> getById(int id) async {
    final body = await _api.run(
      (http.Client c, Map<String, String> h) =>
          c.get(_api.uri('/users/$id'), headers: h),
    );
    return _parse(
      'users/$id',
      () => User.fromJson(body as Map<String, dynamic>),
    );
  }

  /// POST: the server answers 201 with what we sent plus its own id.
  Future<User> create(User draft) async {
    final json = draft.toJson()..remove('id'); // the server assigns the id
    final body = await _api.run(
      (http.Client c, Map<String, String> h) =>
          c.post(_api.uri('/users'), headers: h, body: jsonEncode(json)),
      expect: 201,
      json: true,
    );
    return _parse(
      'users (POST)',
      () => User.fromJson(body as Map<String, dynamic>),
    );
  }

  /// A cast that fails inside fromJson becomes our own exception,
  /// and its text says which address it came from.
  T _parse<T>(String where, T Function() build) {
    try {
      return build();
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
