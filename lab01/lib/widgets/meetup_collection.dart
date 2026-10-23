import 'package:flutter/material.dart';

import '../models/meetup.dart';
import 'meetup_card.dart';

/// R20: a list on phones, a grid on wide screens.
///
/// LayoutBuilder, not MediaQuery: what matters is the width this widget
/// actually got, not the width of the whole screen.
class MeetupCollection extends StatelessWidget {
  const MeetupCollection({
    super.key,
    required this.meetups,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  static const breakpoint = 600.0;

  final List<Meetup> meetups;
  final ValueChanged<Meetup> onOpen;
  final ValueChanged<Meetup> onToggleFavourite;

  Widget _card(Meetup meetup) => MeetupCard(
    meetup: meetup,
    onTap: () => onOpen(meetup),
    onToggleFavourite: () => onToggleFavourite(meetup),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            // Cells are at most 360 px wide; a grid cell needs a height,
            // and 150 fits a two-line title, the date and the place.
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 150,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: meetups.length,
            itemBuilder: (context, index) => _card(meetups[index]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: meetups.length,
          itemBuilder: (context, index) => _card(meetups[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 4),
        );
      },
    );
  }
}
