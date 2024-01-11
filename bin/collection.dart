import 'episode.dart';
import 'global.dart';
import 'playlist_response.dart';
import 'scrap.dart';
import 'table_cover.dart';
import 'table_description.dart';
import 'table_link.dart';
import 'table_thing.dart';
import 'table_title.dart';
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
    var ids = await getCollectionIds(idCollection);
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
    var playlist = await getPlaylist(lang, idCollection);
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
        var image = await Cover.download(
            idThing: idThingCollection,
            lang: lang!,
            withText: false,
            url: Uri.parse(coverUrl));
        await image.file.insert();
        await image.cover.insert();
        image.file.save(covers, '$idCollection.webp');
      }
      if (['fr', 'de', 'en'].contains(lang)) {
        var textImage = await Cover.download(
            idThing: idThingCollection,
            lang: lang!,
            withText: true,
            url: Uri.parse(coverUrl));
        await textImage.file.insert();
        await textImage.cover.insert();
        textImage.file.save(covers, '$idCollection.$lang.webp');
      }
    }
  }

  // collect episodes if any
  var nbEpisodes = collectionPlaylists.first.items.length;
  if (nbEpisodes != 0) {
    for (var playlist in collectionPlaylists) {
      var lang = playlist.metadata.language!;
      for (var item in playlist.items) {
        await collectEpisode(lang, item, idThingCollection);
      }
    }
  }

  return nbEpisodes;
}
