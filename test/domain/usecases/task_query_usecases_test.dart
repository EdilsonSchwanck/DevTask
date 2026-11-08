import 'package:devtask/domain/entities/task.dart';
import 'package:devtask/domain/entities/task_category.dart';
import 'package:devtask/domain/entities/task_filter.dart';
import 'package:devtask/domain/entities/task_priority.dart';
import 'package:devtask/domain/entities/task_statistics.dart';
import 'package:devtask/domain/usecases/filter_tasks.dart';
import 'package:devtask/domain/usecases/get_completed_history.dart';
import 'package:devtask/domain/usecases/get_task_statistics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/fixtures.dart';

void main() {
  final tasks = sampleTasks();
  final filterTasks = FilterTasks(kClock);

  List<int?> ids(Iterable<Task> list) => [for (final t in list) t.id];

  group('FilterTasks', () {
    test('filtra tarefas concluídas', () {
      final result = filterTasks(tasks, filter: TaskFilter.completed);
      expect(ids(result), unorderedEquals([4, 5]));
      expect(result.every((t) => t.isCompleted), isTrue);
    });

    test('filtra tarefas pendentes', () {
      final result = filterTasks(tasks, filter: TaskFilter.pending);
      expect(ids(result), unorderedEquals([1, 2, 3]));
    });

    test('filtra tarefas atrasadas (ignora as concluídas)', () {
      expect(ids(filterTasks(tasks, filter: TaskFilter.overdue)), [2]);
    });

    test('filtra favoritas', () {
      expect(ids(filterTasks(tasks, filter: TaskFilter.favorites)), [3]);
    });

    test(
      'busca pelo título sem diferenciar maiúsculas e ignorando espaços',
      () {
        expect(ids(filterTasks(tasks, query: '  CLEAN ')), [2]);
        expect(filterTasks(tasks, query: 'nothing matches'), isEmpty);
      },
    );

    test('combina filtro e busca', () {
      expect(
        ids(filterTasks(tasks, filter: TaskFilter.completed, query: 'bug')),
        [4],
      );
      expect(
        filterTasks(tasks, filter: TaskFilter.pending, query: 'bug'),
        isEmpty,
      );
    });

    test('ordena abertas primeiro, depois favoritas, prioridade e prazo', () {
      final result = filterTasks(tasks);

      expect(ids(result), [3, 1, 2, 4, 5]);
    });

    test('tarefas com prazo vêm antes das sem prazo', () {
      final a = taskFixture(id: 10, priority: TaskPriority.low);
      final b = taskFixture(id: 11, priority: TaskPriority.low, dueDate: kNow);
      expect(ids(filterTasks([a, b])), [11, 10]);
    });

    test('devolve uma lista que não pode ser alterada', () {
      expect(
        () => filterTasks(tasks).add(taskFixture()),
        throwsUnsupportedError,
      );
    });
  });

  group('GetTaskStatistics', () {
    test('calcula totais, atrasadas, favoritas e categorias', () {
      final stats = GetTaskStatistics(kClock)(tasks);

      expect(stats.total, 5);
      expect(stats.completed, 2);
      expect(stats.pending, 3);
      expect(stats.overdue, 1);
      expect(stats.favorites, 1);
      expect(stats.completionRate, closeTo(0.4, 1e-9));
      expect(stats.byCategory, {
        TaskCategory.work: 2,
        TaskCategory.study: 1,
        TaskCategory.personal: 1,
        TaskCategory.health: 1,
      });
    });

    test('funciona com lista vazia', () {
      final stats = GetTaskStatistics(kClock)([]);
      expect(stats, TaskStatistics.empty);
      expect(stats.completionRate, 0);
    });
  });

  test(
    'GetCompletedHistory devolve as concluídas, das mais recentes para as mais antigas',
    () {
      expect(ids(const GetCompletedHistory()(tasks)), [4, 5]);
    },
  );
}
