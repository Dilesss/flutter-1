import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'dev/level_checks.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

/// Set to true to print the Level 2 / Level 3 checks to the console.
const runLevelChecks = false;

/// The composition root: the only place where the chain is built.
/// ApiClient.live() is ApiClient(http.Client()) — kept inside api_client.dart
/// so that only api_client.dart and user_repository.dart import http.
void main() {
  if (kDebugMode && runLevelChecks) {
    checkModel();
    unawaited(checkRepository(UserRepository(ApiClient.live())));
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => UsersModel(UserRepository(ApiClient.live()))..load(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const UsersScreen(),
    );
  }
}
