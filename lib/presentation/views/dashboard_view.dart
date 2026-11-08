import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_statistics.dart';
import '../bloc/task/task_bloc.dart';
import '../l10n/l10n.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/task_style.dart';
import '../widgets/task_tile.dart';
import 'task_navigation.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key, this.onShowTasks});

  final VoidCallback? onShowTasks;

  @override
  Widget build(BuildContext context) {
    final now = context.read<Clock>().now();
    final l10n = context.l10n;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state.isLoading && state.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = state.statistics;
        final scheme = Theme.of(context).colorScheme;

        void showFiltered(TaskFilter filter) {
          context.read<TaskBloc>().add(TaskFilterChanged(filter));
          onShowTasks?.call();
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
          children: [
            _HeroCard(statistics: stats, hour: now.hour),
            const SizedBox(height: 16),
            _TwoColumnGrid(
              children: [
                StatCard(
                  label: l10n.statTotal,
                  value: stats.total,
                  icon: Icons.layers_rounded,
                  color: scheme.primary,
                  onTap: () => showFiltered(TaskFilter.all),
                ),
                StatCard(
                  label: l10n.statPending,
                  value: stats.pending,
                  icon: Icons.timelapse_rounded,
                  color: const Color(0xFFFB8C00),
                  onTap: () => showFiltered(TaskFilter.pending),
                ),
                StatCard(
                  label: l10n.statCompleted,
                  value: stats.completed,
                  icon: Icons.task_alt_rounded,
                  color: const Color(0xFF43A047),
                  onTap: () => showFiltered(TaskFilter.completed),
                ),
                StatCard(
                  label: l10n.statOverdue,
                  value: stats.overdue,
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFE53935),
                  onTap: () => showFiltered(TaskFilter.overdue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CategoryCard(statistics: stats),
            const SizedBox(height: 24),
            _SectionTitle(title: l10n.upNext, count: state.upNext.length),
            const SizedBox(height: 10),
            if (state.upNext.isEmpty)
              EmptyState(
                icon: Icons.celebration_outlined,
                title: l10n.nothingPendingTitle,
                message: l10n.nothingPendingMessage,
              )
            else
              for (final task in state.upNext)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskTile(
                    task: task,
                    isOverdue: task.isOverdueAt(now),
                    onTap: () => openTaskForm(context, task: task),
                    onToggleCompleted: () => context.read<TaskBloc>().add(
                      TaskCompletionToggled(task),
                    ),
                    onToggleFavorite: () =>
                        context.read<TaskBloc>().add(TaskFavoriteToggled(task)),
                  ),
                ),
          ],
        );
      },
    );
  }
}

/// Gradient header: greeting, completion summary and an animated ring.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.statistics, required this.hour});

  final TaskStatistics statistics;
  final int hour;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final greeting = hour < 12
        ? l10n.greetingMorning
        : hour < 18
        ? l10n.greetingAfternoon
        : l10n.greetingEvening;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.seed.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles, echoing the splash screen.
          const Positioned(
            right: -60,
            top: -70,
            child: _Circle(size: 160, opacity: 0.08),
          ),
          const Positioned(
            left: -40,
            bottom: -80,
            child: _Circle(size: 140, opacity: 0.06),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting 👋',
                      style: text.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.dashboardHeadline,
                      style: text.titleLarge?.copyWith(
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.completionSummary(
                          statistics.completed,
                          statistics.total,
                          statistics.favorites,
                        ),
                        style: text.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _ProgressRing(
                value: statistics.completionRate,
                label: l10n.completionRate,
                percent: Formatters.percent(
                  statistics.completionRate,
                  l10n.localeName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.value,
    required this.label,
    required this.percent,
  });

  final double value;
  final String label;
  final String percent;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        SizedBox.square(
          dimension: 92,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, animated, _) => CircularProgressIndicator(
                  value: animated,
                  strokeWidth: 9,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Center(
                child: Text(
                  percent,
                  style: text.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 96,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: text.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (count != null && count! > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TwoColumnGrid extends StatelessWidget {
  const _TwoColumnGrid({required this.children});

  final List<Widget> children;

  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) const SizedBox(height: _gap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: _gap),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.statistics});

  final TaskStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final total = statistics.total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.byCategory, style: theme.textTheme.titleSmall),
            const SizedBox(height: 14),
            for (final category in TaskCategory.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        category.icon,
                        size: 18,
                        color: category.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 78,
                      child: Text(
                        category.label(l10n),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0,
                            end: total == 0
                                ? 0
                                : (statistics.byCategory[category] ?? 0) /
                                      total,
                          ),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          builder: (_, value, _) => LinearProgressIndicator(
                            value: value,
                            minHeight: 8,
                            color: category.color,
                            backgroundColor: category.color.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${statistics.byCategory[category] ?? 0}',
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
