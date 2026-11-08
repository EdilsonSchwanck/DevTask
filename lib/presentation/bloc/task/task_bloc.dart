import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_draft.dart';
import '../../../domain/entities/task_filter.dart';
import '../../../domain/entities/task_statistics.dart';
import '../../../domain/usecases/create_task.dart';
import '../../../domain/usecases/delete_task.dart';
import '../../../domain/usecases/filter_tasks.dart';
import '../../../domain/usecases/get_completed_history.dart';
import '../../../domain/usecases/get_task_statistics.dart';
import '../../../domain/usecases/get_tasks.dart';
import '../../../domain/usecases/toggle_favorite.dart';
import '../../../domain/usecases/toggle_task_completion.dart';
import '../../../domain/usecases/update_task.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required GetTasks getTasks,
    required CreateTask createTask,
    required UpdateTask updateTask,
    required DeleteTask deleteTask,
    required ToggleTaskCompletion toggleCompletion,
    required ToggleFavorite toggleFavorite,
    required FilterTasks filterTasks,
    required GetTaskStatistics getStatistics,
    required GetCompletedHistory getHistory,
  }) : _getTasks = getTasks,
       _createTask = createTask,
       _updateTask = updateTask,
       _deleteTask = deleteTask,
       _toggleCompletion = toggleCompletion,
       _toggleFavorite = toggleFavorite,
       _filterTasks = filterTasks,
       _getStatistics = getStatistics,
       _getHistory = getHistory,
       super(const TaskState()) {
    on<TasksLoadRequested>(_onLoadRequested);
    on<TaskCreated>(_onCreated);
    on<TaskUpdated>(_onUpdated);
    on<TaskDeleted>(_onDeleted);
    on<TaskCompletionToggled>(_onCompletionToggled);
    on<TaskFavoriteToggled>(_onFavoriteToggled);
    on<TaskFilterChanged>(_onFilterChanged);
    on<TaskSearchQueryChanged>(_onSearchQueryChanged);
    on<TaskMessageDismissed>(_onMessageDismissed);
  }

  static const int upNextLimit = 5;

  final GetTasks _getTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final ToggleTaskCompletion _toggleCompletion;
  final ToggleFavorite _toggleFavorite;
  final FilterTasks _filterTasks;
  final GetTaskStatistics _getStatistics;
  final GetCompletedHistory _getHistory;

  Future<void> _onLoadRequested(
    TasksLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatus.loading, error: () => null));
    try {
      final tasks = await _getTasks();
      emit(_derive(state.copyWith(status: TaskStatus.ready, tasks: tasks)));
    } on AppException catch (e) {
      emit(state.copyWith(status: TaskStatus.failure, error: () => e));
    }
  }

  Future<void> _onCreated(TaskCreated event, Emitter<TaskState> emit) =>
      _mutate(emit, () async {
        final created = await _createTask(event.draft);
        return ([created, ...state.tasks], TaskFeedback.created);
      });

  Future<void> _onUpdated(TaskUpdated event, Emitter<TaskState> emit) =>
      _mutate(emit, () async {
        final updated = await _updateTask(event.task);
        return (_replace(updated), TaskFeedback.updated);
      });

  Future<void> _onDeleted(TaskDeleted event, Emitter<TaskState> emit) =>
      _mutate(emit, () async {
        final id = event.task.id;
        if (id == null) {
          throw const ValidationException(ValidationError.taskNotSaved);
        }
        await _deleteTask(id);
        return (
          state.tasks.where((t) => t.id != id).toList(),
          TaskFeedback.deleted,
        );
      });

  Future<void> _onCompletionToggled(
    TaskCompletionToggled event,
    Emitter<TaskState> emit,
  ) => _mutate(emit, () async {
    final updated = await _toggleCompletion(event.task);
    return (_replace(updated), null);
  });

  Future<void> _onFavoriteToggled(
    TaskFavoriteToggled event,
    Emitter<TaskState> emit,
  ) => _mutate(emit, () async {
    final updated = await _toggleFavorite(event.task);
    return (_replace(updated), null);
  });

  void _onFilterChanged(TaskFilterChanged event, Emitter<TaskState> emit) =>
      emit(_derive(state.copyWith(filter: event.filter)));

  void _onSearchQueryChanged(
    TaskSearchQueryChanged event,
    Emitter<TaskState> emit,
  ) => emit(_derive(state.copyWith(query: event.query)));

  void _onMessageDismissed(
    TaskMessageDismissed event,
    Emitter<TaskState> emit,
  ) => emit(state.copyWith(error: () => null, feedback: () => null));

  Future<void> _mutate(
    Emitter<TaskState> emit,
    Future<(List<Task>, TaskFeedback?)> Function() action,
  ) async {
    try {
      final (tasks, feedback) = await action();
      emit(
        _derive(
          state.copyWith(
            status: TaskStatus.ready,
            tasks: tasks,
            error: () => null,
            feedback: () => feedback,
          ),
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(error: () => e));
    }
  }

  List<Task> _replace(Task updated) => [
    for (final t in state.tasks) t.id == updated.id ? updated : t,
  ];

  TaskState _derive(TaskState s) {
    final open = _filterTasks(s.tasks, filter: TaskFilter.pending);
    return s.copyWith(
      visibleTasks: _filterTasks(s.tasks, filter: s.filter, query: s.query),
      history: _getHistory(s.tasks),
      upNext: open.take(upNextLimit).toList(),
      statistics: _getStatistics(s.tasks),
    );
  }
}
