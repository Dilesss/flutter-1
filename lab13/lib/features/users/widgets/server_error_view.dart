import 'package:flutter/material.dart';

import 'message_view.dart';

class ServerErrorView extends StatelessWidget {
  const ServerErrorView(this.status, {super.key, required this.onRetry});

  final int status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MessageView(
    icon: Icons.cloud_off,
    title: 'The server is having trouble',
    detail: 'Status $status',
    onRetry: onRetry,
  );
}
