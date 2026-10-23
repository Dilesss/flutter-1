import 'package:flutter_test/flutter_test.dart';

import 'package:lab01/main.dart';

void main() {
  testWidgets('shows the meetups tab', (tester) async {
    await tester.pumpWidget(const ClubsApp());
    expect(find.text('Meetups'), findsWidgets);
  });
}
