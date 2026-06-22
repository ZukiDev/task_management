enum TaskStatus {
  pending,
  done;

  String get apiValue => switch (this) {
    TaskStatus.pending => 'pending',
    TaskStatus.done => 'done',
  };

  String get label => switch (this) {
    TaskStatus.pending => 'Pending',
    TaskStatus.done => 'Done',
  };

  static TaskStatus fromApiValue(String? value) {
    switch (value) {
      case 'done':
        return TaskStatus.done;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }
}
