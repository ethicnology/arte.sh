import 'global.dart';

class Subtitles {
  static const table = 'subtitles';
  int idThing;
  int idProvider;
  int idLang;
  String file;
  String ext;

  Subtitles({
    required this.idThing,
    required this.idProvider,
    required this.idLang,
    required this.file,
    required this.ext,
  });

  Future<bool> insert() async {
    try {
      var insert = await supabase.from(table).insert({
        'id_thing': idThing,
        'id_provider': idProvider,
        'id_lang': idLang,
        'file': file,
        'ext': ext,
      }).select();
      log.fine('$idThing␟$table␟${insert.first['id']}');
      return true;
    } catch (e) {
      log.warning('$idThing␟$table␟${e.toString()}');
      return false;
    }
  }
}
