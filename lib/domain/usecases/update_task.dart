import '../../core/errors/exceptions.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';
import 'task_validator.dart';

class UpdateTask {
  const UpdateTask(this._repository);

  final TaskRepository _repository;

  Future<Task> call(Task task) {
    if (task.id == null) {
      throw const ValidationException(ValidationError.taskNotSaved);
    }
    return _repository.update(
      task.copyWith(
        title: TaskValidator.validateTitle(task.title),
        description: TaskValidator.validateDescription(task.description),
      ),
    );
  }
}
