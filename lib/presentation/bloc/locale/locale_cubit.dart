import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/settings_repository.dart';

/// Idiomas que o usuário pode escolher. [system] segue o idioma do aparelho
/// (e cai para inglês quando ele não é suportado).
enum AppLanguage {
  system(null, null),
  portugueseBrazil(Locale('pt', 'BR'), 'pt_BR'),
  englishUs(Locale('en', 'US'), 'en_US');

  const AppLanguage(this.locale, this.code);

  /// `null` deixa o `MaterialApp` decidir pelo idioma do aparelho.
  final Locale? locale;

  /// Valor salvo nas preferências.
  final String? code;

  static AppLanguage fromCode(String? code) => values.firstWhere(
    (l) => l.code == code,
    orElse: () => AppLanguage.system,
  );
}

class LocaleCubit extends Cubit<AppLanguage> {
  LocaleCubit(this._settings)
    : super(AppLanguage.fromCode(_settings.languageCode));

  final SettingsRepository _settings;

  Future<void> select(AppLanguage language) async {
    emit(language);
    await _settings.saveLanguageCode(language.code);
  }
}
