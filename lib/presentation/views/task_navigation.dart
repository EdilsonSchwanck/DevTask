import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../bloc/task/task_bloc.dart';
import 'task_form_page.dart';

Future<void> openTaskForm(BuildContext context, {Task? task}) async {
  final bloc = context.read<TaskBloc>();
  final result = await Navigator.of(context).push<TaskFormResult>(
    MaterialPageRoute(builder: (_) => TaskFormPage(task: task)),
  );

  switch (result) {
    case TaskFormSaved(:final draft):
      bloc.add(
        task == null ? TaskCreated(draft) : TaskUpdated(draft.applyTo(task)),
      );
    case TaskFormDeleteRequested() when task != null:
      bloc.add(TaskDeleted(task));
    case _:
      break;
  }
}
