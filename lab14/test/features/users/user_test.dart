import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lab13/features/users/user.dart';

import '../../fakes/user1_json.dart';

Map<String, dynamic> _user1() => jsonDecode(user1Json) as Map<String, dynamic>;

void main() {
  group('User.fromJson', () {
    test('the real JSON of user 1 parses', () {
      // arrange
      final json = _user1();
      // act
      final user = User.fromJson(json);
      // assert
      expect(user.name, 'Leanne Graham');
      expect(user.address.city, 'Gwenborough');
      expect(user.address.geo.lat, -37.3159); // a double, not a String
    });

    test('"id": "1" (a string) throws — the cast is a claim', () {
      final json = _user1()..['id'] = '1';
      expect(() => User.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('toJson → fromJson gives an equal user', () {
      final user = User.fromJson(_user1());
      expect(User.fromJson(user.toJson()), user);
      expect(user.phoneDigits, '1770736803156442');
    });
  });

  group('the planted bug (Level 5)', () {
    test('Geo.fromJson with "lat": -37.3159 (a number) throws', () {
      final json = <String, dynamic>{'lat': -37.3159, 'lng': '81.1496'};
      expect(() => Geo.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}
