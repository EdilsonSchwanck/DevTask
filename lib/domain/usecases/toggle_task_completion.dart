import '../../core/utils/clock.dart';
import '../entities/task.dart';
import 'update_task.dart';

class ToggleTaskCompletion {
  const ToggleTaskCompletion(this._updateTask, this._clock);

  final UpdateTask _updateTask;
  final Clock _clock;

  Future<Task> call(Task task) {
    final completed = !task.isCompleted;
    return _updateTask(
      task.copyWith(
        isCompleted: completed,
        completedAt: () => completed ? _clock.now() : null,
      ),
    );
  }
}
