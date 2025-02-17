import 'package:audio_session/audio_session.dart';
import 'package:flutter_web_rtc_device_reader/reader/reader.dart';
import 'package:flutter_web_rtc_device_reader/web_rtc_device_reader.dart';

class IosReader implements Reader {
  @override
  Future<String> read() async {
    final categories = [
      AVAudioSessionCategory.ambient,
      AVAudioSessionCategory.soloAmbient,
      AVAudioSessionCategory.playback,
      AVAudioSessionCategory.record,
      AVAudioSessionCategory.playAndRecord,
      AVAudioSessionCategory.multiRoute,
    ];

    final modes = AVAudioSessionMode.values;

    final categoryOptions = <AVAudioSessionCategoryOptions>[
      AVAudioSessionCategoryOptions.none,
      AVAudioSessionCategoryOptions.mixWithOthers,
      AVAudioSessionCategoryOptions.duckOthers,
      AVAudioSessionCategoryOptions.interruptSpokenAudioAndMixWithOthers,
      AVAudioSessionCategoryOptions.allowBluetooth,
      AVAudioSessionCategoryOptions.allowBluetoothA2dp,
      AVAudioSessionCategoryOptions.allowAirPlay,
      AVAudioSessionCategoryOptions.defaultToSpeaker,
    ];

    final outputs = <String>[];
    for (final category in categories) {
      for (final mode in modes) {
        for (final option in categoryOptions) {
          try {
            final output = await _test(category: category, options: option, mode: mode);
            final title = "------ TEST ${outputs.length + 1} ------";
            final formatted = [title, output].join("\n");
            outputs.add(formatted);
          } catch (e, s) {
            print("Error: e: $e, s:$s");
          }
        }
      }
    }

    return outputs.join("\n\n");
  }

  Future<String> _test({
    AVAudioSessionCategory? category,
    AVAudioSessionCategoryOptions? options,
    AVAudioSessionMode? mode,
  }) async {
    final session = AVAudioSession();
    await session.setCategory(category, options, mode);

    final currentCategory = await session.category;
    final currentCategoryOptions = await session.categoryOptions;
    final currentMode = await session.mode;

    await session.setActive(true);
    final devices = await WebRtcDeviceReader.read();
    await session.setActive(false);

    final targetConfiguration = _formatAVAudioSession(category: category, options: options, mode: mode);
    final currentConfiguration = _formatAVAudioSession(
      category: currentCategory,
      options: currentCategoryOptions,
      mode: currentMode,
    );

    return [
      "Target configuration:",
      targetConfiguration,
      "Current configuration:",
      currentConfiguration,
      "WebRtc devices:",
      devices
    ].join("\n");
  }

  String _formatAVAudioSession({
    AVAudioSessionCategory? category,
    AVAudioSessionCategoryOptions? options,
    AVAudioSessionMode? mode,
  }) {
    return "AVAudioSessionCategory: ${category?.rawValue}\n"
        "AVAudioSessionCategoryOptions: ${options?.formattedOptions}\n"
        "AVAudioSessionMode: $mode\n";
  }
}

extension _AVAudioSessionCategoryOptionsExtension on AVAudioSessionCategoryOptions {
  String get formattedOptions {
    return [
      if (contains(AVAudioSessionCategoryOptions.mixWithOthers)) "mixWithOthers",
      if (contains(AVAudioSessionCategoryOptions.duckOthers)) "duckOthers",
      if (contains(AVAudioSessionCategoryOptions.interruptSpokenAudioAndMixWithOthers))
        "interruptSpokenAudioAndMixWithOthers",
      if (contains(AVAudioSessionCategoryOptions.allowBluetooth)) "allowBluetooth",
      if (contains(AVAudioSessionCategoryOptions.allowBluetoothA2dp)) "allowBluetoothA2dp",
      if (contains(AVAudioSessionCategoryOptions.allowAirPlay)) "allowAirPlay",
      if (contains(AVAudioSessionCategoryOptions.defaultToSpeaker)) "defaultToSpeaker",
    ].join(", ");
  }
}
