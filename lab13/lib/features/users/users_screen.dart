import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/offline_banner.dart';
import 'widgets/state_views.dart';
import 'widgets/user_list.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.watch<SettingsModel>().city;
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
      body: RefreshIndicator(onRefresh: m.load, child: _body(m, city)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
    );
  }

  Widget _body(UsersModel m, String? city) {
    if (m.loading) return const LoadingView();
    // Exhaustive: ApiException is sealed, so no default is needed.
    return switch (m.error) {
      null => _list(m, city),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() || UnauthorizedException() => const NotAvailable(),
      ServerException(:final status) => ServerError(status, onRetry: m.load),
      BadResponseException() => const GenericError(),
    };
  }

  /// The list, filtered by the saved city, with the stale banner on top
  /// when (and only when) the data came from the cache.
  Widget _list(UsersModel m, String? city) {
    final visible = city == null
        ? m.items
        : m.items.where((u) => u.address.city == city).toList();
    return Column(
      children: [
        if (m.fromCache) OfflineBanner(onRetry: m.load),
        if (city != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.filter_alt, size: 18),
                const SizedBox(width: 6),
                Text('City: $city · ${visible.length} of ${m.items.length}'),
              ],
            ),
          ),
        Expanded(child: UserList(visible)),
      ],
    );
  }
}
