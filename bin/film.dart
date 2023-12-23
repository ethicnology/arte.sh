import 'arte.dart';
import 'database.dart';
import 'extract.dart';
import 'scrap.dart';
import 'table_description.dart';
import 'table_info.dart';
import 'table_title.dart';

bool validFilmIdArte(String idArte) {
  var parts = idArte.split('-');
  if (parts.length != 3) throw Exception('invalid id');
  if (parts[0].length != 6) throw Exception('first part lenght');
  if (parts[1].length != 3) throw Exception('second part lenght');
  if (parts[2].length != 1) throw Exception('last part lenght');
  if (int.parse(parts[1]) != 0) throw Exception('not a movie');
  return true;
}

Future<void> collectFilm({required String idArte}) async {
  // Define if it's film / series / episode
  final idType = await getIdType("film");

  // Check if thing already created if no create it
  final idThing = await getOrInsertIdThing(idType, idArte);

  // Store each title, subtitle, description per language
  var infos = <Info>[];
  var titles = <Title>[];
  var descriptions = <Description>[];
  for (var lang in languages) {
    var scrapped = await scrap(idThing, lang, idArte);
    if (scrapped != null) {
      titles.add(extractTitle(scrap: scrapped));
      descriptions.add(extractDescription(scrap: scrapped));
      infos.add(extractInfo(scrap: scrapped));
      if (lang == 'fr') {
        var frCover = await extractCover(scrap: scrapped, withText: false);
        var frCoverText = await extractCover(scrap: scrapped, withText: true);
        await frCover?.insert();
        frCover?.toFile('$idArte.webp');
        await frCoverText?.insert();
        frCoverText?.toFile('$idArte.fr.webp');
      }
    }
  }

  for (var title in titles) await title.insert();
  for (var descr in descriptions) await descr.insert();

  // Remove duplicates data to store a single row per thing
  var duration = 0;
  var years = <int>{};
  var actors = <String>{};
  var authors = <String>{};
  var directors = <String>{};
  var countries = <String>{};
  var productors = <String>{};
  for (var info in infos) {
    if (info.duration != null) duration = info.duration!;
    if (info.years != null) years.addAll(info.years!);
    if (info.actors != null) actors.addAll(info.actors!);
    if (info.authors != null) authors.addAll(info.authors!);
    if (info.directors != null) directors.addAll(info.directors!);
    if (info.countries != null) countries.addAll(info.countries!);
    if (info.productors != null) productors.addAll(info.productors!);
  }
  var info = Info(idThing: idThing);
  info.duration = duration;
  info.years = years.isNotEmpty ? years.toList() : null;
  info.actors = actors.isNotEmpty ? actors.toList() : null;
  info.authors = authors.isNotEmpty ? authors.toList() : null;
  info.directors = directors.isNotEmpty ? directors.toList() : null;
  info.countries = countries.isNotEmpty ? countries.toList() : null;
  info.productors = productors.isNotEmpty ? productors.toList() : null;
  await info.insert();
}
