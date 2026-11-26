import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';
import 'generic_error_view.dart';
import 'not_available_view.dart';
import 'offline_view.dart';
import 'server_error_view.dart';

/// One view per kind of error. Exhaustive: ApiException is sealed,
/// so a new subclass would not compile until it gets an arm here.
class UsersErrorView extends StatelessWidget {
  const UsersErrorView(this.error, {super.key, required this.onRetry});

  final ApiException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (error) {
      NoConnectionException() => OfflineView(onRetry: onRetry),
      NotFoundException() ||
      UnauthorizedException() => const NotAvailableView(),
      ServerException(:final status) => ServerErrorView(
        status,
        onRetry: onRetry,
      ),
      BadResponseException() => const GenericErrorView(),
    };
  }
}
