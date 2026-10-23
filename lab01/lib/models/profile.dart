/// The person using the app: their name is what "Join" adds to a list.
class Profile {
  const Profile({required this.name, required this.group});

  /// R3: an empty profile, before the user typed anything.
  const Profile.empty() : name = '', group = '';

  final String name;
  final String group;

  bool get isEmpty => name.trim().isEmpty;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);
}
