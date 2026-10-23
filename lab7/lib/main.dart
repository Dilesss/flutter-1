import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Created once, as fields of State — never in build().
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;
  int _passwordLength = 0;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------- validators
  // null = fine, a String = the message validate() shows under the field.

  String? _validateName(String? v) =>
      (v ?? '').trim().length < 2 ? 'Name is too short' : null;

  String? _validateEmail(String? v) {
    final email = (v ?? '').trim();
    final at = email.indexOf('@');
    if (at < 1 || !email.substring(at).contains('.')) {
      return 'Email looks wrong';
    }
    return null;
  }

  String? _validatePassword(String? v) =>
      (v ?? '').length < 8 ? 'Password is too short' : null;

  // Reads another controller: Confirm must equal Password.
  String? _validateConfirm(String? v) =>
      v != _password.text ? 'Passwords do not match' : null;

  String? _validateGroup(String? g) => g == null ? 'Choose a group' : null;

  String? _validateBirth(String? v) =>
      _birth == null ? 'Choose your date of birth' : null;

  // ---------------------------------------------------------- actions

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.'
      '${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    // Cancel returns null: keep the old date.
    if (picked == null || !mounted) return;
    setState(() {
      _birth = picked;
      _birthText.text = _formatDate(picked);
    });
  }

  void _submit() {
    // The one bang in the project: the Form is built when this runs.
    if (!_formKey.currentState!.validate()) return;
    setState(() => _done = true);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));
  }

  /// null while the box is unticked: the button greys itself.
  VoidCallback? get _onSignUp => _agreed ? _submit : null;

  void _startOver() {
    // No _formKey.currentState here: the Form is not on screen.
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthText]) {
        c.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _passwordLength = 0;
      _done = false;
    });
  }

  void _hideKeyboard(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  // ---------------------------------------------------------- build

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _done ? _summary() : _form(),
    ),
  );

  Widget _summary() => Column(
    children: [
      SummaryCard(
        name: _name.text.trim(),
        email: _email.text.trim(),
        group: _group ?? '',
        birthDate: _birthText.text,
      ),
      const SizedBox(height: 16),
      TextButton(onPressed: _startOver, child: const Text('Start over')),
    ],
  );

  Widget _form() => Form(
    key: _formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
          onTapOutside: _hideKeyboard,
          validator: _validateName,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _email,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onTapOutside: _hideKeyboard,
          validator: _validateEmail,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'name@kbtu.kz',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _password,
          obscureText: true,
          textInputAction: TextInputAction.next,
          onTapOutside: _hideKeyboard,
          onChanged: (v) => setState(() => _passwordLength = v.length),
          validator: _validatePassword,
          decoration: const InputDecoration(
            labelText: 'Password',
            helperText: 'At least 8 characters',
          ),
        ),
        Text('$_passwordLength of 8'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _confirm,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onTapOutside: _hideKeyboard,
          onFieldSubmitted: (_) => _onSignUp?.call(),
          validator: _validateConfirm,
          decoration: const InputDecoration(labelText: 'Confirm password'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _group,
          validator: _validateGroup,
          onChanged: (g) => setState(() => _group = g),
          decoration: const InputDecoration(labelText: 'Group'),
          items: [
            for (final g in groups) DropdownMenuItem(value: g, child: Text(g)),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _birthText,
          readOnly: true,
          onTap: _pickBirth,
          validator: _validateBirth,
          decoration: const InputDecoration(
            labelText: 'Date of birth',
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('I agree to the rules'),
          value: _agreed,
          onChanged: (v) => setState(() => _agreed = v ?? false),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: _onSignUp, child: const Text('Sign up')),
      ],
    ),
  );
}
