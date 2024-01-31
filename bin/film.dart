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
    var scrapped = await Scrap.fetch(idThing, lang, idArte);
    if (scrapped != null) {
      await Title(
        idThing: scrapped.idThing,
        idLang: scrapped.idLang,
        label: scrapped.api.title,
      ).insert();

      await Description(
        idThing: scrapped.idThing,
        idLang: scrapped.idLang,
        subtitle: scrapped.api.subtitle,
        description: scrapped.api.description,
        // TODO remove or split different endpoint shouldn't be in the same table
        fullDescription: scrapped.www.fullDescription,
      ).insert();

      if (lang == 'fr') {
        // insert info once source will be in french
        // because when i merged all languages it created duplicates "Allemagne", "Germany"…
        await Info(
          idThing: scrapped.idThing,
          // TODO remove or split different endpoint shouldn't be in the same table
          duration: scrapped.api.duration,
          years: scrapped.www.years,
          actors: scrapped.www.actors,
          authors: scrapped.www.authors,
          directors: scrapped.www.directors,
          countries: scrapped.www.countries,
          productors: scrapped.www.productors,
        ).insert();

        // insert a cover without text
        await Cover.collect(
          lang: scrapped.lang,
          idThing: scrapped.idThing,
          idArte: scrapped.idArte,
          url: scrapped.www.cover!,
          text: false,
        );

        // Insert availability
        if (scrapped.api.start != null && scrapped.api.stop != null) {
          await Availability(
            idThing: idThing,
            start: DateTime.parse(scrapped.api.start!),
            stop: DateTime.parse(scrapped.api.stop!),
          ).insert();
        }
      }
      if (['fr', 'de', 'en'].contains(lang)) {
        await Cover.collect(
          lang: scrapped.lang,
          idThing: scrapped.idThing,
          idArte: scrapped.idArte,
          url: scrapped.www.cover!,
          text: true,
        );
      }
    }
  }

  await extractSubtitles(idArte);
  await collectSubtitles(idArte, arteProviderId, idThing);
}
