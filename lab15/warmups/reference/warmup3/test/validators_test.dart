import 'package:flutter_test/flutter_test.dart';
import 'package:warmup3/main.dart';

void main() {
  test('email rule', () {
    expect(validateEmail(''), 'Email is required');
    expect(validateEmail('dilnaz@'), 'Not a valid email');
    expect(validateEmail('dilnaz@kbtu.kz'), isNull);
  });
}
