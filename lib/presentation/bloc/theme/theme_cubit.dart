import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/settings_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._settings)
    : super(_settings.darkMode == true ? ThemeMode.dark : ThemeMode.light);

  final SettingsRepository _settings;

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(next);
    await _settings.saveDarkMode(next == ThemeMode.dark);
  }
}
