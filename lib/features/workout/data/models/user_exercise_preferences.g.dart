// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_exercise_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserExercisePreferencesAdapter
    extends TypeAdapter<UserExercisePreferences> {
  @override
  final typeId = 70;

  @override
  UserExercisePreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserExercisePreferences(
      visibleId: fields[0] as String,
      exerciseName: fields[1] as String,
      formCues: fields[2] as String?,
      updatedAt: fields[3] as DateTime,
      needsSync: fields[4] == null ? false : fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserExercisePreferences obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.visibleId)
      ..writeByte(1)
      ..write(obj.exerciseName)
      ..writeByte(2)
      ..write(obj.formCues)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.needsSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserExercisePreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
