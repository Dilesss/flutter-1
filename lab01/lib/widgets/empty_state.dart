import 'package:flutter/material.dart';

/// R23: one widget for every "nothing to show" case:
/// no search match, no favourites, nobody on the list, unknown route.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: scheme.outline),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: text.titleMedium),
            // The button only when both a label and an action were given.
            if ((actionLabel, onAction) case (final label?, final action?)) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: action, child: Text(label)),
            ],
          ],
        ),
      ),
    );
  }
}
