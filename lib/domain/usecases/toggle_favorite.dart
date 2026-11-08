import '../entities/task.dart';
import 'update_task.dart';

class ToggleFavorite {
  const ToggleFavorite(this._updateTask);

  final UpdateTask _updateTask;

  Future<Task> call(Task task) =>
      _updateTask(task.copyWith(isFavorite: !task.isFavorite));
}
