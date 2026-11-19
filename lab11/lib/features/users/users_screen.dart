import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/state_views.dart';
import 'widgets/user_list.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users · jsonplaceholder')),
      body: RefreshIndicator(onRefresh: m.load, child: _body(m)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text('New user'),
      ),
    );
  }

  Widget _body(UsersModel m) {
    if (m.loading) return const LoadingView();
    // Exhaustive: ApiException is sealed, so no default is needed.
    return switch (m.error) {
      null => UserList(m.items),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() || UnauthorizedException() => const NotAvailable(),
      ServerException(:final status) => ServerError(status, onRetry: m.load),
      BadResponseException() => const GenericError(),
    };
  }
}
