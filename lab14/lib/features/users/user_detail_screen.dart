import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_model.dart';
import 'user.dart';

/// Shows everything about one user; email, phone and website open
/// other apps through launchUrl.
class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  /// launchUrl answers with a bool: false = no app can open it.
  Future<void> _open(BuildContext context, Uri uri) async {
    bool ok;
    try {
      ok = await launchUrl(uri);
    } on PlatformException {
      ok = false;
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No app can open this')));
    }
  }

  /// Debug only: proves the token exists without ever printing it.
  Future<void> _copyToken(BuildContext context) async {
    final token = context.read<AuthModel>().token;
    if (token == null) return;
    await Clipboard.setData(ClipboardData(text: token));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Token copied')));
  }

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
            subtitle: const Text('Tap to write an email'),
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text('Tap to call ${user.phoneDigits}'),
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(website ?? 'no website'),
            onTap: website == null
                ? null
                : () => _open(context, Uri.parse('https://$website')),
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
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Copy token to clipboard (debug)'),
              onTap: () => _copyToken(context),
            ),
        ],
      ),
    );
  }
}
