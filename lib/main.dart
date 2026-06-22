import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data locale 'id_ID' agar DateFormatter (lib/core/utils)
  // bisa menampilkan nama bulan/hari dalam Bahasa Indonesia.
  await initializeDateFormatting('id_ID');

  runApp(const TaskTrackerApp());
}