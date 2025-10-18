/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
/// 
/// 📁 Layer: data/repositories
/// 🎯 Feature: app_config
/// 🔧 Type: repository
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
/// 
/// Dependencies:
/// - BaseHybridRepository (local + premium sync)
/// - Hive (local storage)
/// - Firebase (premium cloud sync)
library;

import 'package:gymbro_flutter_new/core/data/repositories/base_hybrid_repository.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/app_config.dart';
import 'package:flutter/foundation.dart';

/// Hybrid repository for app configuration
/// - FREE users: Local storage only (all settings work offline)
/// - PREMIUM users: Local + Cloud sync (settings sync across devices)
class HybridAppConfigRepository extends BaseHybridRepository<UserAppConfig> {
  HybridAppConfigRepository({
    super.firestore,
    super.auth,
  }) : super(
    featureName: 'app_config',
    collectionName: 'user_app_configs',
    requiresPremiumForCloud: true,
  );

  @override
  Map<String, dynamic> toJson(UserAppConfig entity) {
    return entity.toJson();
  }

  @override
  UserAppConfig fromJson(Map<String, dynamic> json) {
    return UserAppConfig.fromJson(json);
  }

  @override
  String getId(UserAppConfig entity) {
    return entity.userId;
  }

  @override
  bool validate(UserAppConfig entity) {
    return entity.userId.isNotEmpty;
  }

  /// Save or update user configuration
  Future<void> saveUserConfig(AppConfig config) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final userConfig = UserAppConfig(
      userId: userId,
      config: config,
      lastUpdated: DateTime.now(),
      deviceInfo: await _getDeviceInfo(),
    );

    // Use base repository save/update (handles local + sync)
    final existing = await get(userId);
    if (existing != null) {
      await update(userConfig);
    } else {
      await save(userConfig);
    }

    debugPrint('✅ App config saved: local + ${canSyncToCloud ? "cloud sync queued" : "no sync (free user)"}');
  }

  /// Get user configuration
  Future<AppConfig?> getUserConfig() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final userConfig = await get(userId);
    return userConfig?.config;
  }

  /// Merge configurations from multiple devices (for premium users)
  Future<AppConfig> mergeConfigurations(List<UserAppConfig> configs) async {
    if (configs.isEmpty) return const AppConfig();
    
    // Sort by last updated, newest first
    configs.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    
    // Return the most recent configuration
    return configs.first.config;
  }

  /// Get device-specific info for sync context
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': defaultTargetPlatform.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Export configuration for backup
  Future<Map<String, dynamic>> exportConfiguration() async {
    final config = await getUserConfig();
    if (config == null) return {};

    return {
      'config': config.toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  /// Import configuration from backup
  Future<void> importConfiguration(Map<String, dynamic> data) async {
    final configJson = data['config'] as Map<String, dynamic>?;
    if (configJson == null) throw Exception('Invalid configuration data');

    final config = AppConfig.fromJson(configJson);
    await saveUserConfig(config);
  }

  /// Get sync status for settings
  Future<Map<String, dynamic>> getConfigSyncStatus() async {
    final stats = await getSyncStats();
    final config = await getUserConfig();
    
    return {
      ...stats,
      'hasConfig': config != null,
      'lastSyncedAt': config != null ? DateTime.now().toIso8601String() : null,
      'syncEnabled': canSyncToCloud,
    };
  }
}

/// User app configuration wrapper
class UserAppConfig {

  UserAppConfig({
    required this.userId,
    required this.config,
    required this.lastUpdated,
    this.deviceInfo,
  });

  factory UserAppConfig.fromJson(Map<String, dynamic> json) {
    return UserAppConfig(
      userId: json['userId'] ?? '',
      config: AppConfig.fromJson(json['config'] ?? {}),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      deviceInfo: json['deviceInfo'],
    );
  }
  final String userId;
  final AppConfig config;
  final DateTime lastUpdated;
  final Map<String, dynamic>? deviceInfo;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'config': config.toJson(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'deviceInfo': deviceInfo,
  };

  UserAppConfig copyWith({
    AppConfig? config,
    DateTime? lastUpdated,
    Map<String, dynamic>? deviceInfo,
  }) {
    return UserAppConfig(
      userId: userId,
      config: config ?? this.config,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }
}