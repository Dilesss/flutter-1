import 'package:flutter_test/flutter_test.dart';

import 'package:lab7/main.dart';

void main() {
  testWidgets('shows the sign-up form', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Sign up'), findsWidgets);
  });
}
