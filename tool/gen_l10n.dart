
import 'dart:io';

const _generatedDir = 'lib/core/l10n/generated';

Future<void> main() async {
  final pubspec = File('pubspec.yaml');
  final original = pubspec.readAsStringSync();

  try {
    pubspec.writeAsStringSync(
      original.replaceFirst(
        'uses-material-design: true',
        'uses-material-design: true\n  generate: true',
      ),
    );
    final gen = await Process.run('flutter', [
      'gen-l10n',
      '--arb-dir=lib/core/l10n/arb',
      '--template-arb-file=app_en.arb',
      '--output-dir=$_generatedDir',
      '--output-localization-file=app_localizations.dart',
      '--output-class=AppLocalizations',
      '--no-nullable-getter',
    ], runInShell: true);
    stdout.write(gen.stdout);
    stderr.write(gen.stderr);
    if (gen.exitCode != 0) exitCode = gen.exitCode;
  } finally {
    pubspec.writeAsStringSync(original);
  }
  if (exitCode != 0) return;

  for (final file in Directory(_generatedDir).listSync().whereType<File>()) {
    if (file.path.endsWith('.dart')) _stripComments(file);
  }
  await Process.run('dart', ['format', _generatedDir], runInShell: true);
  stdout.writeln('Localizations generated without comments.');
}

void _stripComments(File file) {
  final out = <String>[];
  for (final line in file.readAsLinesSync()) {
    if (line.trimLeft().startsWith('//')) continue;
  
    if (line.trim().isEmpty && out.isNotEmpty && out.last.trim().isEmpty) {
      continue;
    }
    out.add(line);
  }
  file.writeAsStringSync('${out.join('\n')}\n');
}
