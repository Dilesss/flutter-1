import 'package:flutter/material.dart';

import 'models/meetup.dart';
import 'screens/detail_screen.dart';
import 'screens/meetup_form_screen.dart';
import 'screens/not_found_screen.dart';

/// R25: every route name in one place. No '/...' string anywhere else.
abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

/// R26: what the detail screen gets — the meetup **and** callbacks that
/// tell the shell about changes.
class DetailArgs {
  const DetailArgs({
    required this.meetup,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Meetup meetup;
  final String userName;
  final ValueChanged<Meetup> onChanged;
  final ValueChanged<String> onDelete;
  final VoidCallback onOpenProfile;
}

/// R26: what the form gets — null for a new meetup. It returns a Meetup
/// through Navigator.pop.
class FormArgs {
  const FormArgs({this.initial});

  final Meetup? initial;
}

/// Builds the pushed screens from typed arguments. A wrong name or wrong
/// arguments return null, which sends the Navigator to [unknownRoute].
Route<dynamic>? generateRoute(RouteSettings settings) {
  return switch ((settings.name, settings.arguments)) {
    (Routes.detail, final DetailArgs args) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => DetailScreen(args: args),
    ),
    (Routes.form, final FormArgs args) => MaterialPageRoute<Meetup>(
      settings: settings,
      builder: (_) => MeetupFormScreen(initial: args.initial),
    ),
    _ => null,
  };
}

Route<dynamic> unknownRoute(RouteSettings settings) => MaterialPageRoute<void>(
  settings: settings,
  builder: (_) => const NotFoundScreen(),
);
