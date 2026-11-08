import 'package:devtask/presentation/l10n/l10n.dart';
import 'package:flutter/material.dart';

const kLocalizationsDelegates = AppLocalizations.localizationsDelegates;
const kSupportedLocales = AppLocalizations.supportedLocales;

Widget localizedApp({
  required Widget home,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: kLocalizationsDelegates,
    supportedLocales: kSupportedLocales,
    home: home,
  );
}
