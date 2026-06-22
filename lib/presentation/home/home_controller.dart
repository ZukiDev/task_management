import '../../core/network/api_exception.dart';
import '../../data/local/session_storage.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_status.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/task_repository.dart';

/// Controller untuk Home Page (dashboard).
///
/// Bertugas: ambil semua task (lewat [TaskRepository]) lalu hitung
/// ringkasan (total/done/pending), ambil user yang sedang login (untuk
/// profile bar), dan menyediakan fungsi search sederhana di sisi klien
/// (filter dari list yang sudah di-fetch — tidak perlu endpoint search
/// terpisah karena restful-api.dev tidak menyediakannya).
class HomeController {
  final TaskRepository _taskRepository;
  final SessionStorage _sessionStorage;

  HomeController(this._taskRepository, this._sessionStorage);

  bool isLoading = false;
  String? errorMessage;
  UserModel? currentUser;
  List<TaskModel> _allTasks = [];
  String searchQuery = '';

  int get totalCount => _allTasks.length;
  int get doneCount =>
      _allTasks.where((t) => t.status == TaskStatus.done).length;
  int get pendingCount =>
      _allTasks.where((t) => t.status == TaskStatus.pending).length;

  /// Task terbaru (maksimal 5) yang ditampilkan di Home, sudah
  /// terfilter oleh [searchQuery] jika ada.
  List<TaskModel> get recentTasks {
    final filtered = _filterBySearch(_allTasks);
    final sorted = [...filtered]
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return sorted.take(5).toList();
  }

  List<TaskModel> _filterBySearch(List<TaskModel> tasks) {
    if (searchQuery.trim().isEmpty) return tasks;
    final query = searchQuery.trim().toLowerCase();
    return tasks.where((t) => t.title.toLowerCase().contains(query)).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
  }

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;

    try {
      currentUser = await _sessionStorage.getUser();
      _allTasks = await _taskRepository.getTasks();
      isLoading = false;
    } on ApiException catch (e) {
      isLoading = false;
      errorMessage = e.message;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Gagal memuat data. Coba lagi.';
    }
  }
}
