// Practice 13, Level 5 — the planted bug. RED ON PURPOSE.
// Run it alone to read a real stack trace:
//   flutter test tool/planted_bug_test.dart
// (it lives in tool/, so the normal `flutter test` does not run it)
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lab13/features/users/user.dart';
import 'package:lab13/features/users/user_repository.dart';
import 'package:lab13/features/users/users_model.dart';

/// A fake "server" whose JSON broke the contract: lat is a NUMBER.
class PlantedBugRepository implements UserRepository {
  static const _json = '''
[{"id": 1, "name": "Leanne Graham", "username": "Bret",
  "email": "Sincere@april.biz", "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "address": {"street": "Kulas Light", "suite": "Apt. 556",
    "city": "Gwenborough", "zipcode": "92998-3874",
    "geo": {"lat": -37.3159, "lng": "81.1496"}},
  "company": {"name": "Romaguera-Crona", "catchPhrase": "Multi-layered"}}]
''';

  @override
  Future<UsersResult> getAll() async {
    await Future<void>.delayed(Duration.zero); // like a real request
    final list = jsonDecode(_json) as List;
    // No mapping to BadResponseException here — that is the bug.
    final users = [
      for (final e in list) User.fromJson(e as Map<String, dynamic>),
    ];
    return (items: users, fromCache: false);
  }

  @override
  Future<User> getById(int id) => throw UnimplementedError();

  @override
  Future<User> create(User draft) => throw UnimplementedError();
}

void main() {
  test('planted bug: lat is a number — read the trace', () async {
    final model = UsersModel(PlantedBugRepository());
    await model.load(); // throws TypeError from Geo.fromJson
  });
}
