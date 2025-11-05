import 'package:flutter/material.dart';

/// Centralized animation constants for app-wide consistency.
///
/// Provides standardized values for durations, curves, and animation parameters
/// to ensure a consistent feel throughout the application.
///
/// Usage:
/// ```dart
/// AnimationController(
///   duration: AppAnimations.fast,
///   vsync: this,
/// );
///
/// Tween<double>(
///   begin: 1.0,
///   end: AppAnimations.cardPressScale,
/// );
/// ```
class AppAnimations {
  // Private constructor to prevent instantiation
  const AppAnimations._();

  // === Durations ===

  /// Fast animation duration (150ms)
  /// Use for: Quick press/release interactions, hover effects
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animation duration (300ms)
  /// Use for: Standard transitions, page animations
  static const Duration normal = Duration(milliseconds: 300);

  /// Icon swap animation duration (200ms)
  /// Use for: Icon transitions between outlined/filled states
  static const Duration iconSwap = Duration(milliseconds: 200);

  // === Curves ===

  /// Standard easing curve
  /// Use for: Most animations, gentle deceleration
  static const Curve standard = Curves.easeOut;

  /// Decelerate curve for premium feel
  /// Use for: Hero transitions, emphasized animations
  static const Curve decelerate = Curves.easeOutCubic;

  // === Card Press Values ===

  /// Scale factor when card is pressed (0.97 = 3% reduction)
  static const double cardPressScale = 0.97;

  /// Overlay opacity when card is pressed (8%)
  /// Applied on top of card background with accent color
  static const double pressOverlayOpacity = 0.08;

  /// Border opacity when card is pressed (30%)
  /// Optional accent color border around card
  static const double pressedBorderOpacity = 0.30;

  // === Icon Sizes ===

  /// Small icon size (20dp)
  /// Use for: Badges, compact UI elements
  static const double iconSizeSmall = 20.0;

  /// Medium icon size (28dp) - Default
  /// Use for: Standard cards, list items
  static const double iconSizeMedium = 28.0;

  /// Large icon size (32dp)
  /// Use for: Featured actions, headers
  static const double iconSizeLarge = 32.0;
}
