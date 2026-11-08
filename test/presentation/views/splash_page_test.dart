import 'package:bloc_test/bloc_test.dart';
import 'package:devtask/core/utils/clock.dart';
import 'package:devtask/presentation/bloc/locale/locale_cubit.dart';
import 'package:devtask/presentation/bloc/task/task_bloc.dart';
import 'package:devtask/presentation/bloc/theme/theme_cubit.dart';
import 'package:devtask/presentation/views/home_page.dart';
import 'package:devtask/presentation/views/splash_page.dart';
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

  const duration = Duration(milliseconds: 1000);

  setUpAll(registerFallbacks);

  setUp(() {
    taskBloc = MockTaskBloc();
    themeCubit = MockThemeCubit();
    when(() => themeCubit.state).thenReturn(ThemeMode.light);
  });

  Future<void> pumpSplash(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      RepositoryProvider<Clock>.value(
        value: kClock,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<TaskBloc>.value(value: taskBloc),
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider(
              create: (_) => LocaleCubit(InMemorySettingsRepository()),
            ),
          ],
          child: localizedApp(
            locale: locale,
            home: const SplashPage(duration: duration),
          ),
        ),
      ),
    );
  }

  testWidgets('mostra o nome, o slogan e a barra de progresso', (tester) async {
    when(() => taskBloc.state).thenReturn(const TaskState());
    await pumpSplash(tester);
    await tester.pump(duration ~/ 2);

    expect(find.byKey(const Key('splash-logo')), findsOneWidget);
    expect(find.text('DevTask'), findsOneWidget);
    expect(find.text('Plan it. Track it. Get it done.'), findsOneWidget);
    expect(find.byKey(const Key('splash-progress')), findsOneWidget);
  });

  testWidgets('aparece em português', (tester) async {
    when(() => taskBloc.state).thenReturn(const TaskState());
    await pumpSplash(tester, locale: const Locale('pt'));
    await tester.pump(duration);

    expect(find.text('Planeje. Acompanhe. Conclua.'), findsOneWidget);
    expect(find.text('Carregando suas tarefas…'), findsOneWidget);
  });

  testWidgets(
    'vai para a Home depois da animação quando as tarefas carregaram',
    (tester) async {
      when(
        () => taskBloc.state,
      ).thenReturn(const TaskState(status: TaskStatus.ready));
      await pumpSplash(tester);

      await tester.pump(duration ~/ 2);
      expect(find.byType(HomePage), findsNothing);

      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(SplashPage), findsNothing);
    },
  );

  testWidgets('espera o carregamento quando ele demora mais que a animação', (
    tester,
  ) async {
    whenListen(
      taskBloc,
      Stream.fromFuture(
        Future.delayed(
          const Duration(seconds: 3),
          () => const TaskState(status: TaskStatus.ready),
        ),
      ),
      initialState: const TaskState(status: TaskStatus.loading),
    );
    await pumpSplash(tester);

    await tester.pump(duration + const Duration(milliseconds: 100));
    expect(find.byType(SplashPage), findsOneWidget);
    // A barra fica indeterminada enquanto espera os dados.
    final bar = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('splash-progress')),
    );
    expect(bar.value, isNull);

    when(
      () => taskBloc.state,
    ).thenReturn(const TaskState(status: TaskStatus.ready));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}
