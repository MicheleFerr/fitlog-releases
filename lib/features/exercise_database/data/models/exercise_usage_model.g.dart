// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_usage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseUsageModelAdapter extends TypeAdapter<ExerciseUsageModel> {
  @override
  final typeId = 30;

  @override
  ExerciseUsageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseUsageModel(
      exerciseId: fields[0] as String,
      exerciseName: fields[1] as String,
      usageCount: (fields[2] as num).toInt(),
      lastUsedAt: fields[3] as DateTime,
      firstUsedAt: fields[4] as DateTime,
      userId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseUsageModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.exerciseName)
      ..writeByte(2)
      ..write(obj.usageCount)
      ..writeByte(3)
      ..write(obj.lastUsedAt)
      ..writeByte(4)
      ..write(obj.firstUsedAt)
      ..writeByte(5)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseUsageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
