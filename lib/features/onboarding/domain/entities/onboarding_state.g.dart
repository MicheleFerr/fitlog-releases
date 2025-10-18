// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OnboardingStateAdapter extends TypeAdapter<OnboardingState> {
  @override
  final int typeId = 3;

  @override
  OnboardingState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OnboardingState(
      hasSeenGlobalOnboarding: fields[0] as bool,
      currentStep: fields[1] as int,
      completedSteps: (fields[2] as List).cast<int>(),
      canResume: fields[3] as bool,
      onboardingVersion: fields[4] as int,
      lastInteraction: fields[5] as DateTime?,
      stepData: (fields[6] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, OnboardingState obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.hasSeenGlobalOnboarding)
      ..writeByte(1)
      ..write(obj.currentStep)
      ..writeByte(2)
      ..write(obj.completedSteps)
      ..writeByte(3)
      ..write(obj.canResume)
      ..writeByte(4)
      ..write(obj.onboardingVersion)
      ..writeByte(5)
      ..write(obj.lastInteraction)
      ..writeByte(6)
      ..write(obj.stepData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
