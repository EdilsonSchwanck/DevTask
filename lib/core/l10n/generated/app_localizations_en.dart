import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DevTask';

  @override
  String get splashTagline => 'Plan it. Track it. Get it done.';

  @override
  String get splashLoading => 'Loading your tasks…';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navHistory => 'History';

  @override
  String get themeLight => 'Light mode';

  @override
  String get themeDark => 'Dark mode';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languagePortuguese => 'Português (Brasil)';

  @override
  String get languageEnglish => 'English (US)';

  @override
  String get languageSheetSubtitle => 'Choose how DevTask talks to you';

  @override
  String get languageSystemSubtitle => 'Follows your device language';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get dashboardHeadline => 'Here\'s how your tasks are going';

  @override
  String get newTask => 'New task';

  @override
  String get editTask => 'Edit task';

  @override
  String get statTotal => 'Total';

  @override
  String get statPending => 'Pending';

  @override
  String get statCompleted => 'Completed';

  @override
  String get statOverdue => 'Overdue';

  @override
  String get completionRate => 'Completion rate';

  @override
  String completionSummary(int completed, int total, num favorites) {
    final intl.NumberFormat favoritesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String favoritesString = favoritesNumberFormat.format(favorites);

    String _temp0 = intl.Intl.pluralLogic(
      favorites,
      locale: localeName,
      other: '$favoritesString favorites',
      one: '1 favorite',
      zero: 'no favorites',
    );
    return '$completed of $total done · $_temp0';
  }

  @override
  String get byCategory => 'By category';

  @override
  String get upNext => 'Up next';

  @override
  String get nothingPendingTitle => 'Nothing pending';

  @override
  String get nothingPendingMessage => 'Tap + to plan your next task.';

  @override
  String get searchHint => 'Search by title';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noTasksTitle => 'No tasks yet';

  @override
  String get noTasksMessage => 'Create your first task with the + button.';

  @override
  String get noMatchesTitle => 'No matching tasks';

  @override
  String get noMatchesMessage => 'Try another filter or search term.';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get historyEmptyTitle => 'No completed tasks yet';

  @override
  String get historyEmptyMessage => 'Tasks you complete will show up here.';

  @override
  String historyGroupHeader(String day, int count) {
    return '$day · $count';
  }

  @override
  String historyItemSubtitle(String category, String priority) {
    return '$category · $priority priority';
  }

  @override
  String get reopen => 'Reopen';

  @override
  String overdueOn(String date) {
    return 'Overdue · $date';
  }

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryStudy => 'Study';

  @override
  String get categoryPersonal => 'Personal';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOther => 'Other';

  @override
  String get titleLabel => 'Title';

  @override
  String get descriptionLabel => 'Description (optional)';

  @override
  String get categoryLabel => 'Category';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get dueDateLabel => 'Due date';

  @override
  String get noDueDate => 'No due date';

  @override
  String get clearDueDate => 'Clear due date';

  @override
  String createdOn(String date) {
    return 'Created $date';
  }

  @override
  String completedOn(String date) {
    return 'Completed $date';
  }

  @override
  String get saveChanges => 'Save changes';

  @override
  String get createTask => 'Create task';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteDialogTitle => 'Delete task?';

  @override
  String get deleteDialogMessage => 'This action cannot be undone.';

  @override
  String get feedbackCreated => 'Task created';

  @override
  String get feedbackUpdated => 'Task updated';

  @override
  String get feedbackDeleted => 'Task deleted';

  @override
  String get errorTitleRequired => 'Title is required.';

  @override
  String errorTitleTooLong(int max) {
    return 'Title must have at most $max characters.';
  }

  @override
  String errorDescriptionTooLong(int max) {
    return 'Description must have at most $max characters.';
  }

  @override
  String get errorTaskNotSaved => 'This task has not been saved yet.';

  @override
  String get errorTaskNotFound => 'Task not found. It may have been deleted.';

  @override
  String get errorStorage => 'Could not access local storage.';
}
