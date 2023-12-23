import 'dart:io';

import 'package:args/args.dart';
import 'package:logging_colorful/logging_colorful.dart';
import 'package:supabase/supabase.dart';

import 'cinema.dart';
import 'film.dart';

final log = LoggerColorful('arte');

var url = Platform.environment['SUPABASE_URL'];
var key = Platform.environment['SUPABASE_KEY'];
var supabase = SupabaseClient(url!, key!);

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
  parser.addOption('mode', abbr: 'm');
  parser.addOption('arte', abbr: 'a');
  parser.addFlag('catalog', defaultsTo: false);

  var cli = parser.parse(args);
  String? mode = cli['mode'];
  String? idArte = cli['arte'];
  bool catalog = cli['catalog'];

  if (idArte != null) validFilmIdArte(idArte);

  log.info('START␟${DateTime.now().toIso8601String()}');
  log.info('MODE␟$mode');
  log.info('ARTE␟$idArte');
  log.info('CATALOG␟$catalog');

  if (mode == 'cinema') {
    var select = await supabase.from('thing').select('arte');
    var filmsInDb = select.map((item) => item['arte']).toSet();
    log.info('FETCH␟${select.length}␟films');
    var cinemaCatalog = await getCinemaCatalog();

    var collect = cinemaCatalog.toSet().difference(filmsInDb);
    if (catalog) collect = cinemaCatalog.toSet();

    log.info('COLLECT␟${collect.length}␟films');
    for (var idArte in collect) await collectFilm(idArte: idArte);
  } else if (mode == 'solo' && idArte != null) {
    await collectFilm(idArte: idArte);
  } else {
    log.severe("INVALID␟$mode");
  }
  log.info('END␟${DateTime.now().toIso8601String()}');
  exit(0);
}
