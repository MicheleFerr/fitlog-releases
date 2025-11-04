import 'package:flutter/material.dart';

/// Extension on BuildContext to get absolute widget coordinates in global space
///
/// Provides methods for calculating global paint bounds, center position, and size
/// of the current widget context.
extension GlobalPaintBoundsExtension on BuildContext {
  /// Gets the absolute bounds of the widget in global screen coordinates
  ///
  /// Returns a [Rect] with the global position and size of the widget,
  /// or null if the widget is not mounted or doesn't have a RenderObject.
  ///
  /// Example:
  /// ```dart
  /// final bounds = context.globalPaintBounds;
  /// if (bounds != null) {
  ///   print('Widget at: ${bounds.topLeft}, size: ${bounds.size}');
  /// }
  /// ```
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    if (renderObject is! RenderBox) {
      return null;
    }

    try {
      final translation = renderObject.getTransformTo(null).getTranslation();
      final offset = Offset(translation.x, translation.y);
      return Rect.fromLTWH(
        offset.dx,
        offset.dy,
        renderObject.size.width,
        renderObject.size.height,
      );
    } catch (e) {
      debugPrint('Error getting globalPaintBounds: $e');
      return null;
    }
  }

  /// Gets the global center position of the widget
  ///
  /// Calculates the center point of the widget's bounds in global coordinates.
  /// Returns null if the widget is not mounted or doesn't have a RenderObject.
  ///
  /// Example:
  /// ```dart
  /// final center = context.globalCenter;
  /// if (center != null) {
  ///   print('Widget center at: $center');
  /// }
  /// ```
  Offset? get globalCenter {
    final bounds = globalPaintBounds;
    return bounds?.center;
  }

  /// Gets the size of the widget in logical pixels
  ///
  /// Returns the width and height of the widget, or null if not mounted.
  ///
  /// Example:
  /// ```dart
  /// final size = context.widgetSize;
  /// if (size != null) {
  ///   print('Widget size: ${size.width}x${size.height}');
  /// }
  /// ```
  Size? get widgetSize {
    final renderObject = findRenderObject();
    return (renderObject is RenderBox) ? renderObject.size : null;
  }

  /// Checks if the widget is within the visible viewport
  ///
  /// Returns true if any part of the widget is visible on screen.
  /// Uses MediaQuery to determine screen bounds and accounting for safe areas.
  ///
  /// Example:
  /// ```dart
  /// if (context.isWidgetInViewport) {
  ///   print('Widget is visible');
  /// }
  /// ```
  bool get isWidgetInViewport {
    final bounds = globalPaintBounds;
    if (bounds == null) return false;

    final mediaQuery = MediaQuery.of(this);
    final screenSize = mediaQuery.size;

    // Check if widget bounds intersect with visible screen area
    final visibleArea = Rect.fromLTWH(
      0,
      0,
      screenSize.width,
      screenSize.height - mediaQuery.viewInsets.bottom,
    );

    return bounds.overlaps(visibleArea);
  }

  /// Gets the offset amount needed to scroll to center this widget
  ///
  /// Useful for auto-scrolling widgets into view. Returns the amount to scroll
  /// from the current position to center the widget on screen.
  ///
  /// Example:
  /// ```dart
  /// final scrollOffset = context.scrollOffsetToCenter;
  /// if (scrollOffset != null) {
  ///   scrollController.animateTo(scrollOffset, ...);
  /// }
  /// ```
  double? get scrollOffsetToCenter {
    final bounds = globalPaintBounds;
    if (bounds == null) return null;

    final mediaQuery = MediaQuery.of(this);
    final screenHeight = mediaQuery.size.height;
    final widgetCenter = bounds.center.dy;
    const screenCenter = 0.5; // Middle of screen

    // Calculate scroll offset to center widget
    return widgetCenter - (screenHeight * screenCenter);
  }
}
