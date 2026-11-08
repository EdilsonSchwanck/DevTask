import 'package:bloc_test/bloc_test.dart';
import 'package:devtask/core/errors/exceptions.dart';
import 'package:devtask/core/utils/clock.dart';
import 'package:devtask/domain/entities/task_filter.dart';
import 'package:devtask/domain/usecases/filter_tasks.dart';
import 'package:devtask/domain/usecases/get_completed_history.dart';
import 'package:devtask/domain/usecases/get_task_statistics.dart';
import 'package:devtask/presentation/bloc/locale/locale_cubit.dart';
import 'package:devtask/presentation/bloc/task/task_bloc.dart';
import 'package:devtask/presentation/bloc/theme/theme_cubit.dart';
import 'package:devtask/presentation/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/fixtures.dart';
import '../../mocks/in_memory_settings_repository.dart';
import '../../mocks/mocks.dart';
import '../../mocks/test_app.dart';

void main() {
  late MockTaskBloc taskBloc;
  late MockThemeCubit themeCubit;

  setUpAll(registerFallbacks);

  TaskState readyState({TaskFilter filter = TaskFilter.all}) {
    final tasks = sampleTasks();
    final filterTasks = FilterTasks(kClock);
    return TaskState(
      status: TaskStatus.ready,
      tasks: tasks,
      filter: filter,
      visibleTasks: filterTasks(tasks, filter: filter),
      history: const GetCompletedHistory()(tasks),
      upNext: filterTasks(tasks, filter: TaskFilter.pending),
      statistics: GetTaskStatistics(kClock)(tasks),
    );
  }

  setUp(() {
    taskBloc = MockTaskBloc();
    themeCubit = MockThemeCubit();
    when(() => themeCubit.state).thenReturn(ThemeMode.light);
    when(() => themeCubit.toggle()).thenAnswer((_) async {});
  });

  Future<void> pumpHome(
    WidgetTester tester,
    TaskState state, {
    AppLanguage language = AppLanguage.englishUs,
  }) async {
    when(() => taskBloc.state).thenReturn(state);
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepositoryProvider<Clock>.value(
        value: kClock,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<TaskBloc>.value(value: taskBloc),
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider(
              create: (_) => LocaleCubit(
                InMemorySettingsRepository(languageCode: language.code),
              ),
            ),
          ],
          child: BlocBuilder<LocaleCubit, AppLanguage>(
            builder: (context, language) => MaterialApp(
              locale: language.locale,
              localizationsDelegates: kLocalizationsDelegates,
              supportedLocales: kSupportedLocales,
              home: const HomePage(),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('mostra a tela em português', (tester) async {
    await pumpHome(
      tester,
      readyState(),
      language: AppLanguage.portugueseBrazil,
    );

    expect(find.text('Painel'), findsWidgets);
    expect(find.text('Taxa de conclusão'), findsOneWidget);
    expect(find.byTooltip('Nova tarefa'), findsOneWidget);
    expect(find.text('2 de 5 concluídas · 1 favorito'), findsOneWidget);
    expect(find.text('Trabalho'), findsWidgets);
  });

  testWidgets('trocar o idioma muda a tela inteira', (tester) async {
    await pumpHome(tester, readyState());
    expect(find.text('Completion rate'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Português (Brasil)'));
    await tester.pumpAndSettle();

    expect(find.text('Taxa de conclusão'), findsOneWidget);
    expect(find.text('Completion rate'), findsNothing);
  });

  testWidgets('painel de idioma mostra todas as opções e marca a atual', (
    tester,
  ) async {
    await pumpHome(tester, readyState());

    await tester.tap(find.byKey(const Key('language-menu')));
    await tester.pumpAndSettle();

    expect(find.text('🇧🇷'), findsOneWidget);
    expect(
      find.text('🇺🇸'),
      findsWidgets,
    ); // opção do painel + botão da AppBar
    expect(find.text('🌐'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-system')));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  for (final language in [
    AppLanguage.portugueseBrazil,
    AppLanguage.englishUs,
  ]) {
    testWidgets(
      'todas as abas cabem numa tela pequena de 320px (${language.name})',
      (tester) async {
        await pumpHome(tester, readyState(), language: language);
        tester.view.physicalSize = const Size(960, 1707); // 320 x 569 dp
        tester.view.devicePixelRatio = 3;
        await tester.pumpAndSettle();

        for (final tab in ['nav-tasks', 'nav-history', 'nav-dashboard']) {
          await tester.tap(find.byKey(Key(tab)));
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('painel mostra as estatísticas', (tester) async {
    await pumpHome(tester, readyState());

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Completion rate'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('Up next'), findsOneWidget);
  });

  testWidgets('mostra o carregamento enquanto busca as tarefas', (
    tester,
  ) async {
    await pumpHome(tester, const TaskState(status: TaskStatus.loading));
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets(
    'aba de tarefas lista as tarefas e envia os eventos de filtro e busca',
    (tester) async {
      await pumpHome(tester, readyState());

      await tester.tap(find.byKey(const Key('nav-tasks')));
      await tester.pumpAndSettle();

      expect(find.text('Prepare sprint review'), findsWidgets);

      await tester.tap(find.byKey(const Key('filter-completed')));
      verify(
        () => taskBloc.add(const TaskFilterChanged(TaskFilter.completed)),
      ).called(1);

      await tester.enterText(find.byKey(const Key('search-field')), 'bug');
      verify(() => taskBloc.add(const TaskSearchQueryChanged('bug'))).called(1);
    },
  );

  testWidgets('marcar uma tarefa envia TaskCompletionToggled', (tester) async {
    await pumpHome(tester, readyState());

    await tester.tap(find.byKey(const Key('nav-tasks')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('task-check-1')));

    verify(
      () => taskBloc.add(TaskCompletionToggled(sampleTasks().first)),
    ).called(1);
  });

  testWidgets('aba de histórico lista as concluídas', (tester) async {
    await pumpHome(tester, readyState());

    await tester.tap(find.byKey(const Key('nav-history')));
    await tester.pumpAndSettle();

    expect(find.text('Fix login bug'), findsOneWidget);
    expect(find.text('Morning run'), findsOneWidget);
  });

  testWidgets('mostra o erro numa snackbar e limpa a mensagem', (tester) async {
    whenListen(
      taskBloc,
      Stream.value(
        readyState().copyWith(
          error: () => const ValidationException(ValidationError.titleRequired),
        ),
      ),
      initialState: readyState(),
    );
    await pumpHome(tester, readyState());
    await tester.pump();

    expect(find.text('Title is required.'), findsOneWidget);
    verify(() => taskBloc.add(const TaskMessageDismissed())).called(1);
  });

  testWidgets('botão de tema troca o tema', (tester) async {
    await pumpHome(tester, readyState());

    await tester.tap(find.byKey(const Key('theme-toggle')));

    verify(() => themeCubit.toggle()).called(1);
  });
}
