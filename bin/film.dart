import 'database/table_availability.dart';
import 'database/table_thing.dart';
import 'extract.dart';
import 'global.dart';
import 'scrap.dart';
import 'subtitles.dart';
import 'database/table_description.dart';
import 'database/table_title.dart';
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
  var titles = <Title>[];
  var descriptions = <Description>[];
  for (var lang in arteLanguages) {
    var scrapped = await scrap(idThing, lang, idArte);
    if (scrapped != null) {
      titles.add(extractTitle(scrap: scrapped));
      descriptions.add(extractDescription(scrap: scrapped));
      if (lang == 'fr') {
        // insert info once source will be in french
        // because when i merged all languages it created duplicates "Allemagne", "Germany"…
        var info = extractInfo(scrap: scrapped);
        await info.insert();

        // insert a cover without text
        var image = await extractImage(scrap: scrapped, withText: false);
        await image?.file.insert();
        await image?.cover.insert();
        await image?.file.save(covers, '$idArte.webp');

        // Insert availability
        if (scrapped['start'] != null && scrapped['stop'] != null) {
          await Availability(
            idThing: idThing,
            start: DateTime.parse(scrapped['start']),
            stop: DateTime.parse(scrapped['stop']),
          ).insert();
        }
      }
      if (['fr', 'de', 'en'].contains(lang)) {
        var textImage = await extractImage(scrap: scrapped, withText: true);
        await textImage?.file.insert();
        await textImage?.cover.insert();
        await textImage?.file.save(covers, '$idArte.$lang.webp');
      }
    }
  }

  for (var title in titles) await title.insert();
  for (var descr in descriptions) await descr.insert();

  await extractSubtitles(idArte);
  await collectSubtitles(idArte, arteProviderId);
}
