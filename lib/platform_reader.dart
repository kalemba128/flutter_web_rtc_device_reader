import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class PlatformReader {
  PlatformReader._();

  static Future<String> read() async {
    final plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      return info.version.toMap().toString();
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return info.toMap().toString();
    }
    return "";
  }
}
