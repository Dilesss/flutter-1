import 'package:flutter/material.dart';

import 'message_view.dart';

class NotAvailableView extends StatelessWidget {
  const NotAvailableView({super.key});

  @override
  Widget build(BuildContext context) =>
      const MessageView(icon: Icons.block, title: 'Not found or not allowed');
}
