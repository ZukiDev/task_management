import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/app_routes.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/local/session_storage.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/task_card.dart';
import 'task_list_controller.dart';

/// Halaman Task List (tab kedua). Full CRUD: lihat semua task, search,
/// filter status, tambah (FAB), edit, hapus, toggle status langsung
/// dari checkbox di kartu.
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final _searchController = TextEditingController();
  late final TaskListController _controller;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final sessionStorage = SessionStorage();
    final taskRepository = TaskRepositoryImpl(
      TaskRemoteDatasource(apiClient),
      sessionStorage,
    );
    _controller = TaskListController(taskRepository);
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {});
    await _controller.loadTasks();
    if (mounted) setState(() {});
  }

  Future<void> _handleToggleStatus(TaskModel task) async {
    final success = await _controller.toggleStatus(task);
    if (!mounted) return;
    setState(() {});
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status task berhasil diperbarui')),
      );
    } else if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.errorMessage!)));
    }
  }

  Future<void> _handleDelete(TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus task?'),
        content: Text('Task "${task.title}" akan dihapus permanen.'),
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

    final success = await _controller.deleteTask(task.id);
    if (!mounted) return;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Task berhasil dihapus'
              : (_controller.errorMessage ?? 'Gagal menghapus'),
        ),
      ),
    );
  }

  Future<void> _goToForm({TaskModel? existingTask}) async {
    final result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.taskForm, arguments: existingTask);
    if (result is String) {
      await _loadTasks();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  Future<void> _goToDetail(TaskModel task) async {
    final result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.taskDetail, arguments: task);
    await _loadTasks();
    if (result is String && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Task Saya', style: AppTextStyles.heading2),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _goToForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTasks,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: AppSearchBar(
                  controller: _searchController,
                  onChanged: (v) {
                    _controller.updateSearchQuery(v);
                    setState(() {});
                  },
                ),
              ),
              _buildFilterChips(),
              const SizedBox(height: 8),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _filterChip('Semua', TaskStatusFilter.all),
          const SizedBox(width: 8),
          _filterChip('Pending', TaskStatusFilter.pending),
          const SizedBox(width: 8),
          _filterChip('Done', TaskStatusFilter.done),
        ],
      ),
    );
  }

  Widget _filterChip(String label, TaskStatusFilter filter) {
    final isSelected = _controller.statusFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        _controller.updateStatusFilter(filter);
        setState(() {});
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && !_controller.hasAnyTaskBeforeFilter) {
      return const AppLoading(message: 'Memuat task...');
    }

    if (_controller.errorMessage != null &&
        !_controller.hasAnyTaskBeforeFilter) {
      return AppErrorView(
        message: _controller.errorMessage!,
        onRetry: _loadTasks,
      );
    }

    final tasks = _controller.tasks;

    if (tasks.isEmpty) {
      return AppEmptyState(
        icon: Icons.task_alt,
        title: _controller.hasAnyTaskBeforeFilter
            ? 'Tidak ada task yang cocok'
            : 'Belum ada task',
        subtitle: _controller.hasAnyTaskBeforeFilter
            ? 'Coba ubah kata kunci atau filter'
            : 'Tap tombol + untuk menambah task baru',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: ValueKey(task.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              await _handleDelete(task);
              return false; // delete sudah ditangani manual di atas
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_outline, color: AppColors.danger),
            ),
            child: TaskCard(
              task: task,
              onTap: () => _goToDetail(task),
              onStatusToggle: (_) => _handleToggleStatus(task),
            ),
          ),
        );
      },
    );
  }
}
