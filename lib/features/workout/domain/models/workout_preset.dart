/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/domain/models
/// 🎯 Feature: workout
/// 🔧 Type: domain model
///
/// Preset models for workout configuration
///
/// ARCHITECTURE (Phase 3 Refactoring):
/// - Domain models for rep, set, and rest time presets
/// - Localization-ready (uses translation keys instead of hardcoded text)
/// - Color-agnostic (colors resolved by theme, not hardcoded)
/// - Configuration-driven (loaded from JSON, not hardcoded)
library;

import 'package:flutter/material.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Rep range preset for different training goals
///
/// Example:
/// ```dart
/// final preset = RepRangePreset(
///   id: 'strength',
///   labelKey: 'repPreset.strength.label',
///   reps: 3,
///   descriptionKey: 'repPreset.strength.description',
///   iconName: 'fitness_center',
///   colorHex: '#E53935',
/// );
/// ```
class RepRangePreset {
  const RepRangePreset({
    required this.id,
    required this.labelKey,
    required this.reps,
    required this.descriptionKey,
    required this.iconName,
    required this.colorHex,
    this.order = 0,
  });

  /// Create from JSON
  factory RepRangePreset.fromJson(Map<String, dynamic> json) {
    return RepRangePreset(
      id: json['id'] as String,
      labelKey: json['labelKey'] as String,
      reps: json['reps'] as int,
      descriptionKey: json['descriptionKey'] as String,
      iconName: json['iconName'] as String,
      colorHex: json['colorHex'] as String,
      order: json['order'] as int? ?? 0,
    );
  }

  /// Unique identifier (e.g., 'strength', 'hypertrophy', 'endurance')
  final String id;

  /// Localization key for label (e.g., 'repPreset.strength.label')
  final String labelKey;

  /// Default rep count for this preset
  final int reps;

  /// Localization key for description (e.g., 'repPreset.strength.description')
  final String descriptionKey;

  /// Icon name (Material Icons) as string (e.g., 'fitness_center')
  final String iconName;

  /// Color as hex string (e.g., '#E53935')
  final String colorHex;

  /// Display order (lower = first)
  final int order;

  /// Parse color from hex string
  /// Falls back to Material Blue 500 (#2196F3) if invalid hex
  Color get color {
    final hex = colorHex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      // Fallback to Material Blue 500 if invalid hex
      // This prevents FormatException crashes like "FFblue"
      return const Color(0xFF2196F3);
    }
  }

  /// Parse icon from name
  IconData get icon {
    return _iconMap[iconName] ?? AppIcons.workout;
  }

  /// Icon name to IconData mapping
  static const Map<String, IconData> _iconMap = {
    'fitness_center': AppIcons.fitnessCenter,
    'bolt': AppIcons.bolt,
    'trending_up': AppIcons.trendingUp,
    'bubble_chart': AppIcons.bubbleChart,
    'timer': AppIcons.timer,
    'all_inclusive': AppIcons.allInclusive,
    'speed': AppIcons.speed,
    'flash_on': AppIcons.flashOn,
    'schedule': AppIcons.schedule,
    'access_time': AppIcons.accessTime,
    'hourglass_empty': AppIcons.hourglassEmpty,
    'timer_off': AppIcons.timerOff,
    'repeat': AppIcons.repeat,
  };

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labelKey': labelKey,
      'reps': reps,
      'descriptionKey': descriptionKey,
      'iconName': iconName,
      'colorHex': colorHex,
      'order': order,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RepRangePreset &&
        other.id == id &&
        other.labelKey == labelKey &&
        other.reps == reps &&
        other.descriptionKey == descriptionKey &&
        other.iconName == iconName &&
        other.colorHex == colorHex &&
        other.order == order;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        labelKey.hashCode ^
        reps.hashCode ^
        descriptionKey.hashCode ^
        iconName.hashCode ^
        colorHex.hashCode ^
        order.hashCode;
  }
}

/// Set count preset
///
/// Example:
/// ```dart
/// final preset = SetCountPreset(
///   id: 'sets_3',
///   sets: 3,
///   order: 2,
/// );
/// ```
class SetCountPreset {
  const SetCountPreset({required this.id, required this.sets, this.order = 0});

  /// Create from JSON
  factory SetCountPreset.fromJson(Map<String, dynamic> json) {
    return SetCountPreset(
      id: json['id'] as String,
      sets: json['sets'] as int,
      order: json['order'] as int? ?? 0,
    );
  }

  /// Unique identifier (e.g., 'sets_3')
  final String id;

  /// Number of sets
  final int sets;

  /// Display order (lower = first)
  final int order;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'sets': sets, 'order': order};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SetCountPreset &&
        other.id == id &&
        other.sets == sets &&
        other.order == order;
  }

  @override
  int get hashCode {
    return id.hashCode ^ sets.hashCode ^ order.hashCode;
  }
}

/// Rest time preset
///
/// Example:
/// ```dart
/// final preset = RestTimePreset(
///   id: 'rest_60',
///   labelKey: 'restPreset.oneMinute',
///   seconds: 60,
///   iconName: 'speed',
/// );
/// ```
class RestTimePreset {
  const RestTimePreset({
    required this.id,
    required this.labelKey,
    required this.seconds,
    required this.iconName,
    this.order = 0,
  });

  /// Create from JSON
  factory RestTimePreset.fromJson(Map<String, dynamic> json) {
    return RestTimePreset(
      id: json['id'] as String,
      labelKey: json['labelKey'] as String,
      seconds: json['seconds'] as int?,
      iconName: json['iconName'] as String,
      order: json['order'] as int? ?? 0,
    );
  }

  /// Unique identifier (e.g., 'rest_60', 'rest_none')
  final String id;

  /// Localization key for label (e.g., 'restPreset.oneMinute')
  final String labelKey;

  /// Rest time in seconds (null = no timer)
  final int? seconds;

  /// Icon name (Material Icons) as string
  final String iconName;

  /// Display order (lower = first)
  final int order;

  /// Parse icon from name
  IconData get icon {
    return RepRangePreset._iconMap[iconName] ?? AppIcons.timer;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labelKey': labelKey,
      'seconds': seconds,
      'iconName': iconName,
      'order': order,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RestTimePreset &&
        other.id == id &&
        other.labelKey == labelKey &&
        other.seconds == seconds &&
        other.iconName == iconName &&
        other.order == order;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        labelKey.hashCode ^
        seconds.hashCode ^
        iconName.hashCode ^
        order.hashCode;
  }
}
