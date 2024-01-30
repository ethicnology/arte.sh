import 'package:supabase/supabase.dart';

import '../global.dart';

class Availability {
  static const table = 'availability';
  int idThing;
  DateTime start;
  DateTime stop;

  Availability(
      {required this.idThing, required this.start, required this.stop});

  Future<bool> insert() async {
    try {
      var insert = await supabase.from(table).insert({
        'id_thing': idThing,
        'start': start.toIso8601String(),
        'stop': stop.toIso8601String(),
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
