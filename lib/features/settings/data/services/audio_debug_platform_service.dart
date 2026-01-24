/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/services
/// 🎯 Feature: settings
/// 🔧 Type: platform service (audio debug test communication)
///
/// Handles platform channel communication with iOS for audio debug tests
/// Bridges Flutter test execution with native iOS timer audio system
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Audio debug platform service for iOS communication
class AudioDebugPlatformService {
  static const String _tag = 'AudioDebugPlatformService';

  // Platform channel for audio debug tests
  static const MethodChannel _channel = MethodChannel('com.gymbro.fitlog/audio_debug');

  // Callback for test results
  final _testResultController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get testResults => _testResultController.stream;

  bool _isInitialized = false;

  /// Initialize platform channel and setup callbacks
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('[$_tag] Already initialized');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[$_tag] Initializing platform channel');
    }

    // Setup method call handler for iOS → Flutter callbacks
    _channel.setMethodCallHandler(_handleMethodCall);

    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('[$_tag] Platform channel initialized');
    }
  }

  /// Handle method calls from iOS
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (kDebugMode) {
      debugPrint('[$_tag] Received method call: ${call.method}');
      debugPrint('[$_tag] Arguments: ${call.arguments}');
    }

    switch (call.method) {
      case 'onAudioTestCompleted':
        _handleTestCompleted(call.arguments as Map<dynamic, dynamic>);
        break;

      case 'onAudioPlayed':
        _handleAudioPlayed(call.arguments as Map<dynamic, dynamic>);
        break;

      case 'onTestProgress':
        _handleTestProgress(call.arguments as Map<dynamic, dynamic>);
        break;

      default:
        if (kDebugMode) {
          debugPrint('[$_tag] Unknown method: ${call.method}');
        }
    }
  }

  /// Handle test completed callback from iOS
  void _handleTestCompleted(Map<dynamic, dynamic> args) {
    final testId = args['testId'] as String;
    final actualSounds = args['actualSounds'] as int;
    final traceId = args['traceId'] as String?;
    final success = args['success'] as bool? ?? true;

    if (kDebugMode) {
      debugPrint('[$_tag] Test completed: $testId');
      debugPrint('[$_tag] Actual sounds: $actualSounds');
      debugPrint('[$_tag] Trace ID: $traceId');
      debugPrint('[$_tag] Success: $success');
    }

    _testResultController.add({
      'type': 'completed',
      'testId': testId,
      'actualSounds': actualSounds,
      'traceId': traceId ?? '',
      'success': success,
    });
  }

  /// Handle audio played event from iOS
  void _handleAudioPlayed(Map<dynamic, dynamic> args) {
    final traceId = args['traceId'] as String;
    final method = args['method'] as String; // 'AVAudioPlayer', 'notification', 'liveActivity'

    if (kDebugMode) {
      debugPrint('[$_tag] Audio played: $traceId via $method');
    }

    _testResultController.add({
      'type': 'audioPlayed',
      'traceId': traceId,
      'method': method,
    });
  }

  /// Handle test progress update from iOS
  void _handleTestProgress(Map<dynamic, dynamic> args) {
    final testId = args['testId'] as String;
    final progress = args['progress'] as double;

    if (kDebugMode) {
      debugPrint('[$_tag] Test progress: $testId - ${(progress * 100).toStringAsFixed(0)}%');
    }

    _testResultController.add({
      'type': 'progress',
      'testId': testId,
      'progress': progress,
    });
  }

  /// Start audio test on iOS
  ///
  /// [testId] - Unique test identifier (e.g., 'A', 'B', 'C', 'TC-1-1')
  /// [duration] - Timer duration in seconds
  /// [appState] - 'foreground' or 'background'
  /// [liveActivityEnabled] - Whether to enable Live Activity
  Future<String?> startAudioTest({
    required String testId,
    required int duration,
    required String appState,
    required bool liveActivityEnabled,
  }) async {
    if (kDebugMode) {
      debugPrint('[$_tag] Starting audio test: $testId');
      debugPrint('[$_tag] Duration: ${duration}s, AppState: $appState, LA: $liveActivityEnabled');
    }

    try {
      final result = await _channel.invokeMethod<String>('startAudioTest', {
        'testId': testId,
        'duration': duration,
        'appState': appState,
        'liveActivityEnabled': liveActivityEnabled,
      });

      if (kDebugMode) {
        debugPrint('[$_tag] Test started successfully. Trace ID: $result');
      }

      return result;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[$_tag] Failed to start test: $e\n$stack');
      }
      rethrow;
    }
  }

  /// Cancel ongoing test
  Future<void> cancelTest(String testId) async {
    if (kDebugMode) {
      debugPrint('[$_tag] Cancelling test: $testId');
    }

    try {
      await _channel.invokeMethod('cancelTest', {
        'testId': testId,
      });

      if (kDebugMode) {
        debugPrint('[$_tag] Test cancelled: $testId');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[$_tag] Failed to cancel test: $e\n$stack');
      }
      rethrow;
    }
  }

  /// Request app to go to background (for background tests)
  Future<void> requestBackgroundMode() async {
    if (kDebugMode) {
      debugPrint('[$_tag] Requesting background mode');
    }

    try {
      await _channel.invokeMethod('requestBackgroundMode');

      if (kDebugMode) {
        debugPrint('[$_tag] Background mode requested');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[$_tag] Failed to request background mode: $e\n$stack');
      }
      // Non-fatal, continua comunque
    }
  }

  /// Dispose resources
  void dispose() {
    if (kDebugMode) {
      debugPrint('[$_tag] Disposing platform service');
    }

    _testResultController.close();
  }
}

/// Provider for audio debug platform service
final audioDebugPlatformServiceProvider = Provider<AudioDebugPlatformService>((ref) {
  final service = AudioDebugPlatformService();

  // Initialize on first access
  service.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
