import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/core/data/hive_box_manager_enhanced.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/gym_equipment_profile.dart';

/// Repository for managing gym equipment profiles (barbells and plates)
class GymEquipmentRepository {
  GymEquipmentRepository([HiveBoxManagerEnhanced? boxManager])
    : _boxManager = boxManager ?? HiveBoxManagerEnhanced();

  static const String _boxName = 'gym_equipment_profiles';

  final HiveBoxManagerEnhanced _boxManager;
  Box<GymEquipmentProfile>? _box;

  bool _initFailed = false;
  bool _initialized = false;

  /// Initialize the storage
  Future<void> init() async {
    if (_initialized) return;
    if (_initFailed) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [GymEquipmentRepository] Skipping init - previous attempt failed',
        );
      }
      return;
    }

    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await _boxManager.openBox<GymEquipmentProfile>(_boxName);
      } else {
        _box = Hive.box<GymEquipmentProfile>(_boxName);
      }

      _initialized = true;
      if (kDebugMode) {
        debugPrint('✅ [GymEquipmentRepository] Initialized successfully');
      }

      // Create default profile if none exists
      await _ensureDefaultProfile();
    } on BoxCorruptedException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [GymEquipmentRepository] Box was corrupted and recovered: $e',
        );
      }
      try {
        _box = await _boxManager.openBox<GymEquipmentProfile>(_boxName);
        await _ensureDefaultProfile();
      } catch (retryError) {
        _initFailed = true;
        if (kDebugMode) {
          debugPrint(
            '❌ [GymEquipmentRepository] Init failed after corruption recovery: $retryError',
          );
        }
      }
    } on BoxOpenException catch (e) {
      _initFailed = true;
      if (kDebugMode) {
        debugPrint('❌ [GymEquipmentRepository] Failed to open box: $e');
      }
    } catch (e) {
      _initFailed = true;
      if (kDebugMode) {
        debugPrint('❌ [GymEquipmentRepository] Unexpected init error: $e');
      }
    }
  }

  /// Ensure at least one default profile exists
  Future<void> _ensureDefaultProfile() async {
    final profiles = await getAllProfiles();
    if (profiles.isEmpty) {
      final defaultProfile = GymEquipmentProfile.createDefault();
      await saveProfile(defaultProfile);
      if (kDebugMode) {
        debugPrint('✅ [GymEquipmentRepository] Created default profile');
      }
    }
  }

  /// Migrate plates from legacy AppConfig to default profile
  /// Called once during first init if legacy plates exist
  Future<void> migrateFromLegacyConfig(List<double>? legacyPlates) async {
    if (legacyPlates == null || legacyPlates.isEmpty) return;

    try {
      await init();
      if (_box == null || _initFailed) return;

      // Check if we already have profiles (means migration was done)
      final profiles = _box!.values.toList();
      if (profiles.length > 1) {
        // More than default = already customized, don't migrate
        return;
      }

      final defaultProfile = profiles.firstWhere(
        (p) => p.isDefault,
        orElse: () => GymEquipmentProfile.createDefault(),
      );

      // Only migrate if default profile has standard plates (not customized)
      if (_listEquals(defaultProfile.availablePlates, GymEquipmentProfile.standardPlates)) {
        final migrated = defaultProfile.copyWith(availablePlates: legacyPlates);
        await saveProfile(migrated);

        if (kDebugMode) {
          debugPrint(
            '✅ [GymEquipmentRepository] Migrated ${legacyPlates.length} plates from AppConfig',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GymEquipmentRepository] Migration failed: $e');
      }
    }
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Get all equipment profiles
  Future<List<GymEquipmentProfile>> getAllProfiles() async {
    try {
      await init();
      if (_box == null || _initFailed) return [];

      return _box!.values.toList()
        ..sort((a, b) {
          // Default profile first, then by name
          if (a.isDefault && !b.isDefault) return -1;
          if (!a.isDefault && b.isDefault) return 1;
          return a.name.compareTo(b.name);
        });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GymEquipmentRepository] Failed to get profiles: $e');
      }
      return [];
    }
  }

  /// Get profile by ID
  Future<GymEquipmentProfile?> getProfile(String id) async {
    try {
      await init();
      if (_box == null || _initFailed) return null;
      return _box!.get(id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GymEquipmentRepository] Failed to get profile $id: $e');
      }
      return null;
    }
  }

  /// Get the default profile
  Future<GymEquipmentProfile?> getDefaultProfile() async {
    try {
      final profiles = await getAllProfiles();
      return profiles.firstWhere(
        (p) => p.isDefault,
        orElse: () => profiles.isNotEmpty
            ? profiles.first
            : GymEquipmentProfile.createDefault(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GymEquipmentRepository] Failed to get default profile: $e');
      }
      return GymEquipmentProfile.createDefault();
    }
  }

  /// Save or update a profile
  Future<void> saveProfile(GymEquipmentProfile profile) async {
    try {
      await init();
      if (_box == null || _initFailed) return;

      await _box!.put(profile.id, profile);

      // 🔥 FIX: Force immediate disk flush for gym equipment profiles
      await _box!.flush();

      if (kDebugMode) {
        debugPrint('✅ [GymEquipmentRepository] Saved profile: ${profile.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GymEquipmentRepository] Failed to save profile: $e');
      }
    }
  }

  /// Set a profile as default
  Future<void> setDefaultProfile(String id) async {
    try {
      await init();
      if (_box == null || _initFailed) return;

      final profiles = await getAllProfiles();

      // Update all profiles
      for (final profile in profiles) {
        final updated = profile.copyWith(isDefault: profile.id == id);
        await _box!.put(profile.id, updated);
      }

      // 🔥 FIX: Flush after batch update to persist all profile changes
      await _box!.flush();

      if (kDebugMode) {
        debugPrint('✅ [GymEquipmentRepository] Set default profile: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GymEquipmentRepository] Failed to set default profile: $e');
      }
    }
  }

  /// Delete a profile
  Future<void> deleteProfile(String id) async {
    try {
      await init();
      if (_box == null || _initFailed) return;

      final profile = await getProfile(id);
      if (profile == null) return;

      // Don't delete the default profile
      if (profile.isDefault) {
        if (kDebugMode) {
          debugPrint('⚠️ [GymEquipmentRepository] Cannot delete default profile');
        }
        return;
      }

      await _box!.delete(id);

      if (kDebugMode) {
        debugPrint('✅ [GymEquipmentRepository] Deleted profile: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GymEquipmentRepository] Failed to delete profile: $e');
      }
    }
  }

  /// Dispose and close the Hive box
  Future<void> dispose() async {
    try {
      if (_box != null && _box!.isOpen) {
        await _box!.close();
        _box = null;
        if (kDebugMode) {
          debugPrint('✅ [GymEquipmentRepository] Disposed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GymEquipmentRepository] Error disposing: $e');
      }
    }
  }
}
