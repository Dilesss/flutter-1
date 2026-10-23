import 'meetup.dart';

/// R9: the three states of a meetup in time.
///
/// `sealed` means these three subclasses are the only ones, so a `switch`
/// over a Countdown must handle all of them — the compiler checks.
sealed class Countdown {
  const Countdown();

  factory Countdown.of(Meetup meetup, DateTime now) {
    final untilStart = meetup.startsAt.difference(now);
    if (!untilStart.isNegative) return Upcoming(untilStart);
    final sinceStart = now.difference(meetup.startsAt);
    if (sinceStart < Meetup.length) return Started(sinceStart);
    return const Ended();
  }
}

/// Not started yet; [left] is the time until the start.
final class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

/// Going on right now; [elapsed] is the time since the start.
final class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

/// Over.
final class Ended extends Countdown {
  const Ended();
}
