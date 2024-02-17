import 'dart:io';

import 'package:args/args.dart';
import 'package:logging_colorful/logging_colorful.dart';

import 'arte_program.dart';
import 'collect.dart';
import 'database/table_provider.dart';
import 'database/table_type.dart';
import 'global.dart';
import 'database/table_thing.dart';
import 'heal_checks.dart';
import 'scrap.dart';
import 'utils.dart';
import 'validate.dart';

Future<void> main(List<String> args) async {
  await pingHealthCheck(start: true);

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

  arteProviderId = await Provider.getId('arte');
  filmTypeId = await Type.getId('film');
  collectionTypeId = await Type.getId('collection');
  episodeTypeId = await Type.getId('episode');

  // CLI
  var parser = ArgParser();
  parser.addOption('id', help: '083874-000-A');
  parser.addOption('slug', abbr: 's', help: 'SUBCATEGORY_FLM');
  parser.addFlag('force', defaultsTo: false, help: 're-collect all catalog');
  var cli = parser.parse(args);
  String? idArte = cli['id'];
  String? slug = cli['slug'];
  bool force = cli['force'];

  // starting…
  log.info('START␟${DateTime.now().toIso8601String()}');
  log.finest('SLUG:␟$slug␟ARTE:␟$idArte␟FORCE:␟$force');

  if (idArte != null) {
    var isStored = await Thing.isStored(idArte);
    if (isStored == false) {
      await collect(idArte);
    } else {
      log.warning('STORED␟$isStored␟FORCE␟$force␟$idArte');
      if (isStored && force) await collect(idArte);
      // DO NOTHING if not forced
    }
  } else {
    var things = await Thing.all();
    var idsArte = things.map((item) => item['arte']).toSet();

    // DOR = Documentaries  –> /fr/videos/documentaires-et-reportages/
    // FLM = Films          –> /fr/videos/cinema/
    // SER = Series         –> /fr/videos/series-et-fictions/
    var slugs = ['DOR', 'CATEGORY_SER', 'SUBCATEGORY_FLM'];
    if (slug != null) slugs = [slug];

    var categories = <ArteProgram>[];
    for (var item in slugs) {
      categories.addAll(await Scrap.catalog(item));
    }

    var catalog = <String>{};
    for (var e in categories) {
      var id = e.programId;
      if (Validate.isFilm(id) || Validate.isCollection(id)) catalog.add(id!);
    }

    Set<String> toCollect = catalog.difference(idsArte);
    if (force) toCollect = catalog.toSet();
    log.info('COLLECT␟${toCollect.length}␟items');

    for (var idArte in toCollect) await collect(idArte);
  }

  log.info('END␟${DateTime.now().toIso8601String()}');

  await pingHealthCheck(start: false);

  exit(0);
}
