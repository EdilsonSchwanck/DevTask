import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase({required DatabaseFactory factory, required String path})
    : _factory = factory,
      _path = path;

  static const int version = 1;
  static const String tasksTable = 'tasks';

  final DatabaseFactory _factory;
  final String _path;
  Future<Database>? _database;

  Future<Database> get database => _database ??= _open();

  Future<Database> _open() => _factory.openDatabase(
    _path,
    options: OpenDatabaseOptions(version: version, onCreate: _onCreate),
  );

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tasksTable (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        title         TEXT    NOT NULL,
        description   TEXT    NOT NULL DEFAULT '',
        category      TEXT    NOT NULL,
        priority      TEXT    NOT NULL,
        due_date      INTEGER,
        is_completed  INTEGER NOT NULL DEFAULT 0,
        is_favorite   INTEGER NOT NULL DEFAULT 0,
        created_at    INTEGER NOT NULL,
        completed_at  INTEGER
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_tasks_completed ON $tasksTable (is_completed)',
    );
  }

  Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null) await (await db).close();
  }
}
