import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gymbro_flutter_new/core/utils/debug_logger.dart';

/// MEMORY LEAK PREVENTION: Mixin to help manage disposable resources
/// 
/// This mixin provides a unified approach to managing common disposable resources
/// like Timers, StreamSubscriptions, AnimationControllers, etc.
/// 
/// Usage:
/// ```dart
/// class MyProvider extends StateNotifier<MyState> with DisposableResourcesMixin {
///   MyProvider() : super(initialState) {
///     _setupResources();
///   }
///   
///   void _setupResources() {
///     // Register resources for automatic disposal
///     addTimer(Timer.periodic(Duration(seconds: 1), _onTick));
///     addStreamSubscription(someStream.listen(_onData));
///   }
/// }
/// ```
mixin DisposableResourcesMixin {
  final List<Timer> _timers = [];
  final List<StreamSubscription> _subscriptions = [];
  final List<AnimationController> _animationControllers = [];
  final List<AudioPlayer> _audioPlayers = [];
  final List<VoidCallback> _customDisposers = [];
  
  bool _isDisposed = false;
  
  /// Check if resources have been disposed
  bool get isDisposed => _isDisposed;
  
  /// Add a timer to be automatically cancelled on dispose
  void addTimer(Timer timer) {
    if (_isDisposed) {
      DebugLogger.log(LogCategory.performance, '⚠️ Attempting to add timer after disposal');
      timer.cancel();
      return;
    }
    _timers.add(timer);
  }
  
  /// Add a stream subscription to be automatically cancelled on dispose
  void addStreamSubscription(StreamSubscription subscription) {
    if (_isDisposed) {
      DebugLogger.log(LogCategory.performance, '⚠️ Attempting to add subscription after disposal');
      subscription.cancel();
      return;
    }
    _subscriptions.add(subscription);
  }
  
  /// Add an animation controller to be automatically disposed on dispose
  void addAnimationController(AnimationController controller) {
    if (_isDisposed) {
      DebugLogger.log(LogCategory.performance, '⚠️ Attempting to add animation controller after disposal');
      controller.dispose();
      return;
    }
    _animationControllers.add(controller);
  }
  
  /// Add an audio player to be automatically disposed on dispose
  void addAudioPlayer(AudioPlayer player) {
    if (_isDisposed) {
      DebugLogger.log(LogCategory.performance, '⚠️ Attempting to add audio player after disposal');
      player.dispose();
      return;
    }
    _audioPlayers.add(player);
  }
  
  /// Add a custom disposer function to be called on dispose
  void addCustomDisposer(VoidCallback disposer) {
    if (_isDisposed) {
      DebugLogger.log(LogCategory.performance, '⚠️ Attempting to add custom disposer after disposal');
      disposer();
      return;
    }
    _customDisposers.add(disposer);
  }
  
  /// Remove a timer from tracking (useful when timer completes naturally)
  void removeTimer(Timer timer) {
    _timers.remove(timer);
  }
  
  /// Remove a subscription from tracking (useful when subscription completes naturally)
  void removeStreamSubscription(StreamSubscription subscription) {
    _subscriptions.remove(subscription);
  }
  
  /// Dispose all managed resources
  /// Call this from your dispose() method
  void disposeResources() {
    if (_isDisposed) {
      DebugLogger.log(LogCategory.performance, '⚠️ Resources already disposed');
      return;
    }
    
    _isDisposed = true;
    
    DebugLogger.log(LogCategory.performance, 'Disposing resources: ${_timers.length} timers, ${_subscriptions.length} subscriptions, ${_animationControllers.length} controllers, ${_audioPlayers.length} players');
    
    // Cancel all timers
    for (final timer in _timers) {
      try {
        timer.cancel();
      } catch (e) {
        DebugLogger.log(LogCategory.performance, '❌ Error cancelling timer: $e');
      }
    }
    _timers.clear();
    
    // Cancel all stream subscriptions
    for (final subscription in _subscriptions) {
      try {
        subscription.cancel();
      } catch (e) {
        DebugLogger.log(LogCategory.performance, '❌ Error cancelling subscription: $e');
      }
    }
    _subscriptions.clear();
    
    // Dispose all animation controllers
    for (final controller in _animationControllers) {
      try {
        controller.dispose();
      } catch (e) {
        DebugLogger.log(LogCategory.performance, '❌ Error disposing animation controller: $e');
      }
    }
    _animationControllers.clear();
    
    // Dispose all audio players
    for (final player in _audioPlayers) {
      try {
        player.dispose();
      } catch (e) {
        DebugLogger.log(LogCategory.performance, '❌ Error disposing audio player: $e');
      }
    }
    _audioPlayers.clear();
    
    // Call custom disposers
    for (final disposer in _customDisposers) {
      try {
        disposer();
      } catch (e) {
        DebugLogger.log(LogCategory.performance, '❌ Error in custom disposer: $e');
      }
    }
    _customDisposers.clear();
    
    DebugLogger.log(LogCategory.performance, '✅ All resources disposed successfully');
  }
  
  /// Get a report of currently managed resources (for debugging)
  Map<String, int> getResourceReport() {
    return {
      'timers': _timers.length,
      'subscriptions': _subscriptions.length,
      'animationControllers': _animationControllers.length,
      'audioPlayers': _audioPlayers.length,
      'customDisposers': _customDisposers.length,
      'isDisposed': _isDisposed ? 1 : 0,
    };
  }
}

/// Extension for StateNotifier to easily use the mixin
extension DisposableStateNotifier<T> on StateNotifier<T> {
  /// Safe dispose method that handles errors gracefully
  void safeDispose() {
    try {
      if (this is DisposableResourcesMixin) {
        (this as DisposableResourcesMixin).disposeResources();
      }
      dispose();
    } catch (e) {
      DebugLogger.log(LogCategory.performance, '❌ Error during safe dispose: $e');
      // Force disposal to prevent memory leaks
      try {
        dispose();
      } catch (secondaryError) {
        DebugLogger.log(LogCategory.performance, '💥 Critical: Secondary disposal error: $secondaryError');
      }
    }
  }
}

/// Disposable resource tracker for widgets
mixin DisposableWidgetMixin<T extends StatefulWidget> on State<T> {
  final List<Timer> _timers = [];
  final List<StreamSubscription> _subscriptions = [];
  final List<AnimationController> _animationControllers = [];
  
  /// Add a timer to be automatically cancelled on dispose
  void addTimer(Timer timer) {
    _timers.add(timer);
  }
  
  /// Add a stream subscription to be automatically cancelled on dispose
  void addStreamSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }
  
  /// Add an animation controller to be automatically disposed on dispose
  void addAnimationController(AnimationController controller) {
    _animationControllers.add(controller);
  }
  
  /// Dispose all widget resources - call this from dispose()
  void disposeWidgetResources() {
    DebugLogger.log(LogCategory.performance, 'Disposing widget resources: ${_timers.length} timers, ${_subscriptions.length} subscriptions, ${_animationControllers.length} controllers');
    
    // Cancel all timers
    for (final timer in _timers) {
      try {
        timer.cancel();
      } catch (e) {
        DebugLogger.log(LogCategory.performance, '❌ Error cancelling widget timer: $e');
      }
    }
    _timers.clear();
    
    // Cancel all stream subscriptions
    for (final subscription in _subscriptions) {
      try {
        subscription.cancel();
      } catch (e) {
        DebugLogger.log(LogCategory.performance, '❌ Error cancelling widget subscription: $e');
      }
    }
    _subscriptions.clear();
    
    // Dispose all animation controllers
    for (final controller in _animationControllers) {
      try {
        controller.dispose();
      } catch (e) {
        DebugLogger.log(LogCategory.performance, '❌ Error disposing widget animation controller: $e');
      }
    }
    _animationControllers.clear();
    
    DebugLogger.log(LogCategory.performance, '✅ Widget resources disposed successfully');
  }
}