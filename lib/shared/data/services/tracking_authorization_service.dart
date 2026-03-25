import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymbro_flutter_new/shared/data/platform_channels.dart';

enum TrackingAuthorizationStatus {
  authorized,
  denied,
  restricted,
  notDetermined,
  notSupported,
  unknown,
}

class TrackingAuthorizationService {
  TrackingAuthorizationService._();

  static const MethodChannel _channel = MethodChannel(
    PlatformChannels.trackingAuthorization,
  );
  static const int _channelRetryAttempts = 5;
  static const Duration _channelRetryDelay = Duration(milliseconds: 250);

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static Future<TrackingAuthorizationStatus> getStatus() async {
    if (!isSupported) return TrackingAuthorizationStatus.notSupported;

    final rawStatus = await _invokeStringMethod('getStatus');
    if (rawStatus == null) {
      return TrackingAuthorizationStatus.unknown;
    }

    return _parseStatus(rawStatus);
  }

  static Future<bool> allowsTrackingAccess() async {
    if (!isSupported) return true;

    final status = await getStatus();
    return status == TrackingAuthorizationStatus.authorized;
  }

  static Future<TrackingAuthorizationStatus>
  requestAuthorizationIfNeeded() async {
    if (!isSupported) return TrackingAuthorizationStatus.notSupported;

    final currentStatus = await getStatus();
    if (currentStatus == TrackingAuthorizationStatus.authorized ||
        currentStatus == TrackingAuthorizationStatus.denied ||
        currentStatus == TrackingAuthorizationStatus.restricted ||
        currentStatus == TrackingAuthorizationStatus.notSupported) {
      return currentStatus;
    }

    final rawStatus = await _invokeStringMethod('requestAuthorization');
    if (rawStatus == null) {
      return TrackingAuthorizationStatus.unknown;
    }

    return _parseStatus(rawStatus);
  }

  static Future<String?> _invokeStringMethod(String method) async {
    MissingPluginException? lastMissingPluginError;

    for (var attempt = 1; attempt <= _channelRetryAttempts; attempt++) {
      try {
        return await _channel.invokeMethod<String>(method);
      } on MissingPluginException catch (error) {
        lastMissingPluginError = error;
        if (attempt == _channelRetryAttempts) {
          break;
        }
        await Future<void>.delayed(_channelRetryDelay);
      } on PlatformException catch (error) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ ATT platform call failed for $method: ${error.code} ${error.message ?? ''}',
          );
        }
        return null;
      }
    }

    if (kDebugMode && lastMissingPluginError != null) {
      debugPrint(
        '⚠️ ATT channel unavailable for $method after '
        '$_channelRetryAttempts attempts',
      );
    }

    return null;
  }

  static TrackingAuthorizationStatus _parseStatus(String? rawStatus) {
    return switch (rawStatus) {
      'authorized' => TrackingAuthorizationStatus.authorized,
      'denied' => TrackingAuthorizationStatus.denied,
      'restricted' => TrackingAuthorizationStatus.restricted,
      'notDetermined' => TrackingAuthorizationStatus.notDetermined,
      'notSupported' => TrackingAuthorizationStatus.notSupported,
      _ => TrackingAuthorizationStatus.unknown,
    };
  }
}
