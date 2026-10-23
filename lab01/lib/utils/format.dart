/// R8: our own date formatting — no intl package.
library;

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// 5 → "05". Used for minutes and hours.
String _two(int n) => n.toString().padLeft(2, '0');

/// "18 Oct, 10:00"
String formatDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]}, ${formatClock(d.hour, d.minute)}';

/// "18 Oct 2026" — for the date field in the form.
String formatDay(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// "09:05"
String formatClock(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

/// "3 d 4 h", "2 h 05 min" or "12 min".
String formatDuration(Duration d) {
  if (d.inDays >= 1) return '${d.inDays} d ${d.inHours % 24} h';
  if (d.inHours >= 1) return '${d.inHours} h ${_two(d.inMinutes % 60)} min';
  return '${d.inMinutes} min';
}
