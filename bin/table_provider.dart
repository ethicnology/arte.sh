import 'global.dart';

class Provider {
  static const table = 'provider';

  static Future<int> getId(String label) async {
    final thing = await supabase.from(table).select().eq('label', label);
    log.info('$label␟$table␟${thing.first['id']}');
    return thing.first['id'];
  }
}
