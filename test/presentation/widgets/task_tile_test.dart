import 'package:devtask/domain/entities/task_priority.dart';
import 'package:devtask/presentation/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/fixtures.dart';
import '../../mocks/test_app.dart';

void main() {
  Widget host(Widget child) => localizedApp(home: Scaffold(body: child));

  testWidgets('mostra título, prioridade, categoria e prazo', (tester) async {
    await tester.pumpWidget(
      host(
        TaskTile(
          task: taskFixture(
            priority: TaskPriority.high,
            dueDate: DateTime(2026, 11, 9),
          ),
          isOverdue: false,
        ),
      ),
    );

    expect(find.text('Write unit tests'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Nov 9, 2026'), findsOneWidget);
  });

  testWidgets('destaca tarefas atrasadas', (tester) async {
    await tester.pumpWidget(
      host(
        TaskTile(
          task: taskFixture(dueDate: DateTime(2026, 11, 1)),
          isOverdue: true,
        ),
      ),
    );
    expect(find.text('Overdue · Nov 1, 2026'), findsOneWidget);
  });

  testWidgets('risca as tarefas concluídas', (tester) async {
    await tester.pumpWidget(
      host(TaskTile(task: taskFixture(isCompleted: true), isOverdue: false)),
    );
    final title = tester.widget<Text>(find.text('Write unit tests'));
    expect(title.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('avisa os toques no checkbox, na estrela e no card', (
    tester,
  ) async {
    var completed = 0, favorited = 0, tapped = 0;
    await tester.pumpWidget(
      host(
        TaskTile(
          task: taskFixture(),
          isOverdue: false,
          onToggleCompleted: () => completed++,
          onToggleFavorite: () => favorited++,
          onTap: () => tapped++,
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.byIcon(Icons.star_outline_rounded));
    await tester.tap(find.text('Write unit tests'));

    expect((completed, favorited, tapped), (1, 1, 1));
  });
}
