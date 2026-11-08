import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/clock.dart';
import 'presentation/bloc/locale/locale_cubit.dart';
import 'presentation/bloc/task/task_bloc.dart';
import 'presentation/bloc/theme/theme_cubit.dart';
import 'presentation/l10n/l10n.dart';
import 'presentation/views/splash_page.dart';

class DevTaskApp extends StatelessWidget {
  const DevTaskApp({super.key, this.splashDuration});

  final Duration? splashDuration;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Clock>.value(
      value: sl<Clock>(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => sl<TaskBloc>()..add(const TasksLoadRequested()),
          ),
          BlocProvider(create: (_) => sl<ThemeCubit>()),
          BlocProvider(create: (_) => sl<LocaleCubit>()),
        ],
        child: Builder(
          builder: (context) {
            final themeMode = context.watch<ThemeCubit>().state;
            final language = context.watch<LocaleCubit>().state;
            return MaterialApp(
              onGenerateTitle: (context) => context.l10n.appTitle,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              locale: language.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: splashDuration == null
                  ? const SplashPage()
                  : SplashPage(duration: splashDuration!),
            );
          },
        ),
      ),
    );
  }
}
