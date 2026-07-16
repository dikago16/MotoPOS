import 'dart:io';

void main() {
  final dir = Directory('d:/FLUTTER/motopos/lib/ui');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final targetColors = [
    'Navy', 'Accent', 'AccentSoft', 'BgPage', 'BgCard', 'Border', 'BorderMid',
    'TableHead', 'RowAlt', 'TxtHigh', 'TxtMid', 'TxtLow', 'Red', 'Green', 'Muted'
  ];

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    // 1. Remove ONLY the specific color definitions
    for (final color in targetColors) {
      final constDef = RegExp(r'const\s+_k' + color + r'\s*=\s*Color\(.*?\);\n?');
      if (constDef.hasMatch(content)) {
        content = content.replaceAll(constDef, '');
        modified = true;
      }
    }

    if (!modified) continue;

    print('Refactoring: ${file.path}');

    // 2. Replace _kName with AppColors.name ONLY for the target colors
    for (final color in targetColors) {
      final lowercaseName = color[0].toLowerCase() + color.substring(1);
      content = content.replaceAll('_k$color', 'AppColors.$lowercaseName');
    }

    // 3. Add import if missing
    if (!content.contains('app_colors.dart')) {
      final importString = "import '../../../core/constants/app_colors.dart';\n";
      final importMatches = RegExp(r"import\s+.*?;\n").allMatches(content);
      if (importMatches.isNotEmpty) {
        final lastMatch = importMatches.last;
        content = content.substring(0, lastMatch.end) + importString + content.substring(lastMatch.end);
      } else {
        content = importString + content;
      }
    }

    file.writeAsStringSync(content);
  }
}
