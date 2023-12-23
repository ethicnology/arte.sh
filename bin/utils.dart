import 'dart:io';
import 'package:path/path.dart' as path;

const appData = 'arte_data';

Future<String> bash(String command) async {
  var process = await Process.run('bash', ['-c', command]);
  return process.stdout.toString().trim();
}

Future<String> createFolder(String folder) async {
  var fullPath = path.join(Directory.current.path, appData, folder);
  try {
    if (!await Directory(fullPath).exists()) {
      await Directory(fullPath).create(recursive: true);
      print('created: $fullPath');
      return fullPath;
    } else {
      print('exists: $fullPath');
      return fullPath;
    }
  } catch (e) {
    throw Exception('Error creating folder: $e');
  }
}

Future<List<File>> listFiles(String folder, String prefix, String ext) async {
  var fullPath = path.join(Directory.current.path, appData, folder);
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
