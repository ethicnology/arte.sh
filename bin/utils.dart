import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:path/path.dart';

import 'global.dart';
import 'table_language.dart';

Future<Map<String, dynamic>> retryUntilGet(Uri url) async {
  await Future.delayed(Duration(seconds: 2));

  var ip = ips[random.nextInt(ips.length)]; // bypass geoblocking

  var response = await get(url, headers: {'X-Forwarded-For': ip});

  var code = response.statusCode;
  while (code == 429) {
    int sleep = 10;
    log.warning('RATE LIMIT␟SLEEP␟$sleep␟seconds');

    await Future.delayed(Duration(seconds: sleep));
    response = await get(url);
    code = response.statusCode;
  }
  if (code == 200) return json.decode(response.body);

  throw Exception('code: $code');
}

Future<List> pagination(int pages, int total, String firstLink) async {
  var firstUri = Uri.parse(firstLink
      .replaceAll('api-internal', 'www')
      .replaceAll('api/emac', 'api/rproxy/emac'));
  var params = Map<String, String>.from(firstUri.queryParameters);

  var data = [];
  for (var p = 1; p <= pages; p++) {
    params['page'] = p.toString();
    var url = firstUri.replace(queryParameters: params);
    var response = await retryUntilGet(url);
    data.addAll(response['value']['data']);
  }

  if (data.length != total) throw Exception('${data.length} / $total');
  return data;
}

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
