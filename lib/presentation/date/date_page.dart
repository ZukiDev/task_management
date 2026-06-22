import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/network/api_client.dart';
import '../../core/routing/app_routes.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/local/session_storage.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_loading.dart';
import '../widgets/task_card.dart';
import 'date_controller.dart';

class DatePage extends StatefulWidget {
  const DatePage({super.key});

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  late final DateController _controller;
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final sessionStorage = SessionStorage();
    final taskRepository = TaskRepositoryImpl(
      TaskRemoteDatasource(apiClient),
      sessionStorage,
    );
    _controller = DateController(taskRepository);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {});
    await _controller.loadTasks();
    if (mounted) setState(() {});
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    _controller.selectDate(selected);
    setState(() => _focusedMonth = focused);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Kalender Task', style: AppTextStyles.heading2),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const AppLoading(message: 'Memuat kalender...');
    }

    if (_controller.errorMessage != null) {
      return AppErrorView(
        message: _controller.errorMessage!,
        onRetry: _loadTasks,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildCalendar(),
          const SizedBox(height: 20),
          Text(
            DateFormatter.toDisplayWithDay(_controller.selectedDate),
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 12),
          ..._buildSelectedDateTaskList(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2100, 12, 31),
        focusedDay: _focusedMonth,
        selectedDayPredicate: (day) =>
            DateFormatter.isSameDay(day, _controller.selectedDate),
        onDaySelected: _onDaySelected,
        eventLoader: (day) => _controller.tasksOn(day),
        calendarFormat: CalendarFormat.month,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.heading2,
        ),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.primaryDark,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppColors.danger,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          markerSize: 6,
          markerMargin: EdgeInsets.only(top: 4),
        ),
      ),
    );
  }

  List<Widget> _buildSelectedDateTaskList() {
    final tasks = _controller.tasksOnSelectedDate;

    if (tasks.isEmpty) {
      return [
        const AppEmptyState(
          icon: Icons.event_available_outlined,
          title: 'Tidak ada task',
          subtitle: 'Tidak ada task pada tanggal ini',
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
                    await _loadTasks();
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
