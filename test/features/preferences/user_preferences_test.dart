import 'package:flutter_test/flutter_test.dart';

// Mock User Preferences Service
class UserPreferencesService {
  final Map<String, dynamic> _preferences = {
    // App Settings
    'theme_mode': 'system', // 'light', 'dark', 'system'
    'language': 'en', // 'en', 'it'
    'units': 'metric', // 'metric', 'imperial'
    
    // Workout Settings
    'default_rest_timer': 60,
    'auto_start_rest_timer': true,
    'vibrate_on_timer_end': true,
    'sound_on_timer_end': true,
    'keep_screen_on': true,
    'show_warmup_sets': true,
    
    // Display Settings
    'show_exercise_images': true,
    'show_exercise_tips': true,
    'compact_workout_view': false,
    'show_volume_chart': true,
    'show_rpe_scale': false,
    
    // Privacy Settings
    'share_workouts_publicly': false,
    'allow_friend_requests': true,
    'show_profile_stats': true,
    'anonymous_leaderboards': false,
    
    // Advanced Settings
    'enable_plate_calculator': true,
    'barbell_weight': 20.0, // kg
    'available_plates': [20.0, 10.0, 5.0, 2.5, 1.25], // kg
    'quick_add_weights': [40.0, 60.0, 80.0, 100.0],
    
    // Backup Settings
    'auto_backup': true,
    'backup_frequency': 'daily', // 'daily', 'weekly', 'manual'
    'last_backup': null,
  };
  
  final List<PreferenceChangeEvent> _changeHistory = [];
  
  Map<String, dynamic> get preferences => Map.unmodifiable(_preferences);
  List<PreferenceChangeEvent> get changeHistory => List.unmodifiable(_changeHistory);
  
  // Get preferences
  T? getPreference<T>(String key) {
    return _preferences[key] as T?;
  }
  
  String getThemeMode() => _preferences['theme_mode'] as String;
  String getLanguage() => _preferences['language'] as String;
  String getUnits() => _preferences['units'] as String;
  
  // Workout preferences
  int getDefaultRestTimer() => _preferences['default_rest_timer'] as int;
  bool getAutoStartRestTimer() => _preferences['auto_start_rest_timer'] as bool;
  bool getVibrateOnTimerEnd() => _preferences['vibrate_on_timer_end'] as bool;
  bool getSoundOnTimerEnd() => _preferences['sound_on_timer_end'] as bool;
  bool getKeepScreenOn() => _preferences['keep_screen_on'] as bool;
  bool getShowWarmupSets() => _preferences['show_warmup_sets'] as bool;
  
  // Update preferences
  Future<void> setPreference(String key, dynamic value) async {
    if (!_preferences.containsKey(key)) {
      throw Exception('Invalid preference key: $key');
    }
    
    final oldValue = _preferences[key];
    
    // Validate value type
    if (oldValue != null && value != null && oldValue.runtimeType != value.runtimeType) {
      throw Exception('Type mismatch for preference $key');
    }
    
    _preferences[key] = value;
    
    // Track change
    _changeHistory.add(PreferenceChangeEvent(
      key: key,
      oldValue: oldValue,
      newValue: value,
      timestamp: DateTime.now(),
    ));
    
    // Simulate save delay
    await Future.delayed(const Duration(milliseconds: 50));
  }
  
  Future<void> setThemeMode(String mode) async {
    if (!['light', 'dark', 'system'].contains(mode)) {
      throw Exception('Invalid theme mode: $mode');
    }
    await setPreference('theme_mode', mode);
  }
  
  Future<void> setLanguage(String language) async {
    if (!['en', 'it'].contains(language)) {
      throw Exception('Unsupported language: $language');
    }
    await setPreference('language', language);
  }
  
  Future<void> setUnits(String units) async {
    if (!['metric', 'imperial'].contains(units)) {
      throw Exception('Invalid units: $units');
    }
    await setPreference('units', units);
  }
  
  Future<void> setDefaultRestTimer(int seconds) async {
    if (seconds < 0 || seconds > 600) {
      throw Exception('Rest timer must be between 0 and 600 seconds');
    }
    await setPreference('default_rest_timer', seconds);
  }
  
  // Batch update
  Future<void> updateMultiple(Map<String, dynamic> updates) async {
    for (final entry in updates.entries) {
      await setPreference(entry.key, entry.value);
    }
  }
  
  // Reset preferences
  Future<void> resetToDefaults() async {
    final defaults = {
      'theme_mode': 'system',
      'language': 'en',
      'units': 'metric',
      'default_rest_timer': 60,
      'auto_start_rest_timer': true,
      'vibrate_on_timer_end': true,
      'sound_on_timer_end': true,
      'keep_screen_on': true,
      'show_warmup_sets': true,
      'show_exercise_images': true,
      'show_exercise_tips': true,
      'compact_workout_view': false,
      'show_volume_chart': true,
      'show_rpe_scale': false,
      'share_workouts_publicly': false,
      'allow_friend_requests': true,
      'show_profile_stats': true,
      'anonymous_leaderboards': false,
      'enable_plate_calculator': true,
      'barbell_weight': 20.0,
      'available_plates': [20.0, 10.0, 5.0, 2.5, 1.25],
      'quick_add_weights': [40.0, 60.0, 80.0, 100.0],
      'auto_backup': true,
      'backup_frequency': 'daily',
      'last_backup': null,
    };
    
    for (final entry in defaults.entries) {
      _preferences[entry.key] = entry.value;
    }
    
    _changeHistory.add(PreferenceChangeEvent(
      key: 'all',
      oldValue: null,
      newValue: 'reset',
      timestamp: DateTime.now(),
    ));
  }
  
  // Export/Import
  Map<String, dynamic> exportPreferences() {
    return Map<String, dynamic>.from(_preferences);
  }
  
  Future<void> importPreferences(Map<String, dynamic> data) async {
    // Validate all keys exist
    for (final key in data.keys) {
      if (!_preferences.containsKey(key)) {
        throw Exception('Invalid preference key in import: $key');
      }
    }
    
    // Import all values
    for (final entry in data.entries) {
      _preferences[entry.key] = entry.value;
    }
    
    _changeHistory.add(PreferenceChangeEvent(
      key: 'all',
      oldValue: null,
      newValue: 'import',
      timestamp: DateTime.now(),
    ));
  }
  
  // Plate calculator
  List<double> calculatePlates(double targetWeight) {
    if (!(_preferences['enable_plate_calculator'] as bool)) {
      return [];
    }
    
    final barbellWeight = _preferences['barbell_weight'] as double;
    final availablePlates = List<double>.from(_preferences['available_plates'] as List);
    
    if (targetWeight <= barbellWeight) {
      return [];
    }
    
    double remainingWeight = (targetWeight - barbellWeight) / 2; // Per side
    final platesPerSide = <double>[];
    
    // Sort plates in descending order
    availablePlates.sort((a, b) => b.compareTo(a));
    
    for (final plate in availablePlates) {
      while (remainingWeight >= plate) {
        platesPerSide.add(plate);
        remainingWeight -= plate;
      }
    }
    
    return platesPerSide;
  }
  
  // Unit conversion
  double convertWeight(double weight, {required bool toImperial}) {
    if (toImperial) {
      return weight * 2.20462; // kg to lbs
    } else {
      return weight / 2.20462; // lbs to kg
    }
  }
  
  double convertDistance(double distance, {required bool toImperial}) {
    if (toImperial) {
      return distance * 0.621371; // km to miles
    } else {
      return distance / 0.621371; // miles to km
    }
  }
  
  // Backup management
  Future<void> performBackup() async {
    await setPreference('last_backup', DateTime.now().toIso8601String());
  }
  
  bool isBackupNeeded() {
    if (!(_preferences['auto_backup'] as bool)) {
      return false;
    }
    
    final lastBackupStr = _preferences['last_backup'] as String?;
    if (lastBackupStr == null) {
      return true;
    }
    
    final lastBackup = DateTime.parse(lastBackupStr);
    final frequency = _preferences['backup_frequency'] as String;
    
    switch (frequency) {
      case 'daily':
        return DateTime.now().difference(lastBackup).inDays >= 1;
      case 'weekly':
        return DateTime.now().difference(lastBackup).inDays >= 7;
      default:
        return false;
    }
  }
  
  // Change history
  List<PreferenceChangeEvent> getRecentChanges({int limit = 10}) {
    final sorted = List<PreferenceChangeEvent>.from(_changeHistory)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return sorted.take(limit).toList();
  }
  
  void clearChangeHistory() {
    _changeHistory.clear();
  }
}

class PreferenceChangeEvent {
  final String key;
  final dynamic oldValue;
  final dynamic newValue;
  final DateTime timestamp;
  
  PreferenceChangeEvent({
    required this.key,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
  });
}

void main() {
  group('⚙️ User Preferences Tests', () {
    late UserPreferencesService preferencesService;
    
    setUp(() {
      preferencesService = UserPreferencesService();
    });
    
    tearDown(() {
      preferencesService.clearChangeHistory();
    });
    
    group('🎨 Theme & Display Settings', () {
      test('✅ Get default theme mode', () {
        expect(preferencesService.getThemeMode(), 'system');
      });
      
      test('✅ Set theme mode to dark', () async {
        await preferencesService.setThemeMode('dark');
        expect(preferencesService.getThemeMode(), 'dark');
      });
      
      test('❌ Invalid theme mode', () async {
        expect(
          () async => await preferencesService.setThemeMode('invalid'),
          throwsException,
        );
      });
      
      test('✅ Toggle display settings', () async {
        await preferencesService.setPreference('show_exercise_images', false);
        await preferencesService.setPreference('compact_workout_view', true);
        
        expect(preferencesService.getPreference<bool>('show_exercise_images'), false);
        expect(preferencesService.getPreference<bool>('compact_workout_view'), true);
      });
    });
    
    group('🌍 Language & Units', () {
      test('✅ Change language to Italian', () async {
        await preferencesService.setLanguage('it');
        expect(preferencesService.getLanguage(), 'it');
      });
      
      test('❌ Unsupported language', () async {
        expect(
          () async => await preferencesService.setLanguage('es'),
          throwsException,
        );
      });
      
      test('✅ Change units to imperial', () async {
        await preferencesService.setUnits('imperial');
        expect(preferencesService.getUnits(), 'imperial');
      });
      
      test('✅ Convert weight kg to lbs', () {
        final lbs = preferencesService.convertWeight(100, toImperial: true);
        expect(lbs, closeTo(220.462, 0.001));
      });
      
      test('✅ Convert distance km to miles', () {
        final miles = preferencesService.convertDistance(10, toImperial: true);
        expect(miles, closeTo(6.21371, 0.001));
      });
    });
    
    group('⏱️ Timer Settings', () {
      test('✅ Get default rest timer', () {
        expect(preferencesService.getDefaultRestTimer(), 60);
      });
      
      test('✅ Set custom rest timer', () async {
        await preferencesService.setDefaultRestTimer(90);
        expect(preferencesService.getDefaultRestTimer(), 90);
      });
      
      test('❌ Invalid rest timer - negative', () async {
        expect(
          () async => await preferencesService.setDefaultRestTimer(-1),
          throwsException,
        );
      });
      
      test('❌ Invalid rest timer - too long', () async {
        expect(
          () async => await preferencesService.setDefaultRestTimer(601),
          throwsException,
        );
      });
      
      test('✅ Timer behavior settings', () async {
        await preferencesService.setPreference('auto_start_rest_timer', false);
        await preferencesService.setPreference('vibrate_on_timer_end', false);
        
        expect(preferencesService.getAutoStartRestTimer(), false);
        expect(preferencesService.getVibrateOnTimerEnd(), false);
        expect(preferencesService.getSoundOnTimerEnd(), true); // Unchanged
      });
    });
    
    group('🏋️ Plate Calculator', () {
      test('✅ Calculate plates for 60kg', () {
        final plates = preferencesService.calculatePlates(60);
        
        // 60kg - 20kg bar = 40kg total = 20kg per side
        expect(plates, [20.0]);
      });
      
      test('✅ Calculate plates for 85kg', () {
        final plates = preferencesService.calculatePlates(85);
        
        // 85kg - 20kg bar = 65kg total = 32.5kg per side
        expect(plates, [20.0, 10.0, 2.5]);
      });
      
      test('✅ Calculate plates for 47.5kg', () {
        final plates = preferencesService.calculatePlates(47.5);
        
        // 47.5kg - 20kg bar = 27.5kg total = 13.75kg per side
        expect(plates, [10.0, 2.5, 1.25]);
      });
      
      test('✅ Empty plates for barbell weight only', () {
        final plates = preferencesService.calculatePlates(20);
        expect(plates, isEmpty);
      });
      
      test('✅ Custom barbell weight', () async {
        await preferencesService.setPreference('barbell_weight', 15.0); // Women's bar
        
        final plates = preferencesService.calculatePlates(35);
        // 35kg - 15kg bar = 20kg total = 10kg per side
        expect(plates, [10.0]);
      });
      
      test('✅ Disabled plate calculator', () async {
        await preferencesService.setPreference('enable_plate_calculator', false);
        
        final plates = preferencesService.calculatePlates(60);
        expect(plates, isEmpty);
      });
    });
    
    group('🔐 Privacy Settings', () {
      test('✅ Default privacy settings', () {
        expect(preferencesService.getPreference<bool>('share_workouts_publicly'), false);
        expect(preferencesService.getPreference<bool>('allow_friend_requests'), true);
        expect(preferencesService.getPreference<bool>('show_profile_stats'), true);
      });
      
      test('✅ Update privacy settings', () async {
        await preferencesService.updateMultiple({
          'share_workouts_publicly': true,
          'allow_friend_requests': false,
          'anonymous_leaderboards': true,
        });
        
        expect(preferencesService.getPreference<bool>('share_workouts_publicly'), true);
        expect(preferencesService.getPreference<bool>('allow_friend_requests'), false);
        expect(preferencesService.getPreference<bool>('anonymous_leaderboards'), true);
      });
    });
    
    group('💾 Backup Settings', () {
      test('✅ Check backup needed - no previous backup', () {
        expect(preferencesService.isBackupNeeded(), true);
      });
      
      test('✅ Perform backup', () async {
        await preferencesService.performBackup();
        
        final lastBackup = preferencesService.getPreference<String>('last_backup');
        expect(lastBackup, isNotNull);
        expect(preferencesService.isBackupNeeded(), false);
      });
      
      test('✅ Daily backup frequency', () async {
        // Set last backup to 2 days ago
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        await preferencesService.setPreference('last_backup', twoDaysAgo.toIso8601String());
        
        expect(preferencesService.isBackupNeeded(), true);
      });
      
      test('✅ Weekly backup frequency', () async {
        await preferencesService.setPreference('backup_frequency', 'weekly');
        
        // Set last backup to 5 days ago
        final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
        await preferencesService.setPreference('last_backup', fiveDaysAgo.toIso8601String());
        
        expect(preferencesService.isBackupNeeded(), false);
        
        // Set last backup to 8 days ago
        final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8));
        await preferencesService.setPreference('last_backup', eightDaysAgo.toIso8601String());
        
        expect(preferencesService.isBackupNeeded(), true);
      });
      
      test('✅ Auto backup disabled', () async {
        await preferencesService.setPreference('auto_backup', false);
        expect(preferencesService.isBackupNeeded(), false);
      });
    });
    
    group('📦 Import/Export', () {
      test('✅ Export preferences', () {
        final exported = preferencesService.exportPreferences();
        
        expect(exported['theme_mode'], 'system');
        expect(exported['language'], 'en');
        expect(exported['default_rest_timer'], 60);
      });
      
      test('✅ Import preferences', () async {
        final importData = {
          'theme_mode': 'dark',
          'language': 'it',
          'default_rest_timer': 90,
          'auto_start_rest_timer': false,
        };
        
        await preferencesService.importPreferences(importData);
        
        expect(preferencesService.getThemeMode(), 'dark');
        expect(preferencesService.getLanguage(), 'it');
        expect(preferencesService.getDefaultRestTimer(), 90);
        expect(preferencesService.getAutoStartRestTimer(), false);
      });
      
      test('❌ Import with invalid key', () async {
        final importData = {
          'invalid_key': 'value',
        };
        
        expect(
          () async => await preferencesService.importPreferences(importData),
          throwsException,
        );
      });
    });
    
    group('🔄 Reset & History', () {
      test('✅ Reset to defaults', () async {
        // Change some settings
        await preferencesService.setThemeMode('dark');
        await preferencesService.setLanguage('it');
        await preferencesService.setDefaultRestTimer(90);
        
        // Reset
        await preferencesService.resetToDefaults();
        
        expect(preferencesService.getThemeMode(), 'system');
        expect(preferencesService.getLanguage(), 'en');
        expect(preferencesService.getDefaultRestTimer(), 60);
      });
      
      test('✅ Track change history', () async {
        await preferencesService.setThemeMode('dark');
        await preferencesService.setLanguage('it');
        await preferencesService.setDefaultRestTimer(90);
        
        final history = preferencesService.changeHistory;
        
        expect(history.length, 3);
        expect(history[0].key, 'theme_mode');
        expect(history[0].oldValue, 'system');
        expect(history[0].newValue, 'dark');
      });
      
      test('✅ Get recent changes', () async {
        // Make many changes
        for (int i = 0; i < 15; i++) {
          await preferencesService.setDefaultRestTimer(60 + i);
        }
        
        final recent = preferencesService.getRecentChanges(limit: 5);
        
        expect(recent.length, 5);
        expect(recent.first.newValue, 74); // Last change
      });
      
      test('✅ Clear change history', () async {
        await preferencesService.setThemeMode('dark');
        await preferencesService.setLanguage('it');
        
        expect(preferencesService.changeHistory.isNotEmpty, true);
        
        preferencesService.clearChangeHistory();
        
        expect(preferencesService.changeHistory.isEmpty, true);
      });
    });
    
    group('❌ Error Handling', () {
      test('Invalid preference key', () async {
        expect(
          () async => await preferencesService.setPreference('invalid_key', 'value'),
          throwsException,
        );
      });
      
      test('Type mismatch', () async {
        expect(
          () async => await preferencesService.setPreference('default_rest_timer', 'not a number'),
          throwsException,
        );
      });
    });
  });
}