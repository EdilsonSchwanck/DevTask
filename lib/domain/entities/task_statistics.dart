import 'package:equatable/equatable.dart';

import 'task_category.dart';

class TaskStatistics extends Equatable {
  const TaskStatistics({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.favorites,
    required this.byCategory,
  });

  static const empty = TaskStatistics(
    total: 0,
    completed: 0,
    pending: 0,
    overdue: 0,
    favorites: 0,
    byCategory: {},
  );

  final int total;
  final int completed;
  final int pending;
  final int overdue;
  final int favorites;

  final Map<TaskCategory, int> byCategory;

  double get completionRate => total == 0 ? 0 : completed / total;

  @override
  List<Object?> get props => [
    total,
    completed,
    pending,
    overdue,
    favorites,
    byCategory,
  ];
}
