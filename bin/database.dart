import 'arte.dart';

Future<int> getOrInsertIdThing(int typeId, String arteId) async {
  const table = 'thing';
  final thing = await supabase.from(table).select().eq('arte', arteId);
  if (thing.isNotEmpty) {
    log.info('$arteId␟$table␟${thing.first['id']}');
    return thing.first['id'];
  } else {
    final newThing = await supabase
        .from('thing')
        .insert({'id_type': typeId, 'arte': arteId}).select();
    log.fine('$arteId␟$table␟${newThing.first['id']}');
    return newThing.first['id'];
  }
}

Future<int> getIdType(String label) async {
  final types = await supabase.from('type').select();
  for (final item in types) {
    if (item['label'] == label) {
      return item['id'];
    }
  }
  throw Exception('$label not found');
}
