import 'package:flutter/material.dart';

/// The kind of club a meetup belongs to.
///
/// An enhanced enum: every value carries its own label and icon, so chips,
/// the dropdown and the avatar all read them from here.
enum ClubCategory {
  tech('Tech', Icons.computer),
  sport('Sport', Icons.sports_basketball),
  music('Music', Icons.music_note),
  art('Art', Icons.palette),
  science('Science', Icons.science),
  debate('Debate', Icons.forum);

  const ClubCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  /// R2: an exhaustive switch expression over the enum. Adding a seventh
  /// value without a colour here is a compile error, not a runtime bug.
  Color color(ColorScheme scheme) => switch (this) {
    ClubCategory.tech => scheme.primary,
    ClubCategory.sport => scheme.tertiary,
    ClubCategory.music => scheme.secondary,
    ClubCategory.art => scheme.error,
    ClubCategory.science => scheme.onSurfaceVariant,
    ClubCategory.debate => scheme.outline,
  };
}
