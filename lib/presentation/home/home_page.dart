import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/app_routes.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/local/session_storage.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/summary_stat_card.dart';
import '../widgets/task_card.dart';
import 'home_controller.dart';

/// Halaman dashboard (tab pertama bottom navigation). Menampilkan:
/// - profile bar (foto + nama user)
/// - search bar (filter task dari sisi klien)
/// - summary card (total / done / pending)
/// - daftar 5 task terbaru
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final sessionStorage = SessionStorage();
    final taskRepository = TaskRepositoryImpl(
      TaskRemoteDatasource(apiClient),
      sessionStorage,
    );
    _controller = HomeController(taskRepository, sessionStorage);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {});
    await _controller.loadDashboard();
    if (mounted) setState(() {});
  }

  void _onSearchChanged(String value) {
    _controller.updateSearchQuery(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(onRefresh: _loadData, child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.currentUser == null) {
      return const AppLoading(message: 'Memuat dashboard...');
    }

    if (_controller.errorMessage != null && _controller.totalCount == 0) {
      return AppErrorView(
        message: _controller.errorMessage!,
        onRetry: _loadData,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _buildProfileBar(),
        const SizedBox(height: 20),
        AppSearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 20),
        _buildSummaryRow(),
        const SizedBox(height: 24),
        const Text('Task terbaru', style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        ..._buildRecentTaskList(),
      ],
    );
  }

  Widget _buildProfileBar() {
    final user = _controller.currentUser;
    final photoPath = user?.localPhotoPath;

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          backgroundImage: (photoPath != null && photoPath.isNotEmpty)
              ? FileImage(File(photoPath))
              : null,
          child: (photoPath == null || photoPath.isEmpty)
              ? const Icon(Icons.person, color: AppColors.primary)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selamat datang,', style: AppTextStyles.bodySecondary),
              Text(
                user?.name.isNotEmpty == true ? user!.name : 'Pengguna',
                style: AppTextStyles.heading2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: SummaryStatCard(
            label: 'Total task',
            value: _controller.totalCount,
            color: AppColors.primary,
            icon: Icons.list_alt,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryStatCard(
            label: 'Selesai',
            value: _controller.doneCount,
            color: AppColors.success,
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryStatCard(
            label: 'Pending',
            value: _controller.pendingCount,
            color: AppColors.warning,
            icon: Icons.access_time,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRecentTaskList() {
    final tasks = _controller.recentTasks;

    if (tasks.isEmpty) {
      return [
        const AppEmptyState(
          icon: Icons.task_alt,
          title: 'Belum ada task',
          subtitle: 'Tambahkan task pertama Anda di tab Task',
        ),
      ];
    }

    return tasks
        .map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskCard(
              task: task,
              onTap: () => Navigator.of(context)
                  .pushNamed(AppRoutes.taskDetail, arguments: task)
                  .then((result) async {
                    await _loadData();
                    if (result is String && mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(result)));
                    }
                  }),
            ),
          ),
        )
        .toList();
  }
}
