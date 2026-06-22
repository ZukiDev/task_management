import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/task_priority.dart';

/// Badge kecil menampilkan prioritas task dengan dot warna + label.
class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  Color get _color => switch (priority) {
    TaskPriority.low => AppColors.priorityLow,
    TaskPriority.medium => AppColors.priorityMedium,
    TaskPriority.high => AppColors.priorityHigh,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          priority.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _color,
          ),
        ),
      ],
    );
  }
}
