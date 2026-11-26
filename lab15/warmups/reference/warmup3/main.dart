import 'package:flutter/material.dart';

/// The rules are plain functions — a unit test calls them directly.
String? validateName(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Name is required' : null;

String? validateEmail(String? v) {
  final text = (v ?? '').trim();
  if (text.isEmpty) return 'Email is required';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
    return 'Not a valid email';
  }
  return null;
}

void main() => runApp(const MaterialApp(home: FormScreen()));

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(); // created once
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose(); // and disposed
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hello, ${_name.text}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: validateName,
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _submit, child: const Text('Submit')),
          ],
        ),
      ),
    );
  }
}
