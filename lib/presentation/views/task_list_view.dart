import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/clock.dart';
import '../../domain/entities/task_filter.dart';
import '../bloc/task/task_bloc.dart';
import '../l10n/l10n.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/task_tile.dart';
import 'task_navigation.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: context.read<TaskBloc>().state.query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TaskBloc>();
    final now = context.read<Clock>().now();
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: ValueListenableBuilder(
            valueListenable: _search,
            builder: (context, value, _) => TextField(
              key: const Key('search-field'),
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: value.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.clearSearch,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          bloc.add(const TaskSearchQueryChanged(''));
                        },
                      ),
              ),
              onChanged: (q) => bloc.add(TaskSearchQueryChanged(q)),
            ),
          ),
        ),
        BlocSelector<TaskBloc, TaskState, TaskFilter>(
          selector: (s) => s.filter,
          builder: (context, filter) => FilterBar(
            selected: filter,
            onChanged: (f) => bloc.add(TaskFilterChanged(f)),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state.isLoading && state.tasks.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final tasks = state.visibleTasks;
              if (tasks.isEmpty) {
                return EmptyState(
                  icon: Icons.inbox_outlined,
                  title: state.tasks.isEmpty
                      ? l10n.noTasksTitle
                      : l10n.noMatchesTitle,
                  message: state.tasks.isEmpty
                      ? l10n.noTasksMessage
                      : l10n.noMatchesMessage,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                itemCount: tasks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Dismissible(
                    key: ValueKey('dismiss-${task.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    onDismissed: (_) => bloc.add(TaskDeleted(task)),
                    child: TaskTile(
                      task: task,
                      isOverdue: task.isOverdueAt(now),
                      onTap: () => openTaskForm(context, task: task),
                      onToggleCompleted: () =>
                          bloc.add(TaskCompletionToggled(task)),
                      onToggleFavorite: () =>
                          bloc.add(TaskFavoriteToggled(task)),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
