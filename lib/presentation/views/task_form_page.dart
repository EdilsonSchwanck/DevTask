import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_draft.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/usecases/task_validator.dart';
import '../l10n/l10n.dart';
import '../widgets/task_style.dart';

sealed class TaskFormResult {
  const TaskFormResult();
}

final class TaskFormSaved extends TaskFormResult {
  const TaskFormSaved(this.draft);

  final TaskDraft draft;
}

final class TaskFormDeleteRequested extends TaskFormResult {
  const TaskFormDeleteRequested();
}

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, this.task});

  /// `null` → create mode.
  final Task? task;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late TaskCategory _category;
  late TaskPriority _priority;
  DateTime? _dueDate;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    _category = task?.category ?? TaskCategory.personal;
    _priority = task?.priority ?? TaskPriority.medium;
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      TaskFormSaved(
        TaskDraft(
          title: _title.text.trim(),
          description: _description.text.trim(),
          category: _category,
          priority: _priority,
          dueDate: _dueDate,
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDialogTitle),
        content: Text(l10n.deleteDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const TaskFormDeleteRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final task = widget.task;
    final l10n = context.l10n;
    final locale = l10n.localeName;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editTask : l10n.newTask),
        actions: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton.filledTonal(
                key: const Key('delete-task'),
                tooltip: l10n.delete,
                style: IconButton.styleFrom(
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                ),
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _delete,
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextFormField(
              key: const Key('title-field'),
              controller: _title,
              autofocus: !_isEditing,
              maxLength: TaskValidator.maxTitleLength,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.titleMedium,
              decoration: InputDecoration(
                labelText: l10n.titleLabel,
                prefixIcon: const Icon(Icons.edit_rounded),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? l10n.errorTitleRequired
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('description-field'),
              controller: _description,
              minLines: 3,
              maxLines: 6,
              maxLength: TaskValidator.maxDescriptionLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.descriptionLabel,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            _FormSection(
              icon: Icons.category_rounded,
              title: l10n.categoryLabel,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in TaskCategory.values)
                    ChoiceChip(
                      avatar: Icon(
                        c.icon,
                        size: 18,
                        color: c == _category ? scheme.onPrimary : c.color,
                      ),
                      label: Text(c.label(l10n)),
                      selected: c == _category,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FormSection(
              icon: Icons.flag_rounded,
              title: l10n.priorityLabel,
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<TaskPriority>(
                  showSelectedIcon: false,
                  segments: [
                    for (final p in TaskPriority.values)
                      ButtonSegment(
                        value: p,
                        label: Text(p.label(l10n)),
                        icon: Icon(p.icon, color: p.color(scheme)),
                      ),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (s) =>
                      setState(() => _priority = s.first),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FormSection(
              icon: Icons.event_rounded,
              title: l10n.dueDateLabel,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDueDate,
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(
                        _dueDate == null
                            ? l10n.noDueDate
                            : Formatters.date(_dueDate!, locale),
                      ),
                    ),
                  ),
                  if (_dueDate != null) ...[
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: l10n.clearDueDate,
                      onPressed: () => setState(() => _dueDate = null),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ],
              ),
            ),
            if (task != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.createdOn(
                        Formatters.dateTime(task.createdAt, locale),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              if (task.completedAt != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.completedOn(
                          Formatters.dateTime(task.completedAt!, locale),
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              key: const Key('save-task'),
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(_isEditing ? l10n.saveChanges : l10n.createTask),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
