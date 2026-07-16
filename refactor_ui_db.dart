import 'dart:io';

void main() {
  final dir = Directory('lib/ui');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    var content = file.readAsStringSync();
    bool changed = false;

    // Check for DBHelper import
    if (content.contains('db_helper.dart')) {
      content = content.replaceAll('db_helper.dart', 'database_service.dart');
      changed = true;
    }

    // Check for DBHelper usage
    if (content.contains('DBHelper.')) {
      content = content.replaceAll('DBHelper.', 'context.read<DatabaseService>().');
      
      // Ensure provider is imported
      if (!content.contains("import 'package:provider/provider.dart';")) {
        // Insert it after the first import
        final lines = content.split('\n');
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('import ')) {
            lines.insert(i + 1, "import 'package:provider/provider.dart';");
            break;
          }
        }
        content = lines.join('\n');
      }
      changed = true;
    }
    
    // Fix GoogleDriveService in backup_restore_screen
    if (file.path.contains('backup_restore_screen.dart')) {
        if (content.contains('final GoogleDriveService _driveService = GoogleDriveService();')) {
            content = content.replaceAll(
                'final GoogleDriveService _driveService = GoogleDriveService();',
                'late final GoogleDriveService _driveService;'
            );
            content = content.replaceAll(
                '  void initState() {\n    super.initState();',
                '  void initState() {\n    super.initState();\n    _driveService = GoogleDriveService(context.read<DatabaseService>());'
            );
            changed = true;
        }
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Updated \${file.path}');
    }
  }
}
