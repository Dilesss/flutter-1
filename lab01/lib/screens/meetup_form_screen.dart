import 'package:flutter/material.dart';

import '../models/club_category.dart';
import '../models/meetup.dart';
import '../utils/format.dart';

/// Every value the user can change, as one record. Records compare by
/// value, so `_snapshot() != _initial` tells whether the form is dirty.
typedef _Snapshot = (
  String title,
  ClubCategory? category,
  bool isOnline,
  String place,
  String capacity,
  DateTime? day,
  TimeOfDay? clock,
  String description,
);

/// One screen for "new" (initial == null) and "edit". It never changes the
/// list itself: it RETURNS the meetup through Navigator.pop (R26).
class MeetupFormScreen extends StatefulWidget {
  const MeetupFormScreen({super.key, this.initial});

  final Meetup? initial;

  @override
  State<MeetupFormScreen> createState() => _MeetupFormScreenState();
}

class _MeetupFormScreenState extends State<MeetupFormScreen> {
  final _formKey = GlobalKey<FormState>();

  /// R3: a new meetup starts from Meetup.empty().
  late final Meetup _base = widget.initial ?? Meetup.empty();
  bool get _isNew => widget.initial == null;

  // R35: controllers and focus nodes are fields — created once, disposed.
  late final _title = TextEditingController(text: _base.title);
  late final _place = TextEditingController(text: _base.place);
  late final _capacity = TextEditingController(text: '${_base.capacity}');
  late final _description = TextEditingController(
    text: _base.description ?? '',
  );
  final _date = TextEditingController();
  final _time = TextEditingController();

  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _capacityFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  // A new meetup has no category, date or time yet: the user must pick them.
  late ClubCategory? _category = _isNew ? null : _base.category;
  late bool _isOnline = _base.isOnline;
  late DateTime? _day = _isNew ? null : _base.startsAt;
  late TimeOfDay? _clock = _isNew
      ? null
      : TimeOfDay.fromDateTime(_base.startsAt);

  bool _saving = false;
  late final _Snapshot _initial;

  @override
  void initState() {
    super.initState();
    if (_day case final day?) _date.text = formatDay(day);
    if (_clock case final clock?) {
      _time.text = formatClock(clock.hour, clock.minute);
    }
    _initial = _snapshot();
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _place,
      _capacity,
      _description,
      _date,
      _time,
    ]) {
      controller.dispose();
    }
    for (final node in [
      _titleFocus,
      _placeFocus,
      _capacityFocus,
      _descriptionFocus,
    ]) {
      node.dispose();
    }
    super.dispose();
  }

  _Snapshot _snapshot() => (
    _title.text,
    _category,
    _isOnline,
    _place.text,
    _capacity.text,
    _day,
    _clock,
    _description.text,
  );

  /// R30: dirty = the current values differ from the ones the form opened with.
  bool get _dirty => _snapshot() != _initial;

  void _hideKeyboard(PointerDownEvent _) => FocusScope.of(context).unfocus();

  // ---------------------------------------------------------------- R34
  // Each validator returns null (fine) or the message to show.

  String? _validateTitle(String? value) {
    final title = (value ?? '').trim();
    if (title.length < 3) return 'At least 3 characters';
    if (title.length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validateCategory(ClubCategory? value) =>
      value == null ? 'Choose a category' : null;

  String? _validatePlace(String? value) {
    final place = (value ?? '').trim();
    if (place.isEmpty) {
      return _isOnline ? 'Link is required' : 'Place is required';
    }
    if (_isOnline && !place.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateCapacity(String? value) {
    final capacity = int.tryParse((value ?? '').trim());
    if (capacity == null) return 'Enter a whole number';
    if (capacity < 1 || capacity > 500) return 'From 1 to 500';
    if (capacity < _base.count) {
      return '${_base.count} people already joined';
    }
    return null;
  }

  String? _validateDate(String? value) => _day == null ? 'Pick a date' : null;

  String? _validateTime(String? value) {
    final day = _day;
    final clock = _clock;
    if (clock == null) return 'Pick a time';
    if (_isNew &&
        day != null &&
        !_combine(day, clock).isAfter(DateTime.now())) {
      return 'A new meetup must be in the future';
    }
    return null;
  }

  DateTime _combine(DateTime day, TimeOfDay clock) =>
      DateTime(day.year, day.month, day.day, clock.hour, clock.minute);

  // ---------------------------------------------------------------- R36

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final first = _isNew ? today : DateTime(2020);
    final current = _day;
    final picked = await showDatePicker(
      context: context,
      initialDate: current != null && !current.isBefore(first)
          ? current
          : today,
      firstDate: first,
      lastDate: DateTime(now.year + 2, 12, 31),
    );
    // Cancel returns null: keep the old value.
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      _day = picked;
      _date.text = formatDay(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _clock ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      _clock = picked;
      _time.text = formatClock(picked.hour, picked.minute);
    });
  }

  // ---------------------------------------------------------------- R17

  /// Builds the meetup from the fields. The pattern makes sure category,
  /// day and time are not null — no `!` needed.
  Meetup? _buildMeetup() {
    if ((_category, _day, _clock) case (
      final category?,
      final day?,
      final clock?,
    )) {
      final description = _description.text.trim();
      return Meetup(
        id: _isNew
            ? DateTime.now().microsecondsSinceEpoch.toString()
            : _base.id,
        title: _title.text.trim(),
        category: category,
        startsAt: _combine(day, clock),
        capacity: int.tryParse(_capacity.text.trim()) ?? _base.capacity,
        isOnline: _isOnline,
        place: _place.text.trim(),
        description: description.isEmpty ? null : description,
        isFavourite: _base.isFavourite,
        members: _base.members,
      );
    }
    return null;
  }

  Future<void> _save() async {
    // A second tap while saving does nothing (the button is also disabled).
    if (_saving) return;
    // R33: one validate() call — the validators do all the checking.
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final meetup = _buildMeetup();
    if (meetup == null) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    // R14: the user may have left during the second.
    if (!mounted) return;
    // Navigator.pop always pops, even with canPop false: Save never asks.
    Navigator.pop(context, meetup);
  }

  // ---------------------------------------------------------------- R30

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('What you typed in this form will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (discard != true) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // The back arrow and the Android back gesture both go through PopScope.
    return PopScope<Meetup>(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New meetup' : 'Edit meetup')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // Re-check _dirty (and so canPop) after every change.
          onChanged: () => setState(() {}),
          // R37: the whole form scrolls, so the keyboard never covers Save.
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                maxLength: 60,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                onTapOutside: _hideKeyboard,
                onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                validator: _validateTitle,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<ClubCategory>(
                initialValue: _category,
                validator: _validateCategory,
                onChanged: (category) => setState(() => _category = category),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final category in ClubCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon),
                          const SizedBox(width: 8),
                          Text(category.label),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online meetup'),
                subtitle: const Text('The place becomes a link'),
                value: _isOnline,
                onChanged: (value) => setState(() => _isOnline = value),
              ),
              const SizedBox(height: 8),
              // R34: with the mode on, the label and the rule change.
              TextFormField(
                controller: _place,
                focusNode: _placeFocus,
                keyboardType: _isOnline
                    ? TextInputType.url
                    : TextInputType.text,
                textInputAction: TextInputAction.next,
                onTapOutside: _hideKeyboard,
                onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                validator: _validatePlace,
                decoration: InputDecoration(
                  labelText: _isOnline ? 'Link' : 'Place',
                  hintText: _isOnline
                      ? 'https://meet.google.com/...'
                      : 'Room 501, Tole Bi 59',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacity,
                focusNode: _capacityFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onTapOutside: _hideKeyboard,
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                validator: _validateCapacity,
                decoration: InputDecoration(
                  labelText: 'Capacity',
                  helperText: _isNew
                      ? '1 to 500 places'
                      : '1 to 500, at least ${_base.count} (already joined)',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _date,
                      readOnly: true,
                      onTap: _pickDate,
                      validator: _validateDate,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _time,
                      readOnly: true,
                      onTap: _pickTime,
                      validator: _validateTime,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        suffixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                focusNode: _descriptionFocus,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                minLines: 2,
                maxLines: 5,
                onTapOutside: _hideKeyboard,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                // R17: disabled while saving, with a spinner inside.
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isNew ? 'Create' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
