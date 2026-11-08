import 'package:devtask/core/errors/exceptions.dart';
import 'package:devtask/data/models/task_model.dart';
import 'package:devtask/data/repositories/task_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/fixtures.dart';
import '../mocks/mocks.dart';

/// Testes unitários: lógica do repositório isolada, com o data source mockado.
void main() {
  late MockTaskLocalDataSource dataSource;
  late TaskRepositoryImpl repository;

  setUpAll(registerFallbacks);

  setUp(() {
    dataSource = MockTaskLocalDataSource();
    repository = TaskRepositoryImpl(dataSource);
  });

  test('create devolve a tarefa com o id gerado pelo banco', () async {
    when(() => dataSource.insert(any())).thenAnswer((_) async => 77);

    final created = await repository.create(taskFixture(id: null));

    expect(created.id, 77);
  });

  test('getAll converte models em entidades', () async {
    when(
      () => dataSource.getAll(),
    ).thenAnswer((_) async => [TaskModel.fromEntity(taskFixture())]);

    expect(await repository.getAll(), [taskFixture()]);
  });

  test('erros inesperados do banco viram StorageException', () async {
    when(() => dataSource.getAll()).thenThrow(Exception('disk I/O error'));

    await expectLater(
      repository.getAll(),
      throwsA(
        isA<StorageException>().having(
          (e) => e.cause,
          'cause',
          isA<Exception>(),
        ),
      ),
    );
  });

  test(
    'update lança TaskNotFoundException quando nenhuma linha é alterada',
    () async {
      when(() => dataSource.update(any())).thenAnswer((_) async => 0);

      await expectLater(
        repository.update(taskFixture(id: 3)),
        throwsA(isA<TaskNotFoundException>()),
      );
    },
  );
}
