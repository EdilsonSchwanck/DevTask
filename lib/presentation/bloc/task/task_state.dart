part of 'task_bloc.dart';

enum TaskStatus { initial, loading, ready, failure }

/// Successful-operation notices; the View turns them into localized text.
enum TaskFeedback { created, updated, deleted }

final class TaskState extends Equatable {
  const TaskState({
    this.status = TaskStatus.initial,
    this.tasks = const [],
    this.filter = TaskFilter.all,
    this.query = '',
    this.visibleTasks = const [],
    this.history = const [],
    this.upNext = const [],
    this.statistics = TaskStatistics.empty,
    this.error,
    this.feedback,
  });

  final TaskStatus status;

  final List<Task> tasks;
  final TaskFilter filter;
  final String query;

  final List<Task> visibleTasks;

  final List<Task> history;

  final List<Task> upNext;
  final TaskStatistics statistics;

  /// One-shot notices consumed by a `BlocListener`. Typed (not strings) so
  /// the View can localize them.
  final AppException? error;
  final TaskFeedback? feedback;

  bool get isLoading => status == TaskStatus.loading;

  TaskState copyWith({
    TaskStatus? status,
    List<Task>? tasks,
    TaskFilter? filter,
    String? query,
    List<Task>? visibleTasks,
    List<Task>? history,
    List<Task>? upNext,
    TaskStatistics? statistics,
    AppException? Function()? error,
    TaskFeedback? Function()? feedback,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      visibleTasks: visibleTasks ?? this.visibleTasks,
      history: history ?? this.history,
      upNext: upNext ?? this.upNext,
      statistics: statistics ?? this.statistics,
      error: error != null ? error() : this.error,
      feedback: feedback != null ? feedback() : this.feedback,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tasks,
    filter,
    query,
    visibleTasks,
    history,
    upNext,
    statistics,
    error,
    feedback,
  ];
}
