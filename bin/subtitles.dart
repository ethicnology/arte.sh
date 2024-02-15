import 'database/table_language.dart';
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

  var subs = <Subtitles>[];
  try {
    for (var file in files) {
      var subtitle = await file.readAsString();
      var name = path.basename(file.path);
      var parts = name.split('.');
      if (idArte == parts.first && parts.length == 3) {
        var lang = parts[1];
        var idLang = langtags[lang];

        log.info('$idThing␟subtitles␟$lang␟found');

        if (idLang == null) {
          log.severe('$idThing␟subtitles␟$lang␟unknown_insert_language');
          idLang = await Language(tag: lang).insert();
        }

        subs.add(
          Subtitles(
            idThing: idThing,
            idProvider: idProvider,
            idLang: idLang,
            file: subtitle,
            ext: parts.last,
          ),
        );
      } else
        throw Exception('whooops');
    }
    for (var sub in subs) await sub.insert();
  } catch (e) {
    throw Exception('Error reading file: $e');
  }
}
