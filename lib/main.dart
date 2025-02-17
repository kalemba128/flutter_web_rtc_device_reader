import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_rtc_device_reader/platform_reader.dart';
import 'package:flutter_web_rtc_device_reader/reader/android_reader.dart';
import 'package:flutter_web_rtc_device_reader/reader/ios_reader.dart';

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
            spacing: 16.0,
            children: [
              Row(
                spacing: 16.0,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ReadButton(onRead: (output) => setState(() => _output = output)),
                  _CopyButton(data: _output),
                ],
              ),
              if (_output != null) Text(_output!),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadButton extends StatefulWidget {
  final void Function(String) onRead;
  const _ReadButton({required this.onRead});

  @override
  State<_ReadButton> createState() => _ReadButtonState();
}

class _ReadButtonState extends State<_ReadButton> {

  bool _isReading = false;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _read,
      child: _isReading ? _buildLoader() : Text("Read"),
    );
  }

  Widget _buildLoader() => SizedBox.square(dimension: 16, child: CircularProgressIndicator(color: Colors.white));

  Future<void> _read() async {
    setState(() => _isReading = true);
    final reader = Platform.isIOS ? IosReader() : AndroidReader();
    final devices = await reader.read();
    final platform = ["Platform:", await PlatformReader.read()].join("\n");
    final output = [platform, devices].join("\n\n");
    setState(() => _isReading = false);
    widget.onRead(output);
  }
}




class _CopyButton extends StatelessWidget {
  final String? data;

  const _CopyButton({required this.data});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: data != null ? () async => _copy(context) : null,
      child: Text("Copy"),
    );
  }

  Future<void> _copy(BuildContext context) async {
    if (data == null) return;
    await Clipboard.setData(ClipboardData(text: data!));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied!')));
    }
  }
}

