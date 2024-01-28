import 'package:supabase/supabase.dart';

import '../global.dart';

class Description {
  static const table = 'arte_description';
  int idThing;
  int idLang;
  String? subtitle;
  String? description;
  String? fullDescription;

  Description({
    required this.idThing,
    required this.idLang,
    this.subtitle,
    this.description,
    this.fullDescription,
  });

  Future<bool> updateFullDescription() async {
    if (fullDescription != null) {
      try {
        var update = await supabase
            .from(table)
            .update({'full_description': fullDescription})
            .eq('id_thing', idThing)
            .eq('id_lang', idLang)
            .select();

        log.fine('$idThing␟$table␟${update.first['id']}');
        return true;
      } catch (e) {
        var error = e;
        e is PostgrestException && e.details != null ? error = e.details! : {};
        log.warning('$idThing␟$table␟${error.toString()}');
        return false;
      }
    }
    return false;
  }

  Future<bool> insert() async {
    if (subtitle != null || description != null || fullDescription != null) {
      try {
        var insert = await supabase.from(table).insert({
          'id_thing': idThing,
          'id_lang': idLang,
          'subtitle': subtitle,
          'description': description,
          'full_description': fullDescription,
        }).select();

        log.fine('$idThing␟$table␟${insert.first['id']}');
        return true;
      } catch (e) {
        var error = e;
        e is PostgrestException && e.details != null ? error = e.details! : {};
        log.warning('$idThing␟$table␟${error.toString()}');
        return false;
      }
    } else {
      log.warning('$idThing␟$table␟NULL values');
      return false;
    }
  }
}
