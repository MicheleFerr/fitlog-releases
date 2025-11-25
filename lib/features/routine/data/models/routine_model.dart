/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/routine/data/models
/// 🎯 Feature: flexible_routine
/// 🔧 Type: model
/// 🌍 Localization: N/A
/// 📱 Platform: Universal
///
/// ROUTINE MODEL - v2.0
///
/// Data layer model for Firestore serialization.
/// Handles conversion between FlexibleRoutine entity and Firestore documents.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/flexible_routine.dart';
import 'package:gymbro_flutter_new/features/routine/domain/entities/routine_preset.dart';

part 'routine_model.g.dart';

/// Firestore-serializable model for FlexibleRoutine
///
/// Handles Firestore-specific conversions:
/// - DateTime to/from Timestamp
/// - Set of int to/from List of int (Firestore doesn't support Set)
/// - Map of int/String to/from Map of String/String (Firestore keys must be String)
/// - Set of String to/from List of String
@JsonSerializable(explicitToJson: true)
class RoutineModel {

  const RoutineModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.presetType,
    required this.trainingDays,
    required this.workoutSchedule,
    required this.isActive,
    required this.completedDays,
    required this.totalWorkouts,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON deserialization
  factory RoutineModel.fromJson(Map<String, dynamic> json) =>
      _$RoutineModelFromJson(json);

  /// Create model from domain entity
  factory RoutineModel.fromEntity(FlexibleRoutine entity) {
    return RoutineModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      presetType: entity.presetType,
      trainingDays: entity.trainingDays.toList()..sort(), // Set → sorted List
      workoutSchedule: _convertScheduleToStringKeys(entity.workoutSchedule), // Map<int, String> → Map<String, String>
      isActive: entity.isActive,
      completedDays: entity.completedDays.toList()..sort(), // Set → sorted List
      totalWorkouts: entity.totalWorkouts,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
  /// Unique routine identifier (matches Firestore document ID)
  final String id;

  /// User who owns this routine
  final String userId;

  /// Routine name
  final String name;

  /// Optional description
  final String description;

  /// Preset type (stored as String via JsonValue annotation)
  final RoutinePreset presetType;

  /// Training days as List of int (Firestore-compatible)
  /// Converted from/to Set of int in entity
  final List<int> trainingDays;

  /// Workout schedule as Map of String to String (Firestore keys must be String)
  /// Converted from/to Map of int to String in entity
  final Map<String, String> workoutSchedule;

  /// Whether this routine is active
  final bool isActive;

  /// Completed days as List of String (Firestore-compatible)
  /// Converted from/to Set of String in entity
  final List<String> completedDays;

  /// Total workouts completed
  final int totalWorkouts;

  /// Creation timestamp (Firestore Timestamp)
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  /// Last update timestamp (Firestore Timestamp)
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;

  /// JSON serialization
  Map<String, dynamic> toJson() => _$RoutineModelToJson(this);

  /// Convert model to domain entity
  FlexibleRoutine toEntity() {
    return FlexibleRoutine(
      id: id,
      userId: userId,
      name: name,
      description: description,
      presetType: presetType,
      trainingDays: trainingDays.toSet(), // List → Set
      workoutSchedule: _convertScheduleToIntKeys(workoutSchedule), // Map<String, String> → Map<int, String>
      isActive: isActive,
      completedDays: completedDays.toSet(), // List → Set
      totalWorkouts: totalWorkouts,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Private Helpers
  // ──────────────────────────────────────────────────────────────────────────

  /// Convert Firestore Timestamp to DateTime
  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is DateTime) {
      return timestamp;
    } else {
      return DateTime.now();
    }
  }

  /// Convert DateTime to Firestore Timestamp
  static Timestamp _timestampToJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }

  /// Convert Map of String to String to Map of int to String
  /// Firestore keys must be String, but entity uses int for day-of-week
  static Map<int, String> _convertScheduleToIntKeys(Map<String, String> schedule) {
    return schedule.map((key, value) {
      final dayInt = int.tryParse(key) ?? 1; // Default to Monday if parse fails
      return MapEntry(dayInt, value);
    });
  }

  /// Convert Map of int to String to Map of String to String
  /// Firestore keys must be String
  static Map<String, String> _convertScheduleToStringKeys(Map<int, String> schedule) {
    return schedule.map((key, value) {
      return MapEntry(key.toString(), value);
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Equality & HashCode (for testing/comparison)
  // ──────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoutineModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RoutineModel(id: $id, name: $name, preset: $presetType)';
  }
}
