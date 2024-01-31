import 'episode.dart';
import 'global.dart';
import 'playlist_response.dart';
import 'scrap.dart';
import 'database/table_cover.dart';
import 'database/table_description.dart';
import 'database/table_link.dart';
import 'database/table_thing.dart';
import 'database/table_title.dart';
import 'validate.dart';

Future collectRecursiveCollections(String idCollection) async {
  if (!Validate.isCollection(idCollection)) {
    log.warning('UNVALID␟$idCollection');
    return;
  }

  var nbEpisodes = await collectCollection(idCollection);
  final idThingCollection =
      await Thing.getIdOrInsert(collectionTypeId, idCollection);

  if (nbEpisodes == 0) {
    var ids = await Scrap.collectionIds(idCollection);
    for (var idSeason in ids) {
      await collectCollection(idSeason);
      final idThingSeason =
          await Thing.getIdOrInsert(collectionTypeId, idSeason);
      await Link(idParent: idThingCollection, idChild: idThingSeason).insert();
    }
  }
}

Future<int> collectCollection(String idCollection) async {
  if (!Validate.isCollection(idCollection)) {
    log.warning('UNVALID␟$idCollection');
    throw Exception('UNVALID␟$idCollection');
  }
  log.info('COLLECT␟$idCollection');

  var collectionPlaylists = <PlaylistResponse>[];
  for (var lang in arteLanguages) {
    var playlist = await Scrap.playlist(lang, idCollection);
    if (playlist != null) collectionPlaylists.add(playlist);
  }

  // insert collection
  final idThingCollection =
      await Thing.getIdOrInsert(collectionTypeId, idCollection);

  // insert collection descriptions (multilingual)
  for (var playlist in collectionPlaylists) {
    var lang = playlist.metadata.language;
    await Description(
      idThing: idThingCollection,
      idLang: langtags[lang]!,
      subtitle: playlist.metadata.subtitle,
      description: playlist.metadata.description,
    ).insert();

    await Title(
      idThing: idThingCollection,
      idLang: langtags[lang]!,
      label: playlist.metadata.title,
    ).insert();

    var coverUrl = playlist.metadata.images?.first.url;
    if (coverUrl != null) {
      if (lang == 'fr') {
        await Cover.collect(
          lang: lang!,
          idThing: idThingCollection,
          idArte: idCollection,
          url: coverUrl,
          text: false,
        );
      }
      if (['fr', 'de', 'en'].contains(lang)) {
        await Cover.collect(
          lang: lang!,
          idThing: idThingCollection,
          idArte: idCollection,
          url: coverUrl,
          text: true,
        );
      }
    }
  }

  // collect episodes if any
  var nbEpisodes = collectionPlaylists.first.items.length;
  if (nbEpisodes != 0) {
    for (var playlist in collectionPlaylists) {
      var lang = playlist.metadata.language!;
      for (var item in playlist.items) {
        var idEpisode = item.providerId;
        if (idEpisode != null) {
          await collectEpisode(lang, idEpisode, idThingCollection);
        }
      }
    }
  }

  return nbEpisodes;
}
