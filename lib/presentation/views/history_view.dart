import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/formatters.dart';
import '../../domain/entities/task.dart';
import '../bloc/task/task_bloc.dart';
import '../l10n/l10n.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_style.dart';
import 'task_navigation.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocSelector<TaskBloc, TaskState, List<Task>>(
      selector: (state) => state.history,
      builder: (context, history) {
        if (history.isEmpty) {
          return EmptyState(
            icon: Icons.history_rounded,
            title: l10n.historyEmptyTitle,
            message: l10n.historyEmptyMessage,
          );
        }

        final groups = <String, List<Task>>{};
        for (final task in history) {
          final day = Formatters.date(
            task.completedAt ?? task.createdAt,
            l10n.localeName,
          );
          (groups[day] ??= []).add(task);
        }

        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
          children: [
            for (final entry in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
                child: Row(
                  children: [
                    Flexible(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.historyGroupHeader(
                                  entry.key,
                                  entry.value.length,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Divider(color: scheme.outlineVariant)),
                  ],
                ),
              ),
              for (final task in entry.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: task.category.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          task.category.icon,
                          color: task.category.color,
                        ),
                      ),
                      title: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        l10n.historyItemSubtitle(
                          task.category.label(l10n),
                          task.priority.label(l10n),
                        ),
                      ),
                      trailing: IconButton.filledTonal(
                        tooltip: l10n.reopen,
                        icon: const Icon(Icons.undo_rounded),
                        onPressed: () => context.read<TaskBloc>().add(
                          TaskCompletionToggled(task),
                        ),
                      ),
                      onTap: () => openTaskForm(context, task: task),
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}
