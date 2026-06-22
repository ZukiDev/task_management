import '../../data/models/task_model.dart';
import '../../data/models/task_status.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasks();

  Future<TaskModel> getTaskById(String id);

  Future<TaskModel> addTask(TaskModel task);

  Future<TaskModel> updateTask(TaskModel task);

  Future<TaskModel> updateStatus(TaskModel task, TaskStatus newStatus);

  Future<void> deleteTask(String id);
}
