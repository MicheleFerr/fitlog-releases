import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'app_config.g.dart';

@HiveType(typeId: 0)
class AppConfig { // Auto-adjust rest time based on RPE feedback

  const AppConfig({
    this.languageCode = 'en',
    this.countryCode = 'US',
    this.themeMode = ThemeMode.system,
    this.measurementUnit = 'kg',
    this.soundEnabled = true,
    this.vibrationsEnabled = true,
    this.timerSound = 'timer_complete',
    this.defaultRestTime = 90,
    this.autoStartTimer = true,
    this.strengthRestTime = 180, // 3 minutes
    this.hypertrophyRestTime = 90, // 1.5 minutes
    this.enduranceRestTime = 60, // 1 minute
    this.showIntensityTechniques = true,
    this.primaryColor = 'blue',
    this.enableLiveActivities = true,
    this.syncWithHealthKit = false,
    this.fontSize = 1.0,
    this.preferredTemplateId,
    this.rpeTracking = true, // Track RPE for APRE system
    this.autoRestTimer = true, // Auto-start rest timer for convenience
    this.setDurationTracking,
    this.plateCalculator = true, // Useful tool enabled by default
    this.warmupSuggestions = true, // Helpful for user safety
    this.availablePlates,
    this.isProMode,
    this.autoCollapseCompleted,
    this.showTutInfo,
    this.showExerciseNotes,
    this.showCommunitySuggestions,
    this.showExerciseInsights,
    this.showCustomTimers,
    this.showAdvancedMenu,
    this.showCollapseCountdown,
    this.simplifiedAnimations,
    this.hasSeenWorkoutOnboarding = false,
    this.onboardingVersion = 1,
    this.betaModeEnabled,
    this.enableApre = true, // APRE auto-regulation enabled by default
    this.defaultApreProtocol = 6, // 6-set protocol as balanced default
    this.autoAdjustRestTime = true, // Default to true for APRE users
    this.showQuickInfoIcon,
    this.showWarmupIcon,
    this.showPreventionIcon,
    this.autoAdjustWeightFromRpe,
    this.autoAdjustRestFromRpe,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      languageCode: json['languageCode'] ?? 'en',
      countryCode: json['countryCode'] ?? 'US',
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      measurementUnit: json['measurementUnit'] ?? 'kg',
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationsEnabled: json['vibrationsEnabled'] ?? true,
      timerSound: json['timerSound'] ?? 'timer_complete',
      defaultRestTime: json['defaultRestTime'] ?? 90,
      autoStartTimer: json['autoStartTimer'] ?? true,
      strengthRestTime: json['strengthRestTime'] ?? 180,
      hypertrophyRestTime: json['hypertrophyRestTime'] ?? 90,
      enduranceRestTime: json['enduranceRestTime'] ?? 60,
      showIntensityTechniques: json['showIntensityTechniques'] ?? true,
      primaryColor: json['primaryColor'] ?? 'blue',
      enableLiveActivities: json['enableLiveActivities'] ?? true,
      syncWithHealthKit: json['syncWithHealthKit'] ?? false,
      fontSize: json['fontSize']?.toDouble() ?? 1.0,
      preferredTemplateId: json['preferredTemplateId'],
      rpeTracking: json['rpeTracking'] ?? true,
      autoRestTimer: json['autoRestTimer'] ?? true,
      plateCalculator: json['plateCalculator'] ?? true,
      warmupSuggestions: json['warmupSuggestions'] ?? true,
      hasSeenWorkoutOnboarding: json['hasSeenWorkoutOnboarding'] ?? false,
      onboardingVersion: json['onboardingVersion'] ?? 1,
      betaModeEnabled: json['betaModeEnabled'] ?? false,
      enableApre: json['enableApre'] ?? true,
      defaultApreProtocol: json['defaultApreProtocol'] ?? 6,
    );
  }
  @HiveField(0)
  final String languageCode;
  
  @HiveField(1)
  final String countryCode;
  
  @HiveField(2)
  final ThemeMode themeMode;
  
  @HiveField(3)
  final String measurementUnit; // 'kg' or 'lbs'
  
  @HiveField(4)
  final bool soundEnabled;
  
  @HiveField(5)
  final bool vibrationsEnabled;
  
  @HiveField(16)
  final String timerSound; // Nome del file audio
  
  @HiveField(6)
  final int defaultRestTime; // seconds
  
  @HiveField(7)
  final bool autoStartTimer;
  
  @HiveField(13)
  final int strengthRestTime; // seconds for 1-5 reps
  
  @HiveField(14)
  final int hypertrophyRestTime; // seconds for 6-12 reps
  
  @HiveField(15)
  final int enduranceRestTime; // seconds for 13+ reps
  
  @HiveField(8)
  final bool showIntensityTechniques;
  
  @HiveField(9)
  final String primaryColor;
  
  @HiveField(10)
  final bool enableLiveActivities;
  
  @HiveField(11)
  final bool syncWithHealthKit;
  
  @HiveField(12)
  final double fontSize; // Scale factor: 0.8 to 1.2
  
  @HiveField(17)
  final String? preferredTemplateId; // ID del template preferito per quick start
  
  @HiveField(18)
  final bool? rpeTracking; // Track RPE for sets
  
  @HiveField(19)
  final bool? autoRestTimer; // Auto start rest timer
  
  @HiveField(20)
  final bool? setDurationTracking; // Track set execution time
  
  @HiveField(21)
  final bool? plateCalculator; // Show plate calculator
  
  @HiveField(22)
  final bool? warmupSuggestions; // Show warmup suggestions
  
  @HiveField(23)
  final List<double>? availablePlates; // Available plates in gym

  @HiveField(24)
  final bool? isProMode; // Pro mode for advanced users

  @HiveField(25)
  final bool? autoCollapseCompleted; // Auto-collapse completed exercises

  @HiveField(26)
  final bool? showTutInfo; // Show TUT (Time Under Tension) information

  @HiveField(27)
  final bool? showExerciseNotes; // Show exercise notes section

  @HiveField(28)
  final bool? showCommunitySuggestions; // Show community suggestions

  @HiveField(29)
  final bool? showExerciseInsights; // Show exercise statistics/insights

  @HiveField(30)
  final bool? showCustomTimers; // Show custom timer settings

  @HiveField(31)
  final bool? showAdvancedMenu; // Show advanced menu options

  @HiveField(32)
  final bool? showCollapseCountdown; // Show auto-collapse countdown visual

  @HiveField(33)
  final bool? simplifiedAnimations;

  @HiveField(34)
  final bool hasSeenWorkoutOnboarding;

  @HiveField(35)
  final int onboardingVersion;

  @HiveField(36)
  final bool? betaModeEnabled;

  @HiveField(37)
  final bool? enableApre; // Enable APRE auto-regulation

  @HiveField(38)
  final int? defaultApreProtocol; // Default APRE protocol: 3, 6, or 10

  @HiveField(39)
  final bool? autoAdjustRestTime; // Auto-adjust rest time based on APRE performance

  @HiveField(40)
  final bool? showQuickInfoIcon; // Show quick info icon in exercise card

  @HiveField(41)
  final bool? showWarmupIcon; // Show warmup icon in exercise card

  @HiveField(42)
  final bool? showPreventionIcon; // Show prevention icon in exercise card

  @HiveField(43)
  final bool? autoAdjustWeightFromRpe; // Auto-adjust weight based on RPE feedback

  @HiveField(44)
  final bool? autoAdjustRestFromRpe;

  Locale get locale => Locale(languageCode, countryCode);

  AppConfig copyWith({
    String? languageCode,
    String? countryCode,
    ThemeMode? themeMode,
    String? measurementUnit,
    bool? soundEnabled,
    bool? vibrationsEnabled,
    String? timerSound,
    int? defaultRestTime,
    bool? autoStartTimer,
    int? strengthRestTime,
    int? hypertrophyRestTime,
    int? enduranceRestTime,
    bool? showIntensityTechniques,
    String? primaryColor,
    bool? enableLiveActivities,
    bool? syncWithHealthKit,
    double? fontSize,
    String? preferredTemplateId,
    bool? rpeTracking,
    bool? autoRestTimer,
    bool? setDurationTracking,
    bool? plateCalculator,
    bool? warmupSuggestions,
    List<double>? availablePlates,
    bool? isProMode,
    bool? autoCollapseCompleted,
    bool? showTutInfo,
    bool? showExerciseNotes,
    bool? showCommunitySuggestions,
    bool? showExerciseInsights,
    bool? showCustomTimers,
    bool? showAdvancedMenu,
    bool? showCollapseCountdown,
    bool? simplifiedAnimations,
    bool? hasSeenWorkoutOnboarding,
    int? onboardingVersion,
    bool? betaModeEnabled,
    bool? enableApre,
    int? defaultApreProtocol,
    bool? autoAdjustRestTime,
    bool? showQuickInfoIcon,
    bool? showWarmupIcon,
    bool? showPreventionIcon,
    bool? autoAdjustWeightFromRpe,
    bool? autoAdjustRestFromRpe,
  }) {
    return AppConfig(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      themeMode: themeMode ?? this.themeMode,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationsEnabled: vibrationsEnabled ?? this.vibrationsEnabled,
      timerSound: timerSound ?? this.timerSound,
      defaultRestTime: defaultRestTime ?? this.defaultRestTime,
      autoStartTimer: autoStartTimer ?? this.autoStartTimer,
      strengthRestTime: strengthRestTime ?? this.strengthRestTime,
      hypertrophyRestTime: hypertrophyRestTime ?? this.hypertrophyRestTime,
      enduranceRestTime: enduranceRestTime ?? this.enduranceRestTime,
      showIntensityTechniques: showIntensityTechniques ?? this.showIntensityTechniques,
      primaryColor: primaryColor ?? this.primaryColor,
      enableLiveActivities: enableLiveActivities ?? this.enableLiveActivities,
      syncWithHealthKit: syncWithHealthKit ?? this.syncWithHealthKit,
      fontSize: fontSize ?? this.fontSize,
      preferredTemplateId: preferredTemplateId ?? this.preferredTemplateId,
      rpeTracking: rpeTracking ?? this.rpeTracking,
      autoRestTimer: autoRestTimer ?? this.autoRestTimer,
      setDurationTracking: setDurationTracking ?? this.setDurationTracking,
      plateCalculator: plateCalculator ?? this.plateCalculator,
      warmupSuggestions: warmupSuggestions ?? this.warmupSuggestions,
      availablePlates: availablePlates ?? this.availablePlates,
      isProMode: isProMode ?? this.isProMode,
      autoCollapseCompleted: autoCollapseCompleted ?? this.autoCollapseCompleted,
      showTutInfo: showTutInfo ?? this.showTutInfo,
      showExerciseNotes: showExerciseNotes ?? this.showExerciseNotes,
      showCommunitySuggestions: showCommunitySuggestions ?? this.showCommunitySuggestions,
      showExerciseInsights: showExerciseInsights ?? this.showExerciseInsights,
      showCustomTimers: showCustomTimers ?? this.showCustomTimers,
      showAdvancedMenu: showAdvancedMenu ?? this.showAdvancedMenu,
      showCollapseCountdown: showCollapseCountdown ?? this.showCollapseCountdown,
      simplifiedAnimations: simplifiedAnimations ?? this.simplifiedAnimations,
      hasSeenWorkoutOnboarding: hasSeenWorkoutOnboarding ?? this.hasSeenWorkoutOnboarding,
      onboardingVersion: onboardingVersion ?? this.onboardingVersion,
      betaModeEnabled: betaModeEnabled ?? this.betaModeEnabled,
      enableApre: enableApre ?? this.enableApre,
      defaultApreProtocol: defaultApreProtocol ?? this.defaultApreProtocol,
      autoAdjustRestTime: autoAdjustRestTime ?? this.autoAdjustRestTime,
      showQuickInfoIcon: showQuickInfoIcon ?? this.showQuickInfoIcon,
      showWarmupIcon: showWarmupIcon ?? this.showWarmupIcon,
      showPreventionIcon: showPreventionIcon ?? this.showPreventionIcon,
      autoAdjustWeightFromRpe: autoAdjustWeightFromRpe ?? this.autoAdjustWeightFromRpe,
      autoAdjustRestFromRpe: autoAdjustRestFromRpe ?? this.autoAdjustRestFromRpe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'countryCode': countryCode,
      'themeMode': themeMode.name,
      'measurementUnit': measurementUnit,
      'soundEnabled': soundEnabled,
      'vibrationsEnabled': vibrationsEnabled,
      'timerSound': timerSound,
      'defaultRestTime': defaultRestTime,
      'autoStartTimer': autoStartTimer,
      'strengthRestTime': strengthRestTime,
      'hypertrophyRestTime': hypertrophyRestTime,
      'enduranceRestTime': enduranceRestTime,
      'showIntensityTechniques': showIntensityTechniques,
      'primaryColor': primaryColor,
      'enableLiveActivities': enableLiveActivities,
      'syncWithHealthKit': syncWithHealthKit,
      'fontSize': fontSize,
      'preferredTemplateId': preferredTemplateId,
      'hasSeenWorkoutOnboarding': hasSeenWorkoutOnboarding,
      'onboardingVersion': onboardingVersion,
      'betaModeEnabled': betaModeEnabled,
    };
  }

  @override
  String toString() {
    return 'AppConfig{languageCode: $languageCode, countryCode: $countryCode, themeMode: $themeMode, measurementUnit: $measurementUnit}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppConfig &&
        other.languageCode == languageCode &&
        other.countryCode == countryCode &&
        other.themeMode == themeMode &&
        other.measurementUnit == measurementUnit &&
        other.soundEnabled == soundEnabled &&
        other.vibrationsEnabled == vibrationsEnabled &&
        other.timerSound == timerSound &&
        other.defaultRestTime == defaultRestTime &&
        other.autoStartTimer == autoStartTimer &&
        other.showIntensityTechniques == showIntensityTechniques &&
        other.primaryColor == primaryColor &&
        other.enableLiveActivities == enableLiveActivities &&
        other.syncWithHealthKit == syncWithHealthKit &&
        other.fontSize == fontSize &&
        other.preferredTemplateId == preferredTemplateId &&
        other.hasSeenWorkoutOnboarding == hasSeenWorkoutOnboarding &&
        other.onboardingVersion == onboardingVersion;
  }

  @override
  int get hashCode {
    return Object.hash(
      languageCode,
      countryCode,
      themeMode,
      measurementUnit,
      soundEnabled,
      vibrationsEnabled,
      timerSound,
      defaultRestTime,
      autoStartTimer,
      showIntensityTechniques,
      primaryColor,
      enableLiveActivities,
      syncWithHealthKit,
      fontSize,
      preferredTemplateId,
      hasSeenWorkoutOnboarding,
      onboardingVersion,
    );
  }
}

// Predefined app configurations
class AppConfigPresets {
  static const AppConfig defaultConfig = AppConfig();
  
  static const AppConfig italianConfig = AppConfig(
    languageCode: 'it',
    countryCode: 'IT',
    measurementUnit: 'kg',
    defaultRestTime: 120,
  );
  
  static const AppConfig americanConfig = AppConfig(
    languageCode: 'en',
    countryCode: 'US',
    measurementUnit: 'lbs',
    defaultRestTime: 90,
  );
  
  static const AppConfig powerlifterConfig = AppConfig(
    defaultRestTime: 180,
    autoStartTimer: false,
    showIntensityTechniques: false,
    soundEnabled: true,
  );
  
  static const AppConfig bodybuilderConfig = AppConfig(
    defaultRestTime: 75,
    autoStartTimer: true,
    showIntensityTechniques: true,
    soundEnabled: true,
  );
}