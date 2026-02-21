/// Set Display Settings Provider
///
/// Derives set row display mode from ExerciseCardSettings density.
/// Single source of truth: exerciseCardSettingsProvider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise_card_settings.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/exercise_card_settings_provider.dart';

/// Display mode for set rows
enum SetDisplayMode {
  /// Compact mode - smaller padding, tighter layout
  compact,

  /// Comfortable mode (default) - larger padding, more spacious
  comfortable,
}

/// Extension to get display values
extension SetDisplayModeExtension on SetDisplayMode {
  /// Vertical padding for the set row
  double get verticalPadding => switch (this) {
    SetDisplayMode.compact => 6.0,
    SetDisplayMode.comfortable => 12.0,
  };

  /// Horizontal padding for the set row
  double get horizontalPadding => switch (this) {
    SetDisplayMode.compact => 6.0,
    SetDisplayMode.comfortable => 8.0,
  };

  /// Bottom margin between sets
  double get bottomMargin => switch (this) {
    SetDisplayMode.compact => 4.0,
    SetDisplayMode.comfortable => 8.0,
  };

  /// Set number circle size
  double get circleSize => switch (this) {
    SetDisplayMode.compact => 22.0,
    SetDisplayMode.comfortable => 28.0,
  };

  /// Border radius
  double get borderRadius => switch (this) {
    SetDisplayMode.compact => 8.0,
    SetDisplayMode.comfortable => 12.0,
  };
}

/// Derives SetDisplayMode from ExerciseCardDensity (single source of truth)
SetDisplayMode _densityToDisplayMode(ExerciseCardDensity density) {
  return switch (density) {
    ExerciseCardDensity.compact => SetDisplayMode.compact,
    ExerciseCardDensity.standard => SetDisplayMode.comfortable,
    ExerciseCardDensity.extended => SetDisplayMode.comfortable,
  };
}

/// Provider for set display mode - derived from ExerciseCardSettings density
final setDisplayProvider = Provider<SetDisplayMode>((ref) {
  final density = ref.watch(exerciseCardDensityProvider);
  return _densityToDisplayMode(density);
});
