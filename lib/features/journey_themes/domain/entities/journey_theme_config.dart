/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/journey_themes/domain/entities
/// Feature: Journey Themes Gamification
/// Type: Entity (Hive Persistable)
///
/// Persisted configuration for the selected journey theme.
/// Uses Hive_ce for local storage.
library;

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/journey_theme.dart';

part 'journey_theme_config.g.dart';

/// Persisted journey theme configuration
@HiveType(typeId: 70)  // Changed from 50 to avoid conflict with WeightSettingsModel
class JourneyThemeConfig extends HiveObject {
  JourneyThemeConfig({
    JourneyTheme? selectedTheme,
    this.previewMode = false,
    DateTime? lastChanged,
    this.customNickname,
  })  : selectedTheme = selectedTheme ?? JourneyTheme.hunter,
        lastChanged = lastChanged ?? DateTime.now();

  /// Currently selected journey theme
  @HiveField(0)
  final JourneyTheme selectedTheme;

  /// Whether user is in preview mode (temporary theme viewing)
  @HiveField(1)
  final bool previewMode;

  /// Timestamp of last theme change
  @HiveField(2)
  final DateTime lastChanged;

  /// Optional custom nickname for personalized greetings
  /// If null, uses the theme's displayName (e.g., "Hero", "Hunter")
  @HiveField(3)
  final String? customNickname;

  /// Create a copy with modified fields
  JourneyThemeConfig copyWith({
    JourneyTheme? selectedTheme,
    bool? previewMode,
    DateTime? lastChanged,
    String? customNickname,
    bool clearNickname = false,
  }) {
    return JourneyThemeConfig(
      selectedTheme: selectedTheme ?? this.selectedTheme,
      previewMode: previewMode ?? this.previewMode,
      lastChanged: lastChanged ?? this.lastChanged,
      customNickname: clearNickname ? null : (customNickname ?? this.customNickname),
    );
  }

  /// Get the display name to use in greetings
  /// Returns customNickname if set, otherwise the theme's displayName
  String get greetingName => customNickname ?? selectedTheme.displayName;

  /// Default configuration
  static JourneyThemeConfig get defaultConfig => JourneyThemeConfig();

  @override
  String toString() =>
      'JourneyThemeConfig(theme: ${selectedTheme.displayName}, preview: $previewMode)';
}

/// Hive TypeAdapter for JourneyTheme enum (manual, not generated)
class JourneyThemeAdapter extends TypeAdapter<JourneyTheme> {
  @override
  final int typeId = 71;  // Changed from 51 to avoid conflict with PlateOptionModel

  @override
  JourneyTheme read(BinaryReader reader) {
    final index = reader.readInt();
    // Safely handle out-of-range indices
    if (index < 0 || index >= JourneyTheme.values.length) {
      return JourneyTheme.hunter; // Default fallback
    }
    return JourneyTheme.values[index];
  }

  @override
  void write(BinaryWriter writer, JourneyTheme obj) {
    writer.writeInt(obj.index);
  }
}
