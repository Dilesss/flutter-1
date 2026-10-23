import 'package:flutter/material.dart';

/// R32: the drawer. Each tile closes the drawer first with Navigator.pop,
/// then asks the shell to act — the shell owns the data and the dialogs.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onAbout, required this.onReset});

  final VoidCallback onAbout;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.groups, size: 48, color: scheme.onPrimaryContainer),
                const SizedBox(height: 8),
                Text(
                  'KBTU Clubs',
                  style: text.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Meetups of student clubs',
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('About'),
            trailing: const Icon(Icons.info_outline),
            onTap: () {
              Navigator.pop(context);
              onAbout();
            },
          ),
          ListTile(
            title: const Text('Reset data'),
            subtitle: const Text('Restore the 12 meetups, clear the profile'),
            trailing: const Icon(Icons.restart_alt),
            onTap: () {
              Navigator.pop(context);
              onReset();
            },
          ),
        ],
      ),
    );
  }
}
