import 'package:bloc_test/bloc_test.dart';
import 'package:devtask/presentation/bloc/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/in_memory_settings_repository.dart';

void main() {
  test('começa no modo claro quando nada foi salvo', () {
    expect(ThemeCubit(InMemorySettingsRepository()).state, ThemeMode.light);
  });

  test('abre no modo escuro quando ele estava salvo', () {
    expect(
      ThemeCubit(InMemorySettingsRepository(darkMode: true)).state,
      ThemeMode.dark,
    );
  });

  late InMemorySettingsRepository settings;

  blocTest<ThemeCubit, ThemeMode>(
    'toggle alterna entre escuro e claro e salva a escolha',
    setUp: () => settings = InMemorySettingsRepository(),
    build: () => ThemeCubit(settings),
    act: (cubit) async {
      await cubit.toggle();
      expect(settings.darkMode, isTrue);
      await cubit.toggle();
    },
    expect: () => [ThemeMode.dark, ThemeMode.light],
    verify: (_) => expect(settings.darkMode, isFalse),
  );
}
