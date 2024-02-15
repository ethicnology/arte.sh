import 'package:supabase/supabase.dart';

import '../global.dart';

class Language {
  static const table = 'language';
  String tag;

  Language({required this.tag});

  Future<int> insert() async {
    try {
      var insert = await supabase
          .from(table)
          .insert({'tag': tag.toLowerCase()}).select();
      log.fine('$table␟$tag␟${insert.first['id']}');
      return insert.first['id'];
    } catch (e) {
      var error = e;
      e is PostgrestException && e.details != null ? error = e.details! : null;
      log.warning('$table␟$tag␟${error.toString()}');
      return -1;
    }
  }

  static Future<List<Map<String, dynamic>>> all() async {
    var select = await supabase.from(table).select();
    log.info('FETCH␟${select.length}␟$table');
    return select;
  }

  static Future<int> getId(String tag) async {
    final select = await supabase.from(table).select('id').eq('tag', tag);
    log.info('${select.first['id']}␟$table␟$tag');
    return select.first['id'];
  }
}
