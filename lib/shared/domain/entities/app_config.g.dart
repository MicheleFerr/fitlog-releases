// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppConfigAdapter extends TypeAdapter<AppConfig> {
  @override
  final typeId = 0;

  @override
  AppConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppConfig(
      languageCode: fields[0] == null ? 'en' : fields[0] as String,
      countryCode: fields[1] == null ? 'US' : fields[1] as String,
      themeMode: fields[2] == null ? ThemeMode.system : fields[2] as ThemeMode,
      measurementUnit: fields[3] == null ? 'kg' : fields[3] as String,
      soundEnabled: fields[4] == null ? true : fields[4] as bool,
      vibrationsEnabled: fields[5] == null ? true : fields[5] as bool,
      timerSound: fields[16] == null ? 'timer_complete' : fields[16] as String,
      defaultRestTime: fields[6] == null ? 90 : (fields[6] as num).toInt(),
      autoStartTimer: fields[7] == null ? true : fields[7] as bool,
      strengthRestTime: fields[13] == null ? 180 : (fields[13] as num).toInt(),
      hypertrophyRestTime: fields[14] == null
          ? 90
          : (fields[14] as num).toInt(),
      enduranceRestTime: fields[15] == null ? 60 : (fields[15] as num).toInt(),
      showIntensityTechniques: fields[8] == null ? true : fields[8] as bool,
      primaryColor: fields[9] == null ? '2196F3' : fields[9] as String,
      enableLiveActivities: fields[10] == null ? true : fields[10] as bool,
      syncWithHealthKit: fields[11] == null ? false : fields[11] as bool,
      fontSize: fields[12] == null ? 1.0 : (fields[12] as num).toDouble(),
      preferredTemplateId: fields[17] as String?,
      rpeTracking: fields[18] == null ? true : fields[18] as bool?,
      autoRestTimer: fields[19] == null ? true : fields[19] as bool?,
      setDurationTracking: fields[20] as bool?,
      plateCalculator: fields[21] == null ? true : fields[21] as bool?,
      warmupSuggestions: fields[22] as bool?,
      availablePlates: (fields[23] as List?)?.cast<double>(),
      isProMode: fields[24] as bool?,
      autoCollapseCompleted: fields[25] as bool?,
      showTutInfo: fields[26] as bool?,
      showExerciseNotes: fields[27] as bool?,
      showCommunitySuggestions: fields[28] as bool?,
      showExerciseInsights: fields[29] as bool?,
      showCustomTimers: fields[30] as bool?,
      showAdvancedMenu: fields[31] as bool?,
      showCollapseCountdown: fields[32] as bool?,
      simplifiedAnimations: fields[33] as bool?,
      hasSeenWorkoutOnboarding: fields[34] == null ? false : fields[34] as bool,
      onboardingVersion: fields[35] == null ? 1 : (fields[35] as num).toInt(),
      betaModeEnabled: fields[36] as bool?,
      enableApre: fields[37] as bool?,
      defaultApreProtocol: (fields[38] as num?)?.toInt(),
      autoAdjustRestTime: fields[39] == null ? true : fields[39] as bool?,
      showQuickInfoIcon: fields[40] as bool?,
      showWarmupIcon: fields[41] as bool?,
      showPreventionIcon: fields[42] as bool?,
      autoAdjustWeightFromRpe: fields[43] as bool?,
      autoAdjustRestFromRpe: fields[44] as bool?,
      effortScale: fields[45] == null ? 'rpe' : fields[45] as String,
      autoPauseOnNavigateAway: fields[46] == null ? true : fields[46] as bool,
      initialOnboardingCompleted: fields[48] == null
          ? false
          : fields[48] as bool,
      skipExerciseDeleteConfirmation: fields[49] == null
          ? false
          : fields[49] as bool,
      simpleMode: fields[50] == null ? false : fields[50] as bool,
      keepScreenAwakeDuringWorkout: fields[51] == null
          ? true
          : fields[51] as bool,
      interfaceSize: fields[52] as InterfaceSize?,
      defaultRestBetweenExercises: fields[53] == null
          ? 90
          : (fields[53] as num).toInt(),
      hasSeenRestPauseTutorial: fields[54] == null ? false : fields[54] as bool,
      appThemeModeValue: fields[55] as String?,
      showWeightVerification: fields[56] == null ? true : fields[56] as bool,
      metronomeEnabled: fields[57] == null ? false : fields[57] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppConfig obj) {
    writer
      ..writeByte(57)
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
      ..writeByte(6)
      ..write(obj.defaultRestTime)
      ..writeByte(7)
      ..write(obj.autoStartTimer)
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
      ..writeByte(13)
      ..write(obj.strengthRestTime)
      ..writeByte(14)
      ..write(obj.hypertrophyRestTime)
      ..writeByte(15)
      ..write(obj.enduranceRestTime)
      ..writeByte(16)
      ..write(obj.timerSound)
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
      ..write(obj.availablePlates)
      ..writeByte(24)
      ..write(obj.isProMode)
      ..writeByte(25)
      ..write(obj.autoCollapseCompleted)
      ..writeByte(26)
      ..write(obj.showTutInfo)
      ..writeByte(27)
      ..write(obj.showExerciseNotes)
      ..writeByte(28)
      ..write(obj.showCommunitySuggestions)
      ..writeByte(29)
      ..write(obj.showExerciseInsights)
      ..writeByte(30)
      ..write(obj.showCustomTimers)
      ..writeByte(31)
      ..write(obj.showAdvancedMenu)
      ..writeByte(32)
      ..write(obj.showCollapseCountdown)
      ..writeByte(33)
      ..write(obj.simplifiedAnimations)
      ..writeByte(34)
      ..write(obj.hasSeenWorkoutOnboarding)
      ..writeByte(35)
      ..write(obj.onboardingVersion)
      ..writeByte(36)
      ..write(obj.betaModeEnabled)
      ..writeByte(37)
      ..write(obj.enableApre)
      ..writeByte(38)
      ..write(obj.defaultApreProtocol)
      ..writeByte(39)
      ..write(obj.autoAdjustRestTime)
      ..writeByte(40)
      ..write(obj.showQuickInfoIcon)
      ..writeByte(41)
      ..write(obj.showWarmupIcon)
      ..writeByte(42)
      ..write(obj.showPreventionIcon)
      ..writeByte(43)
      ..write(obj.autoAdjustWeightFromRpe)
      ..writeByte(44)
      ..write(obj.autoAdjustRestFromRpe)
      ..writeByte(45)
      ..write(obj.effortScale)
      ..writeByte(46)
      ..write(obj.autoPauseOnNavigateAway)
      ..writeByte(48)
      ..write(obj.initialOnboardingCompleted)
      ..writeByte(49)
      ..write(obj.skipExerciseDeleteConfirmation)
      ..writeByte(50)
      ..write(obj.simpleMode)
      ..writeByte(51)
      ..write(obj.keepScreenAwakeDuringWorkout)
      ..writeByte(52)
      ..write(obj.interfaceSize)
      ..writeByte(53)
      ..write(obj.defaultRestBetweenExercises)
      ..writeByte(54)
      ..write(obj.hasSeenRestPauseTutorial)
      ..writeByte(55)
      ..write(obj.appThemeModeValue)
      ..writeByte(56)
      ..write(obj.showWeightVerification)
      ..writeByte(57)
      ..write(obj.metronomeEnabled);
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
