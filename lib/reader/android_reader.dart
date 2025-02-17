import 'package:flutter_web_rtc_device_reader/reader/reader.dart';

import '../web_rtc_device_reader.dart';

class AndroidReader implements Reader {
  @override
  Future<String> read() async => WebRtcDeviceReader.read();
}
