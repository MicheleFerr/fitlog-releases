import 'package:flutter/material.dart';

/// Utility class for calculating spotlight positioning and visibility checks
///
/// Provides static methods for determining optimal placement of spotlight overlays,
/// checking widget visibility, and calculating scroll offsets needed for centering.
class SpotlightPositioningUtil {
  SpotlightPositioningUtil._(); // Private constructor - utility class only

  /// Default padding around spotlight element
  static const double defaultSpotlightPadding = 8.0;

  /// Calculates the offset needed to center a widget on screen
  ///
  /// Takes the target bounds and screen size, and calculates the offset that
  /// would position the widget in the center of the screen.
  ///
  /// Parameters:
  ///   - [targetBounds]: The global bounds (Rect) of the target widget
  ///   - [screenSize]: The size of the screen (from MediaQuery)
  ///   - [padding]: Optional padding around the spotlight (default: 8.0)
  ///
  /// Returns: An [Offset] representing the calculated centering position
  ///
  /// Example:
  /// ```dart
  /// final bounds = Rect.fromLTWH(100, 200, 80, 60);
  /// final offset = SpotlightPositioningUtil.calculateCenteringOffset(
  ///   bounds,
  ///   Size(375, 812),
  /// );
  /// // offset will position the spotlight to center the widget
  /// ```
  static Offset calculateCenteringOffset({
    required Rect targetBounds,
    required Size screenSize,
    double padding = defaultSpotlightPadding,
  }) {
    // Calculate center of target
    final targetCenter = targetBounds.center;

    // Calculate center of screen
    final screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);

    // Calculate offset needed to center element
    final offsetX = screenCenter.dx - targetCenter.dx;
    final offsetY = screenCenter.dy - targetCenter.dy;

    return Offset(offsetX, offsetY);
  }

  /// Checks if a widget is completely visible within the viewport
  ///
  /// Returns true only if the entire widget is within the visible screen area.
  /// Takes into account safe areas and system UI (status bar, navigation bar).
  ///
  /// Parameters:
  ///   - [targetBounds]: The global bounds of the target widget
  ///   - [screenSize]: The size of the screen
  ///   - [viewInsets]: The view insets (safe areas) from MediaQuery
  ///
  /// Returns: A boolean indicating whether the widget is completely visible
  ///
  /// Example:
  /// ```dart
  /// final visible = SpotlightPositioningUtil.isWidgetVisible(
  ///   bounds,
  ///   mediaQuery.size,
  ///   mediaQuery.viewInsets,
  /// );
  /// if (!visible) {
  ///   // Widget needs to be scrolled into view
  /// }
  /// ```
  static bool isWidgetVisible({
    required Rect targetBounds,
    required Size screenSize,
    required EdgeInsets viewInsets,
  }) {
    // Define visible area (accounting for safe areas)
    final visibleArea = Rect.fromLTWH(
      0,
      0,
      screenSize.width,
      screenSize.height - viewInsets.bottom,
    );

    // Check if entire widget is within visible area
    return visibleArea.contains(targetBounds.topLeft) &&
        visibleArea.contains(targetBounds.bottomRight);
  }

  /// Checks if a widget is at least partially visible in the viewport
  ///
  /// Returns true if any part of the widget intersects with the visible area.
  /// More lenient than [isWidgetVisible].
  ///
  /// Parameters:
  ///   - [targetBounds]: The global bounds of the target widget
  ///   - [screenSize]: The size of the screen
  ///   - [viewInsets]: The view insets from MediaQuery
  ///
  /// Returns: A boolean indicating whether widget is partially/fully visible
  static bool isWidgetPartiallyVisible({
    required Rect targetBounds,
    required Size screenSize,
    required EdgeInsets viewInsets,
  }) {
    // Define visible area
    final visibleArea = Rect.fromLTWH(
      0,
      0,
      screenSize.width,
      screenSize.height - viewInsets.bottom,
    );

    // Check if any part overlaps
    return targetBounds.overlaps(visibleArea);
  }

  /// Calculates the scroll offset needed to center a widget
  ///
  /// Determines how much a ScrollView needs to scroll (up or down) to position
  /// the target widget in the center of the viewport.
  ///
  /// Parameters:
  ///   - [targetBounds]: The global bounds of the target widget
  ///   - [screenSize]: The size of the screen
  ///   - [currentScrollOffset]: The current scroll position
  ///
  /// Returns: A double representing the target scroll offset, or null if calculation fails
  ///
  /// Example:
  /// ```dart
  /// final scrollOffset = SpotlightPositioningUtil.calculateScrollOffsetToCenter(
  ///   targetBounds: widgetBounds,
  ///   screenSize: mediaQuery.size,
  ///   currentScrollOffset: scrollController.offset,
  /// );
  /// if (scrollOffset != null) {
  ///   await scrollController.animateTo(
  ///     scrollOffset,
  ///     duration: Duration(milliseconds: 500),
  ///     curve: Curves.easeInOut,
  ///   );
  /// }
  /// ```
  static double? calculateScrollOffsetToCenter({
    required Rect targetBounds,
    required Size screenSize,
    required double currentScrollOffset,
  }) {
    try {
      final screenCenter = screenSize.height / 2;
      final targetCenter = targetBounds.center.dy;

      // Calculate how much to scroll to center the widget
      return currentScrollOffset + (targetCenter - screenCenter);
    } catch (e) {
      debugPrint('Error calculating scroll offset: $e');
      return null;
    }
  }

  /// Validates that a Rect is valid and represents a reasonable widget bounds
  ///
  /// Checks:
  ///   - Rect is not empty
  ///   - Coordinates are non-negative
  ///   - Size is positive (width > 0, height > 0)
  ///   - Position is within reasonable screen bounds
  ///
  /// Parameters:
  ///   - [bounds]: The Rect to validate
  ///   - [screenSize]: The screen size for boundary validation
  ///
  /// Returns: True if bounds are valid, false otherwise
  ///
  /// Example:
  /// ```dart
  /// if (SpotlightPositioningUtil.validateBounds(bounds, screenSize)) {
  ///   // Bounds are safe to use
  /// } else {
  ///   // Bounds are invalid or out of bounds
  /// }
  /// ```
  static bool validateBounds(Rect? bounds, Size screenSize) {
    if (bounds == null) return false;
    if (bounds.isEmpty) return false;
    if (bounds.width <= 0 || bounds.height <= 0) return false;
    if (bounds.left < 0 || bounds.top < 0) return false;
    if (bounds.right > screenSize.width * 1.5)
      return false; // Allow slight overflow
    if (bounds.bottom > screenSize.height * 1.5) return false;

    return true;
  }

  /// Calculates the spotlight Rect with padding
  ///
  /// Creates a slightly larger rect around the target widget to provide
  /// visual padding around the spotlight "hole".
  ///
  /// Parameters:
  ///   - [targetBounds]: The original widget bounds
  ///   - [padding]: Padding to add around the widget (default: 8.0)
  ///
  /// Returns: A new Rect that is [padding] pixels larger on all sides
  static Rect calculateSpotlightRect({
    required Rect targetBounds,
    double padding = defaultSpotlightPadding,
  }) {
    return Rect.fromLTRB(
      targetBounds.left - padding,
      targetBounds.top - padding,
      targetBounds.right + padding,
      targetBounds.bottom + padding,
    );
  }

  /// Calculates the distance to scroll for a widget to reach screen center
  ///
  /// Determines the absolute scroll value needed to center the widget.
  ///
  /// Parameters:
  ///   - [targetBounds]: Global bounds of the target widget
  ///   - [screenHeight]: Height of the screen
  ///
  /// Returns: The absolute scroll offset needed, or null if invalid
  static double? getAbsoluteScrollOffsetForCenter({
    required Rect targetBounds,
    required double screenHeight,
  }) {
    try {
      final widgetCenter = targetBounds.center.dy;
      final screenCenter = screenHeight / 2;

      // Return the offset needed to position widget center at screen center
      return widgetCenter - screenCenter;
    } catch (e) {
      debugPrint('Error calculating absolute scroll offset: $e');
      return null;
    }
  }

  /// Constrains bounds to ensure spotlight doesn't go beyond screen
  ///
  /// Adjusts the spotlight rect to keep it fully within screen bounds,
  /// useful when widget is near screen edges.
  ///
  /// Parameters:
  ///   - [spotlightBounds]: The spotlight rect to constrain
  ///   - [screenSize]: The screen dimensions
  ///   - [margin]: Margin to maintain from screen edge (default: 16.0)
  ///
  /// Returns: A constrained Rect that fits within screen bounds
  static Rect constrainToScreen({
    required Rect spotlightBounds,
    required Size screenSize,
    double margin = 16.0,
  }) {
    var left = spotlightBounds.left;
    var top = spotlightBounds.top;
    var right = spotlightBounds.right;
    var bottom = spotlightBounds.bottom;

    // Constrain horizontally
    if (left < margin) left = margin;
    if (right > screenSize.width - margin) {
      right = screenSize.width - margin;
      left = right - spotlightBounds.width;
    }

    // Constrain vertically
    if (top < margin) top = margin;
    if (bottom > screenSize.height - margin) {
      bottom = screenSize.height - margin;
      top = bottom - spotlightBounds.height;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }
}
