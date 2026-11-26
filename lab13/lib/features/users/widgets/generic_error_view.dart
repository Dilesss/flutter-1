import 'package:flutter/material.dart';

import 'message_view.dart';

/// Bad JSON is a bug report, not a Retry — so no button here.
class GenericErrorView extends StatelessWidget {
  const GenericErrorView({super.key});

  @override
  Widget build(BuildContext context) => const MessageView(
    icon: Icons.bug_report,
    title: 'Something went wrong reading the data',
  );
}
