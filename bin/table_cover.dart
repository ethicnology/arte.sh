import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'global.dart';

class Cover {
  static const table = 'arte_cover';
  int idThing;
  bool withText;
  String file; // base64

  Cover._({required this.idThing, required this.withText, required this.file});

  static Future<Cover> download(
      {required int idThing, required Uri url, required bool withText}) async {
    try {
      if (withText) url = url.replace(queryParameters: {'type': 'TEXT'});
      final response = await get(url);
      if (response.statusCode == 200) {
        var bytes = response.bodyBytes;
        return Cover._(
          idThing: idThing,
          withText: url.toString().contains('TEXT'),
          file: base64.encode(bytes),
        );
      } else {
        log.severe('cover␟${response.statusCode}');
        throw Exception();
      }
    } catch (e) {
      log.severe('cover␟${e.toString()}');
      throw Exception();
    }
  }

  Future<bool> insert() async {
    try {
      var insert = await supabase.from(table).upsert(
        {'id_thing': idThing, 'with_text': withText, 'file': file},
      ).select();
      log.fine('$idThing␟$table␟${insert.first['id']}');
      return true;
    } catch (e) {
      log.warning('$idThing␟$table␟${e.toString()}');
      return false;
    }
  }

  Future<File> toFile(String filename) async {
    return await File('$covers/$filename').writeAsBytes(base64.decode(file));
  }
}
