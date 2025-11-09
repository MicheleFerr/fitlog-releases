/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: shared/data/repositories
/// 🎯 Feature: Template Management
/// 🔧 Type: Unified Repository
/// 🌍 Localization: N/A
/// 🎨 Theme: N/A
/// 📱 Platform: Universal
///
/// Purpose: Unified repository that adapts all existing template repositories
/// into a single, consistent interface with race condition safety.
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'package:gymbro_flutter_new/shared/domain/entities/unified_workout_template.dart';
import 'package:gymbro_flutter_new/shared/domain/helpers/template_migration_helpers.dart';
import 'package:gymbro_flutter_new/features/workout/data/repositories/workout_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/repositories/hybrid_template_repository.dart';
import 'package:gymbro_flutter_new/features/workout_templates/data/services/exercise_matching_service.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

/// Debug logger for unified template repository (TEMPORARY FOR DEBUGGING)
class _UnifiedTemplateLogger {
  static const bool _enableDebugLogs = kDebugMode; // Only in debug mode

  static void log(String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('🔧 UNIFIED_REPO [$timestamp] $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('❌ UNIFIED_REPO_ERROR [$timestamp] $message${error != null ? ' - $error' : ''}');
    }
  }

  static void step(String step, String message) {
    if (_enableDebugLogs) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('📍 UNIFIED_STEP [$timestamp] $step: $message');
    }
  }
}

/// Unified repository that provides a consistent interface to all template sources
/// Handles race conditions, data migration, and provides seamless access
class UnifiedTemplateRepository {

  UnifiedTemplateRepository({
    required WorkoutTemplateRepository legacyRepository,
    required HybridTemplateRepository modernRepository,
    required ExerciseMatchingService exerciseMatchingService,
  })  : _legacyRepository = legacyRepository,
        _modernRepository = modernRepository,
        _exerciseMatchingService = exerciseMatchingService {
    _UnifiedTemplateLogger.log('🚀 UnifiedTemplateRepository initialized');
    _UnifiedTemplateLogger.log('  - Legacy repository: ${legacyRepository.runtimeType}');
    _UnifiedTemplateLogger.log('  - Modern repository: ${modernRepository.runtimeType}');
    _UnifiedTemplateLogger.log('  - Exercise matching service: ${exerciseMatchingService.runtimeType}');
  }
  final WorkoutTemplateRepository _legacyRepository;
  final HybridTemplateRepository _modernRepository;
  final ExerciseMatchingService _exerciseMatchingService;

  // Cache for unified templates to avoid repeated conversions
  final Map<String, UnifiedWorkoutTemplate> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheTimeout = Duration(minutes: 5);

  // Operation tracking for race condition prevention
  final Set<String> _operationsInProgress = {};

  /// Get all user templates from all sources
  /// Handles deduplication and race condition safety
  Future<List<UnifiedWorkoutTemplate>> getUserTemplates({
    bool includeImported = true,
    bool useCache = true,
  }) async {
    _UnifiedTemplateLogger.log('📥 getUserTemplates() called');
    _UnifiedTemplateLogger.log('  - includeImported: $includeImported, useCache: $useCache');

    const operationId = 'getUserTemplates';

    if (_operationsInProgress.contains(operationId)) {
      _UnifiedTemplateLogger.log('⏳ Operation already in progress, waiting...');
      await _waitForOperation(operationId);
    }

    _operationsInProgress.add(operationId);
    _UnifiedTemplateLogger.log('🔒 Operation lock acquired');

    try {
      final allTemplates = <String, UnifiedWorkoutTemplate>{};

      // 1. Get legacy templates with error handling
      _UnifiedTemplateLogger.step('LEGACY', 'Fetching legacy templates...');
      try {
        final legacyTemplates = await _legacyRepository.getAllTemplates();
        _UnifiedTemplateLogger.step('LEGACY', 'Found ${legacyTemplates.length} legacy templates');

        for (final template in legacyTemplates) {
          _UnifiedTemplateLogger.step('LEGACY', 'Converting template: ${template.name} (${template.id})');
          final unified = TemplateMigrationHelpers.fromLegacyTemplate(template);
          allTemplates[unified.id] = unified;
          _updateCache(unified);
        }
        _UnifiedTemplateLogger.step('LEGACY', 'Successfully processed ${legacyTemplates.length} legacy templates');
      } catch (e, stackTrace) {
        _UnifiedTemplateLogger.error('Error loading legacy templates', e);
        _UnifiedTemplateLogger.error('Stack trace: $stackTrace');
        // Continue without legacy templates
      }

      // 2. Get modern templates (may overlap with legacy) with error handling
      _UnifiedTemplateLogger.step('MODERN', 'Fetching modern templates...');
      try {
        final modernTemplates = await _modernRepository.getUserTemplates();
        _UnifiedTemplateLogger.step('MODERN', 'Found ${modernTemplates.length} modern templates');

        for (final template in modernTemplates) {
          _UnifiedTemplateLogger.step('MODERN', 'Converting template: ${template.name} (${template.id})');
          final unified = TemplateMigrationHelpers.fromLegacyTemplate(template);

          // Check for conflicts and use most recent version
          final existing = allTemplates[unified.id];
          if (existing == null || _isMoreRecent(unified, existing)) {
            _UnifiedTemplateLogger.step('MODERN', '  → Using modern version (newer or unique)');
            allTemplates[unified.id] = unified;
            _updateCache(unified);
          } else {
            _UnifiedTemplateLogger.step('MODERN', '  → Keeping legacy version (newer)');
          }
        }
        _UnifiedTemplateLogger.step('MODERN', 'Successfully processed ${modernTemplates.length} modern templates');
      } catch (e, stackTrace) {
        _UnifiedTemplateLogger.error('Error loading modern templates', e);
        _UnifiedTemplateLogger.error('Stack trace: $stackTrace');
        // Continue without modern templates
      }

      // 3. Get imported templates if requested
      if (includeImported) {
        _UnifiedTemplateLogger.step('IMPORT', 'Imported templates feature not yet implemented');
        // This would get imported templates from local storage
        // Implementation depends on how imports are currently stored
      }

      // Sort by creation date (most recent first)
      final result = allTemplates.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _UnifiedTemplateLogger.log('✅ getUserTemplates() completed successfully');
      _UnifiedTemplateLogger.log('  - Total unique templates found: ${result.length}');
      _UnifiedTemplateLogger.log('  - Template names: ${result.map((t) => t.name).take(5).join(', ')}${result.length > 5 ? '...' : ''}');

      return result;
    } catch (e, stackTrace) {
      _UnifiedTemplateLogger.error('Fatal error in getUserTemplates()', e);
      _UnifiedTemplateLogger.error('Stack trace: $stackTrace');
      rethrow;
    } finally {
      _operationsInProgress.remove(operationId);
      _UnifiedTemplateLogger.log('🔓 Operation lock released');
    }
  }

  /// Get template by ID with race condition safety
  Future<UnifiedWorkoutTemplate?> getTemplateById(String templateId) async {
    // Check cache first
    if (_isInCache(templateId)) {
      return _cache[templateId];
    }

    final operationId = 'getTemplate_$templateId';

    if (_operationsInProgress.contains(operationId)) {
      await _waitForOperation(operationId);
      return _cache[templateId]; // Should be cached after operation
    }

    _operationsInProgress.add(operationId);

    try {
      // Try modern repository first (more likely to have recent templates)
      try {
        final modernTemplates = await _modernRepository.getUserTemplates();
        final modernTemplate = modernTemplates.firstWhere((t) => t.id == templateId);
        final unified = TemplateMigrationHelpers.fromLegacyTemplate(modernTemplate);
        _updateCache(unified);
        return unified;
      } catch (e) {
        // Template not found in modern repository, try legacy
      }

      // Try legacy repository
      try {
        final legacyTemplates = await _legacyRepository.getAllTemplates();
        final legacyTemplate = legacyTemplates.firstWhere((t) => t.id == templateId);
        final unified = TemplateMigrationHelpers.fromLegacyTemplate(legacyTemplate);
        _updateCache(unified);
        return unified;
      } catch (e) {
        // Template not found in legacy repository either
      }

      return null;
    } finally {
      _operationsInProgress.remove(operationId);
    }
  }

  /// Create new template with automatic format selection
  Future<String> createTemplate(UnifiedWorkoutTemplate template) async {
    final operationId = 'createTemplate_${template.id}';

    if (_operationsInProgress.contains(operationId)) {
      throw TemplateMigrationException(
          'Template ${template.id} is already being created');
    }

    _operationsInProgress.add(operationId);

    try {
      // Mark as sync in progress to prevent race conditions
      final templateWithFlags = template.copyWith(
        isSyncInProgress: true,
        version: (template.version ?? 0) + 1,
      );

      // Choose target repository based on user preferences or template features
      if (_shouldUseModernRepository(templateWithFlags)) {
        // Convert to legacy format and save to modern repository (it uses legacy format)
        final legacyTemplate = TemplateMigrationHelpers.toLegacyTemplate(templateWithFlags);
        final id = await _modernRepository.createTemplate(legacyTemplate);

        // Update cache with completed template
        final completedTemplate = templateWithFlags.copyWith(
          id: id,
          isSyncInProgress: false,
        );
        _updateCache(completedTemplate);

        return id;
      } else {
        // Convert to legacy format and save
        final legacyTemplate = TemplateMigrationHelpers.toLegacyTemplate(templateWithFlags);
        await _legacyRepository.saveTemplate(legacyTemplate);

        // Update cache
        final completedTemplate = templateWithFlags.copyWith(
          isSyncInProgress: false,
        );
        _updateCache(completedTemplate);

        return templateWithFlags.id;
      }
    } finally {
      _operationsInProgress.remove(operationId);
    }
  }

  /// Update template with conflict resolution
  Future<void> updateTemplate(UnifiedWorkoutTemplate template) async {
    final operationId = 'updateTemplate_${template.id}';

    if (_operationsInProgress.contains(operationId)) {
      throw TemplateMigrationException(
          'Template ${template.id} is already being updated');
    }

    _operationsInProgress.add(operationId);

    try {
      // Check for version conflicts (optimistic locking)
      final existing = await getTemplateById(template.id);
      if (existing != null && existing.version != null && template.version != null) {
        if (existing.version! > template.version!) {
          throw TemplateMigrationException(
              'Template ${template.id} has been modified by another process. Please refresh and try again.');
        }
      }

      // Mark as sync in progress
      final templateWithFlags = template.copyWith(
        isSyncInProgress: true,
        version: (template.version ?? 0) + 1,
        updatedAt: DateTime.now(),
      );

      // Update in appropriate repository based on source
      switch (template.source) {
        case TemplateSource.modern:
          final legacyTemplate = TemplateMigrationHelpers.toLegacyTemplate(templateWithFlags);
          await _modernRepository.updateTemplate(legacyTemplate);
          break;
        case TemplateSource.legacy:
          final legacyTemplate = TemplateMigrationHelpers.toLegacyTemplate(templateWithFlags);
          await _legacyRepository.saveTemplate(legacyTemplate); // Legacy uses saveTemplate for updates
          break;
        case TemplateSource.jsonImport:
          // For imported templates, save to modern repository
          final legacyTemplate = TemplateMigrationHelpers.toLegacyTemplate(templateWithFlags);
          await _modernRepository.updateTemplate(legacyTemplate);
          break;
        case TemplateSource.community:
          // Community templates are read-only, so this shouldn't happen
          throw TemplateMigrationException('Cannot update community template ${template.id}');
      }

      // Update cache
      final completedTemplate = templateWithFlags.copyWith(isSyncInProgress: false);
      _updateCache(completedTemplate);

    } finally {
      _operationsInProgress.remove(operationId);
    }
  }

  /// Delete template with safety checks
  Future<void> deleteTemplate(String templateId) async {
    final operationId = 'deleteTemplate_$templateId';

    _UnifiedTemplateLogger.log('🗑️ deleteTemplate() called for ID: $templateId');

    if (_operationsInProgress.contains(operationId)) {
      throw TemplateMigrationException(
          'Template $templateId is already being deleted');
    }

    _operationsInProgress.add(operationId);

    try {
      // Get template to determine source
      final template = await getTemplateById(templateId);

      if (template == null) {
        _UnifiedTemplateLogger.log('⚠️ Template $templateId not found, attempting deletion from all repositories');

        // Template not found in unified system, but might still exist in individual repos
        // Try to delete from all repositories to ensure complete removal

        bool deletedFromAny = false;

        // Try modern repository
        try {
          await _modernRepository.deleteTemplate(templateId);
          _UnifiedTemplateLogger.log('✅ Deleted from modern repository');
          deletedFromAny = true;
        } catch (e) {
          _UnifiedTemplateLogger.log('ℹ️ Not found in modern repository');
        }

        // Try legacy repository
        try {
          await _legacyRepository.deleteTemplate(templateId);
          _UnifiedTemplateLogger.log('✅ Deleted from legacy repository');
          deletedFromAny = true;
        } catch (e) {
          _UnifiedTemplateLogger.log('ℹ️ Not found in legacy repository');
        }

        if (!deletedFromAny) {
          _UnifiedTemplateLogger.log('⚠️ Template $templateId not found in any repository');
        }

        return;
      }

      _UnifiedTemplateLogger.log('📍 Template found with source: ${template.source}');

      // Mark as being deleted to prevent race conditions
      final templateWithFlags = template.copyWith(isBeingDeleted: true);
      _updateCache(templateWithFlags);

      // Delete from appropriate repositories based on source
      switch (template.source) {
        case TemplateSource.modern:
          _UnifiedTemplateLogger.log('🗑️ Deleting from modern repository');
          await _modernRepository.deleteTemplate(templateId);
          break;

        case TemplateSource.legacy:
          _UnifiedTemplateLogger.log('🗑️ Deleting from legacy repository');
          await _legacyRepository.deleteTemplate(templateId);
          break;

        case TemplateSource.jsonImport:
          _UnifiedTemplateLogger.log('🗑️ Deleting imported template from both repositories');
          // For imported templates, might exist in both - delete from both
          try {
            await _modernRepository.deleteTemplate(templateId);
            _UnifiedTemplateLogger.log('✅ Deleted from modern repository');
          } catch (e) {
            _UnifiedTemplateLogger.log('ℹ️ Not found in modern repository');
          }

          try {
            await _legacyRepository.deleteTemplate(templateId);
            _UnifiedTemplateLogger.log('✅ Deleted from legacy repository');
          } catch (e) {
            _UnifiedTemplateLogger.log('ℹ️ Not found in legacy repository');
          }
          break;

        case TemplateSource.community:
          // Community templates are read-only, so this shouldn't happen
          throw TemplateMigrationException('Cannot delete community template $templateId');
      }

      // Also try to delete from all repositories to ensure complete removal
      // This handles cases where a template might exist in multiple places
      _UnifiedTemplateLogger.log('🔄 Ensuring complete removal from all repositories');

      // Try to delete from other repositories too (in case of duplicates)
      if (template.source != TemplateSource.modern) {
        try {
          await _modernRepository.deleteTemplate(templateId);
          _UnifiedTemplateLogger.log('✅ Also deleted from modern repository');
        } catch (e) {
          // Expected if not there
        }
      }

      if (template.source != TemplateSource.legacy) {
        try {
          await _legacyRepository.deleteTemplate(templateId);
          _UnifiedTemplateLogger.log('✅ Also deleted from legacy repository');
        } catch (e) {
          // Expected if not there
        }
      }

      // Remove from cache
      _cache.remove(templateId);
      _cacheTimestamps.remove(templateId);

      _UnifiedTemplateLogger.log('✅ Template $templateId successfully deleted from all sources');

    } catch (e, stackTrace) {
      _UnifiedTemplateLogger.error('Error deleting template $templateId', e);
      _UnifiedTemplateLogger.error('Stack trace: $stackTrace');
      rethrow;
    } finally {
      _operationsInProgress.remove(operationId);
      _UnifiedTemplateLogger.log('🔓 Delete operation lock released');
    }
  }

  /// Import template from JSON with race condition safety
  Future<UnifiedWorkoutTemplate> importFromJson(
    Map<String, dynamic> jsonData,
    String userId, {
    String languageCode = 'en',
  }) async {
    final templateId = jsonData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    final operationId = 'importTemplate_$templateId';

    if (_operationsInProgress.contains(operationId)) {
      throw TemplateMigrationException(
          'Template $templateId is already being imported');
    }

    _operationsInProgress.add(operationId);

    try {
      // Create unified template from JSON
      final unifiedTemplate = TemplateMigrationHelpers.fromJsonImport(
        jsonData,
        userId: userId,
      );

      // Process exercises using exercise matching service for better compatibility
      final exercises = jsonData['exercises'] as List<dynamic>? ?? [];
      final processedExercises = <Map<String, dynamic>>[];

      for (final exerciseData in exercises) {
        final exerciseName = exerciseData['name'] ?? exerciseData['exerciseName'] ?? '';

        // Try to match exercise name to database using current language
        final matches = await _exerciseMatchingService.findMatches(
          exerciseName,
          maxResults: 1,
          languageCode: languageCode,
        );
        final matchedExercise = matches.isNotEmpty ? matches.first.exercise : null;

        if (matchedExercise != null) {
          processedExercises.add({
            ...exerciseData as Map<String, dynamic>,
            'exerciseName': matchedExercise.nome,
            'category': matchedExercise.focus,
          });
        } else {
          processedExercises.add(exerciseData as Map<String, dynamic>);
        }
      }

      // Convert processed template to unified format
      final finalTemplate = unifiedTemplate.copyWith(
        exercisesRaw: processedExercises,
        isSyncInProgress: false,
      );

      // Save to modern repository (imports go to modern system)
      await createTemplate(finalTemplate);

      _updateCache(finalTemplate);
      return finalTemplate;

    } finally {
      _operationsInProgress.remove(operationId);
    }
  }

  /// Get public/community templates (premium feature)
  Future<List<UnifiedWorkoutTemplate>> getPublicTemplates({
    UnifiedTemplateCategory? category,
    String? searchQuery,
    List<String>? tags,
    String? difficultyLevel,
    int limit = 20,
  }) async {
    // Only modern repository supports public templates
    final modernTemplates = await _modernRepository.getPublicTemplates(
      category: category,
      searchQuery: searchQuery,
      tags: tags,
      difficultyLevel: difficultyLevel,
      limit: limit,
    );

    return modernTemplates
        .map((t) => TemplateMigrationHelpers.fromLegacyTemplate(t))
        .toList();
  }

  /// Clear all caches (useful for logout or memory cleanup)
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    _operationsInProgress.clear();
  }

  /// Helper methods

  bool _shouldUseModernRepository(UnifiedWorkoutTemplate template) {
    // Use modern repository if:
    // - Template has modern features (community, premium, etc.)
    // - Template is public
    // - User has premium account
    return template.visibility == UnifiedTemplateVisibility.public ||
           template.requiresPremium ||
           template.allowComments ||
           template.allowRating ||
           template.downloadCount != 0 ||
           template.rating != null;
  }

  bool _isMoreRecent(UnifiedWorkoutTemplate a, UnifiedWorkoutTemplate b) {
    final aTime = a.updatedAt ?? a.createdAt;
    final bTime = b.updatedAt ?? b.createdAt;
    return aTime.isAfter(bTime);
  }

  void _updateCache(UnifiedWorkoutTemplate template) {
    _cache[template.id] = template;
    _cacheTimestamps[template.id] = DateTime.now();
  }

  bool _isInCache(String templateId) {
    final timestamp = _cacheTimestamps[templateId];
    if (timestamp == null) return false;

    // Check if cache entry is still valid
    if (DateTime.now().difference(timestamp) > _cacheTimeout) {
      _cache.remove(templateId);
      _cacheTimestamps.remove(templateId);
      return false;
    }

    return _cache.containsKey(templateId);
  }

  Future<void> _waitForOperation(String operationId) async {
    const maxWaitTime = Duration(seconds: 30);
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    while (_operationsInProgress.contains(operationId)) {
      if (DateTime.now().difference(startTime) > maxWaitTime) {
        throw TemplateMigrationException(
            'Operation $operationId timed out after ${maxWaitTime.inSeconds} seconds');
      }
      await Future.delayed(checkInterval);
    }
  }
}

// Provider for legacy repository (LOCAL UNIFIED SYSTEM)
final legacyWorkoutTemplateRepositoryProvider = Provider<WorkoutTemplateRepository>((ref) {
  _UnifiedTemplateLogger.log('📦 Creating legacy WorkoutTemplateRepository...');
  final repository = WorkoutTemplateRepository();
  _UnifiedTemplateLogger.log('✅ Legacy repository created: ${repository.runtimeType}');
  return repository;
});

// Provider for hybrid template repository (passes ref for user profile access)
final hybridTemplateRepositoryProvider = Provider<HybridTemplateRepository>((ref) {
  return HybridTemplateRepository(
    boxManager: ref.watch(hiveBoxManagerProvider),
    ref: ref,
  );
});

// Provider for exercise matching service
final exerciseMatchingServiceProvider = Provider<ExerciseMatchingService>((ref) {
  return ExerciseMatchingService.instance;
});

/// Provider for unified template repository
final unifiedTemplateRepositoryProvider = Provider<UnifiedTemplateRepository>((ref) {
  _UnifiedTemplateLogger.log('🏗️ Creating UnifiedTemplateRepository...');

  final legacyRepo = ref.watch(legacyWorkoutTemplateRepositoryProvider);
  final modernRepo = ref.watch(hybridTemplateRepositoryProvider);
  final exerciseService = ref.watch(exerciseMatchingServiceProvider);

  _UnifiedTemplateLogger.log('✅ All dependencies obtained for UnifiedTemplateRepository');

  return UnifiedTemplateRepository(
    legacyRepository: legacyRepo,
    modernRepository: modernRepo,
    exerciseMatchingService: exerciseService,
  );
});

/// Convenience providers for common operations
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final userTemplatesProvider = FutureProvider.autoDispose<List<UnifiedWorkoutTemplate>>((ref) async {
  _UnifiedTemplateLogger.log('🎯 userTemplatesProvider called');
  _UnifiedTemplateLogger.log('Getting unified template repository...');

  final repository = ref.watch(unifiedTemplateRepositoryProvider);
  _UnifiedTemplateLogger.log('Repository obtained: ${repository.runtimeType}');
  _UnifiedTemplateLogger.log('Calling repository.getUserTemplates()...');

  try {
    final result = await repository.getUserTemplates();
    _UnifiedTemplateLogger.log('✅ userTemplatesProvider success: ${result.length} templates');
    return result;
  } catch (e, stackTrace) {
    _UnifiedTemplateLogger.error('❌ userTemplatesProvider failed', e);
    _UnifiedTemplateLogger.error('Stack trace: $stackTrace');
    rethrow;
  }
});

/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final templateByIdProvider = FutureProvider.autoDispose.family<UnifiedWorkoutTemplate?, String>((ref, templateId) async {
  final repository = ref.watch(unifiedTemplateRepositoryProvider);
  return await repository.getTemplateById(templateId);
});

/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final publicTemplatesProvider = FutureProvider.autoDispose.family<List<UnifiedWorkoutTemplate>, PublicTemplateQuery>((ref, query) async {
  final repository = ref.watch(unifiedTemplateRepositoryProvider);
  return await repository.getPublicTemplates(
    category: query.category,
    searchQuery: query.searchQuery,
    tags: query.tags,
    difficultyLevel: query.difficultyLevel,
    limit: query.limit,
  );
});

/// Query parameters for public templates
class PublicTemplateQuery {

  const PublicTemplateQuery({
    this.category,
    this.searchQuery,
    this.tags,
    this.difficultyLevel,
    this.limit = 20,
  });
  final UnifiedTemplateCategory? category;
  final String? searchQuery;
  final List<String>? tags;
  final String? difficultyLevel;
  final int limit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicTemplateQuery &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          searchQuery == other.searchQuery &&
          tags == other.tags &&
          difficultyLevel == other.difficultyLevel &&
          limit == other.limit;

  @override
  int get hashCode =>
      category.hashCode ^
      searchQuery.hashCode ^
      tags.hashCode ^
      difficultyLevel.hashCode ^
      limit.hashCode;
}