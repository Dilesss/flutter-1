# Live-coding warm-ups — the two-minute plans

Rules: empty `flutter create`, timer 20:00, **say the plan out loud first (2 min)**, narrate while typing, **run after every change**, commit when the timer stops — whatever state it is in.

## Warm-up 1 — counter → ChangeNotifier → two screens
Plan to say: *"A `Counter extends ChangeNotifier` with `count` and `increment()`. One `ChangeNotifierProvider` **above** `MaterialApp`. Home shows `watch().count`, a button calls `read().increment()`, and pushes a second screen that shows the same count with its own button."*
Order: model (3 min) → provider in main (2) → home: watch + read (4) → second screen + push (5) → run, tap on both screens (2).

## Warm-up 2 — list from a fake repository that fails on demand
Plan to say: *"An interface `ItemRepository`, a `FakeItemRepository({fail, empty})` with a delay. A `ListModel(this._repo)` with `loading / error / items` and `load()`. The screen: one `switch` — loading, error with Retry, empty, data."*
Order: repo + fake (4) → model with try/on/finally (4) → provider + screen switch (6) → flip `fail` / `empty`, run each state (4).

## Warm-up 3 — a form with two fields + one unit test
Plan to say: *"A StatefulWidget with two controllers created once and disposed. `Form` + `GlobalKey<FormState>`, two `TextFormField`s with validators. The rule is a top-level function `validateEmail(String?)` — so the test calls it directly."*
Order: validator functions (3) → form screen + dispose (7) → submit shows a SnackBar (3) → `test/validators_test.dart` with 3 expects, `flutter test` (4).

At minute 18, if not finished, say: *"I would extract this into a ChangeNotifier and test it — want me to start?"*

`reference/` has one possible finished version of each — **read it only after your own timed attempt.**
