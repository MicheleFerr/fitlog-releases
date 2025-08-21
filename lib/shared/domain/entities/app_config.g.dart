// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppConfigAdapter extends TypeAdapter<AppConfig> {
  @override
  final int typeId = 0;

  @override
  AppConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppConfig(
      languageCode: fields[0] as String,
      countryCode: fields[1] as String,
      themeMode: fields[2] as ThemeMode,
      measurementUnit: fields[3] as String,
      soundEnabled: fields[4] as bool,
      vibrationsEnabled: fields[5] as bool,
      timerSound: fields[16] as String,
      defaultRestTime: fields[6] as int,
      autoStartTimer: fields[7] as bool,
      strengthRestTime: fields[13] as int,
      hypertrophyRestTime: fields[14] as int,
      enduranceRestTime: fields[15] as int,
      showIntensityTechniques: fields[8] as bool,
      primaryColor: fields[9] as String,
      enableLiveActivities: fields[10] as bool,
      syncWithHealthKit: fields[11] as bool,
      fontSize: fields[12] as double,
      preferredTemplateId: fields[17] as String?,
      rpeTracking: fields[18] as bool?,
      autoRestTimer: fields[19] as bool?,
      setDurationTracking: fields[20] as bool?,
      plateCalculator: fields[21] as bool?,
      warmupSuggestions: fields[22] as bool?,
      availablePlates: (fields[23] as List?)?.cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppConfig obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.languageCode)
      ..writeByte(1)
      ..write(obj.countryCode)
      ..writeByte(2)
      ..write(obj.themeMode)
      ..writeByte(3)
      ..write(obj.measurementUnit)
      ..writeByte(4)
      ..write(obj.soundEnabled)
      ..writeByte(5)
      ..write(obj.vibrationsEnabled)
      ..writeByte(16)
      ..write(obj.timerSound)
      ..writeByte(6)
      ..write(obj.defaultRestTime)
      ..writeByte(7)
      ..write(obj.autoStartTimer)
      ..writeByte(13)
      ..write(obj.strengthRestTime)
      ..writeByte(14)
      ..write(obj.hypertrophyRestTime)
      ..writeByte(15)
      ..write(obj.enduranceRestTime)
      ..writeByte(8)
      ..write(obj.showIntensityTechniques)
      ..writeByte(9)
      ..write(obj.primaryColor)
      ..writeByte(10)
      ..write(obj.enableLiveActivities)
      ..writeByte(11)
      ..write(obj.syncWithHealthKit)
      ..writeByte(12)
      ..write(obj.fontSize)
      ..writeByte(17)
      ..write(obj.preferredTemplateId)
      ..writeByte(18)
      ..write(obj.rpeTracking)
      ..writeByte(19)
      ..write(obj.autoRestTimer)
      ..writeByte(20)
      ..write(obj.setDurationTracking)
      ..writeByte(21)
      ..write(obj.plateCalculator)
      ..writeByte(22)
      ..write(obj.warmupSuggestions)
      ..writeByte(23)
      ..write(obj.availablePlates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
