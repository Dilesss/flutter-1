import 'package:flutter/material.dart';

import '../models/meetup.dart';
import '../utils/format.dart';

/// R18: the one card used by the list, the grid and the favourites tab.
class MeetupCard extends StatelessWidget {
  const MeetupCard({
    super.key,
    required this.meetup,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Meetup meetup;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // R5: the record getter, destructured where it is shown.
    final (:taken, free: _) = meetup.places;
    final where = meetup.isOnline ? 'Online · ${meetup.place}' : meetup.place;
    final when = meetup.isPast
        ? '${formatDate(meetup.startsAt)} · past'
        : formatDate(meetup.startsAt);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              MeetupAvatar(meetup: meetup),
              const SizedBox(width: 16),
              // Expanded gives the text a fixed width, so the 60-character
              // title wraps to two lines instead of overflowing.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      meetup.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$when · $taken/${meetup.capacity}',
                      style: text.bodySmall,
                    ),
                    Text(
                      where,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: meetup.isFavourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onToggleFavourite,
                color: meetup.isFavourite ? scheme.error : null,
                icon: Icon(
                  meetup.isFavourite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// R19: the category avatar with a places badge on top of it.
class MeetupAvatar extends StatelessWidget {
  const MeetupAvatar({super.key, required this.meetup});

  final Meetup meetup;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (taken: _, :free) = meetup.places;
    final full = meetup.isFull;

    return Stack(
      // Let the badge hang over the avatar's edge.
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: meetup.category.color(scheme),
          foregroundColor: scheme.surface,
          child: Icon(meetup.category.icon),
        ),
        // No badge at all when there are more than 5 places (collection if).
        if (full || free <= 5)
          Positioned(
            right: -10,
            bottom: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: full ? scheme.error : scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scheme.surface, width: 2),
              ),
              child: Text(
                full ? 'FULL' : '$free left',
                style: text.labelSmall?.copyWith(
                  color: full ? scheme.onError : scheme.onTertiaryContainer,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
