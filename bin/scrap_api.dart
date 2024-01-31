import 'utils.dart';

class Api {
  String? title;
  String? subtitle;
  String? description;
  int? duration;
  String? providerId;
  String? cover;
  String? start;
  String? stop;

  Api._({
    this.title,
    this.subtitle,
    this.description,
    this.duration,
    this.providerId,
    this.start,
    this.stop,
    this.cover,
  });

  static Future<Api> scrap(String lang, String idArte) async {
    var apiUrl =
        Uri.https('api.arte.tv', '/api/player/v2/config/$lang/$idArte');
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

    return Api._(
      title: apiTitle,
      subtitle: apiSubTitle,
      description: apiDescription,
      duration: apiSeconds,
      providerId: apiProviderId,
      cover: lowCover,
      start: begin,
      stop: end,
    );
  }
}
