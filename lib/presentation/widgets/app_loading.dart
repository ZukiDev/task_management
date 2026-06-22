import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Indikator loading terpusat. Dipakai di semua page yang punya state
/// loading agar tampilannya konsisten di seluruh app.
class AppLoading extends StatelessWidget {
  final String? message;

  const AppLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
