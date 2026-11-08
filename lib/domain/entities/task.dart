import 'package:equatable/equatable.dart';

import '../../core/utils/clock.dart';
import 'task_category.dart';
import 'task_priority.dart';

class Task extends Equatable {
  const Task({
    this.id,
    required this.title,
    this.description = '',
    this.category = TaskCategory.personal,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.isCompleted = false,
    this.isFavorite = false,
    required this.createdAt,
    this.completedAt,
  });

  final int? id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool isCompleted;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool isOverdueAt(DateTime now) {
    final due = dueDate;
    if (isCompleted || due == null) return false;
    return due.dateOnly.isBefore(now.dateOnly);
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? Function()? dueDate,
    bool? isCompleted,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? Function()? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate != null ? dueDate() : this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt != null ? completedAt() : this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    priority,
    dueDate,
    isCompleted,
    isFavorite,
    createdAt,
    completedAt,
  ];
}
