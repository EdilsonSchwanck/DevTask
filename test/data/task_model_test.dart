import 'package:devtask/data/models/task_model.dart';
import 'package:devtask/domain/entities/task_category.dart';
import 'package:devtask/domain/entities/task_priority.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/fixtures.dart';

void main() {
  group('TaskModel', () {
    test('converte entidade -> map -> entidade sem perder dados', () {
      final task = taskFixture(
        id: 9,
        description: 'desc',
        category: TaskCategory.study,
        priority: TaskPriority.high,
        dueDate: kNow,
        isCompleted: true,
        isFavorite: true,
        completedAt: kNow,
      );

      final map = TaskModel.fromEntity(task).toMap();
      expect(TaskModel.fromMap(map).toEntity(), task);
    });

    test(
      'salva enums pelo nome, booleanos como 0/1 e datas em milissegundos',
      () {
        final map = TaskModel.fromEntity(
          taskFixture(isFavorite: true, dueDate: kNow),
        ).toMap();

        expect(map['category'], 'work');
        expect(map['priority'], 'medium');
        expect(map['is_favorite'], 1);
        expect(map['is_completed'], 0);
        expect(map['due_date'], kNow.millisecondsSinceEpoch);
        expect(map['completed_at'], isNull);
      },
    );

    test('não envia o id quando a tarefa ainda não foi salva', () {
      expect(
        TaskModel.fromEntity(taskFixture(id: null)).toMap(),
        isNot(contains('id')),
      );
    });

    test('usa valores padrão quando o enum salvo é desconhecido', () {
      final model = TaskModel.fromMap({
        'id': 1,
        'title': 'Legacy row',
        'description': null,
        'category': 'removed-category',
        'priority': 'urgent',
        'is_completed': 0,
        'is_favorite': 0,
        'created_at': kNow.millisecondsSinceEpoch,
      });

      expect(model.category, TaskCategory.other);
      expect(model.priority, TaskPriority.medium);
      expect(model.description, '');
    });
  });
}
