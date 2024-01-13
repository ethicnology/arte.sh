import 'global.dart';

class Rpc {
  static Future<Set<({BigInt id, String arte})>>
      getLast10DaysThingsWithZeroSubtitles() async {
    const function = 'get_last_10_days_things_with_zero_subtitles';
    try {
      final response = await supabase.rpc(function);
      var result = <({BigInt id, String arte})>{};
      for (dynamic item in response as List<dynamic>) {
        result.add((id: BigInt.from(item['id']), arte: item['arte']));
      }
      log.info('RPC␟$function␟${result.length}␟ids');
      return result;
    } catch (e) {
      log.severe('RPC␟$function␟${e.toString()}');
      throw Exception();
    }
  }
}
