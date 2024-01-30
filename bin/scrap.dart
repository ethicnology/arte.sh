import 'global.dart';
import 'playlist_response.dart';
import 'utils.dart';

Future<Map<String, dynamic>?> scrap(
  int idThing,
  String lang,
  String idArte,
) async {
  try {
    var api = await scrapApi(lang, idArte);
    var www = await scrapWww(lang, idArte);
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

Future<Map<String, dynamic>> scrapApi(String lang, String idArte) async {
  var apiUrl = Uri.https('api.arte.tv', '/api/player/v2/config/$lang/$idArte');
  var apiRes = await retryUntilGet(apiUrl);

  Map<String, dynamic> apiMeta = apiRes['data']['attributes']['metadata'];
  Map<String, dynamic> apiRights = apiRes['data']['attributes']['rights'];

  String? apiDescription = apiMeta['description'];
  String? apiTitle = apiMeta['title'];
  String? apiSubTitle = apiMeta['subtitle'];
  int? apiSeconds = apiMeta['duration']['seconds'];
  String? apiProviderId = apiMeta['providerId'];
  String? lowCover = apiMeta['images'][0]['url'];
  String? begin = apiRights['begin'];
  String? end = apiRights['end'];

  return {
    'title': apiTitle,
    'subtitle': apiSubTitle,
    'description': apiDescription,
    'duration': apiSeconds,
    'provider_id': apiProviderId,
    'cover_low': lowCover,
    'start': begin,
    'stop': end,
  };
}

Future<Map<String, dynamic>> scrapWww(String lang, String idArte) async {
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

Future<PlaylistResponse?> getPlaylist(String lang, String idPlaylist) async {
  try {
    var url = 'https://api.arte.tv/api/player/v2/playlist/$lang/$idPlaylist';
    var response = await retryUntilGet(Uri.parse(url));
    return PlaylistResponse.fromJson(response);
  } catch (e) {
    log.severe('SCRAP␟$idPlaylist␟$lang');
    return null;
  }
}

Future<Set<String>> getCollectionIds(String idCollection) async {
  var url =
      'https://www.arte.tv/api/rproxy/emac/v4/fr/web/collections/$idCollection';
  var res = await retryUntilGet(Uri.parse(url));

  var seasons = <String>{};
  for (var zone in res['value']['zones']) {
    var data = zone['content']['data'] as List;
    var code = zone['code'].split('_') as List;
    var seasonId = code.last;
    var collecId = code[code.length - 2];

    if (idCollection == collecId && data.isNotEmpty) {
      log.info('SCRAP␟collection_ids␟$seasonId␟${data.length}␟episodes');
      seasons.add(seasonId);
    } else {
      log.severe('SCRAP␟collection_ids␟$idCollection␟!=␟$collecId');
    }
  }
  if (seasons.isEmpty) {
    throw Exception('SCRAP␟no_seasons');
  } else {
    return seasons;
  }
}
