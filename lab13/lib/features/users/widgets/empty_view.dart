import 'package:flutter/material.dart';

/// The empty state: the request worked, there is just nothing to show.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.city});

  final String? city;

  @override
  Widget build(BuildContext context) {
    final where = city;
    return ListView(
      // scrollable, so pull-to-refresh still works on an empty screen
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(48),
      children: [
        const Icon(Icons.person_search, size: 56),
        const SizedBox(height: 12),
        Text(
          where == null ? 'No users yet' : 'No users in $where',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
