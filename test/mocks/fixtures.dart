import 'package:devtask/core/utils/clock.dart';
import 'package:devtask/domain/entities/task.dart';
import 'package:devtask/domain/entities/task_category.dart';
import 'package:devtask/domain/entities/task_priority.dart';

final DateTime kNow = DateTime(2026, 11, 7, 10);
final Clock kClock = FixedClock(kNow);

Task taskFixture({
  int? id = 1,
  String title = 'Write unit tests',
  String description = '',
  TaskCategory category = TaskCategory.work,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
  bool isCompleted = false,
  bool isFavorite = false,
  DateTime? createdAt,
  DateTime? completedAt,
}) {
  return Task(
    id: id,
    title: title,
    description: description,
    category: category,
    priority: priority,
    dueDate: dueDate,
    isCompleted: isCompleted,
    isFavorite: isFavorite,
    createdAt: createdAt ?? kNow.subtract(const Duration(days: 3)),
    completedAt: completedAt,
  );
}

List<Task> sampleTasks() => [
  taskFixture(
    id: 1,
    title: 'Prepare sprint review',
    priority: TaskPriority.high,
    dueDate: kNow.add(const Duration(days: 1)),
  ),
  taskFixture(
    id: 2,
    title: 'Study Clean Architecture',
    category: TaskCategory.study,
    dueDate: kNow.subtract(const Duration(days: 2)),
  ),
  taskFixture(
    id: 3,
    title: 'Buy groceries',
    category: TaskCategory.personal,
    priority: TaskPriority.low,
    isFavorite: true,
  ),
  taskFixture(
    id: 4,
    title: 'Fix login bug',
    priority: TaskPriority.high,
    isCompleted: true,
    completedAt: kNow.subtract(const Duration(hours: 5)),

    dueDate: kNow.subtract(const Duration(days: 5)),
  ),
  taskFixture(
    id: 5,
    title: 'Morning run',
    category: TaskCategory.health,
    isCompleted: true,
    completedAt: kNow.subtract(const Duration(days: 1)),
  ),
];
