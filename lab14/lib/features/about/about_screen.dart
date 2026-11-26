import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/env.dart';

/// Which build am I holding? Version, build number, mode, environment, host.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, this.hostOverride});

  /// The developer host from Settings (debug builds only), if one is set.
  final String? hostOverride;

  static String get buildMode => kReleaseMode
      ? 'release'
      : kProfileMode
      ? 'profile'
      : 'debug';

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // The future is a field: build() may run many times, the read only once.
  final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final host = widget.hostOverride ?? Env.host;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<PackageInfo>(
        future: _info,
        builder: (context, snapshot) {
          final info = snapshot.data;
          final version = info == null
              ? '…'
              : '${info.version} (${info.buildNumber})';
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(
                  '$version · ${AboutScreen.buildMode} · ${Env.name} · $host',
                ),
                subtitle: const Text('version (build) · mode · env · host'),
              ),
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('Version'),
                trailing: Text(version),
              ),
              ListTile(
                leading: const Icon(Icons.build),
                title: const Text('Build mode'),
                trailing: Text(AboutScreen.buildMode),
              ),
              ListTile(
                leading: const Icon(Icons.layers),
                title: const Text('Environment'),
                trailing: Text(Env.name),
              ),
              ListTile(
                leading: const Icon(Icons.dns),
                title: const Text('API host'),
                subtitle: Text(host),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Open-source licences'),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Users',
                  applicationVersion: version,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
