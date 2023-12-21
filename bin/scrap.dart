import 'dart:convert';

import 'arte.dart';

import 'package:http/http.dart';

Future<Map<String, dynamic>> _fetch(Uri url) async {
  await Future.delayed(Duration(seconds: 2));
  var response = await get(url);

  var code = response.statusCode;
  while (code == 429) {
    int sleep = 10;
    log.warning('RATE LIMIT␟SLEEP␟$sleep␟seconds');

    await Future.delayed(Duration(seconds: sleep));
    response = await get(url);
    code = response.statusCode;
  }
  if (code == 200) return json.decode(response.body);

  throw Exception();
}

Future<Map<String, dynamic>?> scrap(
    int idThing, String lang, String idArte) async {
  try {
    var api = await _scrapApi(idThing, lang, idArte);
    var www = await _scrapWww(idThing, lang, idArte);
    if (api['duration'] == null) throw Exception();
    return {
      'id_thing': idThing,
      'id_arte': idArte,
      'lang': lang,
      ...api,
      ...www
    };
  } catch (e) {
    log.severe('SCRAP␟$idArte␟$idThing␟$lang');
    return null;
  }
}

Future<Map<String, dynamic>> _scrapApi(
  int idThing,
  String lang,
  String idArte,
) async {
  var apiUrl = Uri.https('api.arte.tv', '/api/player/v2/config/$lang/$idArte');
  var apiRes = await _fetch(apiUrl);

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
  var wwwRes = await _fetch(wwwUrl);
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
