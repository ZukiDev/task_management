/// Kumpulan nama route (string constant) yang dipakai di seluruh app.
///
/// Memakai named routes (bukan langsung `MaterialPageRoute` di tiap
/// `onPressed`) supaya navigasi terpusat dan mudah dilacak — semua
/// "kemana app ini bisa pergi" ada di satu file ini.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  /// Main shell berisi bottom navigation (Home, Task, Date, Profile).
  static const String mainShell = '/main';

  static const String taskForm = '/task-form';
  static const String taskDetail = '/task-detail';

  static const String editName = '/profile/edit-name';
  static const String editPhoto = '/profile/edit-photo';
  static const String changePassword = '/profile/change-password';
}