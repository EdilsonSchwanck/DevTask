import 'package:devtask/core/errors/exceptions.dart';
import 'package:devtask/domain/entities/task.dart';
import 'package:devtask/domain/repositories/task_repository.dart';

class InMemoryTaskRepository implements TaskRepository {
  final Map<int, Task> _tasks = {};
  int _nextId = 1;

  @override
  Future<List<Task>> getAll() async => _tasks.values.toList().reversed.toList();

  @override
  Future<Task> getById(int id) async =>
      _tasks[id] ?? (throw TaskNotFoundException(id));

  @override
  Future<Task> create(Task task) async {
    final created = task.copyWith(id: _nextId++);
    _tasks[created.id!] = created;
    return created;
  }

  @override
  Future<Task> update(Task task) async {
    if (!_tasks.containsKey(task.id)) {
      throw TaskNotFoundException(task.id ?? -1);
    }
    return _tasks[task.id!] = task;
  }

  @override
  Future<void> delete(int id) async {
    if (_tasks.remove(id) == null) throw TaskNotFoundException(id);
  }
}
