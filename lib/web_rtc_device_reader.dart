import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRtcDeviceReader {
  WebRtcDeviceReader._();

  static Future<String> read() async {
    final devices = await navigator.mediaDevices.enumerateDevices();
    return devices.map((e) => e.formatted).join("\n");
  }
}

extension _MediaDeviceInfoX on MediaDeviceInfo {
  String get formatted => "[deviceId: $deviceId, groupId: $groupId, kind: $kind, label: $label]";
}
