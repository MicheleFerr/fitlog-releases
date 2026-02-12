// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_popularity_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExercisePopularityHiveModelAdapter
    extends TypeAdapter<ExercisePopularityHiveModel> {
  @override
  final typeId = 111;

  @override
  ExercisePopularityHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExercisePopularityHiveModel(
      exerciseId: fields[0] as String,
      count: (fields[1] as num).toInt(),
      lastUpdated: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ExercisePopularityHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.count)
      ..writeByte(2)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExercisePopularityHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
