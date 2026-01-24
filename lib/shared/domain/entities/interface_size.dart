import 'package:hive_ce_flutter/hive_flutter.dart';

part 'interface_size.g.dart';

/// Interface Size Options
///
/// Unifies font size and set row display mode into a single UX control.
/// This simplifies the settings experience by consolidating two related
/// concerns (text size + layout spacing) into one coherent choice.
///
/// Persona Impact:
/// - Marco (Beginner): ✅ Less confusion - 1 choice instead of 2
/// - Chiara (Multitask): ✅ Faster - single tap to adjust interface
/// - Luca (Powerlifter): ⚠️ Less granular but still has 3 options
/// - Sofia (Aesthetic): ✅ Simpler, cleaner settings
/// - Roberto (Busy): ✅ More efficient - no time wasted on 2 toggles
@HiveType(typeId: 100)
enum InterfaceSize {
  /// Compact interface: small text + tight spacing
  /// - Font scale: 0.8x
  /// - Set row mode: compact
  /// - Use case: Power users who want to see more data on screen
  @HiveField(0)
  compact(
    fontSize: 0.8,
    setRowMode: 'compact',
  ),

  /// Standard interface: medium text + comfortable spacing (default)
  /// - Font scale: 1.0x
  /// - Set row mode: comfortable
  /// - Use case: Most users, balanced readability and density
  @HiveField(1)
  standard(
    fontSize: 1.0,
    setRowMode: 'comfortable',
  ),

  /// Large interface: big text + extra spacing
  /// - Font scale: 1.2x
  /// - Set row mode: comfortable
  /// - Use case: Users who prefer larger text for better readability
  @HiveField(2)
  large(
    fontSize: 1.2,
    setRowMode: 'comfortable',
  );

  const InterfaceSize({
    required this.fontSize,
    required this.setRowMode,
  });

  /// Font scale multiplier (0.8, 1.0, 1.2)
  final double fontSize;

  /// Set row display mode ('compact' or 'comfortable')
  /// Maps to SetDisplayMode enum in set_display_provider
  final String setRowMode;

  /// Convert from fontSize value to InterfaceSize enum
  /// Used for backward compatibility when loading old configs
  static InterfaceSize fromFontSize(double fontSize) {
    if (fontSize <= 0.85) return InterfaceSize.compact;
    if (fontSize <= 1.05) return InterfaceSize.standard;
    return InterfaceSize.large;
  }

  /// Convert to JSON-serializable string
  String toJson() => name;

  /// Convert from JSON string
  static InterfaceSize fromJson(String json) {
    return InterfaceSize.values.firstWhere(
      (e) => e.name == json,
      orElse: () => InterfaceSize.standard,
    );
  }
}
