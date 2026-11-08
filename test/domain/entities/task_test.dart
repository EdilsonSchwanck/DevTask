import 'package:devtask/domain/entities/task_draft.dart';
import 'package:devtask/domain/entities/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/fixtures.dart';

void main() {
  group('Task.isOverdueAt', () {
    test('é verdadeiro quando está aberta e o prazo foi antes de hoje', () {
      final task = taskFixture(dueDate: kNow.subtract(const Duration(days: 1)));
      expect(task.isOverdueAt(kNow), isTrue);
    });

    test('é falso quando o prazo é hoje (compara só a data, não a hora)', () {
      final task = taskFixture(
        dueDate: DateTime(kNow.year, kNow.month, kNow.day),
      );
      expect(task.isOverdueAt(kNow), isFalse);
    });

    test('é falso quando já foi concluída, mesmo com o prazo vencido', () {
      final task = taskFixture(
        dueDate: kNow.subtract(const Duration(days: 10)),
        isCompleted: true,
      );
      expect(task.isOverdueAt(kNow), isFalse);
    });

    test('é falso quando não tem prazo', () {
      expect(taskFixture().isOverdueAt(kNow), isFalse);
    });
  });

  group('Task.copyWith', () {
    test('mantém os campos não alterados e compara por valor', () {
      final task = taskFixture();
      expect(task.copyWith(), task);
      expect(task.copyWith(title: 'Other'), isNot(task));
    });

    test('consegue limpar campos opcionais para null', () {
      final task = taskFixture(dueDate: kNow, completedAt: kNow);
      final reset = task.copyWith(dueDate: () => null, completedAt: () => null);
      expect(reset.dueDate, isNull);
      expect(reset.completedAt, isNull);
    });
  });

  test('TaskDraft.applyTo troca só os campos editáveis', () {
    final task = taskFixture(id: 7, isFavorite: true, dueDate: kNow);
    const draft = TaskDraft(title: 'New title', priority: TaskPriority.high);

    final result = draft.applyTo(task);

    expect(result.id, 7);
    expect(result.isFavorite, isTrue);
    expect(result.title, 'New title');
    expect(result.priority, TaskPriority.high);
    expect(result.dueDate, isNull);
    expect(TaskDraft.fromTask(result).applyTo(result), result);
  });
}
