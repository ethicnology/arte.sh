import 'arte.dart';

class Thing {
  static const table = 'thing';

  static Future<Map<String, dynamic>> get(String arteId) async {
    final thing = await supabase.from(table).select().eq('arte', arteId);
    log.info('$arteId␟$table␟${thing.first['id']}');
    return thing.first;
  }
}
