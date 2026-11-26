import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab13/features/settings/settings_model.dart';
import 'package:lab13/features/users/users_model.dart';
import 'package:lab13/features/users/users_screen.dart';
import 'package:provider/provider.dart';

import '../../fakes/fake_prefs.dart';
import '../../fakes/fake_user_repository.dart';

void main() {
  testWidgets('shows the offline view and Retry', (tester) async {
    // arrange: a model whose repository always fails, loaded once
    final model = UsersModel(
      FakeUserRepository(fail: true, delay: const Duration(seconds: 1)),
    );
    await tester.runAsync(model.load); // real time for the first load
    final settings = SettingsModel(const FakePrefs(), dark: false);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settings),
            ChangeNotifierProvider.value(value: model),
          ],
          child: const UsersScreen(),
        ),
      ),
    );

    // assert: the offline view with its Retry button
    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // act: Retry → the model is loading again → a spinner
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // let the fake finish, so no timer is left pending
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('No connection'), findsOneWidget);
  });
}
