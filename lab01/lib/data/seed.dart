import '../models/club_category.dart';
import '../models/meetup.dart';

/// Twelve meetups with dates relative to today, so the app never runs out
/// of upcoming ones.
///
/// The five the defence looks at:
///  * m1  — title of exactly 60 characters
///  * m2  — full: 6 of 6 places taken
///  * m3  — in the past
///  * m4  — online (place is a link)
///  * m5  — no description
List<Meetup> seedMeetups() {
  final now = DateTime.now();
  DateTime at(int days, int hour, [int minute = 0]) =>
      DateTime(now.year, now.month, now.day + days, hour, minute);

  return [
    Meetup(
      id: 'm1',
      title: 'KBTU Robotics Club: Build a Line-Follower Robot from Scratch',
      category: ClubCategory.tech,
      startsAt: at(3, 15),
      capacity: 25,
      isOnline: false,
      place: 'Lab 312, Tole Bi 59',
      description:
          'Bring a laptop. Arduino kits, sensors and motors are provided. '
          'We finish with a race on the track in the lobby.',
      members: const ['Aruzhan Mukhtar', 'Timur Zhaksylyk', 'Dana Orazbek'],
    ),
    Meetup(
      id: 'm2',
      title: 'Chess Club Blitz Night',
      category: ClubCategory.debate,
      startsAt: at(1, 19),
      capacity: 6,
      isOnline: false,
      place: 'Library, room 2',
      description: 'Five-minute games, Swiss system, six boards only.',
      isFavourite: true,
      members: const [
        'Aida Akhmetova',
        'Dias Nurlanov',
        'Madina Serik',
        'Alikhan Bekov',
        'Arman Kairat',
        'Zhanel Tolegen',
      ],
    ),
    Meetup(
      id: 'm3',
      title: 'Volleyball Training',
      category: ClubCategory.sport,
      startsAt: at(-3, 18),
      capacity: 20,
      isOnline: false,
      place: 'KBTU Sports Hall',
      description: 'Warm-up, serving drills and a match at the end.',
      members: const ['Nurlan Abdi', 'Kamila Dosym', 'Dilnaz Yessenkyzy'],
    ),
    Meetup(
      id: 'm4',
      title: 'Flutter Study Group: State Management',
      category: ClubCategory.tech,
      startsAt: at(2, 20),
      capacity: 100,
      isOnline: true,
      place: 'https://meet.google.com/kbt-flut-ter',
      description: 'setState, InheritedWidget and what comes after them.',
      members: const ['Yerlan Sadyk', 'Sanzhar Kenzhe', 'Dilnaz Yessenkyzy'],
    ),
    Meetup(
      id: 'm5',
      title: 'Open Mic: Acoustic Evening',
      category: ClubCategory.music,
      startsAt: at(5, 18, 30),
      capacity: 40,
      isOnline: false,
      place: 'Main Hall, 1st floor',
      members: const ['Amina Talgat', 'Bekzat Ospan'],
    ),
    Meetup(
      id: 'm6',
      title: 'Watercolour Sketching in the Park',
      category: ClubCategory.art,
      startsAt: at(4, 11),
      capacity: 12,
      isOnline: false,
      place: 'Panfilov Park, main entrance',
      description: 'Paper and paints for the first twelve.',
      isFavourite: true,
      members: const [
        'Inkar Rakhim',
        'Daniyar Amir',
        'Ayan Bolat',
        'Tomiris Serikbay',
        'Aida Akhmetova',
        'Madina Serik',
        'Dana Orazbek',
        'Kamila Dosym',
        'Arman Kairat',
      ],
    ),
    Meetup(
      id: 'm7',
      title: 'Debate: Should AI Write Our Exams?',
      category: ClubCategory.debate,
      startsAt: at(6, 17),
      capacity: 30,
      isOnline: false,
      place: 'Room 501',
      description: 'British Parliamentary format. Judges from the law club.',
      members: const ['Alikhan Bekov', 'Zhanel Tolegen'],
    ),
    Meetup(
      id: 'm8',
      title: 'Astronomy Night: Telescopes on the Roof',
      category: ClubCategory.science,
      startsAt: at(8, 21),
      capacity: 15,
      isOnline: false,
      place: 'Roof terrace, Main building',
      description: 'Dress warmly. Cancelled if the sky is cloudy.',
      members: const [
        'Timur Zhaksylyk',
        'Nurlan Abdi',
        'Yerlan Sadyk',
        'Sanzhar Kenzhe',
        'Amina Talgat',
        'Bekzat Ospan',
        'Inkar Rakhim',
        'Daniyar Amir',
        'Ayan Bolat',
        'Tomiris Serikbay',
        'Aruzhan Mukhtar',
      ],
    ),
    Meetup(
      id: 'm9',
      title: 'Morning Run Around the Campus',
      category: ClubCategory.sport,
      startsAt: at(1, 7, 30),
      capacity: 50,
      isOnline: false,
      place: 'Main entrance, Tole Bi 59',
      description: '5 km at an easy pace. Coffee after.',
      members: const ['Dias Nurlanov'],
    ),
    Meetup(
      id: 'm10',
      title: 'Choir Rehearsal',
      category: ClubCategory.music,
      startsAt: at(-1, 16),
      capacity: 25,
      isOnline: false,
      place: 'Assembly Hall',
      description: 'Preparing for the New Year concert.',
      members: const ['Madina Serik', 'Aida Akhmetova', 'Kamila Dosym'],
    ),
    Meetup(
      id: 'm11',
      title: 'Data Science Reading Group',
      category: ClubCategory.science,
      startsAt: at(10, 19),
      capacity: 30,
      isOnline: true,
      place: 'https://zoom.us/j/2026101510',
      description: 'Chapter 4 of "Hands-On Machine Learning".',
      members: const [],
    ),
    Meetup(
      id: 'm12',
      title: 'Poster Design Workshop',
      category: ClubCategory.art,
      startsAt: at(12, 14),
      capacity: 10,
      isOnline: false,
      place: 'Design studio, room 214',
      description: 'Typography and layout for the spring festival posters.',
      members: const ['Zhanel Tolegen', 'Arman Kairat', 'Ayan Bolat'],
    ),
  ];
}
