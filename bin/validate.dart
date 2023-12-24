import 'global.dart';

class Validate {
  static bool idFilm(String idArte) {
    var parts = idArte.split('-');
    if (parts.length != 3) throw Exception('invalid id');
    if (parts[0].length != 6) throw Exception('first part lenght');
    if (parts[1].length != 3) throw Exception('second part lenght');
    if (parts[2].length != 1) throw Exception('last part lenght');
    if (int.parse(parts[1]) != 0) throw Exception('not a movie');
    return true;
  }

  static void languages(Map<String, int> langtags) {
    for (var lang in arteLanguages) {
      if (langtags.containsKey(lang)) {
        continue;
      } else {
        throw Exception('Arte language not found in langtags');
      }
    }
  }
}
