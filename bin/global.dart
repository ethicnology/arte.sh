import 'dart:io';
import 'dart:math';

import 'package:path/path.dart';
import 'package:supabase/supabase.dart';
import 'package:logging_colorful/logging_colorful.dart';

final log = LoggerColorful('arte');

final url = Platform.environment['SUPABASE_URL'];
final key = Platform.environment['SUPABASE_KEY'];
final supabase = SupabaseClient(url!, key!);

const arteLanguages = <String>["fr", "de", "en", "es", "pl", "it"];

late Map<String, int> langtags;

const ips = ['37.187.124.59', '185.246.211.194', '185.246.211.194'];

final random = Random();

final appData = join(Directory.current.path, 'arte_data');
final covers = join(appData, 'covers');
final subtitles = join(appData, 'subtitles');
