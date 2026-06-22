import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/routing/app_routes.dart';
import '../data/models/task_model.dart';
import '../presentation/auth/login_page.dart';
import '../presentation/auth/register_page.dart';
import '../presentation/profile/change_password_page.dart';
import '../presentation/profile/edit_name_page.dart';
import '../presentation/profile/edit_photo_page.dart';
import '../presentation/shell/main_shell_page.dart';
import '../presentation/splash/splash_page.dart';
import '../presentation/task/task_detail_page.dart';
import '../presentation/task/task_form_page.dart';

/// Root widget aplikasi. Semua navigasi dikelola lewat satu
/// [onGenerateRoute] terpusat di sini — bukan tersebar lewat
/// `MaterialPageRoute` di banyak file `onPressed`. Ini memudahkan
/// melihat "halaman apa saja yang ada di app ini" dari satu tempat,
/// dan memudahkan passing argument secara type-safe.
class TaskTrackerApp extends StatelessWidget {
  const TaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case AppRoutes.mainShell:
        return MaterialPageRoute(builder: (_) => const MainShellPage());

      case AppRoutes.taskForm:
        // Argument opsional: null = mode Add, TaskModel = mode Edit.
        final task = settings.arguments as TaskModel?;
        return MaterialPageRoute(
          builder: (_) => TaskFormPage(existingTask: task),
        );

      case AppRoutes.taskDetail:
        final task = settings.arguments as TaskModel;
        return MaterialPageRoute(builder: (_) => TaskDetailPage(task: task));

      case AppRoutes.editName:
        return MaterialPageRoute(builder: (_) => const EditNamePage());

      case AppRoutes.editPhoto:
        return MaterialPageRoute(builder: (_) => const EditPhotoPage());

      case AppRoutes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route tidak ditemukan: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
