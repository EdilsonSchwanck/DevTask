import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task/task_bloc.dart';
import '../bloc/theme/theme_cubit.dart';
import '../l10n/l10n.dart';
import '../widgets/floating_nav_bar.dart';
import 'dashboard_view.dart';
import 'history_view.dart';
import 'language_sheet.dart';
import 'task_list_view.dart';
import 'task_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titles = [l10n.navDashboard, l10n.navTasks, l10n.navHistory];

    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (prev, curr) =>
          curr.error != prev.error || curr.feedback != prev.feedback,
      listener: (context, state) {
        final error = state.error;
        final message =
            error?.localizedMessage(l10n) ?? state.feedback?.message(l10n);
        if (message == null) return;
        final scheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    error != null
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: error != null
                        ? scheme.onError
                        : scheme.onInverseSurface,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: error != null ? scheme.error : null,
            ),
          );
        context.read<TaskBloc>().add(const TaskMessageDismissed());
      },
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          toolbarHeight: 68,
          titleSpacing: 20,
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(titles[_index], key: ValueKey(_index)),
          ),
          actions: const [
            LanguageButton(),
            SizedBox(width: 8),
            _ThemeToggle(),
            SizedBox(width: 12),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: [
            DashboardView(onShowTasks: () => setState(() => _index = 1)),
            const TaskListView(),
            const HistoryView(),
          ],
        ),
        bottomNavigationBar: FloatingNavBar(
          selectedIndex: _index,
          onSelected: (i) => setState(() => _index = i),
          onAdd: () => openTaskForm(context),
          addTooltip: l10n.newTask,
          items: [
            FloatingNavItem(
              key: const Key('nav-dashboard'),
              icon: Icons.space_dashboard_outlined,
              selectedIcon: Icons.space_dashboard_rounded,
              label: l10n.navDashboard,
            ),
            FloatingNavItem(
              key: const Key('nav-tasks'),
              icon: Icons.checklist_rounded,
              selectedIcon: Icons.checklist_rtl_rounded,
              label: l10n.navTasks,
            ),
            FloatingNavItem(
              key: const Key('nav-history'),
              icon: Icons.history_rounded,
              selectedIcon: Icons.history_toggle_off_rounded,
              label: l10n.navHistory,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = context.select((ThemeCubit c) => c.state == ThemeMode.dark);
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      key: const Key('theme-toggle'),
      tooltip: isDark ? l10n.themeLight : l10n.themeDark,
      style: IconButton.styleFrom(
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      ),
      onPressed: () => context.read<ThemeCubit>().toggle(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween(begin: 0.6, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
        ),
      ),
    );
  }
}
