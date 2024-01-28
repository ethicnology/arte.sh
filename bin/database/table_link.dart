import 'package:supabase/supabase.dart';

import '../global.dart';

class Link {
  static const table = 'link';

  int idParent;
  int idChild;
  Link({required this.idParent, required this.idChild});

  Future<bool> insert() async {
    try {
      var insert = await supabase
          .from(table)
          .insert({'id_parent': idParent, 'id_child': idChild}).select();
      log.fine('$idParent␟$table␟$idChild␟${insert.first['id']}');
      return true;
    } catch (e) {
      var error = e;
      e is PostgrestException && e.details != null ? error = e.details! : null;
      log.warning('$idParent␟$table␟$idChild␟${error.toString()}');
      return false;
    }
  }
}
