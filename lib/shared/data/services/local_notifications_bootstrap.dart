import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Coordinates one-time initialization of the singleton
/// [FlutterLocalNotificationsPlugin].
///
/// The plugin factory returns a shared instance, so repeated `initialize()`
/// calls from different services overwrite the tap callback registered on the
/// method channel. This helper ensures we only initialize when necessary and
/// allows a later caller to upgrade the bootstrap with a tap callback.
abstract final class LocalNotificationsBootstrap {
  static bool _initialized = false;
  static bool _hasTapCallback = false;

  static Future<bool?> ensureInitialized({
    required FlutterLocalNotificationsPlugin plugin,
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async {
    final needsCallbackUpgrade =
        onDidReceiveNotificationResponse != null && !_hasTapCallback;

    if (_initialized && !needsCallbackUpgrade) {
      return true;
    }

    final result = await plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    _initialized = true;
    _hasTapCallback =
        _hasTapCallback || onDidReceiveNotificationResponse != null;

    return result;
  }

  @visibleForTesting
  static void resetForTesting() {
    _initialized = false;
    _hasTapCallback = false;
  }
}
