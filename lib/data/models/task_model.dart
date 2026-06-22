import 'task_priority.dart';
import 'task_status.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime dueDate;
  final TaskPriority priority;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.priority,
  });

  factory TaskModel.draft({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    TaskStatus status = TaskStatus.pending,
  }) {
    return TaskModel(
      id: '',
      title: title,
      description: description,
      status: status,
      dueDate: dueDate,
      priority: priority,
    );
  }

  factory TaskModel.fromApiJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    return TaskModel(
      id: json['id']?.toString() ?? '',
      title: json['name']?.toString() ?? '(Tanpa judul)',
      description: data['description']?.toString() ?? '',
      status: TaskStatus.fromApiValue(data['status']?.toString()),
      dueDate:
          DateTime.tryParse(data['dueDate']?.toString() ?? '') ??
          DateTime.now(),
      priority: TaskPriority.fromApiValue(data['priority']?.toString()),
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      'name': title,
      'data': {
        'description': description,
        'status': status.apiValue,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.apiValue,
      },
    };
  }

  Map<String, dynamic> toStatusPatchJson(TaskStatus newStatus) {
    return {
      'data': {
        'description': description,
        'status': newStatus.apiValue,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.apiValue,
      },
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? dueDate,
    TaskPriority? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
    );
  }
}
