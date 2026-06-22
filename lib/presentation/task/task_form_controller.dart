import '../../core/network/api_exception.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_priority.dart';
import '../../data/models/task_status.dart';
import '../../domain/repositories/task_repository.dart';

class TaskFormController {
  final TaskRepository _taskRepository;
  final TaskModel? existingTask;

  TaskFormController(this._taskRepository, {this.existingTask});

  bool get isEditMode => existingTask != null;

  bool isSubmitting = false;
  String? errorMessage;

  Future<TaskModel?> submit({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
  }) async {
    isSubmitting = true;
    errorMessage = null;

    try {
      TaskModel result;
      if (isEditMode) {
        final updatedDraft = existingTask!.copyWith(
          title: title,
          description: description,
          dueDate: dueDate,
          priority: priority,
        );
        result = await _taskRepository.updateTask(updatedDraft);
      } else {
        final draft = TaskModel.draft(
          title: title,
          description: description,
          dueDate: dueDate,
          priority: priority,
          status: TaskStatus.pending,
        );
        result = await _taskRepository.addTask(draft);
      }
      isSubmitting = false;
      return result;
    } on ApiException catch (e) {
      isSubmitting = false;
      errorMessage = e.message;
      return null;
    } catch (e) {
      isSubmitting = false;
      errorMessage = 'Gagal menyimpan task. Coba lagi.';
      return null;
    }
  }
}
