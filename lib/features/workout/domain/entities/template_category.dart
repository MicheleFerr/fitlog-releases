import 'package:flutter/material.dart';

/// Template category with semantic gradient colors
///
/// Each category has distinct visual identity through color gradients
/// that adapt to light/dark themes for optimal contrast.
enum TemplateCategory {
  /// Strength training (weights, resistance)
  /// Gradient: Red shades (warm, powerful)
  strength,

  /// Cardio training (running, cycling, HIIT)
  /// Gradient: Blue shades (energetic, dynamic)
  cardio,

  /// Flexibility/mobility training (stretching, yoga)
  /// Gradient: Green shades (calm, balanced)
  flexibility,

  /// Hybrid training (combined modalities)
  /// Gradient: Purple shades (versatile, comprehensive)
  hybrid;

  /// Get localized display name
  String localizedName(BuildContext context) {
    switch (this) {
      case TemplateCategory.strength:
        return 'Template Category Strength';
      case TemplateCategory.cardio:
        return 'Template Category Cardio';
      case TemplateCategory.flexibility:
        return 'Template Category Flexibility';
      case TemplateCategory.hybrid:
        return 'Template Category Hybrid';
    }
  }

  /// Get gradient colors for this category
  ///
  /// Returns [start, end] colors for LinearGradient.
  /// Gradients are theme-aware for proper contrast.
  List<Color> gradientColors(bool isDark) {
    switch (this) {
      case TemplateCategory.strength:
        // Red gradient: powerful, intense
        return isDark
            ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E72)]
            : [const Color(0xFFEF5350), const Color(0xFFFF7043)];

      case TemplateCategory.cardio:
        // Blue gradient: energetic, dynamic
        return isDark
            ? [const Color(0xFF4ECDC4), const Color(0xFF44A5E4)]
            : [const Color(0xFF26C6DA), const Color(0xFF42A5F5)];

      case TemplateCategory.flexibility:
        // Green gradient: calm, balanced
        return isDark
            ? [const Color(0xFF95E1D3), const Color(0xFF6BCB77)]
            : [const Color(0xFF66BB6A), const Color(0xFF4DB6AC)];

      case TemplateCategory.hybrid:
        // Purple gradient: versatile, comprehensive
        return isDark
            ? [const Color(0xFFA8E6CF), const Color(0xFFB19CD9)]
            : [const Color(0xFF9575CD), const Color(0xFF7E57C2)];
    }
  }

  /// Get gradient as LinearGradient widget
  LinearGradient toGradient(bool isDark) {
    final colors = gradientColors(isDark);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }
}
