import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'app_config.g.dart';

@HiveType(typeId: 0)
class AppConfig {
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
    this.rpeTracking,
    this.autoRestTimer,
    this.setDurationTracking,
    this.plateCalculator,
    this.warmupSuggestions,
    this.availablePlates,
  });

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
    };
  }

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
    );
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
        other.preferredTemplateId == preferredTemplateId;
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