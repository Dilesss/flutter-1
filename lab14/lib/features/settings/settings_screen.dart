import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../profile/profile_screen.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final auth = context.read<AuthModel>();
    // Close every pushed screen first; App then shows LoginScreen.
    Navigator.of(context).popUntil((route) => route.isFirst);
    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>().items;

    // The cities come from the loaded users (sorted, no duplicates).
    final cities = {for (final u in users) u.address.city}.toList()..sort();
    final saved = s.city;
    if (saved != null && !cities.contains(saved)) cities.add(saved);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark mode'),
            value: s.dark,
            onChanged: (v) => s.setDark(v),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              initialValue: saved,
              decoration: const InputDecoration(
                labelText: 'Show users from',
                prefixIcon: Icon(Icons.location_city),
              ),
              items: [
                const DropdownMenuItem<String?>(child: Text('All cities')),
                for (final c in cities)
                  DropdownMenuItem<String?>(value: c, child: Text(c)),
              ],
              onChanged: (c) => s.setCity(c),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile photo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
