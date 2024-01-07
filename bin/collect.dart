import 'collection.dart';
import 'film.dart';
import 'global.dart';
import 'validate.dart';

collect(String idArte) async {
  if (!Validate.isFilm(idArte) && !Validate.isCollection(idArte)) {
    log.warning('UNVALID␟$idArte');
    return;
  }

  if (Validate.isFilm(idArte)) {
    await collectFilm(idArte);
  } else if (Validate.isCollection(idArte)) {
    await collectRecursiveCollections(idArte);
  }
}
