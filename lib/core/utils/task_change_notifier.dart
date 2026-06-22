import 'package:flutter/foundation.dart';

class TaskChangeNotifier {
  TaskChangeNotifier._internal();
  static final TaskChangeNotifier _instance = TaskChangeNotifier._internal();
  factory TaskChangeNotifier() => _instance;

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notify() {
    for (final listener in List<VoidCallback>.of(_listeners)) {
      listener();
    }
  }
}
