// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_draft.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutDraftAdapter extends TypeAdapter<WorkoutDraft> {
  @override
  final int typeId = 10;

  @override
  WorkoutDraft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutDraft(
      id: fields[0] as String,
      workoutJson: fields[1] as String,
      lastSaved: fields[2] as DateTime,
      deviceId: fields[3] as String?,
      metadata: (fields[4] as Map?)?.cast<String, dynamic>(),
      isRecovered: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutDraft obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workoutJson)
      ..writeByte(2)
      ..write(obj.lastSaved)
      ..writeByte(3)
      ..write(obj.deviceId)
      ..writeByte(4)
      ..write(obj.metadata)
      ..writeByte(5)
      ..write(obj.isRecovered);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutDraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
