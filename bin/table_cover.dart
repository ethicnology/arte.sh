import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'global.dart';

class Cover {
  static const table = 'cover';
  int idThing;
  int idLang;
  String file; // base64

  Cover._({required this.idThing, required this.idLang, required this.file});

  static Future<Cover> download({
    required int idThing,
    required String lang,
    required bool withText,
    required Uri url,
  }) async {
    try {
      if (withText) url = url.replace(queryParameters: {'type': 'TEXT'});
      var fhd = url.path.replaceFirst(RegExp(r'\d{2,4}x\d{2,4}'), '1920x1080');
      url = url.replace(path: fhd);

      final response = await get(url);
      if (response.statusCode == 200) {
        var bytes = response.bodyBytes;
        return Cover._(
          idThing: idThing,
          idLang: withText ? langtags[lang]! : langtags['und']!,
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
        {'id_thing': idThing, 'id_lang': idLang, 'file': file},
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
