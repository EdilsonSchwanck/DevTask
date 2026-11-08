import 'package:devtask/domain/repositories/settings_repository.dart';

/// Preferências em memória para os testes.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository({this.languageCode, this.darkMode});

  @override
  String? languageCode;

  @override
  bool? darkMode;

  @override
  Future<void> saveLanguageCode(String? code) async => languageCode = code;

  @override
  Future<void> saveDarkMode(bool darkMode) async => this.darkMode = darkMode;
}
