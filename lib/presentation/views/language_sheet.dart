import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/locale/locale_cubit.dart';
import '../l10n/l10n.dart';

extension on AppLanguage {
  String get flag => switch (this) {
    AppLanguage.system => '🌐',
    AppLanguage.portugueseBrazil => '🇧🇷',
    AppLanguage.englishUs => '🇺🇸',
  };

  String title(AppLocalizations l10n) => switch (this) {
    AppLanguage.system => l10n.languageSystem,
    AppLanguage.portugueseBrazil => l10n.languagePortuguese,
    AppLanguage.englishUs => l10n.languageEnglish,
  };

  String subtitle(AppLocalizations l10n) => switch (this) {
    AppLanguage.system => l10n.languageSystemSubtitle,
    AppLanguage.portugueseBrazil => 'pt-BR',
    AppLanguage.englishUs => 'en-US',
  };
}

/// AppBar pill showing the active language (flag + code). Opens [LanguageSheet].
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    // Shows the language actually in use, even when following the system.
    final code = Localizations.localeOf(context).languageCode;
    final flag = code == 'pt' ? '🇧🇷' : '🇺🇸';

    return Tooltip(
      message: l10n.language,
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        shape: const StadiumBorder(),
        child: InkWell(
          key: const Key('language-menu'),
          customBorder: const StadiumBorder(),
          onTap: () => showLanguageSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  code.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showLanguageSheet(BuildContext context) {
  final cubit = context.read<LocaleCubit>();
  return showModalBottomSheet<void>(
    context: context,
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const LanguageSheet()),
  );
}

class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final selected = context.watch<LocaleCubit>().state;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.language, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              l10n.languageSheetSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            for (final language in AppLanguage.values) ...[
              _LanguageOption(
                language: language,
                selected: language == selected,
                onTap: () {
                  context.read<LocaleCubit>().select(language);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: selected
            ? scheme.primary.withValues(alpha: 0.08)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? scheme.primary : Colors.transparent,
          width: 1.6,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: Key('language-${language.name}'),
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.title(l10n),
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        language.subtitle(l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(selected),
                    color: selected ? scheme.primary : scheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
