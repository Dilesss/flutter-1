import 'package:flutter_test/flutter_test.dart';

import 'package:lab8/main.dart';

void main() {
  testWidgets('shows the reading list', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Reading list (5)'), findsOneWidget);
  });
}
