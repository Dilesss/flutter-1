import 'package:flutter/material.dart';

import '../models/club_category.dart';
import '../models/meetup.dart';
import '../widgets/empty_state.dart';
import '../widgets/meetup_collection.dart';

/// Tab 1. Gets the meetups from the shell and sends taps back up as
/// callbacks (R10). Only the search and filter choices live here.
class MeetupsTab extends StatefulWidget {
  const MeetupsTab({
    super.key,
    required this.meetups,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Meetup> meetups;
  final ValueChanged<Meetup> onOpen;
  final ValueChanged<Meetup> onToggleFavourite;

  @override
  State<MeetupsTab> createState() => _MeetupsTabState();
}

class _MeetupsTabState extends State<MeetupsTab> {
  final _search = TextEditingController();

  /// null means "All".
  ClubCategory? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// R7: filter with `where`, then sort a copy (`toList()`), never the
  /// shell's list itself.
  List<Meetup> get _visible {
    final query = _search.text.trim().toLowerCase();
    final matches = widget.meetups.where(
      (m) =>
          (query.isEmpty || m.title.toLowerCase().contains(query)) &&
          (_category == null || m.category == _category) &&
          (_showPast || !m.isPast),
    );
    return matches.toList()..sort(compareMeetups);
  }

  void _clearSearch() => setState(() => _search.clear());

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    // R21: search, chips and the list in one Column; the list gets the rest
    // of the height through Expanded.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _search,
            // The text already changed in the controller; rebuild to filter.
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search meetups',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _chip(
                ChoiceChip(
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
              ),
              for (final category in ClubCategory.values)
                _chip(
                  ChoiceChip(
                    avatar: Icon(category.icon),
                    label: Text(category.label),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                ),
              _chip(
                FilterChip(
                  label: const Text('Show past'),
                  selected: _showPast,
                  onSelected: (value) => setState(() => _showPast = value),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No meetups match',
                  actionLabel: 'Clear search',
                  onAction: _clearSearch,
                )
              : MeetupCollection(
                  meetups: visible,
                  onOpen: widget.onOpen,
                  onToggleFavourite: widget.onToggleFavourite,
                ),
        ),
      ],
    );
  }

  Widget _chip(Widget chip) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: chip);
}
