import 'package:devtask/core/errors/exceptions.dart';
import 'package:devtask/core/utils/formatters.dart';
import 'package:devtask/domain/entities/task_category.dart';
import 'package:devtask/domain/entities/task_filter.dart';
import 'package:devtask/domain/entities/task_priority.dart';
import 'package:devtask/presentation/bloc/task/task_bloc.dart';
import 'package:devtask/presentation/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations pt;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    pt = await AppLocalizations.delegate.load(const Locale('pt'));
    await initializeDateFormatting();
  });

  test('suporta exatamente inglês e português', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode),
      unorderedEquals(['en', 'pt']),
    );
  });

  test('todo valor de enum tem texto nos dois idiomas', () {
    for (final l10n in [en, pt]) {
      for (final v in TaskCategory.values) {
        expect(v.label(l10n), isNotEmpty);
      }
      for (final v in TaskPriority.values) {
        expect(v.label(l10n), isNotEmpty);
      }
      for (final v in TaskFilter.values) {
        expect(v.label(l10n), isNotEmpty);
      }
      for (final v in TaskFeedback.values) {
        expect(v.message(l10n), isNotEmpty);
      }
    }
    expect(TaskCategory.study.label(pt), 'Estudos');
    expect(TaskPriority.high.label(pt), 'Alta');
    expect(TaskFilter.overdue.label(en), 'Overdue');
  });

  test('os erros do domínio são traduzidos', () {
    const required = ValidationException(ValidationError.titleRequired);
    expect(required.localizedMessage(en), 'Title is required.');
    expect(required.localizedMessage(pt), 'O título é obrigatório.');

    expect(
      const ValidationException(
        ValidationError.titleTooLong,
      ).localizedMessage(pt),
      'O título deve ter no máximo 80 caracteres.',
    );
    expect(
      const TaskNotFoundException(3).localizedMessage(en),
      'Task not found. It may have been deleted.',
    );
    expect(
      const StorageException().localizedMessage(pt),
      'Não foi possível acessar o armazenamento local.',
    );
    for (final error in ValidationError.values) {
      expect(ValidationException(error).localizedMessage(pt), isNotEmpty);
    }
  });

  test('as regras de plural funcionam nos dois idiomas', () {
    expect(en.completionSummary(1, 4, 0), '1 of 4 done · no favorites');
    expect(en.completionSummary(2, 4, 3), '2 of 4 done · 3 favorites');
    expect(pt.completionSummary(2, 4, 1), '2 de 4 concluídas · 1 favorito');
  });

  test('datas e porcentagens seguem o idioma', () {
    final date = DateTime(2026, 11, 9, 14, 30);
    expect(Formatters.date(date, en.localeName), 'Nov 9, 2026');
    expect(Formatters.date(date, pt.localeName), '9 de nov. de 2026');
    expect(Formatters.dateTime(date, pt.localeName), contains('14:30'));
    expect(Formatters.percent(0.4, en.localeName), '40%');
  });
}
