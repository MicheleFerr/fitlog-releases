/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/analytics/data/local
/// 🎯 Feature: analytics
/// 🔧 Type: adapter
///
/// HiveMuscleCorrectionAdapter - Hive TypeAdapter for MuscleCorrection entity
///
/// **Purpose**: Enable Hive to store/retrieve MuscleCorrection objects
///
/// **TypeId**: 80 (unique ID - 10 was colliding with WorkoutDraft)
///
/// **Storage Location**: `HiveBoxManager.corrections` box
///
/// **Key Strategy**: `exerciseName` as key (one correction per exercise)
///
/// **Usage**:
/// ```dart
/// // Register adapter (in main.dart or HiveBoxManager init)
/// Hive.registerAdapter(HiveMuscleCorrectionAdapter());
///
/// // Store correction
/// await correctionBox.put('Bench Press', correction.toJson());
///
/// // Retrieve correction
/// final json = correctionBox.get('Bench Press');
/// final correction = MuscleCorrection.fromJson(json);
/// ```
library;

import 'package:hive_ce/hive.dart';
import 'package:gymbro_flutter_new/features/analytics/domain/entities/muscle_correction.dart';

/// Hive TypeAdapter for MuscleCorrection entity
///
/// **TypeId 80**: Unique ID for MuscleCorrection adapter
/// (10 was colliding with WorkoutDraft)
@HiveType(typeId: 80)
class HiveMuscleCorrectionAdapter extends TypeAdapter<Map<String, dynamic>> {
  @override
  final int typeId = 80;

  @override
  Map<String, dynamic> read(BinaryReader reader) {
    // Read number of fields
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Reconstruct JSON map
    return {
      'exerciseName': fields[0] as String,
      'oldMuscleGroup': fields[1] as String,
      'newMuscleGroup': fields[2] as String,
      'timestamp': DateTime.fromMillisecondsSinceEpoch(fields[3] as int)
          .toIso8601String(),
    };
  }

  @override
  void write(BinaryWriter writer, Map<String, dynamic> obj) {
    // Write number of fields
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj['exerciseName'])
      ..writeByte(1)
      ..write(obj['oldMuscleGroup'])
      ..writeByte(2)
      ..write(obj['newMuscleGroup'])
      ..writeByte(3)
      ..write(
        DateTime.parse(obj['timestamp'] as String).millisecondsSinceEpoch,
      );
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveMuscleCorrectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Extension for easy MuscleCorrection to/from Hive JSON
extension MuscleCorrectionHiveExtension on MuscleCorrection {
  /// Convert to JSON-serializable map for Hive storage
  Map<String, dynamic> toHiveJson() {
    return {
      'exerciseName': exerciseName,
      'oldMuscleGroup': oldMuscleGroup,
      'newMuscleGroup': newMuscleGroup,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from Hive JSON map
  static MuscleCorrection fromHiveJson(Map<String, dynamic> json) {
    return MuscleCorrection(
      exerciseName: json['exerciseName'] as String,
      oldMuscleGroup: json['oldMuscleGroup'] as String,
      newMuscleGroup: json['newMuscleGroup'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
