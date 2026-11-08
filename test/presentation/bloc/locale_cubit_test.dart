import 'package:bloc_test/bloc_test.dart';
import 'package:devtask/presentation/bloc/locale/locale_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/in_memory_settings_repository.dart';

void main() {
  test('segue o idioma do aparelho quando nada foi salvo', () {
    final cubit = LocaleCubit(InMemorySettingsRepository());
    expect(cubit.state, AppLanguage.system);
    expect(cubit.state.locale, isNull);
  });

  test('abre com o idioma que estava salvo', () {
    final cubit = LocaleCubit(
      InMemorySettingsRepository(languageCode: 'pt_BR'),
    );
    expect(cubit.state, AppLanguage.portugueseBrazil);
  });

  test('código desconhecido volta para o idioma do aparelho', () {
    final cubit = LocaleCubit(InMemorySettingsRepository(languageCode: 'xx'));
    expect(cubit.state, AppLanguage.system);
  });

  late InMemorySettingsRepository settings;

  blocTest<LocaleCubit, AppLanguage>(
    'select emite e salva o idioma escolhido',
    setUp: () => settings = InMemorySettingsRepository(),
    build: () => LocaleCubit(settings),
    act: (cubit) => cubit.select(AppLanguage.portugueseBrazil),
    expect: () => [AppLanguage.portugueseBrazil],
    verify: (_) => expect(settings.languageCode, 'pt_BR'),
  );

  blocTest<LocaleCubit, AppLanguage>(
    'voltar para o padrão do sistema apaga o idioma salvo',
    setUp: () => settings = InMemorySettingsRepository(languageCode: 'en_US'),
    build: () => LocaleCubit(settings),
    act: (cubit) => cubit.select(AppLanguage.system),
    expect: () => [AppLanguage.system],
    verify: (_) => expect(settings.languageCode, isNull),
  );

  test('associa os idiomas aos locales pt-BR e en-US', () {
    expect(AppLanguage.portugueseBrazil.locale, const Locale('pt', 'BR'));
    expect(AppLanguage.englishUs.locale, const Locale('en', 'US'));
  });
}
