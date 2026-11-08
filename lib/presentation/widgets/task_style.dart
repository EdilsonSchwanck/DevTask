import 'package:flutter/material.dart';

import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_priority.dart';

extension TaskCategoryStyle on TaskCategory {
  IconData get icon => switch (this) {
    TaskCategory.work => Icons.work_outline_rounded,
    TaskCategory.study => Icons.school_outlined,
    TaskCategory.personal => Icons.person_outline_rounded,
    TaskCategory.health => Icons.favorite_outline_rounded,
    TaskCategory.other => Icons.label_outline_rounded,
  };

  Color get color => switch (this) {
    TaskCategory.work => const Color(0xFF3D5AFE),
    TaskCategory.study => const Color(0xFF8E24AA),
    TaskCategory.personal => const Color(0xFF00897B),
    TaskCategory.health => const Color(0xFFE53935),
    TaskCategory.other => const Color(0xFF757575),
  };
}

extension TaskPriorityStyle on TaskPriority {
  Color color(ColorScheme scheme) => switch (this) {
    TaskPriority.low => const Color(0xFF26A69A),
    TaskPriority.medium => const Color(0xFFFB8C00),
    TaskPriority.high => const Color(0xFFE53935),
  };

  IconData get icon => switch (this) {
    TaskPriority.low => Icons.keyboard_double_arrow_down_rounded,
    TaskPriority.medium => Icons.drag_handle_rounded,
    TaskPriority.high => Icons.keyboard_double_arrow_up_rounded,
  };
}
