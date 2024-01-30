import 'global.dart';
import 'database/rpc.dart';
import 'subtitles.dart';
import 'validate.dart';

Future<void> retryMissings() async {
  var thingsWithoutSubs = await Rpc.getLast10DaysThingsWithZeroSubtitles();
  var countCollections = 0, countEpisodes = 0, countFilms = 0;
  for (var thing in thingsWithoutSubs) {
    if (Validate.isFilm(thing.arte) || Validate.isEpisode(thing.arte)) {
      await extractSubtitles(thing.arte);
      await collectSubtitles(thing.arte, arteProviderId, thing.id.toInt());
    }
    if (Validate.isFilm(thing.arte)) countFilms += 1;
    if (Validate.isEpisode(thing.arte)) countEpisodes += 1;
    if (Validate.isCollection(thing.arte)) countCollections += 1;
  }
  log.info('RETRY␟$countFilms␟films');
  log.info('RETRY␟$countEpisodes␟episodes');
  log.info('RETRY␟$countCollections␟collections');
}
