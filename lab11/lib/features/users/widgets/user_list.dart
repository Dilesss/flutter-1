import 'package:flutter/material.dart';

import '../user.dart';
import '../user_detail_screen.dart';

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // always scrollable, so pull-to-refresh works even with few items
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final u = users[i];
        return ListTile(
          leading: CircleAvatar(child: Text('${u.id}')),
          title: Text(u.name),
          subtitle: Text('${u.email} · ${u.address.city}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => UserDetailScreen(user: u)),
          ),
        );
      },
    );
  }
}
