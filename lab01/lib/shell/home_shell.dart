import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/meetup.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../tabs/favourites_tab.dart';
import '../tabs/meetups_tab.dart';
import '../tabs/profile_tab.dart';
import '../widgets/app_drawer.dart';

/// The shell: NavigationBar with three tabs and the drawer.
///
/// R10: the meetups and the profile live HERE, in the shell's State.
/// Tabs get them as constructor parameters and send changes back up
/// through callbacks. One copy of the data, one place that changes it.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _titles = ['Meetups', 'Favourites', 'Profile'];

  List<Meetup> _meetups = seedMeetups();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  // R12: every setState wraps the change only.
  void _selectTab(int index) => setState(() => _tab = index);

  void _replace(Meetup updated) => setState(() {
    _meetups = [for (final m in _meetups) m.id == updated.id ? updated : m];
  });

  void _toggleFavourite(Meetup meetup) =>
      _replace(meetup.copyWith(isFavourite: !meetup.isFavourite));

  void _delete(String id) => setState(() {
    _meetups = _meetups.where((m) => m.id != id).toList();
  });

  void _updateProfile(Profile profile) => setState(() => _profile = profile);

  /// R26: the detail gets the meetup and callbacks through route arguments.
  void _openDetail(Meetup meetup) {
    Navigator.pushNamed<void>(
      context,
      Routes.detail,
      arguments: DetailArgs(
        meetup: meetup,
        userName: _profile.name,
        onChanged: _replace,
        onDelete: _delete,
        // R28: a pushed screen asks the shell to switch tabs.
        onOpenProfile: () => _selectTab(2),
      ),
    );
  }

  /// R27: await the form's result, check null and mounted, then setState.
  Future<void> _create() async {
    final created = await Navigator.pushNamed<Meetup>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (!mounted) return;
    if (created == null) return;
    setState(() => _meetups = [..._meetups, created]);
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('KBTU Clubs'),
        content: const Text(
          'Meetups of KBTU student clubs: find one, join it, '
          'or create your own. Lab 1, Mobile Development.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'All changes are lost: the 12 seed meetups come back '
          'and the profile is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) return;
    setState(() {
      _meetups = seedMeetups();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: AppDrawer(onAbout: _showAbout, onReset: _resetData),
      body: switch (_tab) {
        0 => MeetupsTab(
          meetups: _meetups,
          onOpen: _openDetail,
          onToggleFavourite: _toggleFavourite,
        ),
        1 => FavouritesTab(
          meetups: _meetups,
          onOpen: _openDetail,
          onToggleFavourite: _toggleFavourite,
          onBrowse: () => _selectTab(0),
        ),
        _ => ProfileTab(
          profile: _profile,
          meetups: _meetups,
          onChanged: _updateProfile,
          themeMode: widget.themeMode,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      },
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: const Text('New meetup'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Meetups',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
