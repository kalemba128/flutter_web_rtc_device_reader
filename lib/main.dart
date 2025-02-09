import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebRTC Device Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Page(),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  String? _output;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter WebRTC Device Reader')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ReadButton(onRead: (output) => setState(() => _output = output)),
              _CopyButton(data: _output),
              if (_output != null) Text(_output!),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadButton extends StatelessWidget {
  final void Function(String) onRead;

  const _ReadButton({super.key, required this.onRead});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        final devices = (await navigator.mediaDevices.enumerateDevices()).map((e) => e.formatted).join("\n\n");
        final platform = "Platform: ${await _getPlatform()}";
        final output = [platform, devices].join("\n\n");
        onRead(output);
      },
      child: Text("Read"),
    );
  }

  Future<String> _getPlatform() async {
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

class _CopyButton extends StatelessWidget {
  final String? data;

  const _CopyButton({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: data != null ? _copy : null,
      child: Text("Copy"),
    );
  }

  Future<void> _copy() async {
    if (data == null) return;
    await Clipboard.setData(ClipboardData(text: data!));
  }
}

extension _MediaDeviceInfoX on MediaDeviceInfo {
  String get formatted => "[deviceId: $deviceId, groupId: $groupId, kind: $kind, label: $label]";
}
