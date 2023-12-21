import 'dart:convert';

import 'package:http/http.dart';

import 'arte.dart';

Future<List<String>> getCinemaCatalog() async {
  try {
    var subCategory = Uri.https(
        'www.arte.tv', '/api/rproxy/emac/v4/fr/web/pages/SUBCATEGORY_FLM');

    await Future.delayed(Duration(seconds: 2));
    var response = await get(subCategory);

    if (response.statusCode != 200) throw Exception('${response.statusCode}');
    var firstReq = json.decode(response.body);

    var zones = firstReq['value']['zones'][0];
    String id = zones['id'].split('_')[0];
    int total = zones['content']['pagination']['totalCount'];

    var catalog = <String>{};
    var fetch = true;
    var index = 0;
    while (fetch) {
      var moreFilms = Uri.parse(
          'https://www.arte.tv/api/rproxy/emac/v4/fr/web/zones/$id/content?page=$index&pageId=SUBCATEGORY_FLM');

      await Future.delayed(Duration(seconds: 2));
      var res = await get(moreFilms);

      if (res.statusCode != 200) throw Exception('${res.statusCode}');
      var iterativeReq = json.decode(res.body);

      var data = iterativeReq['value']['data'];
      for (var element in data) {
        String? idArte = element['programId'];
        if (idArte != null) catalog.add(idArte);
      }

      index += 1;
      fetch = iterativeReq['value']['data'].isNotEmpty;
    }
    if (catalog.length == total) {
      log.info('$total␟films␟catalog');
    } else {
      log.severe('${total - catalog.length}␟films␟missing from catalog');
    }
    return catalog.toList();
  } catch (e) {
    log.severe('collect␟films␟catalog␟${e.toString()}');
    throw Exception();
  }
}
