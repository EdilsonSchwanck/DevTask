import 'package:devtask/core/database/app_database.dart';
import 'package:devtask/core/errors/exceptions.dart';
import 'package:devtask/data/datasources/task_local_datasource.dart';
import 'package:devtask/data/repositories/task_repository_impl.dart';
import 'package:devtask/domain/entities/task_category.dart';
import 'package:devtask/domain/entities/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../mocks/fixtures.dart';

void main() {
  late AppDatabase database;
  late TaskRepositoryImpl repository;

  setUpAll(sqfliteFfiInit);

  setUp(() {
    database = AppDatabase(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
    repository = TaskRepositoryImpl(SqfliteTaskLocalDataSource(database));
  });

  tearDown(() => database.close());

  test('começa vazio', () async {
    expect(await repository.getAll(), isEmpty);
  });

  test('cria uma tarefa e gera um id', () async {
    final created = await repository.create(taskFixture(id: null));

    expect(created.id, isNotNull);
    expect(await repository.getById(created.id!), created);
  });

  test(
    'busca todas as tarefas do SQLite, das mais novas para as mais antigas',
    () async {
      final older = await repository.create(
        taskFixture(
          id: null,
          title: 'Older',
          createdAt: kNow.subtract(const Duration(days: 2)),
        ),
      );
      final newer = await repository.create(
        taskFixture(id: null, title: 'Newer', createdAt: kNow),
      );

      expect(await repository.getAll(), [newer, older]);
    },
  );

  test('salva todos os campos', () async {
    final created = await repository.create(
      taskFixture(
        id: null,
        description: 'Long description',
        category: TaskCategory.health,
        priority: TaskPriority.high,
        dueDate: kNow,
        isFavorite: true,
        isCompleted: true,
        completedAt: kNow,
      ),
    );

    expect((await repository.getAll()).single, created);
  });

  test('atualiza uma tarefa existente', () async {
    final created = await repository.create(taskFixture(id: null));
    final changed = created.copyWith(title: 'Updated', isFavorite: true);

    await repository.update(changed);

    expect(await repository.getById(created.id!), changed);
  });

  test('exclui uma tarefa', () async {
    final created = await repository.create(taskFixture(id: null));

    await repository.delete(created.id!);

    expect(await repository.getAll(), isEmpty);
  });

  test('lança TaskNotFoundException para ids que não existem', () async {
    await expectLater(
      repository.getById(999),
      throwsA(isA<TaskNotFoundException>()),
    );
    await expectLater(
      repository.update(taskFixture(id: 999)),
      throwsA(isA<TaskNotFoundException>()),
    );
    await expectLater(
      repository.delete(999),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('não deixa atualizar uma tarefa sem id', () async {
    await expectLater(
      repository.update(taskFixture(id: null)),
      throwsA(isA<ValidationException>()),
    );
  });
}
