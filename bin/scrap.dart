import 'global.dart';
import 'utils.dart';

Future<Map<String, dynamic>?> scrap(
  int idThing,
  String lang,
  String idArte,
) async {
  try {
    var api = await _scrapApi(idThing, lang, idArte);
    var www = await _scrapWww(idThing, lang, idArte);
    if (api['duration'] == null) throw Exception();
    return {
      'id_thing': idThing,
      'id_arte': idArte,
      'lang': lang,
      'id_lang': langtags[lang],
      ...api,
      ...www
    };
  } catch (e) {
    log.severe('SCRAP␟$idThing␟$lang␟$idArte');
    return null;
  }
}

Future<Map<String, dynamic>> _scrapApi(
  int idThing,
  String lang,
  String idArte,
) async {
  var apiUrl = Uri.https('api.arte.tv', '/api/player/v2/config/$lang/$idArte');
  var apiRes = await retryUntilGet(apiUrl);

  Map<String, dynamic> apiMeta = apiRes['data']['attributes']['metadata'];
  String? apiDescription = apiMeta['description'];
  String? apiTitle = apiMeta['title'];
  String? apiSubTitle = apiMeta['subtitle'];
  int? apiSeconds = apiMeta['duration']['seconds'];
  String? apiProviderId = apiMeta['providerId'];
  String? lowCover = apiMeta['images'][0]['url'];

  return {
    'title': apiTitle,
    'subtitle': apiSubTitle,
    'description': apiDescription,
    'duration': apiSeconds,
    'provider_id': apiProviderId,
    'cover_low': lowCover,
    'stream': apiRes['data']['attributes']['streams'][0]['url']
  };
}

Future<Map<String, dynamic>> _scrapWww(
    int idThing, String lang, String idArte) async {
  var wwwUrl = Uri.https(
      'www.arte.tv', '/api/rproxy/emac/v4/$lang/web/programs/$idArte');
  var wwwRes = await retryUntilGet(wwwUrl);
  String? highCover = wwwRes['value']['metadata']['og']['image']['url'];

  Map<String, String> titles = {};
  List<dynamic> languages = wwwRes['value']['alternativeLanguages'];

  for (var lang in languages) titles[lang['code']] = lang['title'];

  List<int>? years = [];
  List<String>? actors = [];
  List<String>? authors = [];
  List<String>? directors = [];
  List<String>? countries = [];
  List<String>? productors = [];

  String? fullDescription;
  List<dynamic> zones = wwwRes['value']['zones'];
  for (var item in zones) {
    List<dynamic> contentData = item['content']['data'];
    for (var element in contentData) {
      if (element.containsKey('fullDescription')) {
        fullDescription = element['fullDescription'];
      }

      if (element.containsKey('credits')) {
        List<dynamic> credits = element['credits'];
        for (var credit in credits) {
          switch (credit['code']) {
            case 'PRODUCTION_YEAR':
              years.addAll(
                  credit['values'].map<int>((value) => int.parse(value)));
              break;
            case 'ACT':
              actors.addAll(
                  credit['values'].map<String>((value) => value.toString()));
              break;
            case 'AUT':
              authors.addAll(
                  credit['values'].map<String>((value) => value.toString()));
              break;
            case 'REA':
              directors.addAll(
                  credit['values'].map<String>((value) => value.toString()));
              break;
            case 'PRD':
              productors.addAll(
                  credit['values'].map<String>((value) => value.toString()));
              break;
            case 'COUNTRY':
              countries.addAll(
                  credit['values'].map<String>((value) => value.toString()));
              break;
            default:
              break;
          }
        }
      }
    }
  }

  return {
    'years': years,
    'actors': actors,
    'authors': authors,
    'countries': countries,
    'directors': directors,
    'productors': productors,
    'cover_high': highCover,
    'full_description': fullDescription,
  };
}

Future<List<String>> scrapFilmsIds() async {
  try {
    var url = Uri.https(
        'www.arte.tv', '/api/rproxy/emac/v4/fr/web/pages/SUBCATEGORY_FLM');
    var response = await retryUntilGet(url);
    var zones = response['value']['zones'][0];
    String id = zones['id'].split('_')[0];
    int total = zones['content']['pagination']['totalCount'];

    var catalog = <String>{};
    var fetch = true;
    var index = 0;
    while (fetch) {
      var more = Uri.https(
        'www.arte.tv',
        '/api/rproxy/emac/v4/fr/web/zones/$id/content',
        {'page': '$index'},
      );
      var response = await retryUntilGet(more);

      var data = response['value']['data'];
      for (var element in data) {
        String? idArte = element['programId'];
        if (idArte != null) catalog.add(idArte);
      }

      index += 1;
      fetch = data.isNotEmpty;
    }
    if (catalog.length == total) {
      log.info('SCRAP␟$total␟films␟ids from catalog');
    } else {
      log.severe('${total - catalog.length}␟films␟missing from catalog');
    }
    return catalog.toList();
  } catch (e) {
    log.severe('SCRAP␟films␟catalog␟${e.toString()}');
    throw Exception();
  }
}
