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
      log.warning('$idParent␟$table␟$idChild␟${e.toString()}');
      return false;
    }
  }
}
