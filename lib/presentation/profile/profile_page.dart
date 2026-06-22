import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routing/app_routes.dart';
import '../../data/datasources/profile_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/local/session_storage.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import 'profile_controller.dart';
import '../../core/network/api_client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    final sessionStorage = SessionStorage();
    final profileRepository = ProfileRepositoryImpl(
      sessionStorage,
      ProfileLocalDatasource(),
    );
    final authRepository = AuthRepositoryImpl(
      AuthRemoteDatasource(ApiClient()),
      sessionStorage,
    );
    _controller = ProfileController(profileRepository, authRepository);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {});
    await _controller.loadProfile();
    if (mounted) setState(() {});
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Anda akan keluar dari akun ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _controller.logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = _controller.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Profil', style: AppTextStyles.heading2),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    backgroundImage:
                        (user?.localPhotoPath != null &&
                            user!.localPhotoPath!.isNotEmpty)
                        ? FileImage(File(user.localPhotoPath!))
                        : null,
                    child:
                        (user?.localPhotoPath == null ||
                            user!.localPhotoPath!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name.isNotEmpty == true ? user!.name : 'Pengguna',
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _menuTile(
              icon: Icons.badge_outlined,
              label: 'Ubah Nama',
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.editName).then((_) => _loadProfile()),
            ),
            _menuTile(
              icon: Icons.image_outlined,
              label: 'Ubah Foto Profil',
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.editPhoto).then((_) => _loadProfile()),
            ),
            _menuTile(
              icon: Icons.lock_outline,
              label: 'Ubah Password',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.changePassword),
            ),
            const SizedBox(height: 12),
            _menuTile(
              icon: Icons.logout,
              label: 'Keluar',
              iconColor: AppColors.danger,
              labelColor: AppColors.danger,
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = AppColors.textPrimary,
    Color labelColor = AppColors.textPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(label, style: TextStyle(color: labelColor)),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
