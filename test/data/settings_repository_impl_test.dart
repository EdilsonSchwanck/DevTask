import 'package:devtask/data/repositories/settings_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SettingsRepositoryImpl> build([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SettingsRepositoryImpl(await SharedPreferences.getInstance());
  }

  test('sem nada salvo, idioma e tema são null', () async {
    final settings = await build();
    expect(settings.languageCode, isNull);
    expect(settings.darkMode, isNull);
  });

  test('salva e lê o idioma', () async {
    final settings = await build();
    await settings.saveLanguageCode('pt_BR');

    expect(settings.languageCode, 'pt_BR');
    final reopened = SettingsRepositoryImpl(
      await SharedPreferences.getInstance(),
    );
    expect(reopened.languageCode, 'pt_BR');
  });

  test('salvar null remove o idioma', () async {
    final settings = await build({'settings.language': 'en_US'});
    await settings.saveLanguageCode(null);
    expect(settings.languageCode, isNull);
  });

  test('salva e lê o tema', () async {
    final settings = await build();
    await settings.saveDarkMode(true);
    expect(settings.darkMode, isTrue);
  });
}
