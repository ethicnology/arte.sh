import 'arte_program.dart';
import 'global.dart';
import 'playlist_response.dart';
import 'scrap_api.dart';
import 'scrap_www.dart';
import 'utils.dart';

class Scrap {
  int idThing;
  String idArte;
  String lang;
  int idLang;
  Api api;
  Www www;

  Scrap._({
    required this.idThing,
    required this.idArte,
    required this.lang,
    required this.idLang,
    required this.api,
    required this.www,
  });

  static Future<Scrap?> fetch(
    int idThing,
    String lang,
    String idArte,
  ) async {
    try {
      var api = await Api.scrap(lang, idArte);
      var www = await Www.scrap(lang, idArte);
      if (api.duration == null) throw Exception();

      return Scrap._(
          idThing: idThing,
          idArte: idArte,
          lang: lang,
          idLang: langtags[lang]!,
          api: api,
          www: www);
    } catch (e) {
      log.severe('SCRAP␟$idThing␟$lang␟$idArte');
      return null;
    }
  }

  static Future<PlaylistResponse?> playlist(
    String lang,
    String idPlaylist,
  ) async {
    try {
      var url = 'https://api.arte.tv/api/player/v2/playlist/$lang/$idPlaylist';
      var response = await retryUntilGet(Uri.parse(url));
      return PlaylistResponse.fromJson(response);
    } catch (e) {
      log.severe('SCRAP␟$idPlaylist␟$lang');
      return null;
    }
  }

  static Future<Set<String>> collectionIds(String idCollection) async {
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

  static Future<List<ArteProgram>> catalog(String path) async {
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
}
