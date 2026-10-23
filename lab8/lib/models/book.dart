// Plain Dart: nothing from Flutter is imported here.

class Book {
  Book({
    required this.title,
    required this.author,
    required this.pages,
    this.year,
    this.read = false,
  });

  /// Builds a Book from a map. A missing 'year' stays null,
  /// a missing 'read' becomes false. No `!` anywhere.
  Book.fromMap(Map<String, dynamic> m)
    : title = m['title'] as String,
      author = m['author'] as String,
      pages = m['pages'] as int,
      year = m['year'] as int?,
      read = m['read'] as bool? ?? false;

  final String title;
  final String author;
  final int pages;
  final int? year;
  bool read;

  /// "Null Safety for Humans — B. Seitkali, 196 pp. (2022)".
  /// Without a year the parentheses are not printed at all.
  @override
  String toString() =>
      '$title — $author, $pages pp.${year == null ? '' : ' ($year)'}';
}

/// Sum of all pages, with fold.
int totalPages(List<Book> books) =>
    books.fold(0, (sum, book) => sum + book.pages);

/// The books not read yet, with where.
List<Book> unread(List<Book> books) => books.where((b) => !b.read).toList();

/// Every author once, in the original order: map, then toSet.
List<String> authors(List<Book> books) =>
    books.map((b) => b.author).toSet().toList();

final seed = <Book>[
  Book(
    title: 'Widgets All the Way Down',
    author: 'A. Nurmagambetova',
    pages: 288,
    year: 2021,
    read: true,
  ),
  Book(
    title: 'Null Safety for Humans',
    author: 'B. Seitkali',
    pages: 196,
    year: 2022,
  ),
  Book(
    title: 'Constraints Go Down, Sizes Go Up',
    author: 'C. Tashimova',
    pages: 320,
  ),
  Book(
    title: 'The Navigator Is a Stack',
    author: 'D. Alibekov',
    pages: 240,
    year: 2020,
  ),
  Book(
    title:
        'A Very Long Title About Forms, Focus, the Keyboard '
        'and Everything That Overflows',
    author: 'E. Omarova',
    pages: 176,
    year: 2023,
  ),
];
