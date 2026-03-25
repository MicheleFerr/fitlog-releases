import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/data/platform_channels.dart';

/// Syncs the preferred timer sound into the iOS app-group defaults used by widget intents.
class IOSTimerSoundPreferenceService {
  IOSTimerSoundPreferenceService._();

  static const _channel = MethodChannel(PlatformChannels.unified);
  static final IOSTimerSoundPreferenceService instance =
      IOSTimerSoundPreferenceService._();

  Future<void> syncPreferredSound(String soundName) async {
    if (!Platform.isIOS) return;

    try {
      await _channel.invokeMethod<String>('setPreferredTimerSound', {
        'soundName': soundName,
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[IOSTimerSoundPreferenceService] Failed to sync timer sound: ${e.message}',
        );
      }
    }
  }
}
