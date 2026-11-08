import '../../core/database/app_database.dart';
import '../models/task_model.dart';

abstract interface class TaskLocalDataSource {
  Future<List<TaskModel>> getAll();

  Future<TaskModel?> getById(int id);

  Future<int> insert(TaskModel task);

  Future<int> update(TaskModel task);

  Future<int> delete(int id);
}

class SqfliteTaskLocalDataSource implements TaskLocalDataSource {
  const SqfliteTaskLocalDataSource(this._appDatabase);

  final AppDatabase _appDatabase;

  static const _table = AppDatabase.tasksTable;

  @override
  Future<List<TaskModel>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map(TaskModel.fromMap).toList();
  }

  @override
  Future<TaskModel?> getById(int id) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : TaskModel.fromMap(rows.first);
  }

  @override
  Future<int> insert(TaskModel task) async {
    final db = await _appDatabase.database;
    return db.insert(_table, task.toMap()..remove('id'));
  }

  @override
  Future<int> update(TaskModel task) async {
    final db = await _appDatabase.database;
    return db.update(
      _table,
      task.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<int> delete(int id) async {
    final db = await _appDatabase.database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
