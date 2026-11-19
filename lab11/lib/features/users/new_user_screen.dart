import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_model.dart';

/// POST from the UI: name, username, email (the validators from week 7).
class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final draft = User(
      id: 0, // the server assigns the real id (11)
      name: _name.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
      phone: '',
      address: const Address(
        street: '',
        suite: '',
        city: 'Almaty',
        zipcode: '',
        geo: Geo(lat: 43.2389, lng: 76.8897),
      ),
      company: (name: 'KBTU', catchPhrase: ''),
    );

    final error = await context.read<UsersModel>().create(draft);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    final text = switch (error) {
      NoConnectionException() => 'No connection — try again',
      ServerException(:final status) => 'Server error $status',
      BadResponseException() => 'The server sent something unexpected',
      NotFoundException() || UnauthorizedException() => 'Not allowed',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select<UsersModel, bool>((m) => m.saving);
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textInputAction: TextInputAction.next,
              validator: (v) => _required(v, 'Name'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              textInputAction: TextInputAction.next,
              validator: (v) {
                final empty = _required(v, 'Username');
                if (empty != null) return empty;
                if ((v ?? '').trim().length < 3) return 'At least 3 letters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final empty = _required(v, 'Email');
                if (empty != null) return empty;
                if (!_emailRe.hasMatch((v ?? '').trim())) {
                  return 'Not a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              // disabled while the POST is in flight
              onPressed: saving ? null : _save,
              child: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
