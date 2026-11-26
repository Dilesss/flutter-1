import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/env.dart';
import '../settings_model.dart';

/// Developer-only: pick the API host at runtime. Shown behind kDebugMode
/// by the Settings screen — never in a release build.
class DeveloperHostTile extends StatelessWidget {
  const DeveloperHostTile({super.key});

  static const _choices = <String?>[
    null, // Env.host — whatever the build was made with
    'jsonplaceholder.typicode.com',
    'example.invalid', // does not exist → the Offline view
  ];

  Future<void> _pick(BuildContext context) async {
    final settings = context.read<SettingsModel>();
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('API host (debug only)'),
        children: [
          for (final h in _choices)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, h ?? ''),
              child: Text(h ?? 'Default: ${Env.host}'),
            ),
        ],
      ),
    );
    if (picked == null) return; // dialog dismissed
    await settings.setDevHost(picked.isEmpty ? null : picked);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restart the app to use the new host')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final host = context.watch<SettingsModel>().devHost;
    return ListTile(
      leading: const Icon(Icons.developer_mode),
      title: const Text('Developer: API host'),
      subtitle: Text(host ?? 'Default: ${Env.host}'),
      onTap: () => _pick(context),
    );
  }
}
