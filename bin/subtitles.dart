import 'global.dart';
import 'database/table_subtitles.dart';
import 'utils.dart';
import 'package:path/path.dart' as path;

extractSubtitles(String idArte) async {
  var arteUrl = 'https://www.arte.tv/fr/videos/$idArte';
  var command = [
    'yt-dlp',
    '--skip-download',
    '--sub-langs all',
    '--write-subs',
    '-o "$subtitles/$idArte.%(ext)s"',
    arteUrl
  ];
  var stdout = await bash(command.join(' '));
  return stdout;
}

collectSubtitles(String idArte, int idProvider, int idThing) async {
  var files = await listFiles(subtitles, idArte, 'vtt');
  if (files.isEmpty) return;

  log.info('$idThing␟subtitles␟${files.length}␟found_on_disk');

  try {
    for (var file in files) {
      var subtitle = await file.readAsString();
      var name = path.basename(file.path);
      var parts = name.split('.');

      if (idArte == parts.first && parts.length == 3) {
        var lang = parts[1];

        var isClosedCaptions = false;

        // check if subtitles are closed captions
        var isUnusualSub = lang.contains('-');
        if (isUnusualSub) {
          var unusual = lang.split('-');
          lang = unusual[0];
          var extra = unusual[1];
          if (extra == 'acc') isClosedCaptions = true;
        }

        log.info('$idThing␟subtitles␟$lang␟found');

        // check if language exist in database
        var idLang = langtags[lang];
        if (idLang == null) {
          log.severe('$idThing␟subtitles␟$lang␟unknown_language');
          idLang = langtags['und']!;
        }

        // Check if there is a subtitles already registered
        // with same idThing and idLang that has `is_closed_captions` = null
        // if yes we will update instead of insert the data
        final ids = await Subtitles.getNullClosedCaptions(idThing, idLang);
        int? id = ids.length == 1 ? ids.first['id'] : null;

        // if id is null insert
        // if id is not null update
        await Subtitles(
          idThing: idThing,
          idProvider: idProvider,
          idLang: idLang,
          file: subtitle,
          ext: parts.last,
          isClosedCaptions: isClosedCaptions,
        ).upsert(id: id);
      } else
        throw Exception('whooops');
    }
  } catch (e) {
    throw Exception('Error reading file: $e');
  }
}
