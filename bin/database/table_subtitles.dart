import 'package:supabase/supabase.dart';

import '../global.dart';

class Subtitles {
  static const table = 'subtitles';
  int idThing;
  int idProvider;
  int idLang;
  String file;
  String ext;
  bool? isClosedCaptions;

  Subtitles({
    required this.idThing,
    required this.idProvider,
    required this.idLang,
    required this.file,
    required this.ext,
    this.isClosedCaptions,
  });

  static Future<PostgrestList> getNullClosedCaptions(
    int idThing,
    int idLang,
  ) async {
    final subtitles = await supabase
        .from(table)
        .select('id')
        .eq('id_thing', idThing)
        .eq('id_lang', idLang)
        .isFilter('is_closed_captions', null);
    log.info(
        '$idThing␟$table␟${subtitles.length}␟null_closed_captions␟lang:$idLang');
    return subtitles;
  }

  static Future<PostgrestList> get(int idThing, int idLang) async {
    final subtitles = await supabase
        .from(table)
        .select()
        .eq('id_thing', idThing)
        .eq('id_lang', idLang);
    log.info('$idThing␟$table␟${subtitles.length}␟lang:$idLang');
    return subtitles;
  }

  Future<bool> upsert({int? id}) async {
    var data = {
      'id_thing': idThing,
      'id_provider': idProvider,
      'id_lang': idLang,
      'file': file,
      'ext': ext,
      'is_closed_captions': isClosedCaptions
    };
    var op = 'insert';
    if (id != null) data['id'] = id;
    if (id != null) op = 'update';
    try {
      var upsert = await supabase.from(table).upsert(data).select();
      log.fine('$idThing␟$table␟${upsert.first['id']}␟$op');
      return true;
    } catch (e) {
      var error = e;
      e is PostgrestException && e.details != null ? error = e.details! : null;
      log.warning('$idThing␟$table␟${error.toString()}');
      return false;
    }
  }
}
