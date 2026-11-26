import 'package:flutter/material.dart';

import 'message_view.dart';

class OfflineView extends StatelessWidget {
  const OfflineView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: Icons.wifi_off,
    title: 'No connection',
    detail: 'Check the network and try again.',
    onRetry: onRetry,
  );
}
