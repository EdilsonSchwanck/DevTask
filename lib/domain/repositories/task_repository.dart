import '../entities/task.dart';

abstract interface class TaskRepository {
  Future<List<Task>> getAll();

  Future<Task> getById(int id);

  Future<Task> create(Task task);

  Future<Task> update(Task task);

  Future<void> delete(int id);
}
