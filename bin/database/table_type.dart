import '../global.dart';

class Type {
  static const table = 'type';

  static Future<int> getId(String label) async {
    final select = await supabase.from(table).select('id').eq('label', label);
    log.info('${select.first['id']}␟$table␟$label');
    return select.first['id'];
  }
}
