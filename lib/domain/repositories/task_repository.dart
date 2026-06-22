import '../../data/models/task_model.dart';
import '../../data/models/task_status.dart';

/// Kontrak operasi terkait Task. Presentation layer (Controller) HANYA
/// bergantung pada interface ini, tidak pernah langsung ke
/// [TaskRepositoryImpl] atau [ApiClient].
///
/// Keuntungannya: kalau suatu saat backend diganti (misal dari
/// restful-api.dev ke backend Golang sendiri), cukup buat implementasi
/// baru dari interface ini — seluruh kode presentation tidak perlu
/// disentuh sama sekali.
abstract class TaskRepository {
  /// Mengambil semua task milik user yang sedang login.
  Future<List<TaskModel>> getTasks();

  /// Mengambil detail satu task berdasarkan id.
  Future<TaskModel> getTaskById(String id);

  /// Membuat task baru. Mengembalikan task yang sudah memiliki id dari
  /// server.
  Future<TaskModel> addTask(TaskModel task);

  /// Memperbarui seluruh field task (judul, deskripsi, tanggal, prioritas).
  Future<TaskModel> updateTask(TaskModel task);

  /// Memperbarui status saja (Done/Pending) lewat PATCH — operasi paling
  /// sering dipakai dari Task List & Task Detail.
  Future<TaskModel> updateStatus(TaskModel task, TaskStatus newStatus);

  /// Menghapus task berdasarkan id.
  Future<void> deleteTask(String id);
}
