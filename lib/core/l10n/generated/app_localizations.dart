import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  String get appTitle;

  String get splashTagline;

  String get splashLoading;

  String get navDashboard;

  String get navTasks;

  String get navHistory;

  String get themeLight;

  String get themeDark;

  String get language;

  String get languageSystem;

  String get languagePortuguese;

  String get languageEnglish;

  String get languageSheetSubtitle;

  String get languageSystemSubtitle;

  String get greetingMorning;

  String get greetingAfternoon;

  String get greetingEvening;

  String get dashboardHeadline;

  String get newTask;

  String get editTask;

  String get statTotal;

  String get statPending;

  String get statCompleted;

  String get statOverdue;

  String get completionRate;

  String completionSummary(int completed, int total, num favorites);

  String get byCategory;

  String get upNext;

  String get nothingPendingTitle;

  String get nothingPendingMessage;

  String get searchHint;

  String get clearSearch;

  String get noTasksTitle;

  String get noTasksMessage;

  String get noMatchesTitle;

  String get noMatchesMessage;

  String get filterAll;

  String get filterPending;

  String get filterCompleted;

  String get filterOverdue;

  String get filterFavorites;

  String get historyEmptyTitle;

  String get historyEmptyMessage;

  String historyGroupHeader(String day, int count);

  String historyItemSubtitle(String category, String priority);

  String get reopen;

  String overdueOn(String date);

  String get addFavorite;

  String get removeFavorite;

  String get priorityLow;

  String get priorityMedium;

  String get priorityHigh;

  String get categoryWork;

  String get categoryStudy;

  String get categoryPersonal;

  String get categoryHealth;

  String get categoryOther;

  String get titleLabel;

  String get descriptionLabel;

  String get categoryLabel;

  String get priorityLabel;

  String get dueDateLabel;

  String get noDueDate;

  String get clearDueDate;

  String createdOn(String date);

  String completedOn(String date);

  String get saveChanges;

  String get createTask;

  String get delete;

  String get cancel;

  String get deleteDialogTitle;

  String get deleteDialogMessage;

  String get feedbackCreated;

  String get feedbackUpdated;

  String get feedbackDeleted;

  String get errorTitleRequired;

  String errorTitleTooLong(int max);

  String errorDescriptionTooLong(int max);

  String get errorTaskNotSaved;

  String get errorTaskNotFound;

  String get errorStorage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
