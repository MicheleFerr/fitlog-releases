/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: shared/presentation/widgets
/// Feature: Mobile Web Guard
/// Type: Widget (Guard/Wrapper)
///
/// Wraps content to detect mobile web users and show warning modal.
/// Redirects to landing page if user dismisses modal.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymbro_flutter_new/shared/presentation/providers/device_provider.dart';
import 'package:gymbro_flutter_new/shared/presentation/widgets/mobile_web_warning_modal.dart';

// Conditional import for web user agent
import 'package:gymbro_flutter_new/shared/presentation/widgets/mobile_web_guard_stub.dart'
    if (dart.library.html) 'package:gymbro_flutter_new/shared/presentation/widgets/mobile_web_guard_web.dart'
    as web_impl;

/// Guards content from mobile web users
///
/// When a mobile web user accesses this widget:
/// 1. Detects device type using viewport and user agent
/// 2. Shows [MobileWebWarningModal] if mobile detected
/// 3. User can choose to open app, download, or continue to landing
///
/// Usage:
/// ```dart
/// MobileWebGuard(
///   child: MainShell(navigationShell: navigationShell),
/// )
/// ```
class MobileWebGuard extends ConsumerStatefulWidget {
  const MobileWebGuard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<MobileWebGuard> createState() => _MobileWebGuardState();
}

class _MobileWebGuardState extends ConsumerState<MobileWebGuard> {
  bool _hasChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasChecked && kIsWeb) {
      _hasChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkMobileWeb();
      });
    }
  }

  void _checkMobileWeb() {
    if (!mounted || !kIsWeb) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final userAgent = web_impl.getUserAgent();

    // Update provider with detection
    ref.read(mobileWebProvider.notifier).updateDetection(
          screenWidth: screenWidth,
          userAgent: userAgent,
        );

    final mobileState = ref.read(mobileWebProvider);

    // Show modal if mobile web and hasn't seen warning
    if (mobileState.isMobileWeb && !mobileState.hasSeenWarning) {
      MobileWebWarningModal.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension to easily wrap any widget with mobile web guard
extension MobileWebGuardX on Widget {
  /// Wraps this widget with [MobileWebGuard] for mobile web protection
  Widget withMobileWebGuard() {
    if (!kIsWeb) return this;
    return MobileWebGuard(child: this);
  }
}
