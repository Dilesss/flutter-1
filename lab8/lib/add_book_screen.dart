import 'package:flutter/material.dart';

import 'models/book.dart';

/// A form that answers with a new Book through pop.
class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  // Created once, as fields of State, and disposed.
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    for (final c in [_title, _author, _pages, _year]) {
      c.dispose();
    }
    super.dispose();
  }

  // null = fine, a String = the message under the field.

  String? _validateTitle(String? v) =>
      (v ?? '').trim().length < 2 ? 'At least 2 characters' : null;

  String? _validateAuthor(String? v) =>
      (v ?? '').trim().isEmpty ? 'Author is required' : null;

  String? _validatePages(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n <= 0) return 'A whole number above 0';
    return null;
  }

  String? _validateYear(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return null; // an empty year is allowed
    final now = DateTime.now().year;
    final y = int.tryParse(text);
    if (y == null || y < 1450 || y > now) return 'A year from 1450 to $now';
    return null;
  }

  void _save() {
    // The one bang: the Form is on screen when Save runs.
    if (!_formKey.currentState!.validate()) return;
    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      // Safe: the validator already proved it is a number.
      pages: int.parse(_pages.text.trim()),
      // tryParse('') is null — exactly what an empty year means.
      year: int.tryParse(_year.text.trim()),
    );
    Navigator.of(context).pop(book);
  }

  void _hideKeyboard(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                onTapOutside: _hideKeyboard,
                validator: _validateTitle,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _author,
                textInputAction: TextInputAction.next,
                onTapOutside: _hideKeyboard,
                validator: _validateAuthor,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pages,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onTapOutside: _hideKeyboard,
                validator: _validatePages,
                decoration: const InputDecoration(labelText: 'Pages'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _year,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onTapOutside: _hideKeyboard,
                onFieldSubmitted: (_) => _save(),
                validator: _validateYear,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  helperText: 'Optional',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
