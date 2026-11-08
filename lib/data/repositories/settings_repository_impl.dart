import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _languageKey = 'settings.language';
  static const _darkModeKey = 'settings.dark_mode';

  @override
  String? get languageCode => _prefs.getString(_languageKey);

  @override
  Future<void> saveLanguageCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_languageKey);
    } else {
      await _prefs.setString(_languageKey, code);
    }
  }

  @override
  bool? get darkMode => _prefs.getBool(_darkModeKey);

  @override
  Future<void> saveDarkMode(bool darkMode) =>
      _prefs.setBool(_darkModeKey, darkMode);
}
