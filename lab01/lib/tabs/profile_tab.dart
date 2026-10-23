import 'package:flutter/material.dart';

import '../models/meetup.dart';
import '../models/profile.dart';

/// Tab 3: name, group and the theme.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.meetups,
    required this.onChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Meetup> meetups;
  final ValueChanged<Profile> onChanged;

  /// R11: the theme lives in the app's State; it arrives here as a value
  /// and goes back up as a callback.
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  /// R38: "SE-2301", "IS-24": 2–5 letters, a dash, 2–4 digits.
  static final _groupPattern = RegExp(r'^[A-Za-z]{2,5}-\d{2,4}$');

  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _group = TextEditingController(text: widget.profile.group);

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only when the model itself changed (e.g. "Reset data" in the drawer
    // cleared it) — never on an unrelated rebuild, or it would wipe typing.
    if (oldWidget.profile.name != widget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (oldWidget.profile.group != widget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _validateGroup(String? value) {
    final group = (value ?? '').trim();
    if (group.isEmpty || _groupPattern.hasMatch(group)) return null;
    return 'Format: SE-2301';
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    widget.onChanged(
      widget.profile.copyWith(
        name: _name.text.trim(),
        group: _group.text.trim().toUpperCase(),
      ),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final name = widget.profile.name;
    // Computed on every build from the list, never stored.
    final lists = name.isEmpty
        ? 0
        : widget.meetups.where((m) => m.contains(name)).length;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              child: Text(
                name.isEmpty ? '?' : name[0].toUpperCase(),
                style: text.headlineMedium,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _name,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onFieldSubmitted: (_) => _save(),
            decoration: const InputDecoration(
              labelText: 'Name',
              helperText: 'Press Enter to save',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _group,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.characters,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onFieldSubmitted: (_) => _save(),
            validator: _validateGroup,
            decoration: const InputDecoration(
              labelText: 'Group',
              hintText: 'SE-2301',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text('You are on $lists lists', style: text.titleMedium),
          const Divider(height: 32),
          Text('Theme', style: text.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final (mode, label, icon) in const [
                (ThemeMode.light, 'Light', Icons.light_mode),
                (ThemeMode.dark, 'Dark', Icons.dark_mode),
                (ThemeMode.system, 'System', Icons.brightness_auto),
              ])
                ChoiceChip(
                  avatar: Icon(icon),
                  label: Text(label),
                  selected: widget.themeMode == mode,
                  onSelected: (_) => widget.onThemeModeChanged(mode),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
