import 'dart:math';

import 'package:dotenv/dotenv.dart';
import 'package:path/path.dart';
import 'package:supabase/supabase.dart';
import 'package:logging_colorful/logging_colorful.dart';

final log = LoggerColorful('arte');

const arteLanguages = <String>["fr", "de", "en", "es", "pl", "it"];

late Map<String, int> langtags;

const ips = ['37.187.124.59', '185.246.211.194', '185.246.211.194'];

final random = Random();

final _env = DotEnv(includePlatformEnvironment: true)..load();
final _url = _env['SUPABASE_URL'];
final _key = _env['SUPABASE_KEY'];
final _path = _env['OUTPUT_PATH'];
final supabase = SupabaseClient(_url!, _key!);

final appData = join(_path!, 'arte_data');
final covers = join(appData, 'covers');
final subtitles = join(appData, 'subtitles');
