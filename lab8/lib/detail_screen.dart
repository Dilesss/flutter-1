import 'package:flutter/material.dart';

import 'models/book.dart';

/// What the user decided on the detail screen.
enum BookAction { toggleRead, delete }

/// Receives its Book through the constructor and answers with a BookAction.
/// It never touches the list itself.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete '${book.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(BookAction.delete);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Book')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(book.title, style: text.headlineSmall),
          const SizedBox(height: 8),
          ListTile(leading: const Icon(Icons.person), title: Text(book.author)),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text('${book.pages} pages'),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(book.year?.toString() ?? 'Year unknown'),
          ),
          ListTile(
            leading: Icon(
              book.read ? Icons.check_circle : Icons.circle_outlined,
            ),
            title: Text(book.read ? 'Read' : 'Not read yet'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(BookAction.toggleRead),
            child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _delete(context),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
