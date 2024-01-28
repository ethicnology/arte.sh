import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:supabase/supabase.dart';

import '../global.dart';

class DataFile {
  static const table = 'file';
  String hash;
  String data;

  DataFile._({required this.hash, required this.data});

  static Future<DataFile> download({required Uri url}) async {
    try {
      final response = await get(url);
      if (response.statusCode == 200) {
        var bytes = response.bodyBytes;
        return DataFile._(
          hash: sha256.convert(bytes).toString(),
          data: base64.encode(bytes),
        );
      } else {
        log.severe('file␟${response.statusCode}');
        throw Exception();
      }
    } catch (e) {
      log.severe('file␟${e.toString()}');
      throw Exception();
    }
  }

  Future<bool> insert() async {
    try {
      var insert = await supabase
          .from(table)
          .insert({'hash': hash, 'data': data}).select();
      log.fine('${insert.first['id']}␟$table␟$hash');
      return true;
    } catch (e) {
      var error = e;
      e is PostgrestException && e.details != null ? error = e.details! : null;
      log.warning('$hash␟$table␟${error.toString()}');
      return false;
    }
  }

  Future<File> save(String folder, String filename) async {
    return await File('$folder/$filename').writeAsBytes(base64.decode(data));
  }
}
