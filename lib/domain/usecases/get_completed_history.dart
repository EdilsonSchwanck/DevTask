import '../entities/task.dart';

class GetCompletedHistory {
  const GetCompletedHistory();

  List<Task> call(List<Task> tasks) {
    final done = tasks.where((t) => t.isCompleted).toList()
      ..sort((a, b) {
        final aAt = a.completedAt ?? a.createdAt;
        final bAt = b.completedAt ?? b.createdAt;
        return bAt.compareTo(aAt);
      });
    return List.unmodifiable(done);
  }
}
