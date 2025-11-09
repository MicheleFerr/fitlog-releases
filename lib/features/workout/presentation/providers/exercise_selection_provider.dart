import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/workout/domain/entities/exercise.dart';
import 'package:gymbro_flutter_new/shared/presentation/providers/app_config_provider.dart';

/// 🚀 TIER-1 PERFORMANCE: Immutable exercise data model
class ExerciseData {
  
  const ExerciseData({
    required this.id,
    required this.nome,
    required this.focus,
    this.imageUrl,
    this.muscoliSecondari,
    required this.difficolta,
    required this.tipoEsercizio,
    required this.attrezzatura,
    required this.patternMovimento,
    required this.rangeRipetizioni,
    this.noteTecniche,
  });
  
  factory ExerciseData.fromJson(Map<String, dynamic> json) {
    return ExerciseData(
      id: json['id'] as String,
      nome: json['nome'] as String,
      focus: json['focus'] as String,
      imageUrl: json['imageUrl'] as String?,
      muscoliSecondari: json['muscoliSecondari'] as String?,
      difficolta: json['difficolta'] as String,
      tipoEsercizio: json['tipoEsercizio'] as String,
      attrezzatura: json['attrezzatura'] as String,
      patternMovimento: json['patternMovimento'] as String,
      rangeRipetizioni: json['rangeRipetizioni'] as String,
      noteTecniche: json['noteTecniche'] as String?,
    );
  }
  final String id;
  final String nome;
  final String focus;
  final String? imageUrl;
  final String? muscoliSecondari;
  final String difficolta;
  final String tipoEsercizio;
  final String attrezzatura;
  final String patternMovimento;
  final String rangeRipetizioni;
  final String? noteTecniche;

  // English getters for compatibility
  String get name => nome;
  String get category => tipoEsercizio;
  List<String> get muscleGroups => [
    focus,
    if (muscoliSecondari != null && muscoliSecondari!.isNotEmpty) muscoliSecondari!,
  ];
}

/// 🚀 TIER-1: Cached and indexed exercise database
class ExerciseDatabase {
  
  ExerciseDatabase._({
    required this.exercises,
    required Map<String, List<int>> searchIndex,
    required Map<String, List<int>> categoryIndex,
    required Map<String, List<int>> equipmentIndex,
  }) : _searchIndex = searchIndex,
       _categoryIndex = categoryIndex,
       _equipmentIndex = equipmentIndex;
  final List<ExerciseData> exercises;
  final Map<String, List<int>> _searchIndex;
  final Map<String, List<int>> _categoryIndex;
  final Map<String, List<int>> _equipmentIndex;
  
  /// Build optimized indexes for O(1) lookups
  static Future<ExerciseDatabase> load({String languageCode = 'en'}) async {
    // Use localized JSON file
    final jsonFile = languageCode == 'it'
        ? 'assets/data/exercises_it.json'
        : 'assets/data/exercises.json';

    final jsonString = await rootBundle.loadString(jsonFile);
    final List<dynamic> jsonList = json.decode(jsonString);
    
    final exercises = jsonList
        .map((json) => ExerciseData.fromJson(json as Map<String, dynamic>))
        .toList(growable: false); // Fixed size list for better memory
    
    // Build search index (lowercase for case-insensitive search)
    final searchIndex = <String, List<int>>{};
    final categoryIndex = <String, List<int>>{};
    final equipmentIndex = <String, List<int>>{};
    
    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      
      // Search index by name tokens
      final tokens = exercise.nome.toLowerCase().split(' ');
      for (final token in tokens) {
        for (int j = 1; j <= token.length; j++) {
          final prefix = token.substring(0, j);
          (searchIndex[prefix] ??= []).add(i);
        }
      }
      
      // Category index
      final categories = exercise.focus.split(', ');
      for (final category in categories) {
        (categoryIndex[category.toLowerCase()] ??= []).add(i);
      }
      
      // Equipment index
      (equipmentIndex[exercise.attrezzatura.toLowerCase()] ??= []).add(i);
    }
    
    return ExerciseDatabase._(
      exercises: exercises,
      searchIndex: searchIndex,
      categoryIndex: categoryIndex,
      equipmentIndex: equipmentIndex,
    );
  }
  
  /// O(1) search with pre-built index
  List<ExerciseData> search(String query) {
    if (query.isEmpty) return const [];
    
    final tokens = query.toLowerCase().split(' ');
    Set<int>? resultIndices;
    
    for (final token in tokens) {
      final tokenIndices = _searchIndex[token];
      if (tokenIndices == null) return const [];
      
      if (resultIndices == null) {
        resultIndices = tokenIndices.toSet();
      } else {
        resultIndices = resultIndices.intersection(tokenIndices.toSet());
      }
    }
    
    return resultIndices?.map((i) => exercises[i]).toList() ?? const [];
  }
  
  List<ExerciseData> byCategory(String category) {
    final indices = _categoryIndex[category.toLowerCase()];
    return indices?.map((i) => exercises[i]).toList() ?? const [];
  }
  
  List<ExerciseData> byEquipment(String equipment) {
    final indices = _equipmentIndex[equipment.toLowerCase()];
    return indices?.map((i) => exercises[i]).toList() ?? const [];
  }
  
  /// Get antagonist muscle suggestions for supersets
  List<ExerciseData> getAntagonistSuggestions(String primaryMuscle) {
    final antagonistMap = {
      'petto': ['dorso', 'dorsali'],
      'dorso': ['petto'],
      'bicipiti': ['tricipiti'],
      'tricipiti': ['bicipiti'],
      'quadricipiti': ['femorali', 'glutei'],
      'femorali': ['quadricipiti'],
    };
    
    final antagonists = antagonistMap[primaryMuscle.toLowerCase()] ?? [];
    final suggestions = <ExerciseData>[];
    
    for (final antagonist in antagonists) {
      suggestions.addAll(byCategory(antagonist));
    }
    
    return suggestions.take(10).toList(); // Limit to 10 suggestions
  }
}

/// 🚀 TIER-1: Singleton provider for exercise database (loaded once)
/// 🔧 MEMORY FIX: Added autoDispose to prevent memory leaks
/// Automatically disposes provider instances when widget is disposed
final exerciseDatabaseProvider = FutureProvider.autoDispose<ExerciseDatabase>((ref) async {
  final config = ref.watch(appConfigProvider);
  return ExerciseDatabase.load(languageCode: config.languageCode);
});

/// 🚀 TIER-1: Selection state with minimal rebuilds
class ExerciseSelectionState {
  
  const ExerciseSelectionState({
    this.searchQuery = '',
    this.selectedIds = const {},
    this.focusedCategory,
    this.focusedEquipment,
    this.isMultiSelect = false,
    this.targetType,
  });
  final String searchQuery;
  final Set<String> selectedIds;
  final String? focusedCategory;
  final String? focusedEquipment;
  final bool isMultiSelect;
  final ExerciseType? targetType;
  
  ExerciseSelectionState copyWith({
    String? searchQuery,
    Set<String>? selectedIds,
    Object? focusedCategory = _undefined,
    Object? focusedEquipment = _undefined,
    bool? isMultiSelect,
    Object? targetType = _undefined,
  }) {
    return ExerciseSelectionState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIds: selectedIds ?? this.selectedIds,
      focusedCategory: focusedCategory == _undefined
          ? this.focusedCategory
          : focusedCategory as String?,
      focusedEquipment: focusedEquipment == _undefined
          ? this.focusedEquipment
          : focusedEquipment as String?,
      isMultiSelect: isMultiSelect ?? this.isMultiSelect,
      targetType: targetType == _undefined
          ? this.targetType
          : targetType as ExerciseType?,
    );
  }
}

// Sentinel value for nullable parameters in copyWith
const Object _undefined = Object();

/// 🚀 TIER-1: State notifier with optimized updates
class ExerciseSelectionNotifier extends StateNotifier<ExerciseSelectionState> {
  ExerciseSelectionNotifier() : super(const ExerciseSelectionState());
  
  void updateSearch(String query) {
    // Debounced in UI layer
    state = state.copyWith(searchQuery: query);
  }
  
  void toggleSelection(String exerciseId) {
    final newSelection = Set<String>.from(state.selectedIds);
    if (newSelection.contains(exerciseId)) {
      newSelection.remove(exerciseId);
    } else {
      if (!state.isMultiSelect) {
        newSelection.clear();
      }
      newSelection.add(exerciseId);
    }
    state = state.copyWith(selectedIds: newSelection);
  }
  
  void clearSelection() {
    state = state.copyWith(selectedIds: const {});
  }
  
  void setMultiSelect(bool enabled) {
    state = state.copyWith(
      isMultiSelect: enabled,
      selectedIds: enabled ? state.selectedIds : const {},
    );
  }
  
  void setTargetType(ExerciseType? type) {
    state = state.copyWith(
      targetType: type,
      isMultiSelect: type == ExerciseType.superset,
    );
  }
  
  void setCategory(String? category) {
    state = state.copyWith(focusedCategory: category);
  }
  
  void setEquipment(String? equipment) {
    state = state.copyWith(focusedEquipment: equipment);
  }
  
  void reset() {
    state = const ExerciseSelectionState();
  }

  /// Clear all filters (but keep selection)
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      focusedCategory: null,
      focusedEquipment: null,
    );
  }

  /// Clear specific filter
  void clearCategoryFilter() {
    state = state.copyWith(focusedCategory: null);
  }

  void clearEquipmentFilter() {
    state = state.copyWith(focusedEquipment: null);
  }

  void clearSearchQuery() {
    state = state.copyWith(searchQuery: '');
  }
}

// ✅ FIX: Removed .autoDispose to persist filters across navigation
final exerciseSelectionProvider =
    StateNotifierProvider<ExerciseSelectionNotifier, ExerciseSelectionState>((ref) {
  return ExerciseSelectionNotifier();
});

/// 🚀 TIER-1: Memoized filtered results
final filteredExercisesProvider = Provider.autoDispose<AsyncValue<List<ExerciseData>>>((ref) {
  final database = ref.watch(exerciseDatabaseProvider);
  final selection = ref.watch(exerciseSelectionProvider);
  
  return database.when(
    data: (db) {
      List<ExerciseData> results;
      
      // Priority: search query
      if (selection.searchQuery.isNotEmpty) {
        results = db.search(selection.searchQuery);
      }
      // Category filter
      else if (selection.focusedCategory != null) {
        results = db.byCategory(selection.focusedCategory!);
      }
      // Equipment filter
      else if (selection.focusedEquipment != null) {
        results = db.byEquipment(selection.focusedEquipment!);
      }
      // All exercises
      else {
        results = db.exercises;
      }
      
      return AsyncData(results);
    },
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
  );
});

/// 🚀 TIER-1: Selected exercises data (computed)
final selectedExercisesProvider = Provider.autoDispose<List<ExerciseData>>((ref) {
  final database = ref.watch(exerciseDatabaseProvider);
  final selection = ref.watch(exerciseSelectionProvider.select((s) => s.selectedIds));
  
  return database.when(
    data: (db) {
      return db.exercises
          .where((e) => selection.contains(e.id))
          .toList();
    },
    loading: () => const [],
    error: (_, __) => const [],
  );
});

/// 🚀 TIER-1: Antagonist suggestions for supersets
final antagonistSuggestionsProvider = Provider.autoDispose.family<List<ExerciseData>, String>((ref, primaryMuscle) {
  final database = ref.watch(exerciseDatabaseProvider);
  
  return database.when(
    data: (db) => db.getAntagonistSuggestions(primaryMuscle),
    loading: () => const [],
    error: (_, __) => const [],
  );
});