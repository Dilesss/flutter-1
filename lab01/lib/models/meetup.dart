import 'dart:collection';

import 'club_category.dart';

/// One meeting of a KBTU student club.
///
/// R1: immutable — every field is final, the constructor is const and changes
/// go through [copyWith]. The members list is private and exposed read-only.
class Meetup {
  const Meetup({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.capacity,
    required this.isOnline,
    required this.place,
    this.description,
    this.isFavourite = false,
    this._members = const [],
  });

  /// R3: the defaults for a brand-new meetup in the form.
  Meetup.empty()
    : id = '',
      title = '',
      category = ClubCategory.tech,
      startsAt = DateTime.now(),
      capacity = 20,
      isOnline = false,
      place = '',
      description = null,
      isFavourite = false,
      _members = const [];

  /// How long a meetup lasts; used by the countdown to tell
  /// "happening now" from "ended".
  static const length = Duration(hours: 2);

  final String id;
  final String title;
  final ClubCategory category;
  final DateTime startsAt;

  /// The limit the members list counts against.
  final int capacity;

  /// The mode: when true, [place] is a link instead of a room.
  final bool isOnline;
  final String place;

  /// Optional text: shown only when present (R6).
  final String? description;
  final bool isFavourite;
  final List<String> _members;

  /// Read-only view: `meetup.members.add(...)` throws instead of
  /// silently changing state from outside.
  List<String> get members => UnmodifiableListView(_members);

  // R4: derived values are getters, never stored fields.
  int get count => _members.length;
  int get free => capacity > count ? capacity - count : 0;
  bool get isFull => count >= capacity;
  bool get isPast => startsAt.isBefore(DateTime.now());
  bool contains(String name) => _members.contains(name);

  /// R5: taken and free places as one record.
  ({int taken, int free}) get places => (taken: count, free: free);

  Meetup copyWith({
    String? title,
    ClubCategory? category,
    DateTime? startsAt,
    int? capacity,
    bool? isOnline,
    String? place,
    String? description,
    bool? isFavourite,
    List<String>? members,
  }) => Meetup(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    startsAt: startsAt ?? this.startsAt,
    capacity: capacity ?? this.capacity,
    isOnline: isOnline ?? this.isOnline,
    place: place ?? this.place,
    description: description ?? this.description,
    isFavourite: isFavourite ?? this.isFavourite,
    members: members ?? _members,
  );

  /// A copy with [name] added to the members. The original is untouched.
  Meetup withMember(String name) => copyWith(members: [..._members, name]);

  /// A copy without [name]. Built with `where`, never `remove` (R7).
  Meetup withoutMember(String name) =>
      copyWith(members: _members.where((m) => m != name).toList());
}

/// Upcoming meetups first by date, past ones last.
int compareMeetups(Meetup a, Meetup b) {
  if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
  return a.startsAt.compareTo(b.startsAt);
}
