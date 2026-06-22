import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _displayFormatWithDay = DateFormat(
    'EEEE, d MMM yyyy',
    'id_ID',
  );
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _isoDateFormat = DateFormat('yyyy-MM-dd');

  static String toDisplay(DateTime date) => _displayFormat.format(date);

  static String toDisplayWithDay(DateTime date) =>
      _displayFormatWithDay.format(date);

  static String toMonthYear(DateTime date) => _monthYearFormat.format(date);

  static String toDateKey(DateTime date) => _isoDateFormat.format(date);

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
