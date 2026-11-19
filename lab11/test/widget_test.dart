import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab11/core/api/api_client.dart';
import 'package:lab11/core/api/api_exception.dart';
import 'package:lab11/features/users/user.dart';
import 'package:lab11/features/users/user_repository.dart';

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

UserRepository _repo(http.Response Function(http.Request r) answer) =>
    UserRepository(ApiClient(MockClient((r) async => answer(r))));

void main() {
  test('fromJson / toJson round-trip', () {
    final u = User.fromJson(_json);
    expect(u.address.geo.lat, -37.3159);
    expect(u.phoneDigits, '17707368031');
    expect(User.fromJson(u.toJson()), u);
  });

  test('404 → NotFoundException', () {
    final repo = _repo((_) => http.Response('{}', 404));
    expect(repo.getById(999), throwsA(isA<NotFoundException>()));
  });

  test('500 → ServerException(500)', () {
    final repo = _repo((_) => http.Response('oops', 500));
    expect(repo.getAll(), throwsA(isA<ServerException>()));
  });

  test('bad JSON → BadResponseException', () {
    final repo = _repo((_) => http.Response('<html>', 200));
    expect(repo.getAll(), throwsA(isA<BadResponseException>()));
  });

  test('wrong type → BadResponseException', () {
    final repo = _repo(
      (_) => http.Response(jsonEncode({..._json, 'id': '1'}), 200),
    );
    expect(repo.getById(1), throwsA(isA<BadResponseException>()));
  });
}
