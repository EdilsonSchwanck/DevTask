import '../../core/utils/clock.dart';
import '../entities/task.dart';
import '../entities/task_category.dart';
import '../entities/task_statistics.dart';

class GetTaskStatistics {
  const GetTaskStatistics(this._clock);

  final Clock _clock;

  TaskStatistics call(List<Task> tasks) {
    final now = _clock.now();
    final byCategory = <TaskCategory, int>{};
    var completed = 0, overdue = 0, favorites = 0;

    for (final task in tasks) {
      byCategory.update(task.category, (n) => n + 1, ifAbsent: () => 1);
      if (task.isCompleted) completed++;
      if (task.isOverdueAt(now)) overdue++;
      if (task.isFavorite) favorites++;
    }

    return TaskStatistics(
      total: tasks.length,
      completed: completed,
      pending: tasks.length - completed,
      overdue: overdue,
      favorites: favorites,
      byCategory: Map.unmodifiable(byCategory),
    );
  }
}
