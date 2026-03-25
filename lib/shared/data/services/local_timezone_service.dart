import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/data/platform_channels.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Initializes the timezone database and configures [tz.local] to the device
/// timezone when native support is available.
abstract final class LocalTimezoneService {
  static Future<void>? _initialization;

  static Future<void> ensureInitialized() {
    return _initialization ??= _initialize();
  }

  static Future<void> _initialize() async {
    tz_data.initializeTimeZones();

    if (kIsWeb) {
      return;
    }

    try {
      final timeZoneId = await const MethodChannel(
        PlatformChannels.unified,
      ).invokeMethod<String>('getLocalTimeZone');

      if (timeZoneId == null || timeZoneId.isEmpty) {
        return;
      }

      tz.setLocalLocation(tz.getLocation(timeZoneId));

      if (kDebugMode) {
        debugPrint('[Timezone] Local timezone configured: $timeZoneId');
      }
    } on MissingPluginException catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[Timezone] Native timezone channel unavailable, using default timezone: $error',
        );
      }
    } on ArgumentError catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[Timezone] Unknown timezone returned by native layer, using default timezone: $error',
        );
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[Timezone] Failed to configure local timezone, using default timezone: $error',
        );
      }
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    _initialization = null;
  }
}
