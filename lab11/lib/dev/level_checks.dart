import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../features/users/user.dart';
import '../features/users/user_repository.dart';

/// Level 2: the real JSON of user 1 (copied from Postman).
const _user1 = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {"lat": "-37.3159", "lng": "81.1496"}
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';

/// Level 2: parse with no screen, and check the round-trip.
void checkModel() {
  final user = User.fromJson(jsonDecode(_user1) as Map<String, dynamic>);
  debugPrint('L2 parsed: $user, phoneDigits=${user.phoneDigits}');
  final again = User.fromJson(user.toJson());
  debugPrint('L2 round-trip equal: ${again == user}');
}

/// Level 3: the repository against the real server.
Future<void> checkRepository(UserRepository repo) async {
  try {
    final all = await repo.getAll();
    debugPrint('L3 getAll: ${all.length} users');
    for (final u in all) {
      debugPrint('  ${u.name}');
    }
  } on ApiException catch (e) {
    debugPrint('L3 getAll failed: $e');
  }

  try {
    await repo.getById(999);
  } on NotFoundException {
    debugPrint('L3 getById(999): not found');
  } on ApiException catch (e) {
    debugPrint('L3 getById(999) other error: $e');
  }

  try {
    final created = await repo.create(
      const User(
        id: 0,
        name: 'Dilnaz',
        username: 'dilnaz',
        email: 'dilnaz@kbtu.kz',
        phone: '+7 700 000 00 00',
        address: Address(
          street: 'Tole bi 59',
          suite: '',
          city: 'Almaty',
          zipcode: '050000',
          geo: Geo(lat: 43.2389, lng: 76.8897),
        ),
        company: (name: 'KBTU', catchPhrase: 'Learning Flutter'),
      ),
    );
    debugPrint('L3 create: server assigned id ${created.id}');
  } on ApiException catch (e) {
    debugPrint('L3 create failed: $e');
  }
}
