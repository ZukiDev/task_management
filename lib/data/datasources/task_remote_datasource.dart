import '../../core/network/api_client.dart';
import '../models/task_model.dart';
import '../models/task_status.dart';

/// Datasource yang tahu detail endpoint task restful-api.dev.
///
/// Semua method butuh [collectionName] (hasil dari
/// `CollectionNameHelper.fromEmail`) dan [token] JWT user yang sedang
/// login — keduanya disuplai oleh [TaskRepositoryImpl], datasource ini
/// tidak tahu cara mendapatkannya (tidak bergantung ke SessionStorage).
class TaskRemoteDatasource {
  final ApiClient _apiClient;

  TaskRemoteDatasource(this._apiClient);

  Future<List<TaskModel>> getTasks({
    required String collectionName,
    required String token,
  }) async {
    final json = await _apiClient.get(
      '/collections/$collectionName/objects',
      token: token,
      queryParams: {'auth-type': 'jwt'},
    );
    final list = (json as List).cast<Map<String, dynamic>>();
    return list.map(TaskModel.fromApiJson).toList();
  }

  Future<TaskModel> getTaskById({
    required String collectionName,
    required String token,
    required String id,
  }) async {
    final json = await _apiClient.get(
      '/collections/$collectionName/objects/$id',
      token: token,
      queryParams: {'auth-type': 'jwt'},
    );
    return TaskModel.fromApiJson(json as Map<String, dynamic>);
  }

  Future<TaskModel> addTask({
    required String collectionName,
    required String token,
    required TaskModel task,
  }) async {
    final json = await _apiClient.post(
      '/collections/$collectionName/objects',
      token: token,
      queryParams: {'auth-type': 'jwt'},
      body: task.toApiJson(),
    );
    return TaskModel.fromApiJson(json as Map<String, dynamic>);
  }

  Future<TaskModel> updateTask({
    required String collectionName,
    required String token,
    required TaskModel task,
  }) async {
    final json = await _apiClient.put(
      '/collections/$collectionName/objects/${task.id}',
      token: token,
      queryParams: {'auth-type': 'jwt'},
      body: task.toApiJson(),
    );
    return TaskModel.fromApiJson(json as Map<String, dynamic>);
  }

  Future<TaskModel> updateStatus({
    required String collectionName,
    required String token,
    required TaskModel task,
    required TaskStatus newStatus,
  }) async {
    final json = await _apiClient.patch(
      '/collections/$collectionName/objects/${task.id}',
      token: token,
      queryParams: {'auth-type': 'jwt'},
      body: task.toStatusPatchJson(newStatus),
    );
    return TaskModel.fromApiJson(json as Map<String, dynamic>);
  }

  Future<void> deleteTask({
    required String collectionName,
    required String token,
    required String id,
  }) async {
    await _apiClient.delete(
      '/collections/$collectionName/objects/$id',
      token: token,
      queryParams: {'auth-type': 'jwt'},
    );
  }
}
