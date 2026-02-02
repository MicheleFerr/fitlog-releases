// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_workout_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduledWorkoutModelAdapter extends TypeAdapter<ScheduledWorkoutModel> {
  @override
  final typeId = 62;

  @override
  ScheduledWorkoutModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduledWorkoutModel(
      id: fields[0] as String,
      templateId: fields[1] as String,
      templateName: fields[2] as String,
      scheduledDate: fields[3] as DateTime,
      reminderHour: (fields[4] as num).toInt(),
      reminderMinute: (fields[5] as num).toInt(),
      status: fields[6] as ScheduleStatusModel,
      completedAt: fields[7] as DateTime?,
      createdAt: fields[8] as DateTime?,
      notificationId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduledWorkoutModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.templateId)
      ..writeByte(2)
      ..write(obj.templateName)
      ..writeByte(3)
      ..write(obj.scheduledDate)
      ..writeByte(4)
      ..write(obj.reminderHour)
      ..writeByte(5)
      ..write(obj.reminderMinute)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledWorkoutModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScheduleStatusModelAdapter extends TypeAdapter<ScheduleStatusModel> {
  @override
  final typeId = 61;

  @override
  ScheduleStatusModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScheduleStatusModel.pending;
      case 1:
        return ScheduleStatusModel.due;
      case 2:
        return ScheduleStatusModel.completed;
      case 3:
        return ScheduleStatusModel.skipped;
      case 4:
        return ScheduleStatusModel.missed;
      default:
        return ScheduleStatusModel.pending;
    }
  }

  @override
  void write(BinaryWriter writer, ScheduleStatusModel obj) {
    switch (obj) {
      case ScheduleStatusModel.pending:
        writer.writeByte(0);
      case ScheduleStatusModel.due:
        writer.writeByte(1);
      case ScheduleStatusModel.completed:
        writer.writeByte(2);
      case ScheduleStatusModel.skipped:
        writer.writeByte(3);
      case ScheduleStatusModel.missed:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleStatusModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
