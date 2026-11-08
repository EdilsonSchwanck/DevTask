import 'package:devtask/domain/entities/task_category.dart';
import 'package:devtask/domain/entities/task_draft.dart';
import 'package:devtask/domain/entities/task_priority.dart';
import 'package:devtask/presentation/views/task_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/fixtures.dart';
import '../../mocks/test_app.dart';

void main() {
  Future<List<TaskFormResult?>> pumpForm(
    WidgetTester tester, {
    TaskFormPage? page,
  }) async {
    final results = <TaskFormResult?>[];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: kLocalizationsDelegates,
        supportedLocales: kSupportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(
              await Navigator.of(context).push<TaskFormResult>(
                MaterialPageRoute(builder: (_) => page ?? const TaskFormPage()),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('não salva sem título', (tester) async {
    final results = await pumpForm(tester);

    await tester.tap(find.byKey(const Key('save-task')));
    await tester.pumpAndSettle();

    expect(find.text('Title is required.'), findsOneWidget);
    expect(results, isEmpty);
  });

  testWidgets('devolve os dados preenchidos no formulário', (tester) async {
    final results = await pumpForm(tester);

    await tester.enterText(find.byKey(const Key('title-field')), '  Ship v1  ');
    await tester.enterText(
      find.byKey(const Key('description-field')),
      'Release notes',
    );
    await tester.tap(find.text('Study'));
    await tester.tap(find.text('High'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('save-task')));
    await tester.pumpAndSettle();

    final saved = results.single! as TaskFormSaved;
    expect(
      saved.draft,
      const TaskDraft(
        title: 'Ship v1',
        description: 'Release notes',
        category: TaskCategory.study,
        priority: TaskPriority.high,
      ),
    );
  });

  testWidgets('no modo edição vem preenchido e permite excluir', (
    tester,
  ) async {
    final results = await pumpForm(
      tester,
      page: TaskFormPage(task: taskFixture(title: 'Existing task')),
    );

    expect(find.text('Edit task'), findsOneWidget);
    expect(find.text('Existing task'), findsOneWidget);

    await tester.tap(find.byKey(const Key('delete-task')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(results.single, isA<TaskFormDeleteRequested>());
  });
}
