import 'package:flutter/material.dart';

import '../../domain/entities/task_filter.dart';
import '../l10n/l10n.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key, required this.selected, required this.onChanged});

  final TaskFilter selected;
  final ValueChanged<TaskFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final filter in TaskFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                key: Key('filter-${filter.name}'),
                label: Text(filter.label(context.l10n)),
                selected: filter == selected,
                onSelected: (_) => onChanged(filter),
              ),
            ),
        ],
      ),
    );
  }
}
