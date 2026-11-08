import 'package:flutter/widgets.dart';

import '../../core/errors/exceptions.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/usecases/task_validator.dart';
import '../bloc/task/task_bloc.dart';

export '../../core/l10n/generated/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension TaskCategoryL10n on TaskCategory {
  String label(AppLocalizations l10n) => switch (this) {
    TaskCategory.work => l10n.categoryWork,
    TaskCategory.study => l10n.categoryStudy,
    TaskCategory.personal => l10n.categoryPersonal,
    TaskCategory.health => l10n.categoryHealth,
    TaskCategory.other => l10n.categoryOther,
  };
}

extension TaskPriorityL10n on TaskPriority {
  String label(AppLocalizations l10n) => switch (this) {
    TaskPriority.low => l10n.priorityLow,
    TaskPriority.medium => l10n.priorityMedium,
    TaskPriority.high => l10n.priorityHigh,
  };
}

extension TaskFilterL10n on TaskFilter {
  String label(AppLocalizations l10n) => switch (this) {
    TaskFilter.all => l10n.filterAll,
    TaskFilter.pending => l10n.filterPending,
    TaskFilter.completed => l10n.filterCompleted,
    TaskFilter.overdue => l10n.filterOverdue,
    TaskFilter.favorites => l10n.filterFavorites,
  };
}

extension TaskFeedbackL10n on TaskFeedback {
  String message(AppLocalizations l10n) => switch (this) {
    TaskFeedback.created => l10n.feedbackCreated,
    TaskFeedback.updated => l10n.feedbackUpdated,
    TaskFeedback.deleted => l10n.feedbackDeleted,
  };
}

extension AppExceptionL10n on AppException {
  String localizedMessage(AppLocalizations l10n) => switch (this) {
    ValidationException(:final error) => switch (error) {
      ValidationError.titleRequired => l10n.errorTitleRequired,
      ValidationError.titleTooLong => l10n.errorTitleTooLong(
        TaskValidator.maxTitleLength,
      ),
      ValidationError.descriptionTooLong => l10n.errorDescriptionTooLong(
        TaskValidator.maxDescriptionLength,
      ),
      ValidationError.taskNotSaved => l10n.errorTaskNotSaved,
    },
    TaskNotFoundException() => l10n.errorTaskNotFound,
    StorageException() => l10n.errorStorage,
  };
}
