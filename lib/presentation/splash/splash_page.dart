import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../data/local/session_storage.dart';
import 'splash_controller.dart';

/// Halaman pertama yang muncul saat app dibuka. Mengecek apakah ada
/// session login yang masih valid, lalu mengarahkan ke Main Shell
/// (kalau sudah login) atau Login Page (kalau belum / token expired).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplashController(SessionStorage());
    _navigateAfterCheck();
  }

  Future<void> _navigateAfterCheck() async {
    // Memberi sedikit delay agar splash tidak "berkedip" terlalu cepat
    // jika pengecekan session sangat instan.
    final result = await Future.wait([
      _controller.checkSession(),
      Future.delayed(const Duration(milliseconds: 800)),
    ]);

    if (!mounted) return;

    final splashResult = result[0] as SplashResult;
    final destination = splashResult == SplashResult.authenticated
        ? AppRoutes.mainShell
        : AppRoutes.login;

    Navigator.of(context).pushReplacementNamed(destination);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 72),
            SizedBox(height: 16),
            Text(
              'Task Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
