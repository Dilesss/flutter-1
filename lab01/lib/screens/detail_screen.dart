import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/meetup.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

/// Pushed from a card; covers the NavigationBar (one Navigator, R28).
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  /// A local copy so this screen redraws at once; every change is also
  /// sent to the shell through args.onChanged.
  late Meetup _meetup = widget.args.meetup;

  DateTime _now = DateTime.now();
  late final Timer _timer;

  String get _me => widget.args.userName;
  bool get _joined => _me.isNotEmpty && _meetup.contains(_me);

  /// R13: created once here, cancelled in dispose — after leaving the
  /// screen the timer never calls setState on a dead State.
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _apply(Meetup updated) {
    setState(() => _meetup = updated);
    widget.args.onChanged(updated);
  }

  /// R15: ask with `showDialog<bool>`, act only on true.
  Future<void> _join() async {
    if (_me.isEmpty) {
      final openProfile = widget.args.onOpenProfile;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in Profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              // Close this screen if it is still open, then let the
              // shell switch to the profile tab.
              if (mounted) Navigator.pop(context);
              openProfile();
            },
          ),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join "${_meetup.title}"?'),
        content: Text('You take one of ${_meetup.free} free places.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Join'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) return;
    _apply(_meetup.withMember(_me));
  }

  void _leave() => _apply(_meetup.withoutMember(_me));

  /// R26/R27: the form returns the edited meetup through pop.
  Future<void> _edit() async {
    final edited = await Navigator.pushNamed<Meetup>(
      context,
      Routes.form,
      arguments: FormArgs(initial: _meetup),
    );
    if (!mounted) return;
    if (edited == null) return;
    _apply(edited);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete meetup?'),
        content: Text('"${_meetup.title}" will be removed for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) return;
    widget.args.onDelete(_meetup.id);
    Navigator.pop(context);
  }

  /// R9: an exhaustive switch over the sealed class.
  String _countdownText(Countdown countdown) => switch (countdown) {
    Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
    Started() => 'Happening now',
    Ended() => 'Ended',
  };

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = _meetup.places;

    // R16: a button that cannot act gets onPressed: null.
    // Joined → "Leave"; full or past → disabled "Join".
    final VoidCallback? primaryAction = _joined
        ? _leave
        : (_meetup.isFull || _meetup.isPast ? null : _join);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // R31: the AppBar adds the back arrow itself; we never write one.
        appBar: AppBar(
          title: Text(_meetup.category.label),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (action) => switch (action) {
                _MenuAction.edit => _edit(),
                _MenuAction.delete => _delete(),
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(
              meetup: _meetup,
              countdown: _countdownText(Countdown.of(_meetup, _now)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: primaryAction,
                  icon: Icon(_joined ? Icons.logout : Icons.group_add),
                  label: Text(
                    _joined ? 'Leave' : (_meetup.isFull ? 'Full' : 'Join'),
                  ),
                ),
              ),
            ),
            // R29: the count in the label is read on every build — live.
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Members ($taken)'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(meetup: _meetup, taken: taken, free: free),
                  _MembersTab(meetup: _meetup, me: _me),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// R24: an image from assets/ with the icon in the middle, the category in
/// one corner and the countdown in the other.
class _Header extends StatelessWidget {
  const _Header({required this.meetup, required this.countdown});

  final Meetup meetup;
  final String countdown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/header.jpg', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: meetup.category.color(scheme),
              foregroundColor: scheme.surface,
              child: Icon(meetup.category.icon, size: 36),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Chip(
              avatar: Icon(meetup.category.icon),
              label: Text(meetup.category.label),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Chip(
              avatar: const Icon(Icons.timer_outlined),
              label: Text(countdown),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({
    required this.meetup,
    required this.taken,
    required this.free,
  });

  final Meetup meetup;
  final int taken;
  final int free;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(meetup.title, style: text.headlineSmall),
        const SizedBox(height: 16),
        _InfoRow(
          icon: Icons.schedule,
          label: 'When',
          value: formatDate(meetup.startsAt),
        ),
        _InfoRow(
          icon: meetup.isOnline ? Icons.link : Icons.place_outlined,
          label: meetup.isOnline ? 'Link' : 'Place',
          value: meetup.place,
        ),
        _InfoRow(
          icon: Icons.groups_outlined,
          label: 'Places',
          value: '$taken taken · $free free of ${meetup.capacity}',
        ),
        // R6: the optional text only when present — no `!` needed.
        if (meetup.description case final description?) ...[
          const Divider(height: 32),
          Text(description, style: text.bodyLarge),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.labelMedium),
                Text(value, style: text.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab({required this.meetup, required this.me});

  final Meetup meetup;
  final String me;

  @override
  Widget build(BuildContext context) {
    final members = meetup.members;
    if (members.isEmpty) {
      return const EmptyState(
        icon: Icons.group_outlined,
        message: 'Nobody has joined yet',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final name = members[index];
        final isMe = me.isNotEmpty && name == me;
        // "You" is highlighted with ListTile.selected and a chip.
        return ListTile(
          selected: isMe,
          title: Text('${index + 1}. $name'),
          trailing: isMe ? const Chip(label: Text('You')) : null,
        );
      },
    );
  }
}
