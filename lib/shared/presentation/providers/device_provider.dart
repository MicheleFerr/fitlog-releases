/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: shared/presentation/providers
/// Feature: Device Detection Providers
/// Type: Riverpod Providers
///
/// Provides device detection state for web mobile detection and routing.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/shared/domain/services/device_detection_service.dart';

/// Provider for DeviceDetectionService singleton
final deviceDetectionServiceProvider = Provider<DeviceDetectionService>((ref) {
  return DeviceDetectionService();
});

/// Provider to check if current platform is web
final isWebProvider = Provider<bool>((ref) {
  return kIsWeb;
});

/// State class for mobile web detection
class MobileWebState {

  const MobileWebState({
    required this.isMobileWeb,
    required this.hasSeenWarning,
    required this.userAgent,
  });
  final bool isMobileWeb;
  final bool hasSeenWarning;
  final String userAgent;

  MobileWebState copyWith({
    bool? isMobileWeb,
    bool? hasSeenWarning,
    String? userAgent,
  }) {
    return MobileWebState(
      isMobileWeb: isMobileWeb ?? this.isMobileWeb,
      hasSeenWarning: hasSeenWarning ?? this.hasSeenWarning,
      userAgent: userAgent ?? this.userAgent,
    );
  }
}

/// Notifier for mobile web state
class MobileWebNotifier extends Notifier<MobileWebState> {
  @override
  MobileWebState build() {
    return const MobileWebState(
      isMobileWeb: false,
      hasSeenWarning: false,
      userAgent: '',
    );
  }

  /// Update mobile detection based on screen width and user agent
  void updateDetection({
    required double screenWidth,
    required String userAgent,
  }) {
    if (!kIsWeb) {
      state = state.copyWith(isMobileWeb: false);
      return;
    }

    final service = DeviceDetectionService();
    final isMobile = service.isMobileWeb(screenWidth) ||
        service.isMobileUserAgent(userAgent);

    state = state.copyWith(
      isMobileWeb: isMobile,
      userAgent: userAgent,
    );
  }

  /// Mark that user has seen the mobile warning
  void markWarningSeen() {
    state = state.copyWith(hasSeenWarning: true);
  }

  /// Reset warning (for testing)
  void resetWarning() {
    state = state.copyWith(hasSeenWarning: false);
  }
}

/// Provider for mobile web state with notifier
final mobileWebProvider = NotifierProvider<MobileWebNotifier, MobileWebState>(
  MobileWebNotifier.new,
);

/// Simple provider to check if should show mobile warning
///
/// Returns true if:
/// - Running on web
/// - Detected as mobile
/// - User hasn't seen warning yet
final shouldShowMobileWarningProvider = Provider<bool>((ref) {
  final mobileState = ref.watch(mobileWebProvider);
  return mobileState.isMobileWeb && !mobileState.hasSeenWarning;
});
