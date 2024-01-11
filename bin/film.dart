import 'table_thing.dart';
import 'extract.dart';
import 'global.dart';
import 'scrap.dart';
import 'subtitles.dart';
import 'table_description.dart';
import 'table_info.dart';
import 'table_title.dart';
import 'validate.dart';

Future<void> collectFilm(String idArte) async {
  if (!Validate.isFilm(idArte)) {
    log.warning('UNVALID␟$idArte');
    return;
  }
  log.info('COLLECT␟$idArte');

  // Check if thing already created if no create it
  final idThing = await Thing.getIdOrInsert(filmTypeId, idArte);

  // Store each title, subtitle, description per language
  var infos = <Info>[];
  var titles = <Title>[];
  var descriptions = <Description>[];
  for (var lang in arteLanguages) {
    var scrapped = await scrap(idThing, lang, idArte);
    if (scrapped != null) {
      titles.add(extractTitle(scrap: scrapped));
      descriptions.add(extractDescription(scrap: scrapped));
      infos.add(extractInfo(scrap: scrapped));
      if (lang == 'fr') {
        var image = await extractImage(scrap: scrapped, withText: false);
        await image?.file.insert();
        await image?.cover.insert();
        image?.file.save(covers, '$idArte.webp');
      }
      if (['fr', 'de', 'en'].contains(lang)) {
        var textImage = await extractImage(scrap: scrapped, withText: true);
        await textImage?.file.insert();
        await textImage?.cover.insert();
        textImage?.file.save(covers, '$idArte.$lang.webp');
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

  await extractSubtitles(idArte);
  await collectSubtitles(idArte, arteProviderId);
}
