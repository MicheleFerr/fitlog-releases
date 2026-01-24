// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interface_size.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InterfaceSizeAdapter extends TypeAdapter<InterfaceSize> {
  @override
  final typeId = 100;

  @override
  InterfaceSize read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InterfaceSize.compact;
      case 1:
        return InterfaceSize.standard;
      case 2:
        return InterfaceSize.large;
      default:
        return InterfaceSize.compact;
    }
  }

  @override
  void write(BinaryWriter writer, InterfaceSize obj) {
    switch (obj) {
      case InterfaceSize.compact:
        writer.writeByte(0);
      case InterfaceSize.standard:
        writer.writeByte(1);
      case InterfaceSize.large:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterfaceSizeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
