import 'dart:io';

void main() {
  final file = File('lib/data/database_service.dart');
  var content = file.readAsStringSync();

  // Rename class
  content = content.replaceAll('class DBHelper {', 'class DatabaseService {');

  // Convert static variables and methods to instance variables/methods, except 'static const'
  // Actually, we can just replace 'static ' with '' if it is followed by a type like 'Future' or 'Database?'
  content = content.replaceAll('static Database?', 'Database?');
  content = content.replaceAll('static Future', 'Future');
  
  // What about static non-async methods? E.g. 'static void', 'static int'? 
  // Most methods in DB helper are 'static Future' so the above handles 95%. Let's also check for other statics.
  content = content.replaceAll('static String', 'String');
  content = content.replaceAll('static int', 'int');
  content = content.replaceAll('static double', 'double');
  content = content.replaceAll('static bool', 'bool');
  content = content.replaceAll('static List', 'List');
  content = content.replaceAll('static void', 'void');

  file.writeAsStringSync(content);
  print('Updated database_service.dart');
}
