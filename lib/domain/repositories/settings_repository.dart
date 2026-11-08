/// Preferências do usuário que precisam sobreviver ao fechar o app.
///
/// As leituras são síncronas porque os valores são carregados uma vez na
/// inicialização. Assim o app já abre com o idioma e o tema certos.
abstract interface class SettingsRepository {
  /// Código do idioma salvo (`pt_BR`, `en_US`) ou `null` para seguir o aparelho.
  String? get languageCode;

  Future<void> saveLanguageCode(String? code);

  /// `null` quando o usuário nunca escolheu um tema.
  bool? get darkMode;

  Future<void> saveDarkMode(bool darkMode);
}
