import 'package:equatable/equatable.dart';

import 'task.dart';
import 'task_category.dart';
import 'task_priority.dart';

class TaskDraft extends Equatable {
  const TaskDraft({
    required this.title,
    this.description = '',
    this.category = TaskCategory.personal,
    this.priority = TaskPriority.medium,
    this.dueDate,
  });

  factory TaskDraft.fromTask(Task task) => TaskDraft(
    title: task.title,
    description: task.description,
    category: task.category,
    priority: task.priority,
    dueDate: task.dueDate,
  );

  final String title;
  final String description;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime? dueDate;

  Task applyTo(Task task) => task.copyWith(
    title: title,
    description: description,
    category: category,
    priority: priority,
    dueDate: () => dueDate,
  );

  @override
  List<Object?> get props => [title, description, category, priority, dueDate];
}
