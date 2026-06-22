enum TaskPriority {
  low,
  medium,
  high;

  String get apiValue => switch (this) {
    TaskPriority.low => 'low',
    TaskPriority.medium => 'medium',
    TaskPriority.high => 'high',
  };

  String get label => switch (this) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
  };

  static TaskPriority fromApiValue(String? value) {
    switch (value) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}
