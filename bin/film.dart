import 'database/table_availability.dart';
import 'database/table_cover.dart';
import 'database/table_info.dart';
import 'database/table_thing.dart';
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
  for (var lang in arteLanguages) {
    var scrapped = await scrap(idThing, lang, idArte);
    if (scrapped != null) {
      await Title(
        idThing: scrapped['id_thing'],
        idLang: scrapped['id_lang'],
        label: scrapped['title'],
      ).insert();

      await Description(
        idThing: scrapped['id_thing'],
        idLang: scrapped['id_lang'],
        subtitle: scrapped['subtitle'],
        description: scrapped['description'],
        fullDescription: scrapped['full_description'],
      ).insert();

      if (lang == 'fr') {
        // insert info once source will be in french
        // because when i merged all languages it created duplicates "Allemagne", "Germany"…
        await Info(
          idThing: scrapped['id_thing'],
          duration: scrapped['duration'],
          years: scrapped['years'],
          actors: scrapped['actors'],
          authors: scrapped['authors'],
          directors: scrapped['directors'],
          countries: scrapped['countries'],
          productors: scrapped['productors'],
        ).insert();

        // insert a cover without text
        await Cover.collect(
          lang: scrapped['lang'],
          idThing: scrapped['id_thing'],
          idArte: scrapped['id_arte'],
          url: scrapped['cover_high'],
          text: false,
        );

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
        await Cover.collect(
          lang: scrapped['lang'],
          idThing: scrapped['id_thing'],
          idArte: scrapped['id_arte'],
          url: scrapped['cover_high'],
          text: true,
        );
      }
    }
  }

  await extractSubtitles(idArte);
  await collectSubtitles(idArte, arteProviderId, idThing);
}
