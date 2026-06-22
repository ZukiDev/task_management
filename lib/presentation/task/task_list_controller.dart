import '../../core/network/api_exception.dart';
import '../../core/utils/task_change_notifier.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_status.dart';
import '../../domain/repositories/task_repository.dart';

enum TaskStatusFilter { all, pending, done }

class TaskListController {
  final TaskRepository _taskRepository;

  TaskListController(this._taskRepository);

  bool isLoading = false;
  String? errorMessage;
  List<TaskModel> _allTasks = [];
  String searchQuery = '';
  TaskStatusFilter statusFilter = TaskStatusFilter.all;

  List<TaskModel> get tasks {
    var result = _allTasks;

    if (statusFilter == TaskStatusFilter.pending) {
      result = result.where((t) => t.status == TaskStatus.pending).toList();
    } else if (statusFilter == TaskStatusFilter.done) {
      result = result.where((t) => t.status == TaskStatus.done).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      result = result
          .where((t) => t.title.toLowerCase().contains(query))
          .toList();
    }

    final sorted = [...result]
      ..sort((a, b) {
        if (a.status != b.status) {
          return a.status == TaskStatus.pending ? -1 : 1;
        }
        return a.dueDate.compareTo(b.dueDate);
      });
    return sorted;
  }

  bool get hasAnyTaskBeforeFilter => _allTasks.isNotEmpty;

  void updateSearchQuery(String query) {
    searchQuery = query;
  }

  void updateStatusFilter(TaskStatusFilter filter) {
    statusFilter = filter;
  }

  Future<void> loadTasks() async {
    isLoading = true;
    errorMessage = null;

    try {
      _allTasks = await _taskRepository.getTasks();
      isLoading = false;
    } on ApiException catch (e) {
      isLoading = false;
      errorMessage = e.message;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Gagal memuat task. Coba lagi.';
    }
  }

  Future<bool> toggleStatus(TaskModel task) async {
    final newStatus = task.status == TaskStatus.done
        ? TaskStatus.pending
        : TaskStatus.done;

    try {
      final updated = await _taskRepository.updateStatus(task, newStatus);
      final index = _allTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) _allTasks[index] = updated;
      TaskChangeNotifier().notify();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'Gagal mengubah status task.';
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await _taskRepository.deleteTask(id);
      _allTasks.removeWhere((t) => t.id == id);
      TaskChangeNotifier().notify();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'Gagal menghapus task.';
      return false;
    }
  }
}
