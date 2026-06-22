import '../../core/network/api_exception.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';

class DateController {
  final TaskRepository _taskRepository;

  DateController(this._taskRepository);

  bool isLoading = false;
  String? errorMessage;

  Map<String, List<TaskModel>> _tasksByDate = {};
  DateTime selectedDate = DateTime.now();

  Future<void> loadTasks() async {
    isLoading = true;
    errorMessage = null;

    try {
      final tasks = await _taskRepository.getTasks();
      _tasksByDate = _groupByDate(tasks);
      isLoading = false;
    } on ApiException catch (e) {
      isLoading = false;
      errorMessage = e.message;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Gagal memuat task. Coba lagi.';
    }
  }

  Map<String, List<TaskModel>> _groupByDate(List<TaskModel> tasks) {
    final map = <String, List<TaskModel>>{};
    for (final task in tasks) {
      final key = DateFormatter.toDateKey(task.dueDate);
      map.putIfAbsent(key, () => []).add(task);
    }
    return map;
  }

  List<TaskModel> tasksOn(DateTime date) {
    return _tasksByDate[DateFormatter.toDateKey(date)] ?? [];
  }

  List<TaskModel> get tasksOnSelectedDate {
    final tasks = tasksOn(selectedDate);
    final sorted = [...tasks]
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return sorted;
  }

  void selectDate(DateTime date) {
    selectedDate = date;
  }
}
