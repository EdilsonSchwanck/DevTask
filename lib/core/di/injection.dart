import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/datasources/task_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/filter_tasks.dart';
import '../../domain/usecases/get_completed_history.dart';
import '../../domain/usecases/get_task_statistics.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../domain/usecases/update_task.dart';
import '../../presentation/bloc/locale/locale_cubit.dart';
import '../../presentation/bloc/task/task_bloc.dart';
import '../../presentation/bloc/theme/theme_cubit.dart';
import '../database/app_database.dart';
import '../utils/clock.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies({
  AppDatabase? database,
  SettingsRepository? settings,
  Clock clock = const SystemClock(),
}) async {
  await sl.reset();

  // As preferências são carregadas antes do app abrir, para ele já iniciar
  // com o idioma e o tema que o usuário escolheu.
  final settingsRepository =
      settings ?? SettingsRepositoryImpl(await SharedPreferences.getInstance());

  // Core
  sl
    ..registerSingleton<Clock>(clock)
    ..registerSingleton<SettingsRepository>(settingsRepository)
    ..registerSingleton<AppDatabase>(
      database ??
          AppDatabase(
            factory: databaseFactory,
            path: p.join(await getDatabasesPath(), 'devtask.db'),
          ),
    )
    // Data
    ..registerLazySingleton<TaskLocalDataSource>(
      () => SqfliteTaskLocalDataSource(sl()),
    )
    ..registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()))
    // Domain
    ..registerLazySingleton(() => GetTasks(sl()))
    ..registerLazySingleton(() => CreateTask(sl(), sl()))
    ..registerLazySingleton(() => UpdateTask(sl()))
    ..registerLazySingleton(() => DeleteTask(sl()))
    ..registerLazySingleton(() => ToggleTaskCompletion(sl(), sl()))
    ..registerLazySingleton(() => ToggleFavorite(sl()))
    ..registerLazySingleton(() => FilterTasks(sl()))
    ..registerLazySingleton(() => GetTaskStatistics(sl()))
    ..registerLazySingleton(() => const GetCompletedHistory())
    // ViewModels
    ..registerFactory(
      () => TaskBloc(
        getTasks: sl(),
        createTask: sl(),
        updateTask: sl(),
        deleteTask: sl(),
        toggleCompletion: sl(),
        toggleFavorite: sl(),
        filterTasks: sl(),
        getStatistics: sl(),
        getHistory: sl(),
      ),
    )
    ..registerFactory(() => ThemeCubit(sl()))
    ..registerFactory(() => LocaleCubit(sl()));
}
