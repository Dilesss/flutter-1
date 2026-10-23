# KBTU Clubs

Lab 1, Mobile Development. An app for the meetups of KBTU student clubs:
find a meetup, join it, keep favourites, or create your own.

**Domain.** A *meetup* has a title, a club category (Tech, Sport, Music, Art,
Science, Debate), a start time, a capacity and the list of members who
joined. An *online* meetup has a link instead of a room. "Join" adds your
profile name to the members; when the list reaches the capacity the meetup
is full. All data lives in memory: twelve seed meetups, dated relative to
today.

## Screenshots

| Phone, light | Phone, dark | Tablet, grid |
|---|---|---|
| ![Phone light](screenshots/phone_light.png) | ![Phone dark](screenshots/phone_dark.png) | ![Tablet grid](screenshots/tablet_grid.png) |

## Structure

```
lib/
  main.dart                 ClubsApp: ThemeMode state, MaterialApp, themes
  routes.dart               Routes names, typed arguments, onGenerateRoute
  models/                   ClubCategory, Meetup, Profile, Countdown
  data/seed.dart            twelve seed meetups
  utils/format.dart         "18 Oct, 10:00" without packages
  shell/home_shell.dart     NavigationBar + drawer; owns meetups and profile
  tabs/                     meetups, favourites, profile
  screens/                  detail, form, not found
  widgets/                  card, list/grid, empty state, drawer
```

## Decisions

The list of meetups and the profile live in the shell's `State`, because
all three tabs and the pushed screens read them; tabs get them as
constructor parameters and send every change back up through a callback,
so there is one copy of the data and one place that changes it.
The detail screen receives callbacks because it acts on a meetup that the
shell owns (join, leave, delete) while it is still open, whereas the form
only produces a value, so it returns the new or edited meetup through
`Navigator.pop` and the caller decides what to do with it.
The grid is chosen by a `LayoutBuilder`, not `MediaQuery`, because what
matters is the width the list actually received, not the size of the whole
screen.
The form's `PopScope` compares a record of the current field values with
the record taken when the form opened, so only a form that really differs
asks "Discard changes?", and Save, which pops with `Navigator.pop`, never
asks.
With week 9's tools I would move the meetups out of the shell's `State`
into shared state and keep them on the device, so they survive a restart.
