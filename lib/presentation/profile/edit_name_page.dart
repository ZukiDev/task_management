import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../data/datasources/profile_local_datasource.dart';
import '../../data/local/session_storage.dart';
import '../../data/repositories/profile_repository_impl.dart';

/// Halaman sederhana untuk mengubah nama. Tidak perlu Controller
/// terpisah karena logic-nya satu baris (panggil repository), state
/// loading cukup field lokal di State.
class EditNamePage extends StatefulWidget {
  const EditNamePage({super.key});

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitting = false;

  late final _profileRepository = ProfileRepositoryImpl(
    SessionStorage(),
    ProfileLocalDatasource(),
  );

  @override
  void initState() {
    super.initState();
    _loadCurrentName();
  }

  Future<void> _loadCurrentName() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileRepository.getProfile();
      _nameController.text = profile.name;
    } catch (_) {
      // Biarkan field kosong jika gagal — user tetap bisa mengisi manual.
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await _profileRepository.updateName(_nameController.text.trim());
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan nama. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Ubah Nama', style: AppTextStyles.heading2),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        validator: (v) =>
                            Validators.required(v, fieldName: 'Nama'),
                        decoration: const InputDecoration(
                          labelText: 'Nama lengkap',
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Simpan',
                                  style: AppTextStyles.button,
                                ),
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
