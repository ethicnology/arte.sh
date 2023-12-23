import 'table_provider.dart';
import 'table_subtitles.dart';
import 'table_thing.dart';
import 'utils.dart';
import 'package:path/path.dart' as path;

const folder = 'subtitles';

downloadSubs({required String idArte}) async {
  var path = await createFolder(folder);
  var arteUrl = 'https://www.arte.tv/fr/videos/$idArte';
  var command = [
    'yt-dlp',
    '--skip-download',
    '--sub-langs all',
    '--write-subs',
    '-o "$path/$idArte.%(ext)s"',
    arteUrl
  ];
  var stdout = await bash(command.join(' '));
  return stdout;
}

collectSubs({required String idArte}) async {
  var files = await listFiles(folder, idArte, 'vtt');
  if (files.isEmpty) return;

  final thing = await Thing.get(idArte);
  final idThing = thing['id'];

  final provider = await Provider.get('arte');
  final idProvider = provider['id'];

  var subs = <Subtitles>[];
  try {
    for (var file in files) {
      var subtitle = await file.readAsString();
      var name = path.basename(file.path);
      var parts = name.split('.');
      if (idArte == parts.first && parts.length == 3) {
        subs.add(
          Subtitles(
            idThing: idThing,
            idProvider: idProvider,
            lang: parts[1],
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
