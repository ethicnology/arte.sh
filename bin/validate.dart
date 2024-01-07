import 'global.dart';

class Validate {
  static bool isArteId(String? idArte) {
    return Validate.isFilm(idArte) ||
        Validate.isEpisode(idArte) ||
        Validate.isCollection(idArte);
  }

  static bool isFilm(String? idArte) {
    if (idArte == null) return false;
    var parts = idArte.split('-');
    if (parts.length != 3) return false;
    if (parts[0].length != 6) return false;
    if (parts[1].length != 3) return false;
    if (parts[2].length != 1) return false;
    if (int.parse(parts[1]) != 0) return false;
    return true;
  }

  static bool isEpisode(String? idArte) {
    if (idArte == null) return false;
    var parts = idArte.split('-');
    if (parts.length != 3) return false; // invalid id
    if (parts[0].length != 6) return false; // first part lenght
    if (parts[1].length != 3) return false; // second part lenght
    if (parts[2].length != 1) return false; // last part lenght
    if (int.parse(parts[1]) <= 0) return false; // not an episode
    return true;
  }

  static bool isCollection(String? idArte) {
    if (idArte == null) return false;
    var parts = idArte.split('-');
    if (parts.length != 2) return false;
    if (parts[0].length != 2) return false;
    if (parts[1].length != 6) return false;
    if (parts[0] != 'RC') return false;
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
