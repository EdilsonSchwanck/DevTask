import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../domain/entities/task.dart';
import '../l10n/l10n.dart';
import 'priority_badge.dart';
import 'task_style.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.isOverdue,
    this.onTap,
    this.onToggleCompleted,
    this.onToggleFavorite,
  });

  final Task task;
  final bool isOverdue;
  final VoidCallback? onTap;
  final VoidCallback? onToggleCompleted;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final due = task.dueDate;
    final dueText = due == null ? null : Formatters.date(due, l10n.localeName);
    final accent = task.isCompleted
        ? scheme.outlineVariant
        : task.priority.color(scheme);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: task.isCompleted ? 0.7 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Priority accent stripe.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 5,
                  color: accent,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Center(
                    child: Transform.scale(
                      scale: 1.15,
                      child: Checkbox(
                        key: Key('task-check-${task.id}'),
                        value: task.isCompleted,
                        shape: const CircleBorder(),
                        side: BorderSide(color: accent, width: 2),
                        onChanged: onToggleCompleted == null
                            ? null
                            : (_) => onToggleCompleted!(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? scheme.onSurfaceVariant
                                : null,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            task.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            PriorityBadge(priority: task.priority),
                            _MetaChip(
                              icon: task.category.icon,
                              label: task.category.label(l10n),
                              color: task.category.color,
                            ),
                            if (due != null)
                              _MetaChip(
                                icon: isOverdue
                                    ? Icons.event_busy_rounded
                                    : Icons.event_rounded,
                                label: isOverdue
                                    ? l10n.overdueOn(dueText!)
                                    : dueText!,
                                color: isOverdue
                                    ? scheme.error
                                    : scheme.onSurfaceVariant,
                                emphasized: isOverdue,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: IconButton(
                    key: Key('task-favorite-${task.id}'),
                    tooltip: task.isFavorite
                        ? l10n.removeFavorite
                        : l10n.addFavorite,
                    onPressed: onToggleFavorite,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        task.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        key: ValueKey(task.isFavorite),
                        color: task.isFavorite
                            ? const Color(0xFFFFB300)
                            : scheme.outline,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
