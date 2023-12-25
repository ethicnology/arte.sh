import 'dart:io';

import 'package:args/args.dart';
import 'package:logging_colorful/logging_colorful.dart';

import 'table_provider.dart';
import 'table_type.dart';
import 'film.dart';
import 'global.dart';
import 'scrap.dart';
import 'table_thing.dart';
import 'utils.dart';
import 'validate.dart';

Future<void> main(List<String> args) async {
  // Logger
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print([
      record.loggerName,
      record.level.name,
      record.message.replaceAll('␟', '\t')
    ].join('\t'));
  });

  // Folders
  await createFolder(covers);
  await createFolder(subtitles);

  // Languages validation
  langtags = await getLangtagIds();
  Validate.languages(langtags);

  // CLI
  var parser = ArgParser();
  parser.addOption('mode', abbr: 'm', help: 'film', mandatory: true);
  parser.addOption('arte', abbr: 'a', help: '083874-000-A');
  parser.addFlag('force', defaultsTo: false, help: 're-collect all catalog');
  var cli = parser.parse(args);
  String mode = cli['mode'];
  String? idArte = cli['arte'];
  bool force = cli['force'];

  // validate cli arguments
  if (idArte != null) Validate.idFilm(idArte);
  if (!['film'].contains(mode)) throw Exception('wrong mode');
  final idType = await Type.getId(mode); // film/series/episode
  final idProvider = await Provider.getId('arte');

  // starting…
  log.info('START␟${DateTime.now().toIso8601String()}');
  log.finest('MODE:␟$mode␟ARTE:␟$idArte␟FORCE:␟$force');

  if (mode == 'film') {
    if (idArte != null) {
      var isStored = await Thing.isStored(idArte);
      if (isStored == false) {
        await collectFilm(idArte, idType, idProvider);
      } else {
        log.warning('STORED␟$isStored␟FORCE␟$force␟$idArte');
        if (isStored && force) await collectFilm(idArte, idType, idProvider);
        // DO NOTHING if not forced
      }
    } else {
      var things = await Thing.all();
      var idsArte = things.map((item) => item['arte']).toSet();

      var catalog = await scrapFilmsIds();

      Set<String> collect = catalog.toSet().difference(idsArte);
      if (force) collect = catalog.toSet();
      log.info('COLLECT␟${collect.length}␟films');

      for (var idArte in collect) await collectFilm(idArte, idType, idProvider);
    }
  }
  log.info('END␟${DateTime.now().toIso8601String()}');
  exit(0);
}
