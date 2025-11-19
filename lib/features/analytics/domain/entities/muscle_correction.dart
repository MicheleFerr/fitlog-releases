/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/domain/entities
/// 🎯 Feature: analytics
/// 🔧 Type: entity
///
/// MuscleCorrection - Entity for tracking muscle group corrections
///
/// **Purpose**: Store user corrections to exercise muscle group assignments
///
/// **Use Case**: When user identifies incorrect muscle group for an exercise,
/// they can correct it locally and optionally report to admin for global fix.
///
/// **Workflow**:
/// 1. User long-presses exercise card
/// 2. BottomSheet shows with dropdown for new muscle group
/// 3. User saves → stored in Hive (local immediate fix)
/// 4. Dialog asks "Report to admin?" → if yes, submits to Firestore
/// 5. Admin reviews in Firestore console → approves/rejects
/// 6. User gets notification (real-time listener or push)
///
/// **Fields**:
/// - `exerciseName`: Name of the exercise being corrected
/// - `oldMuscleGroup`: Original (incorrect) muscle group
/// - `newMuscleGroup`: User-selected (correct) muscle group
/// - `timestamp`: When the correction was made
///
/// **Storage**:
/// - Local: Hive (immediate effect on app UI)
/// - Remote: Firestore `muscle_group_feedback` collection (for admin review)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'muscle_correction.freezed.dart';
part 'muscle_correction.g.dart';

/// Muscle group correction entity
///
/// **Immutable** value object using Freezed
@freezed
class MuscleCorrection with _$MuscleCorrection {
  const factory MuscleCorrection({
    /// Exercise name (e.g., "Bench Press", "Squat")
    required String exerciseName,

    /// Original muscle group (e.g., "Chest", "Back")
    required String oldMuscleGroup,

    /// Corrected muscle group (e.g., "Shoulders", "Legs")
    required String newMuscleGroup,

    /// When the correction was made (local timestamp)
    required DateTime timestamp,
  }) = _MuscleCorrection;

  /// Create from JSON (for Hive storage)
  factory MuscleCorrection.fromJson(Map<String, dynamic> json) =>
      _$MuscleCorrectionFromJson(json);
}
