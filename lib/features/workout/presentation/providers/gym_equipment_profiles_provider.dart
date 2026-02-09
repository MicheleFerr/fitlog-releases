import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/core/providers/state_provider_helper.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/gym_equipment_profile.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/gym_equipment_repository.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// Repository provider for gym equipment profiles
final gymEquipmentRepositoryProvider = Provider<GymEquipmentRepository>((ref) {
  return GymEquipmentRepository();
});

/// All gym equipment profiles
final allGymEquipmentProfilesProvider =
    FutureProvider.autoDispose<List<GymEquipmentProfile>>((ref) async {
  if (kDebugMode) {
    debugPrint('🏋️ [GYM_EQUIPMENT] Loading all profiles');
  }

  final repository = ref.watch(gymEquipmentRepositoryProvider);
  final profiles = await repository.getAllProfiles();

  if (kDebugMode) {
    debugPrint('🏋️ [GYM_EQUIPMENT] Loaded ${profiles.length} profiles');
  }

  return profiles;
});

/// Currently selected/default profile
final currentGymEquipmentProfileProvider =
    FutureProvider.autoDispose<GymEquipmentProfile?>((ref) async {
  final repository = ref.watch(gymEquipmentRepositoryProvider);
  return repository.getDefaultProfile();
});

/// State for currently selected profile ID in plate calculator
/// This allows switching profiles without changing the default
final selectedProfileIdProvider = createStateProvider<String?>(null);

/// Active profile for plate calculator (selected or default)
final activeGymEquipmentProfileProvider =
    FutureProvider.autoDispose<GymEquipmentProfile?>((ref) async {
  final repository = ref.watch(gymEquipmentRepositoryProvider);
  final selectedId = ref.watch(selectedProfileIdProvider);

  if (selectedId != null) {
    final selected = await repository.getProfile(selectedId);
    if (selected != null) return selected;
  }

  return repository.getDefaultProfile();
});

/// State for temporary plate exclusions (not persisted)
/// Resets when workout ends or app restarts
final excludedPlatesProvider = createStateProvider<Set<double>>({});

/// Notifier for managing gym equipment profiles with mutations
class GymEquipmentProfilesNotifier extends AsyncNotifier<List<GymEquipmentProfile>> {
  @override
  Future<List<GymEquipmentProfile>> build() async {
    final repository = ref.watch(gymEquipmentRepositoryProvider);
    return repository.getAllProfiles();
  }

  /// Create a new profile
  Future<GymEquipmentProfile?> createProfile({
    required String name,
    double? defaultBarbellWeight,
    List<double>? availablePlates,
    bool setAsDefault = false,
  }) async {
    try {
      final repository = ref.read(gymEquipmentRepositoryProvider);

      final profile = GymEquipmentProfile.create(
        name: name,
        defaultBarbellWeight: defaultBarbellWeight,
        availablePlates: availablePlates,
        isDefault: setAsDefault,
      );

      await repository.saveProfile(profile);

      if (setAsDefault) {
        await repository.setDefaultProfile(profile.id);
      }

      // Refresh the list
      ref.invalidateSelf();

      if (kDebugMode) {
        debugPrint('🏋️ [GYM_EQUIPMENT] Created profile: ${profile.name}');
      }

      return profile;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GYM_EQUIPMENT] Failed to create profile: $e');
      }
      return null;
    }
  }

  /// Update an existing profile
  Future<bool> updateProfile(GymEquipmentProfile profile) async {
    try {
      final repository = ref.read(gymEquipmentRepositoryProvider);
      await repository.saveProfile(profile);

      // Refresh the list
      ref.invalidateSelf();

      if (kDebugMode) {
        debugPrint('🏋️ [GYM_EQUIPMENT] Updated profile: ${profile.name}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GYM_EQUIPMENT] Failed to update profile: $e');
      }
      return false;
    }
  }

  /// Delete a profile
  Future<bool> deleteProfile(String id) async {
    try {
      final repository = ref.read(gymEquipmentRepositoryProvider);
      await repository.deleteProfile(id);

      // Refresh the list
      ref.invalidateSelf();

      if (kDebugMode) {
        debugPrint('🏋️ [GYM_EQUIPMENT] Deleted profile: $id');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GYM_EQUIPMENT] Failed to delete profile: $e');
      }
      return false;
    }
  }

  /// Set a profile as default
  Future<bool> setAsDefault(String id) async {
    try {
      final repository = ref.read(gymEquipmentRepositoryProvider);
      await repository.setDefaultProfile(id);

      // Refresh the list
      ref.invalidateSelf();

      if (kDebugMode) {
        debugPrint('🏋️ [GYM_EQUIPMENT] Set default profile: $id');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GYM_EQUIPMENT] Failed to set default profile: $e');
      }
      return false;
    }
  }

  /// Migrate existing availablePlates from AppConfig to default profile
  Future<void> migrateFromAppConfig() async {
    try {
      final appConfig = ref.read(appConfigProvider);
      final existingPlates = appConfig.availablePlates;

      if (existingPlates == null || existingPlates.isEmpty) {
        if (kDebugMode) {
          debugPrint('🏋️ [GYM_EQUIPMENT] No AppConfig plates to migrate');
        }
        return;
      }

      final repository = ref.read(gymEquipmentRepositoryProvider);
      final defaultProfile = await repository.getDefaultProfile();

      if (defaultProfile != null) {
        // Update default profile with migrated plates
        final updated = defaultProfile.copyWith(
          availablePlates: existingPlates,
        );
        await repository.saveProfile(updated);

        if (kDebugMode) {
          debugPrint(
            '🏋️ [GYM_EQUIPMENT] Migrated ${existingPlates.length} plates from AppConfig',
          );
        }

        // Refresh
        ref.invalidateSelf();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GYM_EQUIPMENT] Migration failed: $e');
      }
    }
  }
}

/// Provider for managing gym equipment profiles with mutations
final gymEquipmentProfilesNotifierProvider =
    AsyncNotifierProvider<GymEquipmentProfilesNotifier, List<GymEquipmentProfile>>(
  GymEquipmentProfilesNotifier.new,
);

/// Helper to reset temporary exclusions (call when workout ends)
void resetPlateExclusions(WidgetRef ref) {
  ref.read(excludedPlatesProvider.notifier).state = {};
}
