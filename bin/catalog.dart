import 'global.dart';
import 'arte_program.dart';
import 'utils.dart';

Future<List<ArteProgram>> scrapCatalog(String path) async {
  try {
    var url =
        Uri.https('www.arte.tv', '/api/rproxy/emac/v4/fr/web/pages/$path');

    var response = await retryUntilGet(url);
    var zones = response['value']['zones'];

    List<ArteProgram> catalog = [];
    for (var zone in zones) {
      var pagination = zone['content']['pagination'];

      var programs = <ArteProgram>[];
      if (pagination != null) {
        var total = pagination['totalCount'];
        programs = await paginate(pagination);
        if (programs.length != total) {
          throw Exception('${programs.length}/$total');
        }
      } else {
        programs = List<Map<String, dynamic>>.from(zone['content']['data'])
            .expand((e) => [ArteProgram.fromJson(e)])
            .toList();
      }
      catalog.addAll(programs);
    }
    log.info('FOUND␟${catalog.length}␟$path');
    return catalog;
  } catch (e) {
    log.severe('SCRAP␟$path␟${e.toString()}');
    throw Exception();
  }
}

Future<Set<String>> scrapCatalogIds(String path) async {
  var catalog = await scrapCatalog(path);
  var ids = <String>{};
  for (var e in catalog) {
    if (e.programId != null) ids.add(e.programId!);
  }
  log.info('DEDUP␟${ids.length}␟$path');
  return ids;
}
