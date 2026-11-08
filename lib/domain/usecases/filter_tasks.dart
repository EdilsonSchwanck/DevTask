import '../../core/utils/clock.dart';
import '../entities/task.dart';
import '../entities/task_filter.dart';

class FilterTasks {
  const FilterTasks(this._clock);

  final Clock _clock;

  List<Task> call(
    List<Task> tasks, {
    TaskFilter filter = TaskFilter.all,
    String query = '',
  }) {
    final now = _clock.now();
    final normalizedQuery = query.trim().toLowerCase();

    final result = tasks.where((task) {
      final matchesFilter = switch (filter) {
        TaskFilter.all => true,
        TaskFilter.pending => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
        TaskFilter.overdue => task.isOverdueAt(now),
        TaskFilter.favorites => task.isFavorite,
      };
      final matchesQuery =
          normalizedQuery.isEmpty ||
          task.title.toLowerCase().contains(normalizedQuery);
      return matchesFilter && matchesQuery;
    }).toList()..sort(_compare);

    return List.unmodifiable(result);
  }

  static int _compare(Task a, Task b) {
    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
    if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
    final byPriority = b.priority.weight.compareTo(a.priority.weight);
    if (byPriority != 0) return byPriority;
    final aDue = a.dueDate, bDue = b.dueDate;
    if (aDue != null && bDue != null) {
      final byDue = aDue.compareTo(bDue);
      if (byDue != 0) return byDue;
    } else if (aDue != null || bDue != null) {
      return aDue != null ? -1 : 1;
    }
    return b.createdAt.compareTo(a.createdAt);
  }
}
