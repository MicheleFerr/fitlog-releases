// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey_theme_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JourneyThemeConfigAdapter extends TypeAdapter<JourneyThemeConfig> {
  @override
  final typeId = 70;

  @override
  JourneyThemeConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JourneyThemeConfig(
      selectedTheme: fields[0] as JourneyTheme?,
      previewMode: fields[1] == null ? false : fields[1] as bool,
      lastChanged: fields[2] as DateTime?,
      customNickname: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, JourneyThemeConfig obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.selectedTheme)
      ..writeByte(1)
      ..write(obj.previewMode)
      ..writeByte(2)
      ..write(obj.lastChanged)
      ..writeByte(3)
      ..write(obj.customNickname);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyThemeConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
