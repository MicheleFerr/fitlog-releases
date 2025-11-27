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
      currentStep: (fields[1] as num).toInt(),
      completedSteps: (fields[2] as List).cast<int>(),
      canResume: fields[3] as bool,
      onboardingVersion: (fields[4] as num).toInt(),
      lastInteraction: fields[5] as DateTime?,
      stepData: (fields[6] as Map).cast<String, dynamic>(),
      userExperienceLevel: fields[10] as String?,
      seenOverlays: (fields[11] as List).cast<String>(),
      overlayVersionSeen: (fields[12] as num).toInt(),
      quickStartCompletedAt: fields[13] as DateTime?,
      hasCompletedFirstWorkout: fields[14] as bool,
      firstExerciseAddedAt: fields[15] as DateTime?,
      firstSetCompletedAt: fields[16] as DateTime?,
      hasSeenRestTimerExplanation: fields[17] as bool,
      userGoal: fields[18] as String?,
      weeklyWorkoutTarget: (fields[19] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, OnboardingState obj) {
    writer
      ..writeByte(17)
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
      ..write(obj.stepData)
      ..writeByte(10)
      ..write(obj.userExperienceLevel)
      ..writeByte(11)
      ..write(obj.seenOverlays)
      ..writeByte(12)
      ..write(obj.overlayVersionSeen)
      ..writeByte(13)
      ..write(obj.quickStartCompletedAt)
      ..writeByte(14)
      ..write(obj.hasCompletedFirstWorkout)
      ..writeByte(15)
      ..write(obj.firstExerciseAddedAt)
      ..writeByte(16)
      ..write(obj.firstSetCompletedAt)
      ..writeByte(17)
      ..write(obj.hasSeenRestTimerExplanation)
      ..writeByte(18)
      ..write(obj.userGoal)
      ..writeByte(19)
      ..write(obj.weeklyWorkoutTarget);
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
