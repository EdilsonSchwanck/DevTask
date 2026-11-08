import '../../core/errors/exceptions.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._local);

  final TaskLocalDataSource _local;

  @override
  Future<List<Task>> getAll() => _guard(() async {
    final models = await _local.getAll();
    return [for (final model in models) model.toEntity()];
  });

  @override
  Future<Task> getById(int id) => _guard(() async {
    final model = await _local.getById(id);
    if (model == null) throw TaskNotFoundException(id);
    return model.toEntity();
  });

  @override
  Future<Task> create(Task task) => _guard(() async {
    final id = await _local.insert(TaskModel.fromEntity(task));
    return task.copyWith(id: id);
  });

  @override
  Future<Task> update(Task task) => _guard(() async {
    final id = task.id;
    if (id == null) {
      throw const ValidationException(ValidationError.taskNotSaved);
    }
    final affected = await _local.update(TaskModel.fromEntity(task));
    if (affected == 0) throw TaskNotFoundException(id);
    return task;
  });

  @override
  Future<void> delete(int id) => _guard(() async {
    final affected = await _local.delete(id);
    if (affected == 0) throw TaskNotFoundException(id);
  });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (error) {
      throw StorageException(error);
    }
  }
}
