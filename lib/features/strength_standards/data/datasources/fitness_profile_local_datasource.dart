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
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/features/strength_standards/domain/entities/user_fitness_questionnaire.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_names.dart';

/// Local Hive data source for fitness profile storage
/// Provides persistent storage for user fitness questionnaire and medical clearance data
///
/// ✅ MIGRATED to HiveBoxManagerEnhanced pattern (Oct 2025)
/// - No direct Hive.openBox() calls
/// - Centralized box lifecycle management
class FitnessProfileLocalDataSource {
  /// Constructor with dependency injection
  FitnessProfileLocalDataSource(this._boxManager);
  final HiveBoxManagerEnhanced _boxManager;

  /// Get fitness profile box via HiveBoxManagerEnhanced
  Future<Box<Map>> _getFitnessProfileBox() async {
    return await _boxManager.openBox<Map>(HiveBoxNames.fitnessProfile);
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

  /// Get fitness questionnaire by userId
  Future<UserFitnessQuestionnaire?> getFitnessQuestionnaire(
    String userId,
  ) async {
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

  /// Check if user has completed fitness questionnaire
  Future<bool> hasFitnessProfile(String userId) async {
    final profile = await getFitnessQuestionnaire(userId);
    return profile != null;
  }

  /// Clear fitness profile for user
  Future<void> clearFitnessProfile(String userId) async {
    final box = await _getFitnessProfileBox();
    final key = 'profile_$userId';
    await box.delete(key);
    debugPrint('🗑️ Cleared fitness profile for user: $userId');
  }

  /// Clear all data for user (for logout/account deletion)
  Future<void> clearAllUserData(String userId) async {
    await clearFitnessProfile(userId);
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

    if (profile == null) return null;

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'userId': userId,
      'fitnessProfile': profile.toJson(),
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

    debugPrint('📥 Imported fitness data for user: $userId');
  }
}
