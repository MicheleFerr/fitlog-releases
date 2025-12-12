/// GymBro TrackLog - Flutter Fitness App
///
/// SafeScrollControllerMixin - Prevents memory leaks with scroll controllers
///
/// **Problem Solved:**
/// When a widget accepts an optional external ScrollController:
/// - If external: addListener but DON'T dispose (controller owned externally)
/// - BUT you MUST removeListener, or memory leak!
///
/// **Usage:**
/// ```dart
/// class _MyWidgetState extends State<MyWidget>
///     with SafeScrollControllerMixin {
///
///   @override
///   void initState() {
///     super.initState();
///     initScrollController(
///       externalController: widget.controller,
///       onScroll: _onScroll,
///     );
///   }
///
///   @override
///   void dispose() {
///     disposeScrollController();
///     super.dispose();
///   }
///
///   void _onScroll() { /* handle scroll */ }
/// }
/// ```
library;

import 'package:flutter/material.dart';

/// Mixin that safely manages ScrollController lifecycle
///
/// Automatically handles:
/// - Creating internal controller if no external one provided
/// - Adding listener to controller
/// - Removing listener on dispose (CRITICAL - prevents memory leak)
/// - Disposing internal controller only (external ones managed by owner)
mixin SafeScrollControllerMixin<T extends StatefulWidget> on State<T> {
  ScrollController? _scrollController;
  bool _ownsController = false;
  VoidCallback? _scrollListener;

  /// The scroll controller - use this in your build method
  ScrollController get scrollController {
    assert(_scrollController != null, 'Call initScrollController() in initState first');
    return _scrollController!;
  }

  /// Initialize the scroll controller
  ///
  /// [externalController] - Optional controller from widget props
  /// [onScroll] - Callback for scroll events (will be properly cleaned up)
  /// [initialScrollOffset] - Initial offset for internal controller
  void initScrollController({
    ScrollController? externalController,
    VoidCallback? onScroll,
    double initialScrollOffset = 0.0,
  }) {
    if (externalController != null) {
      _scrollController = externalController;
      _ownsController = false;
    } else {
      _scrollController = ScrollController(
        initialScrollOffset: initialScrollOffset,
      );
      _ownsController = true;
    }

    if (onScroll != null) {
      _scrollListener = onScroll;
      _scrollController!.addListener(_scrollListener!);
    }
  }

  /// Dispose the scroll controller safely
  ///
  /// MUST be called in your State's dispose() method BEFORE super.dispose()
  void disposeScrollController() {
    // Always remove listener to prevent memory leaks
    if (_scrollListener != null) {
      _scrollController?.removeListener(_scrollListener!);
      _scrollListener = null;
    }

    // Only dispose if we own the controller
    if (_ownsController) {
      _scrollController?.dispose();
    }

    _scrollController = null;
  }

  /// Check if scroll is near bottom (useful for lazy loading)
  ///
  /// [threshold] - How close to bottom to trigger (0.0-1.0, default 0.8 = 80%)
  bool isNearBottom({double threshold = 0.8}) {
    if (_scrollController == null || !_scrollController!.hasClients) {
      return false;
    }

    final maxScroll = _scrollController!.position.maxScrollExtent;
    final currentScroll = _scrollController!.position.pixels;

    return currentScroll >= maxScroll * threshold;
  }

  /// Check if scroll is near top
  ///
  /// [threshold] - How close to top to trigger (pixels, default 100)
  bool isNearTop({double threshold = 100.0}) {
    if (_scrollController == null || !_scrollController!.hasClients) {
      return false;
    }

    return _scrollController!.position.pixels <= threshold;
  }

  /// Scroll to top with animation
  Future<void> scrollToTop({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) async {
    if (_scrollController == null || !_scrollController!.hasClients) {
      return;
    }

    await _scrollController!.animateTo(
      0,
      duration: duration,
      curve: curve,
    );
  }

  /// Scroll to bottom with animation
  Future<void> scrollToBottom({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) async {
    if (_scrollController == null || !_scrollController!.hasClients) {
      return;
    }

    await _scrollController!.animateTo(
      _scrollController!.position.maxScrollExtent,
      duration: duration,
      curve: curve,
    );
  }
}
