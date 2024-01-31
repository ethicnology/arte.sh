import 'utils.dart';

class Www {
  List<int>? years;
  List<String>? actors;
  List<String>? authors;
  List<String>? countries;
  List<String>? directors;
  List<String>? productors;
  String? cover;
  String? fullDescription;

  Www._({
    this.years,
    this.actors,
    this.authors,
    this.countries,
    this.directors,
    this.productors,
    this.cover,
    this.fullDescription,
  });

  static Future<Www> scrap(String lang, String idArte) async {
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

    return Www._(
      years: years,
      actors: actors,
      authors: authors,
      countries: countries,
      directors: directors,
      productors: productors,
      cover: highCover,
      fullDescription: fullDescription,
    );
  }
}
