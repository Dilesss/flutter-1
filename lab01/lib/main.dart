import 'package:flutter/material.dart';

import 'routes.dart';
import 'shell/home_shell.dart';

void main() => runApp(const ClubsApp());

/// R11: ThemeMode lives here, in the State ABOVE MaterialApp, because
/// MaterialApp is what reads it.
class ClubsApp extends StatefulWidget {
  const ClubsApp({super.key});

  @override
  State<ClubsApp> createState() => _ClubsAppState();
}

class _ClubsAppState extends State<ClubsApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) {
    // R22: the seed is the one colour written by hand; every colour in the
    // app is a role of the scheme generated from it. Change it here and
    // both themes follow.
    const seed = Colors.indigo;
    return MaterialApp(
      title: 'KBTU Clubs',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      // R25: routes holds only the shell; pushed screens are generated.
      routes: {
        Routes.home: (context) =>
            HomeShell(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
      },
      onGenerateRoute: generateRoute,
      onUnknownRoute: unknownRoute,
    );
  }
}
