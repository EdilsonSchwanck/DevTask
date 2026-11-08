import 'package:bloc_test/bloc_test.dart';
import 'package:devtask/core/errors/exceptions.dart';
import 'package:devtask/domain/entities/task.dart';
import 'package:devtask/domain/entities/task_draft.dart';
import 'package:devtask/domain/entities/task_filter.dart';
import 'package:devtask/domain/usecases/create_task.dart';
import 'package:devtask/domain/usecases/delete_task.dart';
import 'package:devtask/domain/usecases/filter_tasks.dart';
import 'package:devtask/domain/usecases/get_completed_history.dart';
import 'package:devtask/domain/usecases/get_task_statistics.dart';
import 'package:devtask/domain/usecases/get_tasks.dart';
import 'package:devtask/domain/usecases/toggle_favorite.dart';
import 'package:devtask/domain/usecases/toggle_task_completion.dart';
import 'package:devtask/domain/usecases/update_task.dart';
import 'package:devtask/presentation/bloc/task/task_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/fixtures.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockTaskRepository repository;

  setUpAll(registerFallbacks);

  /// Casos de uso reais em cima de um repositório mockado: testamos o bloc
  /// sem fingir as regras de negócio.
  TaskBloc buildBloc() {
    final updateTask = UpdateTask(repository);
    return TaskBloc(
      getTasks: GetTasks(repository),
      createTask: CreateTask(repository, kClock),
      updateTask: updateTask,
      deleteTask: DeleteTask(repository),
      toggleCompletion: ToggleTaskCompletion(updateTask, kClock),
      toggleFavorite: ToggleFavorite(updateTask),
      filterTasks: FilterTasks(kClock),
      getStatistics: GetTaskStatistics(kClock),
      getHistory: const GetCompletedHistory(),
    );
  }

  /// Estado "ready" com as [tasks], calculado do mesmo jeito que o bloc faz.
  TaskState readyWith(List<Task> tasks, {TaskFilter filter = TaskFilter.all}) {
    final filterTasks = FilterTasks(kClock);
    return TaskState(
      status: TaskStatus.ready,
      tasks: tasks,
      filter: filter,
      visibleTasks: filterTasks(tasks, filter: filter),
      history: const GetCompletedHistory()(tasks),
      upNext: filterTasks(tasks, filter: TaskFilter.pending).take(5).toList(),
      statistics: GetTaskStatistics(kClock)(tasks),
    );
  }

  setUp(() {
    repository = MockTaskRepository();
    when(
      () => repository.update(any()),
    ).thenAnswer((i) async => i.positionalArguments.first as Task);
  });

  test('o estado inicial é TaskState()', () {
    expect(buildBloc().state, const TaskState());
  });

  group('TasksLoadRequested', () {
    blocTest<TaskBloc, TaskState>(
      'emite [loading, ready] com os dados calculados quando carrega',
      setUp: () => when(
        () => repository.getAll(),
      ).thenAnswer((_) async => sampleTasks()),
      build: buildBloc,
      act: (bloc) => bloc.add(const TasksLoadRequested()),
      expect: () => [
        const TaskState(status: TaskStatus.loading),
        readyWith(sampleTasks()),
      ],
      verify: (bloc) {
        expect(bloc.state.statistics.total, 5);
        expect(bloc.state.history.map((t) => t.id), [4, 5]);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emite [loading, failure] quando o repositório falha',
      setUp: () =>
          when(() => repository.getAll()).thenThrow(const StorageException()),
      build: buildBloc,
      act: (bloc) => bloc.add(const TasksLoadRequested()),
      expect: () => [
        const TaskState(status: TaskStatus.loading),
        const TaskState(status: TaskStatus.failure, error: StorageException()),
      ],
    );
  });

  group('TaskCreated', () {
    blocTest<TaskBloc, TaskState>(
      'adiciona a nova tarefa e emite o aviso de sucesso',
      setUp: () => when(() => repository.create(any())).thenAnswer(
        (i) async => (i.positionalArguments.first as Task).copyWith(id: 100),
      ),
      build: buildBloc,
      seed: () => readyWith(sampleTasks()),
      act: (bloc) => bloc.add(const TaskCreated(TaskDraft(title: 'New task'))),
      verify: (bloc) {
        expect(bloc.state.tasks.first.id, 100);
        expect(bloc.state.tasks, hasLength(6));
        expect(bloc.state.statistics.total, 6);
        expect(bloc.state.feedback, TaskFeedback.created);
        expect(bloc.state.error, isNull);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emite erro de validação e mantém a lista quando o título está vazio',
      build: buildBloc,
      seed: () => readyWith(sampleTasks()),
      act: (bloc) => bloc.add(const TaskCreated(TaskDraft(title: '  '))),
      expect: () => [
        readyWith(sampleTasks()).copyWith(
          error: () => const ValidationException(ValidationError.titleRequired),
        ),
      ],
      verify: (_) => verifyNever(() => repository.create(any())),
    );
  });

  blocTest<TaskBloc, TaskState>(
    'TaskUpdated troca a tarefa em todas as listas',
    build: buildBloc,
    seed: () => readyWith(sampleTasks()),
    act: (bloc) =>
        bloc.add(TaskUpdated(sampleTasks().first.copyWith(title: 'Renamed'))),
    verify: (bloc) {
      expect(bloc.state.tasks.firstWhere((t) => t.id == 1).title, 'Renamed');
      expect(bloc.state.upNext.any((t) => t.title == 'Renamed'), isTrue);
      expect(bloc.state.feedback, TaskFeedback.updated);
    },
  );

  blocTest<TaskBloc, TaskState>(
    'TaskDeleted remove a tarefa',
    setUp: () => when(() => repository.delete(any())).thenAnswer((_) async {}),
    build: buildBloc,
    seed: () => readyWith(sampleTasks()),
    act: (bloc) => bloc.add(TaskDeleted(sampleTasks().first)),
    verify: (bloc) {
      expect(bloc.state.tasks.map((t) => t.id), isNot(contains(1)));
      expect(bloc.state.statistics.total, 4);
      verify(() => repository.delete(1)).called(1);
    },
  );

  blocTest<TaskBloc, TaskState>(
    'TaskCompletionToggled leva a tarefa para o histórico',
    build: buildBloc,
    seed: () => readyWith(sampleTasks()),
    act: (bloc) => bloc.add(TaskCompletionToggled(sampleTasks().first)),
    verify: (bloc) {
      expect(bloc.state.history.first.id, 1);
      expect(bloc.state.history.first.completedAt, kNow);
      expect(bloc.state.statistics.completed, 3);
    },
  );

  blocTest<TaskBloc, TaskState>(
    'TaskFavoriteToggled atualiza o total de favoritas',
    build: buildBloc,
    seed: () => readyWith(sampleTasks()),
    act: (bloc) => bloc.add(TaskFavoriteToggled(sampleTasks().first)),
    verify: (bloc) => expect(bloc.state.statistics.favorites, 2),
  );

  blocTest<TaskBloc, TaskState>(
    'TaskFilterChanged(completed) mostra só as concluídas',
    build: buildBloc,
    seed: () => readyWith(sampleTasks()),
    act: (bloc) => bloc.add(const TaskFilterChanged(TaskFilter.completed)),
    expect: () => [readyWith(sampleTasks(), filter: TaskFilter.completed)],
    verify: (bloc) => expect(bloc.state.visibleTasks.map((t) => t.id), [4, 5]),
  );

  blocTest<TaskBloc, TaskState>(
    'TaskSearchQueryChanged filtra as tarefas pelo título',
    build: buildBloc,
    seed: () => readyWith(sampleTasks()),
    act: (bloc) => bloc.add(const TaskSearchQueryChanged('groceries')),
    verify: (bloc) {
      expect(bloc.state.query, 'groceries');
      expect(bloc.state.visibleTasks.map((t) => t.id), [3]);
    },
  );

  blocTest<TaskBloc, TaskState>(
    'erros nas alterações vão para o estado e TaskMessageDismissed limpa',
    setUp: () => when(
      () => repository.delete(any()),
    ).thenThrow(const TaskNotFoundException(1)),
    build: buildBloc,
    seed: () => readyWith(sampleTasks()),
    act: (bloc) => bloc
      ..add(TaskDeleted(sampleTasks().first))
      ..add(const TaskMessageDismissed()),
    expect: () => [
      readyWith(
        sampleTasks(),
      ).copyWith(error: () => const TaskNotFoundException(1)),
      readyWith(sampleTasks()),
    ],
  );
}
