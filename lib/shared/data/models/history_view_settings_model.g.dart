// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_view_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryViewSettingsModelAdapter
    extends TypeAdapter<HistoryViewSettingsModel> {
  @override
  final int typeId = 55;

  @override
  HistoryViewSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryViewSettingsModel(
      viewMode: fields[0] as HistoryViewModeModel,
      showThumbnails: fields[1] as bool,
      showDuration: fields[2] as bool,
      showExerciseCount: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryViewSettingsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.viewMode)
      ..writeByte(1)
      ..write(obj.showThumbnails)
      ..writeByte(2)
      ..write(obj.showDuration)
      ..writeByte(3)
      ..write(obj.showExerciseCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryViewSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HistoryViewModeModelAdapter extends TypeAdapter<HistoryViewModeModel> {
  @override
  final int typeId = 54;

  @override
  HistoryViewModeModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HistoryViewModeModel.list;
      case 1:
        return HistoryViewModeModel.compact;
      case 2:
        return HistoryViewModeModel.calendar;
      case 3:
        return HistoryViewModeModel.stats;
      default:
        return HistoryViewModeModel.list;
    }
  }

  @override
  void write(BinaryWriter writer, HistoryViewModeModel obj) {
    switch (obj) {
      case HistoryViewModeModel.list:
        writer.writeByte(0);
        break;
      case HistoryViewModeModel.compact:
        writer.writeByte(1);
        break;
      case HistoryViewModeModel.calendar:
        writer.writeByte(2);
        break;
      case HistoryViewModeModel.stats:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryViewModeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
