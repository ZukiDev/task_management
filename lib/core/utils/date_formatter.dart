import 'package:intl/intl.dart';

/// Kumpulan fungsi format tanggal yang dipakai berulang di banyak widget
/// (Task Card, Task Detail, Date Page). Disatukan di sini agar formatnya
/// konsisten di seluruh app.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _displayFormatWithDay =
      DateFormat('EEEE, d MMM yyyy', 'id_ID');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _isoDateFormat = DateFormat('yyyy-MM-dd');

  /// Format ringkas untuk kartu task. Contoh: "21 Jun 2026"
  static String toDisplay(DateTime date) => _displayFormat.format(date);

  /// Format lengkap dengan nama hari untuk Task Detail.
  /// Contoh: "Senin, 21 Jun 2026"
  static String toDisplayWithDay(DateTime date) =>
      _displayFormatWithDay.format(date);

  /// Untuk header kalender bulanan. Contoh: "Juni 2026"
  static String toMonthYear(DateTime date) => _monthYearFormat.format(date);

  /// Format "yyyy-MM-dd" dipakai sebagai key Map<String, List<Task>> di
  /// DateController, supaya perbandingan tanggal tidak terganggu oleh
  /// komponen jam/menit/detik.
  static String toDateKey(DateTime date) => _isoDateFormat.format(date);

  /// Membandingkan apakah dua DateTime jatuh di hari kalender yang sama,
  /// mengabaikan jam/menit/detik.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}