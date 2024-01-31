import 'database/table_availability.dart';
import 'global.dart';
import 'scrap_api.dart';
import 'scrap_www.dart';
import 'subtitles.dart';
import 'database/table_cover.dart';
import 'database/table_description.dart';
import 'database/table_info.dart';
import 'database/table_link.dart';
import 'database/table_thing.dart';
import 'database/table_title.dart';
import 'validate.dart';

Future collectEpisode(
  String lang,
  String idEpisode,
  int idThingCollection,
) async {
  if (!Validate.isEpisode(idEpisode)) {
    log.warning('UNVALID␟$idEpisode');
    return;
  }
  log.info('COLLECT␟$idEpisode␟$lang');

  final idThing = await Thing.getIdOrInsert(episodeTypeId, idEpisode);

  var api = await Api.scrap(lang, idEpisode);

  await Description(
    idThing: idThing,
    idLang: langtags[lang]!,
    subtitle: api.subtitle,
    description: api.description,
  ).insert();

  await Title(
    idThing: idThing,
    idLang: langtags[lang]!,
    label: api.title,
  ).insert();

  // DO NOT REPEAT for each languages (performances)
  if (lang == 'fr') {
    await Link(idParent: idThingCollection, idChild: idThing).insert();

    var www = await Www.scrap(lang, idEpisode);

    // Insert availability
    if (api.start != null && api.stop != null) {
      await Availability(
        idThing: idThing,
        start: DateTime.parse(api.start!),
        stop: DateTime.parse(api.stop!),
      ).insert();
    }

    await Info(
      idThing: idThing,
      duration: api.duration,
      years: www.years,
      actors: www.actors,
      authors: www.authors,
      directors: www.directors,
      countries: www.countries,
      productors: www.productors,
    ).insert();

    if (api.cover != null) {
      await Cover.collect(
        lang: lang,
        idThing: idThing,
        idArte: idEpisode,
        url: api.cover!,
        text: false,
      );
    }
    await extractSubtitles(idEpisode);
    await collectSubtitles(idEpisode, arteProviderId, idThing);
  }
}
