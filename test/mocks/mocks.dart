import 'package:bloc_test/bloc_test.dart';
import 'package:devtask/data/datasources/task_local_datasource.dart';
import 'package:devtask/data/models/task_model.dart';
import 'package:devtask/domain/repositories/task_repository.dart';
import 'package:devtask/presentation/bloc/task/task_bloc.dart';
import 'package:devtask/presentation/bloc/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

import 'fixtures.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}

class MockTaskBloc extends MockBloc<TaskEvent, TaskState> implements TaskBloc {}

class MockThemeCubit extends MockCubit<ThemeMode> implements ThemeCubit {}

void registerFallbacks() {
  registerFallbackValue(taskFixture());
  registerFallbackValue(TaskModel.fromEntity(taskFixture()));
  registerFallbackValue(const TasksLoadRequested());
}
