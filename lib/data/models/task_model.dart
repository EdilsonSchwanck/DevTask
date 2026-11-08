import '../../domain/entities/task.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_priority.dart';

class TaskModel extends Task {
  const TaskModel({
    super.id,
    required super.title,
    super.description,
    super.category,
    super.priority,
    super.dueDate,
    super.isCompleted,
    super.isFavorite,
    required super.createdAt,
    super.completedAt,
  });

  factory TaskModel.fromEntity(Task task) => TaskModel(
    id: task.id,
    title: task.title,
    description: task.description,
    category: task.category,
    priority: task.priority,
    dueDate: task.dueDate,
    isCompleted: task.isCompleted,
    isFavorite: task.isFavorite,
    createdAt: task.createdAt,
    completedAt: task.completedAt,
  );

  factory TaskModel.fromMap(Map<String, Object?> map) => TaskModel(
    id: map['id'] as int?,
    title: map['title']! as String,
    description: (map['description'] as String?) ?? '',
    category: TaskCategory.fromName(map['category'] as String?),
    priority: TaskPriority.fromName(map['priority'] as String?),
    dueDate: _dateFrom(map['due_date']),
    isCompleted: map['is_completed'] == 1,
    isFavorite: map['is_favorite'] == 1,
    createdAt: _dateFrom(map['created_at'])!,
    completedAt: _dateFrom(map['completed_at']),
  );

  Task toEntity() => Task(
    id: id,
    title: title,
    description: description,
    category: category,
    priority: priority,
    dueDate: dueDate,
    isCompleted: isCompleted,
    isFavorite: isFavorite,
    createdAt: createdAt,
    completedAt: completedAt,
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'category': category.name,
    'priority': priority.name,
    'due_date': dueDate?.millisecondsSinceEpoch,
    'is_completed': isCompleted ? 1 : 0,
    'is_favorite': isFavorite ? 1 : 0,
    'created_at': createdAt.millisecondsSinceEpoch,
    'completed_at': completedAt?.millisecondsSinceEpoch,
  };

  static DateTime? _dateFrom(Object? value) =>
      value is int ? DateTime.fromMillisecondsSinceEpoch(value) : null;
}
