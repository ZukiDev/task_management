import '../../core/network/api_exception.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../local/session_storage.dart';
import '../models/task_model.dart';
import '../models/task_status.dart';

/// Implementasi [TaskRepository].
///
/// Sebelum memanggil [TaskRemoteDatasource], repository ini selalu
/// mengambil token & nama collection terbaru dari [SessionStorage] —
/// sehingga datasource sendiri tidak perlu tahu dari mana token/
/// collection itu berasal (separation of concern).
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource _remoteDatasource;
  final SessionStorage _sessionStorage;

  TaskRepositoryImpl(this._remoteDatasource, this._sessionStorage);

  Future<({String token, String collectionName})> _requireSession() async {
    final token = await _sessionStorage.getToken();
    final collectionName = await _sessionStorage.getCollectionName();
    if (token == null || token.isEmpty || collectionName == null) {
      throw const UnauthorizedException(
        'Sesi tidak ditemukan. Silakan login kembali.',
      );
    }
    return (token: token, collectionName: collectionName);
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final session = await _requireSession();
    return _remoteDatasource.getTasks(
      collectionName: session.collectionName,
      token: session.token,
    );
  }

  @override
  Future<TaskModel> getTaskById(String id) async {
    final session = await _requireSession();
    return _remoteDatasource.getTaskById(
      collectionName: session.collectionName,
      token: session.token,
      id: id,
    );
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    final session = await _requireSession();
    return _remoteDatasource.addTask(
      collectionName: session.collectionName,
      token: session.token,
      task: task,
    );
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final session = await _requireSession();
    return _remoteDatasource.updateTask(
      collectionName: session.collectionName,
      token: session.token,
      task: task,
    );
  }

  @override
  Future<TaskModel> updateStatus(TaskModel task, TaskStatus newStatus) async {
    final session = await _requireSession();
    return _remoteDatasource.updateStatus(
      collectionName: session.collectionName,
      token: session.token,
      task: task,
      newStatus: newStatus,
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    final session = await _requireSession();
    await _remoteDatasource.deleteTask(
      collectionName: session.collectionName,
      token: session.token,
      id: id,
    );
  }
}
