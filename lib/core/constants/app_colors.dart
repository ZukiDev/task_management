import 'package:flutter/material.dart';

/// Palet warna terpusat. Semua widget mengambil warna dari sini supaya
/// gampang diubah konsisten di satu tempat (bukan hardcode di tiap widget).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3D5CFF);
  static const Color primaryDark = Color(0xFF2A3FCC);

  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF1E2138);
  static const Color textSecondary = Color(0xFF8A8FA3);

  static const Color success = Color(0xFF22B07D);
  static const Color successBg = Color(0xFFE3F8EF);

  static const Color warning = Color(0xFFE8A33D);
  static const Color warningBg = Color(0xFFFCF1DF);

  static const Color danger = Color(0xFFE5484D);
  static const Color dangerBg = Color(0xFFFCE8E8);

  static const Color border = Color(0xFFE6E8F0);

  // Priority colors
  static const Color priorityLow = Color(0xFF22B07D);
  static const Color priorityMedium = Color(0xFFE8A33D);
  static const Color priorityHigh = Color(0xFFE5484D);
}
