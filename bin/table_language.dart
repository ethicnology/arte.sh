import 'global.dart';

class Language {
  static const table = 'language';

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
