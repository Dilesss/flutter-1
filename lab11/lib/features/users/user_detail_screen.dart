import 'package:flutter/material.dart';

import 'user.dart';

/// Shows everything about one user. Phone and website are taps that do
/// nothing yet — Practice 12 gives them url_launcher.
class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    final website = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.badge),
            title: Text('@${user.username}'),
            subtitle: Text('id ${user.id}'),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(user.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text('digits: ${user.phoneDigits}'),
            onTap: () {}, // Practice 12: url_launcher (tel:)
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(website ?? 'no website'),
            onTap: website == null ? null : () {}, // Practice 12
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('${a.street}, ${a.suite}'),
            subtitle: Text(
              '${a.city} ${a.zipcode}\n'
              'lat ${a.geo.lat}, lng ${a.geo.lng}',
            ),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(user.company.name),
            subtitle: Text(user.company.catchPhrase),
          ),
        ],
      ),
    );
  }
}
