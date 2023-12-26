import 'dart:io';
import 'package:path/path.dart';

import 'global.dart';
import 'table_language.dart';

Future<String> bash(String command) async {
  var process = await Process.run('bash', ['-c', command]);
  return process.stdout.toString().trim();
}

Future<String> createFolder(String folder) async {
  var fullPath = join(path!, folder);
  try {
    if (!await Directory(fullPath).exists()) {
      await Directory(fullPath).create(recursive: true);
      log.fine('CREATED␟$folder␟$fullPath');
      return fullPath;
    } else {
      return fullPath;
    }
  } catch (e) {
    log.severe('FAILED␟$folder␟$fullPath');
    throw Exception('Error creating folder: $e');
  }
}

Future<List<File>> listFiles(String folder, String prefix, String ext) async {
  var fullPath = join(path!, folder);
  var files = await Directory(fullPath).list().toList();
  var filter = files.where((file) {
    if (file is File) {
      var fileName = file.uri.pathSegments.last;
      return fileName.startsWith(prefix) && fileName.endsWith('.$ext');
    }
    return false;
  }).toList();
  return filter.cast<File>();
}

Future<Map<String, int>> getLangtagIds() async {
  var dbLanguages = await Language.all();
  Map<String, int> result = {};
  for (var dbLang in dbLanguages) {
    result[dbLang['tag']] = dbLang['id'];
  }
  return result;
}
