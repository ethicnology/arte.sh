import 'package:supabase/supabase.dart';

import '../global.dart';

class Title {
  static const table = 'title';
  int idThing;
  int idLang;
  String? label;
  bool? isOriginal;

  Title({
    required this.idThing,
    required this.idLang,
    this.label,
    this.isOriginal,
  });

  Future<bool> insert() async {
    try {
      var insert = await supabase.from(table).insert({
        'id_thing': idThing,
        'id_lang': idLang,
        'label': label,
        'is_original': isOriginal,
      }).select();
      log.fine('$idThing␟$table␟${insert.first['id']}');
      return true;
    } catch (e) {
      var error = e;
      e is PostgrestException && e.details != null ? error = e.details! : null;
      log.warning('$idThing␟$table␟${error.toString()}');
      return false;
    }
  }
}
