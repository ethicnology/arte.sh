import 'global.dart';

class Description {
  static const table = 'arte_description';
  int idThing;
  String lang;
  String? subtitle;
  String? description;
  String? fullDescription;

  Description({
    required this.idThing,
    required this.lang,
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
            .eq('lang', lang)
            .select();

        log.fine('$idThing␟$table␟${update.first['id']}');
        return true;
      } catch (e) {
        log.warning('$idThing␟$table␟${e.toString()}');
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
          'lang': lang,
          'subtitle': subtitle,
          'description': description,
          'full_description': fullDescription,
        }).select();

        log.fine('$idThing␟$table␟${insert.first['id']}');
        return true;
      } catch (e) {
        log.warning('$idThing␟$table␟${e.toString()}');
        return false;
      }
    } else {
      log.warning('$idThing␟$table␟NULL values');
      return false;
    }
  }
}
