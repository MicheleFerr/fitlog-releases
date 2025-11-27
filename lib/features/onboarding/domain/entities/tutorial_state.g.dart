// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutorial_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TutorialStateAdapter extends TypeAdapter<TutorialState> {
  @override
  final typeId = 60;

  @override
  TutorialState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TutorialState(
      seenTutorialsList: fields[0] == null
          ? const []
          : (fields[0] as List).cast<String>(),
      dismissedHintsList: fields[1] == null
          ? const []
          : (fields[1] as List).cast<String>(),
      lastDismissTimeList: fields[2] == null
          ? const []
          : (fields[2] as List).cast<String>(),
      totalWorkouts: fields[3] == null ? 0 : (fields[3] as num).toInt(),
      firstWorkoutDate: fields[4] as DateTime?,
      tutorialsEnabled: fields[5] == null ? true : fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TutorialState obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.seenTutorialsList)
      ..writeByte(1)
      ..write(obj.dismissedHintsList)
      ..writeByte(2)
      ..write(obj.lastDismissTimeList)
      ..writeByte(3)
      ..write(obj.totalWorkouts)
      ..writeByte(4)
      ..write(obj.firstWorkoutDate)
      ..writeByte(5)
      ..write(obj.tutorialsEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorialStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
