import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/routing/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/task_change_notifier.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/local/session_storage.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_status.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../widgets/priority_badge.dart';
import '../widgets/status_badge.dart';

/// Halaman detail task. Menampilkan seluruh field lengkap, tombol
/// toggle status, serta aksi Edit dan Hapus.
///
/// Halaman ini cukup sederhana sehingga tidak memerlukan Controller
/// terpisah — state ditangani langsung di StatefulWidget memakai
/// TaskRepository, konsisten dengan keputusan "controller dipakai bila
/// ada logic non-trivial; halaman read-mostly cukup state lokal".
class TaskDetailPage extends StatefulWidget {
  final TaskModel task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TaskModel _task;
  bool _isUpdatingStatus = false;
  bool _isDeleting = false;

  late final taskRepository = TaskRepositoryImpl(
    TaskRemoteDatasource(ApiClient()),
    SessionStorage(),
  );

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _toggleStatus() async {
    final newStatus = _task.status == TaskStatus.done
        ? TaskStatus.pending
        : TaskStatus.done;

    setState(() => _isUpdatingStatus = true);
    try {
      final updated = await taskRepository.updateStatus(_task, newStatus);
      setState(() {
        _task = updated;
        _isUpdatingStatus = false;
      });
      TaskChangeNotifier().notify();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status task berhasil diperbarui')),
      );
    } on ApiException catch (e) {
      setState(() => _isUpdatingStatus = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _goToEdit() async {
    final result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.taskForm, arguments: _task);
    if (result is String) {
      // Ambil ulang data terbaru setelah edit.
      try {
        final refreshed = await taskRepository.getTaskById(_task.id);
        setState(() => _task = refreshed);
      } catch (_) {
        // Jika gagal refresh, tetap tampilkan data lama tanpa mengganggu
        // pengalaman pengguna dengan error tambahan.
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus task?'),
        content: Text('Task "${_task.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    try {
      await taskRepository.deleteTask(_task.id);
      TaskChangeNotifier().notify();
      if (!mounted) return;
      Navigator.of(context).pop('Task berhasil dihapus');
    } on ApiException catch (e) {
      setState(() => _isDeleting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _task.status == TaskStatus.done;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Detail Task', style: AppTextStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _goToEdit,
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: _isDeleting ? null : _handleDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(_task.title, style: AppTextStyles.heading1),
                  ),
                  StatusBadge(status: _task.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormatter.toDisplayWithDay(_task.dueDate),
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(width: 16),
                  PriorityBadge(priority: _task.priority),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Deskripsi', style: AppTextStyles.caption),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  _task.description.isNotEmpty
                      ? _task.description
                      : 'Tidak ada deskripsi.',
                  style: AppTextStyles.body,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isUpdatingStatus ? null : _toggleStatus,
                  icon: _isUpdatingStatus
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isDone
                              ? Icons.replay_outlined
                              : Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                  label: Text(
                    isDone ? 'Tandai sebagai Pending' : 'Tandai sebagai Done',
                    style: AppTextStyles.button,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDone
                        ? AppColors.warning
                        : AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
