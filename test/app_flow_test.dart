import 'package:devtask/app.dart';
import 'package:devtask/core/database/app_database.dart';
import 'package:devtask/core/di/injection.dart';
import 'package:devtask/domain/repositories/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'mocks/fixtures.dart';
import 'mocks/in_memory_settings_repository.dart';
import 'mocks/in_memory_task_repository.dart';

void main() {
  late InMemoryTaskRepository repository;
  late InMemorySettingsRepository settings;

  setUp(() async {
    settings = InMemorySettingsRepository();
    await configureDependencies(
      database: AppDatabase(
        factory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
      ),
      settings: settings,
      clock: kClock,
    );
    repository = InMemoryTaskRepository();
    sl
      ..unregister<TaskRepository>()
      ..registerSingleton<TaskRepository>(repository);
  });

  Future<void> waitForSnackBar(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const DevTaskApp(splashDuration: Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('cria, conclui, vê no histórico e exclui uma tarefa', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Nothing pending'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-task')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('title-field')),
      'Publish portfolio',
    );
    await tester.tap(find.byKey(const Key('save-task')));
    await tester.pumpAndSettle();
    await waitForSnackBar(tester);

    expect(find.text('Publish portfolio'), findsOneWidget);
    expect(await repository.getAll(), hasLength(1));

    await tester.tap(find.byKey(const Key('nav-tasks')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-history')));
    await tester.pumpAndSettle();
    expect(find.text('Publish portfolio'), findsOneWidget);
    expect((await repository.getAll()).single.completedAt, kNow);

    await tester.tap(find.text('Publish portfolio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-task')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('No completed tasks yet'), findsOneWidget);
    expect(await repository.getAll(), isEmpty);
  });

  testWidgets('editar uma tarefa atualiza ela em todas as telas', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('add-task')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('title-field')), 'Draft');
    await tester.tap(find.byKey(const Key('save-task')));
    await tester.pumpAndSettle();
    await waitForSnackBar(tester);

    await tester.tap(find.byKey(const Key('nav-tasks')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Draft'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('title-field')), 'Final');
    await tester.tap(find.byKey(const Key('save-task')));
    await tester.pumpAndSettle();
    await waitForSnackBar(tester);

    expect(find.text('Final'), findsOneWidget);
    expect((await repository.getAll()).single.title, 'Final');
  });

  testWidgets('botão de tema muda para o modo escuro', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('idioma e tema continuam depois de fechar e abrir o app', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Dashboard'), findsWidgets);

    await tester.tap(find.byKey(const Key('language-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-portugueseBrazil')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pumpAndSettle();

  
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester);

    expect(find.text('Painel'), findsWidgets);
    expect(find.text('Dashboard'), findsNothing);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
