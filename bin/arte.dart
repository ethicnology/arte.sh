import 'dart:io';

import 'package:args/args.dart';
import 'package:logging_colorful/logging_colorful.dart';
import 'package:supabase/supabase.dart';

import 'cinema.dart';
import 'film.dart';
import 'subtitles.dart';

final log = LoggerColorful('arte');

final url = Platform.environment['SUPABASE_URL'];
final key = Platform.environment['SUPABASE_KEY'];
final supabase = SupabaseClient(url!, key!);

const languages = <String>["fr", "de", "en", "es", "pl", "it"];

Future<void> main(List<String> args) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print([
      record.loggerName,
      record.level.name,
      record.message.replaceAll('␟', '\t')
    ].join('\t'));
  });

  var parser = ArgParser();
  parser.addOption('mode', abbr: 'm', help: 'film, subtitles');
  parser.addOption('arte', abbr: 'a', help: '083874-000-A');
  parser.addFlag('catalog', defaultsTo: false, help: 'collect all catalog');

  var cli = parser.parse(args);
  String? mode = cli['mode'];
  String? idArte = cli['arte'];
  bool catalog = cli['catalog'];

  if (idArte != null) validFilmIdArte(idArte);

  log.info('START␟${DateTime.now().toIso8601String()}');
  log.info('MODE␟$mode');
  log.info('ARTE␟$idArte');
  log.info('CATALOG␟$catalog');

  if (mode == 'film' && idArte == null) {
    await collectCinemaCatalog(force: catalog);
  } else if (mode == 'film' && idArte != null) {
    await collectFilm(idArte: idArte);
  } else if (mode == 'subtitles' && idArte != null) {
    await downloadSubs(idArte: idArte);
    await collectSubs(idArte: idArte);
  }
  log.info('END␟${DateTime.now().toIso8601String()}');
  exit(0);
}
