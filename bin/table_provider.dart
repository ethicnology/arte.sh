import 'global.dart';

class Provider {
  static const table = 'provider';

  static Future<int> getId(String label) async {
    final select = await supabase.from(table).select().eq('label', label);
    log.info('$label␟$table␟${select.first['id']}');
    return select.first['id'];
  }
}
