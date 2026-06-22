import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/local/session_storage.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'login_controller.dart';

/// Halaman Login. StatefulWidget murni untuk UI: render form, validasi
/// lewat Form/TextFormField, dan delegasikan logic ke [LoginController].
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    // Dependency dirakit manual di sini (tanpa DI framework) — cukup
    // untuk scope app ini. Kalau project membesar, ini titik yang
    // mudah diganti dengan service locator (get_it) atau Provider.
    final sessionStorage = SessionStorage();
    final apiClient = ApiClient();
    final authRepository = AuthRepositoryImpl(
      AuthRemoteDatasource(apiClient),
      sessionStorage,
    );
    _controller = LoginController(authRepository);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {}); // trigger build agar tombol loading muncul cepat
    final success = await _controller.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    setState(() {});

    if (!mounted) return;

    if (success) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.mainShell, (route) => false);
    } else if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text('Selamat datang', style: AppTextStyles.heading1),
                const SizedBox(height: 6),
                const Text(
                  'Masuk untuk mengelola task Anda',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _controller.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _controller.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Masuk', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.register),
                    child: const Text('Belum punya akun? Daftar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
