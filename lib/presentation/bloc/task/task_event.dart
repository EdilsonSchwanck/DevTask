part of 'task_bloc.dart';

sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

final class TasksLoadRequested extends TaskEvent {
  const TasksLoadRequested();
}

final class TaskCreated extends TaskEvent {
  const TaskCreated(this.draft);

  final TaskDraft draft;

  @override
  List<Object?> get props => [draft];
}

final class TaskUpdated extends TaskEvent {
  const TaskUpdated(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

final class TaskDeleted extends TaskEvent {
  const TaskDeleted(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

final class TaskCompletionToggled extends TaskEvent {
  const TaskCompletionToggled(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

final class TaskFavoriteToggled extends TaskEvent {
  const TaskFavoriteToggled(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

final class TaskFilterChanged extends TaskEvent {
  const TaskFilterChanged(this.filter);

  final TaskFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class TaskSearchQueryChanged extends TaskEvent {
  const TaskSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class TaskMessageDismissed extends TaskEvent {
  const TaskMessageDismissed();
}
