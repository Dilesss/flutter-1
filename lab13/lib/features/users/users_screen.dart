import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/loading_view.dart';
import 'widgets/users_content.dart';
import 'widgets/users_error_view.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.watch<SettingsModel>().city;
    final visible = city == null
        ? m.items
        : m.items.where((u) => u.address.city == city).toList();

    // Loading → spinner; otherwise exhaustive on the sealed error.
    Widget body = const LoadingView();
    if (!m.loading) {
      body = switch (m.error) {
        null => UsersContent(
          users: visible,
          total: m.items.length,
          fromCache: m.fromCache,
          onRetry: m.load,
          city: city,
        ),
        final error => UsersErrorView(error, onRetry: m.load),
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: m.load, child: body),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
    );
  }
}
