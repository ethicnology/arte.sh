import 'global.dart';

class Info {
  static const table = 'arte_info';
  int idThing;
  int? duration;
  List<int>? years;
  List<String>? actors;
  List<String>? authors;
  List<String>? directors;
  List<String>? countries;
  List<String>? productors;

  Info({
    required this.idThing,
    this.duration,
    this.years,
    this.actors,
    this.authors,
    this.directors,
    this.countries,
    this.productors,
  });

  Future<bool> insert() async {
    try {
      var insert = await supabase.from(table).insert({
        'id_thing': idThing,
        'duration': duration,
        'years': years,
        'actors': actors,
        'authors': authors,
        'directors': directors,
        'countries': countries,
        'productors': productors,
      }).select();

      log.fine('$idThing␟$table␟${insert.first['id']}');
      return true;
    } catch (e) {
      log.warning('$idThing␟$table␟${e.toString()}');
      return false;
    }
  }
}
