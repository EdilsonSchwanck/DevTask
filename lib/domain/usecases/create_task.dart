import '../../core/utils/clock.dart';
import '../entities/task.dart';
import '../entities/task_draft.dart';
import '../repositories/task_repository.dart';
import 'task_validator.dart';

class CreateTask {
  const CreateTask(this._repository, this._clock);

  final TaskRepository _repository;
  final Clock _clock;

  Future<Task> call(TaskDraft draft) {
    final task = Task(
      title: TaskValidator.validateTitle(draft.title),
      description: TaskValidator.validateDescription(draft.description),
      category: draft.category,
      priority: draft.priority,
      dueDate: draft.dueDate,
      createdAt: _clock.now(),
    );
    return _repository.create(task);
  }
}
