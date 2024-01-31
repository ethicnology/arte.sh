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
    Map<String, dynamic> attributes = apiRes['data']['attributes'];

    String? apiDescription = attributes['metadata']['description'];
    String? apiTitle = attributes['metadata']['title'];
    String? apiSubTitle = attributes['metadata']['subtitle'];
    int? apiSeconds = attributes['metadata']['duration']['seconds'];
    String? apiProviderId = attributes['metadata']['providerId'];
    String? lowCover = attributes['metadata']['images'][0]['url'];

    String? begin, end;
    if (attributes['rights'] != null) {
      begin = attributes['rights']['begin'];
      end = attributes['rights']['end'];
    }

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
