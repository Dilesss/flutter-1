import 'package:flutter/material.dart';

import '../models/meetup.dart';
import '../widgets/empty_state.dart';
import '../widgets/meetup_collection.dart';

/// Tab 2: the favourite meetups. Stateless — everything comes from the shell.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.meetups,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  final List<Meetup> meetups;
  final ValueChanged<Meetup> onOpen;
  final ValueChanged<Meetup> onToggleFavourite;

  /// Switches to the first tab — through the shell (R28).
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = meetups.where((m) => m.isFavourite).toList()
      ..sort(compareMeetups);
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet.\nTap the heart on a meetup.',
        actionLabel: 'Browse meetups',
        onAction: onBrowse,
      );
    }
    return MeetupCollection(
      meetups: favourites,
      onOpen: onOpen,
      onToggleFavourite: onToggleFavourite,
    );
  }
}
