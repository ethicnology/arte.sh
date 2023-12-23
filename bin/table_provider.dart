import 'arte.dart';

class Provider {
  static const table = 'provider';

  static Future<Map<String, dynamic>> get(String label) async {
    final thing = await supabase.from(table).select().eq('label', label);
    log.info('$label␟$table␟${thing.first['id']}');
    return thing.first;
  }
}
