import 'package:http/http.dart';

import 'global.dart';

Future<void> pingHealthCheck({required bool start}) async {
  var url = healthcheck!;
  if (start) url += "/start";
  await get(Uri.parse(url));
}
