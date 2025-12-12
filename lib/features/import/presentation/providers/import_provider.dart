/// Import Provider
///
/// State management for the import workflow using Riverpod.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/exercise_database/presentation/providers/hybrid_exercise_provider.dart';
import 'package:gymbro_flutter_new/features/workout/presentation/providers/workout_dependency_injection.dart';
import 'package:gymbro_flutter_new/features/import/data/repositories/import_repository.dart';
import 'package:gymbro_flutter_new/features/import/domain/entities/import_result.dart';

/// Import state
sealed class ImportState {
  const ImportState();
}

class ImportInitial extends ImportState {
  const ImportInitial();
}

class ImportParsing extends ImportState {
  const ImportParsing();
}

class ImportParsed extends ImportState {
  const ImportParsed(this.result);
  final ImportParseResult result;
}

class ImportExecuting extends ImportState {
  const ImportExecuting();
}

class ImportCompleted extends ImportState {
  const ImportCompleted(this.result);
  final ImportFinalResult result;
}

class ImportError extends ImportState {
  const ImportError(this.message);
  final String message;
}

/// Import notifier for managing import workflow
class ImportNotifier extends StateNotifier<ImportState> {
  ImportNotifier(this._repository) : super(const ImportInitial());

  final ImportRepository _repository;
  ImportParseResult? _currentParseResult;

  /// Get current parse result for UI display
  ImportParseResult? get currentParseResult => _currentParseResult;

  /// Parse CSV content
  Future<void> parseCSV(String csvContent, {String sourceApp = 'strong'}) async {
    state = const ImportParsing();

    try {
      final result = await _repository.parseAndMap(csvContent, sourceApp: sourceApp);
      _currentParseResult = result;
      state = ImportParsed(result);
    } catch (e) {
      state = ImportError('Failed to parse CSV: $e');
    }
  }

  /// Apply manual exercise mappings
  void applyManualMapping(String originalName, String exerciseId) {
    if (_currentParseResult == null) return;

    _currentParseResult = _repository.applyManualMappings(
      _currentParseResult!,
      {originalName: exerciseId},
    );
    state = ImportParsed(_currentParseResult!);
  }

  /// Apply multiple manual mappings at once
  void applyManualMappings(Map<String, String> mappings) {
    if (_currentParseResult == null) return;

    _currentParseResult = _repository.applyManualMappings(
      _currentParseResult!,
      mappings,
    );
    state = ImportParsed(_currentParseResult!);
  }

  /// Execute final import
  Future<void> executeImport({bool skipUnmapped = false}) async {
    if (_currentParseResult == null) {
      state = const ImportError('No data to import');
      return;
    }

    state = const ImportExecuting();

    try {
      final result = await _repository.executeImport(
        _currentParseResult!,
        skipUnmapped: skipUnmapped,
      );

      state = ImportCompleted(result);
    } catch (e) {
      state = ImportError('Failed to import: $e');
    }
  }

  /// Reset to initial state
  void reset() {
    _currentParseResult = null;
    state = const ImportInitial();
  }
}

/// Provider for import repository
final importRepositoryProvider = Provider<ImportRepository>((ref) {
  final exercises = ref.watch(allExercisesProvider).valueOrNull ?? [];
  final workoutRepo = ref.watch(workoutRepositoryProvider);

  return ImportRepository(
    exerciseDatabase: exercises,
    workoutRepository: workoutRepo,
  );
});

/// Provider for import notifier
final importNotifierProvider = StateNotifierProvider<ImportNotifier, ImportState>((ref) {
  final repository = ref.watch(importRepositoryProvider);
  return ImportNotifier(repository);
});

/// Provider for available source apps
final importSourceAppsProvider = Provider<List<ImportSourceApp>>((ref) {
  return [
    ImportSourceApp(
      id: 'strong',
      name: 'Strong',
      description: 'Import from Strong app CSV export',
      iconPath: 'assets/icons/strong_logo.png', // TODO: Add icon
      isSupported: true,
    ),
    ImportSourceApp(
      id: 'hevy',
      name: 'Hevy',
      description: 'Import from Hevy app CSV export',
      iconPath: 'assets/icons/hevy_logo.png', // TODO: Add icon
      isSupported: false, // TODO: Implement
    ),
  ];
});

/// Source app configuration
class ImportSourceApp {
  const ImportSourceApp({
    required this.id,
    required this.name,
    required this.description,
    this.iconPath,
    required this.isSupported,
  });

  final String id;
  final String name;
  final String description;
  final String? iconPath;
  final bool isSupported;
}
