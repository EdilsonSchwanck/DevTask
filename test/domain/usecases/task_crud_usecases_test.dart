import 'package:devtask/core/errors/exceptions.dart';
import 'package:devtask/domain/entities/task.dart';
import 'package:devtask/domain/entities/task_category.dart';
import 'package:devtask/domain/entities/task_draft.dart';
import 'package:devtask/domain/entities/task_priority.dart';
import 'package:devtask/domain/usecases/create_task.dart';
import 'package:devtask/domain/usecases/delete_task.dart';
import 'package:devtask/domain/usecases/get_tasks.dart';
import 'package:devtask/domain/usecases/task_validator.dart';
import 'package:devtask/domain/usecases/toggle_favorite.dart';
import 'package:devtask/domain/usecases/toggle_task_completion.dart';
import 'package:devtask/domain/usecases/update_task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/fixtures.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockTaskRepository repository;

  setUpAll(registerFallbacks);

  setUp(() {
    repository = MockTaskRepository();
    // Por padrão o repositório devolve o que recebe.
    when(() => repository.create(any())).thenAnswer(
      (i) async => (i.positionalArguments.first as Task).copyWith(id: 42),
    );
    when(
      () => repository.update(any()),
    ).thenAnswer((i) async => i.positionalArguments.first as Task);
  });

  group('CreateTask', () {
    late CreateTask createTask;

    setUp(() => createTask = CreateTask(repository, kClock));

    test('cria uma tarefa com sucesso', () async {
      final created = await createTask(
        TaskDraft(
          title: 'Plan release',
          description: 'Checklist',
          category: TaskCategory.work,
          priority: TaskPriority.high,
          dueDate: kNow,
        ),
      );

      expect(created.id, 42);
      expect(created.title, 'Plan release');
      expect(created.createdAt, kNow);
      expect(created.isCompleted, isFalse);
      final saved =
          verify(() => repository.create(captureAny())).captured.single as Task;
      expect(saved.id, isNull);
      expect(saved.priority, TaskPriority.high);
    });

    test('remove espaços do título e da descrição', () async {
      final created = await createTask(
        const TaskDraft(title: '  Read book  ', description: '  ch. 3 '),
      );
      expect(created.title, 'Read book');
      expect(created.description, 'ch. 3');
    });

    test('impede uma tarefa sem título', () {
      expect(
        () => createTask(const TaskDraft(title: '')),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(() => repository.create(any()));
    });

    test('impede um título só com espaços', () {
      expect(
        () => createTask(const TaskDraft(title: '   ')),
        throwsA(isA<ValidationException>()),
      );
    });

    test('impede um título longo demais', () {
      final title = 'x' * (TaskValidator.maxTitleLength + 1);
      expect(
        () => createTask(TaskDraft(title: title)),
        throwsA(isA<ValidationException>()),
      );
    });

    test('impede uma descrição longa demais', () {
      final description = 'x' * (TaskValidator.maxDescriptionLength + 1);
      expect(
        () => createTask(TaskDraft(title: 'ok', description: description)),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('UpdateTask', () {
    late UpdateTask updateTask;

    setUp(() => updateTask = UpdateTask(repository));

    test('atualiza uma tarefa existente', () async {
      final task = taskFixture(id: 3).copyWith(title: ' Renamed ');
      final updated = await updateTask(task);

      expect(updated.title, 'Renamed');
      verify(
        () => repository.update(task.copyWith(title: 'Renamed')),
      ).called(1);
    });

    test('impede título vazio', () {
      expect(
        () => updateTask(taskFixture().copyWith(title: '')),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(() => repository.update(any()));
    });

    test('impede atualizar uma tarefa que nunca foi salva', () {
      expect(
        () => updateTask(taskFixture(id: null)),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('DeleteTask', () {
    test('exclui uma tarefa pelo id', () async {
      when(() => repository.delete(5)).thenAnswer((_) async {});
      await DeleteTask(repository)(5);
      verify(() => repository.delete(5)).called(1);
    });

    test('repassa o TaskNotFoundException', () {
      when(
        () => repository.delete(9),
      ).thenThrow(const TaskNotFoundException(9));
      expect(
        () => DeleteTask(repository)(9),
        throwsA(isA<TaskNotFoundException>()),
      );
    });
  });

  test('GetTasks devolve o que vem do repositório', () async {
    final tasks = sampleTasks();
    when(() => repository.getAll()).thenAnswer((_) async => tasks);
    expect(await GetTasks(repository)(), tasks);
  });

  group('ToggleTaskCompletion', () {
    late ToggleTaskCompletion toggle;

    setUp(() => toggle = ToggleTaskCompletion(UpdateTask(repository), kClock));

    test('conclui uma tarefa aberta e preenche completedAt', () async {
      final result = await toggle(taskFixture());
      expect(result.isCompleted, isTrue);
      expect(result.completedAt, kNow);
    });

    test('reabre uma tarefa concluída e limpa completedAt', () async {
      final result = await toggle(
        taskFixture(isCompleted: true, completedAt: kNow),
      );
      expect(result.isCompleted, isFalse);
      expect(result.completedAt, isNull);
    });
  });

  test('ToggleFavorite marca e desmarca a favorita', () async {
    final toggle = ToggleFavorite(UpdateTask(repository));
    expect((await toggle(taskFixture())).isFavorite, isTrue);
    expect((await toggle(taskFixture(isFavorite: true))).isFavorite, isFalse);
  });
}
