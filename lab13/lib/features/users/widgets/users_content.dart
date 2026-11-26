import 'package:flutter/material.dart';

import '../user.dart';
import 'city_filter_row.dart';
import 'empty_view.dart';
import 'offline_banner.dart';
import 'user_list.dart';

/// The data state: the stale banner (only for cached data), the filter
/// row (only with a city), then the list or the empty state.
class UsersContent extends StatelessWidget {
  const UsersContent({
    super.key,
    required this.users,
    required this.total,
    required this.fromCache,
    required this.onRetry,
    this.city,
  });

  final List<User> users;
  final int total;
  final bool fromCache;
  final VoidCallback onRetry;
  final String? city;

  @override
  Widget build(BuildContext context) {
    final filter = city;
    return Column(
      children: [
        if (fromCache) OfflineBanner(onRetry: onRetry),
        if (filter != null)
          CityFilterRow(city: filter, shown: users.length, total: total),
        Expanded(
          child: users.isEmpty ? EmptyView(city: filter) : UserList(users),
        ),
      ],
    );
  }
}
