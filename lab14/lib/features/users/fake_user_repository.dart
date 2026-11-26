import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

/// A repository with no network: two users built in Dart.
/// Used by the tests and as a demo mode for the defence machine.
class FakeUserRepository implements UserRepository {
  FakeUserRepository({this.fail = false, this.delay = Duration.zero});

  /// true → every call throws NoConnectionException.
  final bool fail;

  /// How long each call "takes".
  final Duration delay;

  static const users = [
    User(
      id: 1,
      name: 'Aigerim Sadykova',
      username: 'aigerim',
      email: 'aigerim@kbtu.kz',
      phone: '+7 701 111 22 33',
      website: 'kbtu.edu.kz',
      address: Address(
        street: 'Tole bi 59',
        suite: 'Room 301',
        city: 'Almaty',
        zipcode: '050000',
        geo: Geo(lat: 43.2567, lng: 76.9286),
      ),
      company: (name: 'KBTU', catchPhrase: 'Learning Flutter'),
    ),
    User(
      id: 2,
      name: 'Nurlan Bekov',
      username: 'nurlan',
      email: 'nurlan@kbtu.kz',
      phone: '+7 702 444 55 66',
      address: Address(
        street: 'Mangilik El 55',
        suite: 'Apt. 12',
        city: 'Astana',
        zipcode: '010000',
        geo: Geo(lat: 51.0909, lng: 71.4187),
      ),
      company: (name: 'Kaspi', catchPhrase: 'Mobile first'),
    ),
  ];

  Future<void> _wait() async {
    await Future<void>.delayed(delay);
    if (fail) throw const NoConnectionException();
  }

  @override
  Future<UsersResult> getAll() async {
    await _wait();
    return (items: users, fromCache: false);
  }

  @override
  Future<User> getById(int id) async {
    await _wait();
    for (final u in users) {
      if (u.id == id) return u;
    }
    throw const NotFoundException();
  }

  @override
  Future<User> create(User draft) async {
    await _wait();
    return User(
      id: users.length + 1,
      name: draft.name,
      username: draft.username,
      email: draft.email,
      phone: draft.phone,
      website: draft.website,
      address: draft.address,
      company: draft.company,
    );
  }
}
