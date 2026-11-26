import 'package:flutter/material.dart';

import '../user.dart';
import '../user_detail_screen.dart';

/// One row of the list: name, email · city; a tap opens the details.
class UserTile extends StatelessWidget {
  const UserTile(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text('${user.id}')),
      title: Text(user.name),
      subtitle: Text('${user.email} · ${user.address.city}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => UserDetailScreen(user: user)),
      ),
    );
  }
}
