/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: data/datasources
/// 🎯 Feature: strength_standards
/// 🔧 Type: datasource
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Dependencies:
/// - Hive (local storage)
/// - Domain entities
library;

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/medical_clearance_questionnaire.dart';

/// Local Hive data source for fitness profile storage
/// Provides persistent storage for user fitness questionnaire and medical clearance data
class FitnessProfileLocalDataSource {
  static const String _fitnessProfileBoxName = 'fitness_profile';
  static const String _medicalClearanceBoxName = 'medical_clearance';

  /// Initialize Hive boxes
  static Future<void> initialize() async {
    try {
      // Open fitness profile box
      if (!Hive.isBoxOpen(_fitnessProfileBoxName)) {
        await Hive.openBox<Map>(_fitnessProfileBoxName);
        debugPrint('✅ Opened fitness_profile box');
      } else {
        debugPrint('ℹ️ Fitness profile box already open');
      }

      // Open medical clearance box
      if (!Hive.isBoxOpen(_medicalClearanceBoxName)) {
        await Hive.openBox<Map>(_medicalClearanceBoxName);
        debugPrint('✅ Opened medical_clearance box');
      } else {
        debugPrint('ℹ️ Medical clearance box already open');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing fitness profile Hive boxes: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get fitness profile box (open if needed)
  Future<Box<Map>> _getFitnessProfileBox() async {
    return Hive.isBoxOpen(_fitnessProfileBoxName)
        ? Hive.box<Map>(_fitnessProfileBoxName)
        : await Hive.openBox<Map>(_fitnessProfileBoxName);
  }

  /// Get medical clearance box (open if needed)
  Future<Box<Map>> _getMedicalClearanceBox() async {
    return Hive.isBoxOpen(_medicalClearanceBoxName)
        ? Hive.box<Map>(_medicalClearanceBoxName)
        : await Hive.openBox<Map>(_medicalClearanceBoxName);
  }

  /// Save fitness questionnaire locally
  Future<void> saveFitnessQuestionnaire(
    UserFitnessQuestionnaire questionnaire,
    String userId,
  ) async {
    final box = await _getFitnessProfileBox();
    final key = 'profile_$userId';

    final Map<String, dynamic> data = questionnaire.toJson();
    data['userId'] = userId;
    data['lastModified'] = DateTime.now().toIso8601String();

    // Force conversion to ensure Hive saves as Map<String, dynamic>
    final Map<String, dynamic> dataToSave = Map<String, dynamic>.from(data);
    await box.put(key, dataToSave);

    debugPrint('💾 Saved fitness profile for user: $userId');
  }

  /// Save medical clearance questionnaire locally
  Future<void> saveMedicalClearance(
    MedicalClearanceQuestionnaire clearance,
    String userId,
  ) async {
    final box = await _getMedicalClearanceBox();
    final key = 'clearance_$userId';

    final Map<String, dynamic> data = clearance.toJson();
    data['userId'] = userId;
    data['lastModified'] = DateTime.now().toIso8601String();

    final Map<String, dynamic> dataToSave = Map<String, dynamic>.from(data);
    await box.put(key, dataToSave);

    debugPrint('💾 Saved medical clearance for user: $userId');
  }

  /// Get fitness questionnaire by userId
  Future<UserFitnessQuestionnaire?> getFitnessQuestionnaire(String userId) async {
    final box = await _getFitnessProfileBox();
    final key = 'profile_$userId';

    final data = box.get(key);
    if (data == null) {
      debugPrint('ℹ️ No fitness profile found for user: $userId');
      return null;
    }

    try {
      final jsonData = Map<String, dynamic>.from(data);
      return UserFitnessQuestionnaire.fromJson(jsonData);
    } catch (e) {
      debugPrint('❌ Error parsing fitness questionnaire: $e');
      return null;
    }
  }

  /// Get medical clearance questionnaire by userId
  Future<MedicalClearanceQuestionnaire?> getMedicalClearance(String userId) async {
    final box = await _getMedicalClearanceBox();
    final key = 'clearance_$userId';

    final data = box.get(key);
    if (data == null) {
      debugPrint('ℹ️ No medical clearance found for user: $userId');
      return null;
    }

    try {
      final jsonData = Map<String, dynamic>.from(data);
      return MedicalClearanceQuestionnaire.fromJson(jsonData);
    } catch (e) {
      debugPrint('❌ Error parsing medical clearance: $e');
      return null;
    }
  }

  /// Check if user has completed fitness questionnaire
  Future<bool> hasFitnessProfile(String userId) async {
    final profile = await getFitnessQuestionnaire(userId);
    return profile != null;
  }

  /// Check if user has completed medical clearance
  Future<bool> hasMedicalClearance(String userId) async {
    final clearance = await getMedicalClearance(userId);
    return clearance != null;
  }

  /// Clear fitness profile for user
  Future<void> clearFitnessProfile(String userId) async {
    final box = await _getFitnessProfileBox();
    final key = 'profile_$userId';
    await box.delete(key);
    debugPrint('🗑️ Cleared fitness profile for user: $userId');
  }

  /// Clear medical clearance for user
  Future<void> clearMedicalClearance(String userId) async {
    final box = await _getMedicalClearanceBox();
    final key = 'clearance_$userId';
    await box.delete(key);
    debugPrint('🗑️ Cleared medical clearance for user: $userId');
  }

  /// Clear all data for user (for logout/account deletion)
  Future<void> clearAllUserData(String userId) async {
    await clearFitnessProfile(userId);
    await clearMedicalClearance(userId);
    debugPrint('🗑️ Cleared all fitness data for user: $userId');
  }

  /// Get last modified timestamp for fitness profile
  Future<DateTime?> getLastModifiedTimestamp(String userId) async {
    final box = await _getFitnessProfileBox();
    final key = 'profile_$userId';

    final data = box.get(key);
    if (data == null || data['lastModified'] == null) return null;

    try {
      return DateTime.parse(data['lastModified']);
    } catch (_) {
      return null;
    }
  }

  /// Export fitness data for backup
  Future<Map<String, dynamic>?> exportFitnessData(String userId) async {
    final profile = await getFitnessQuestionnaire(userId);
    final clearance = await getMedicalClearance(userId);

    if (profile == null) return null;

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'userId': userId,
      'fitnessProfile': profile.toJson(),
      'medicalClearance': clearance?.toJson(),
      'version': '1.0.0',
    };
  }

  /// Import fitness data from backup
  Future<void> importFitnessData(
    Map<String, dynamic> data,
    String userId,
  ) async {
    if (data['fitnessProfile'] != null) {
      final profile = UserFitnessQuestionnaire.fromJson(data['fitnessProfile']);
      await saveFitnessQuestionnaire(profile, userId);
    }

    if (data['medicalClearance'] != null) {
      final clearance = MedicalClearanceQuestionnaire.fromJson(data['medicalClearance']);
      await saveMedicalClearance(clearance, userId);
    }

    debugPrint('📥 Imported fitness data for user: $userId');
  }
}
