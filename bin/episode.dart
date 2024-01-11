import 'global.dart';
import 'playlist_response.dart';
import 'scrap.dart';
import 'subtitles.dart';
import 'table_cover.dart';
import 'table_description.dart';
import 'table_info.dart';
import 'table_link.dart';
import 'table_thing.dart';
import 'table_title.dart';
import 'validate.dart';

Future collectEpisode(
  String lang,
  PlaylistItem item,
  int idThingCollection,
) async {
  var idEpisode = item.providerId;
  if (!Validate.isEpisode(idEpisode)) {
    log.warning('UNVALID␟$idEpisode');
    return;
  }
  log.info('COLLECT␟$idEpisode');

  final idThing = await Thing.getIdOrInsert(episodeTypeId, idEpisode!);

  await Description(
    idThing: idThing,
    idLang: langtags[lang]!,
    subtitle: item.subtitle,
    description: item.description,
  ).insert();

  await Title(
    idThing: idThing,
    idLang: langtags[lang]!,
    label: item.title,
  ).insert();

  // DO NOT REPEAT for each languages (performances)
  if (lang == 'fr') {
    await Link(idParent: idThingCollection, idChild: idThing).insert();

    var www = await scrapWww(lang, idEpisode);

    await Info(
      idThing: idThing,
      duration: item.duration?.inSeconds,
      years: www['years'],
      actors: www['actors'],
      authors: www['authors'],
      directors: www['directors'],
      countries: www['countries'],
      productors: www['productors'],
    ).insert();

    var coverUrl = item.images?.first.url;
    if (coverUrl != null) {
      var image = await Cover.download(
          idThing: idThing,
          lang: lang,
          withText: false,
          url: Uri.parse(coverUrl));
      await image.file.insert();
      await image.cover.insert();
      image.file.save(covers, '$idEpisode.webp');
    }
    await extractSubtitles(idEpisode);
    await collectSubtitles(idEpisode, arteProviderId);
  }
}
