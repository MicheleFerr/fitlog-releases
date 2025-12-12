/// GymBro TrackLog - Flutter Fitness App
///
/// SafeAnimationControllerMixin - Ensures proper animation controller disposal
///
/// **Problem Solved:**
/// AnimationController can leak memory if:
/// - addStatusListener called but never removed
/// - addListener called but never removed
/// - Controller not disposed
///
/// **Usage:**
/// ```dart
/// class _MyWidgetState extends State<MyWidget>
///     with SingleTickerProviderStateMixin, SafeAnimationControllerMixin {
///
///   @override
///   void initState() {
///     super.initState();
///     initAnimationController(
///       duration: Duration(milliseconds: 300),
///       onStatusChange: _onAnimationStatusChange,
///     );
///   }
///
///   @override
///   void dispose() {
///     disposeAnimationController();
///     super.dispose();
///   }
/// }
/// ```
library;

import 'package:flutter/material.dart';

/// Mixin that safely manages AnimationController lifecycle
///
/// Automatically handles:
/// - Creating animation controller with proper vsync
/// - Adding status/value listeners
/// - Removing all listeners on dispose (CRITICAL)
/// - Disposing controller
mixin SafeAnimationControllerMixin<T extends StatefulWidget> on State<T> {
  AnimationController? _animationController;
  final List<VoidCallback> _valueListeners = [];
  final List<AnimationStatusListener> _statusListeners = [];

  /// The animation controller - use this in your build method
  AnimationController get animationController {
    assert(_animationController != null,
        'Call initAnimationController() in initState first');
    return _animationController!;
  }

  /// Initialize the animation controller
  ///
  /// IMPORTANT: Your State class must also use SingleTickerProviderStateMixin
  /// or TickerProviderStateMixin to provide the vsync.
  ///
  /// [duration] - Animation duration
  /// [reverseDuration] - Duration when reversing (optional)
  /// [onValueChange] - Callback for value changes (properly cleaned up)
  /// [onStatusChange] - Callback for status changes (properly cleaned up)
  /// [lowerBound] - Lower bound of animation (default 0.0)
  /// [upperBound] - Upper bound of animation (default 1.0)
  /// [value] - Initial value
  void initAnimationController({
    required Duration duration,
    Duration? reverseDuration,
    VoidCallback? onValueChange,
    AnimationStatusListener? onStatusChange,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    double? value,
  }) {
    assert(this is TickerProvider,
        'State must use SingleTickerProviderStateMixin or TickerProviderStateMixin');

    _animationController = AnimationController(
      vsync: this as TickerProvider,
      duration: duration,
      reverseDuration: reverseDuration,
      lowerBound: lowerBound,
      upperBound: upperBound,
      value: value,
    );

    if (onValueChange != null) {
      addValueListener(onValueChange);
    }

    if (onStatusChange != null) {
      addStatusListener(onStatusChange);
    }
  }

  /// Add a value listener (safely tracked for cleanup)
  void addValueListener(VoidCallback listener) {
    _valueListeners.add(listener);
    _animationController?.addListener(listener);
  }

  /// Add a status listener (safely tracked for cleanup)
  void addStatusListener(AnimationStatusListener listener) {
    _statusListeners.add(listener);
    _animationController?.addStatusListener(listener);
  }

  /// Remove a value listener
  void removeValueListener(VoidCallback listener) {
    _valueListeners.remove(listener);
    _animationController?.removeListener(listener);
  }

  /// Remove a status listener
  void removeStatusListener(AnimationStatusListener listener) {
    _statusListeners.remove(listener);
    _animationController?.removeStatusListener(listener);
  }

  /// Dispose the animation controller safely
  ///
  /// MUST be called in your State's dispose() method BEFORE super.dispose()
  void disposeAnimationController() {
    // Remove all value listeners
    for (final listener in _valueListeners) {
      _animationController?.removeListener(listener);
    }
    _valueListeners.clear();

    // Remove all status listeners
    for (final listener in _statusListeners) {
      _animationController?.removeStatusListener(listener);
    }
    _statusListeners.clear();

    // Dispose controller
    _animationController?.dispose();
    _animationController = null;
  }

  /// Forward animation with mounted check
  Future<void> forwardAnimation({double? from}) async {
    if (!mounted || _animationController == null) return;
    await _animationController!.forward(from: from);
  }

  /// Reverse animation with mounted check
  Future<void> reverseAnimation({double? from}) async {
    if (!mounted || _animationController == null) return;
    await _animationController!.reverse(from: from);
  }

  /// Reset animation
  void resetAnimation() {
    _animationController?.reset();
  }

  /// Check if animation is running
  bool get isAnimating => _animationController?.isAnimating ?? false;

  /// Check if animation is completed
  bool get isCompleted =>
      _animationController?.status == AnimationStatus.completed;

  /// Check if animation is dismissed
  bool get isDismissed =>
      _animationController?.status == AnimationStatus.dismissed;
}
