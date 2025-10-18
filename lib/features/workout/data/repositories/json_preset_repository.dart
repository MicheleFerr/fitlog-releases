/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: features/workout/data/repositories
/// 🎯 Feature: workout
/// 🔧 Type: repository implementation
///
/// JSON-based preset repository implementation
///
/// ARCHITECTURE (Phase 3 Refactoring):
/// - Loads presets from local JSON files
/// - Caches in memory for performance
/// - Supports hot reload (refresh from JSON)
/// - Offline-first (no network required)
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gymbro_flutter_new/features/workout/domain/models/workout_preset.dart';
import 'package:gymbro_flutter_new/features/workout/domain/services/i_preset_service.dart';

/// JSON-based preset service implementation
///
/// Loads presets from asset JSON files:
/// - `assets/data/rep_presets.json`
/// - `assets/data/set_presets.json`
/// - `assets/data/rest_time_presets.json`
///
/// Example usage:
/// ```dart
/// final service = JSONPresetService();
/// await service.initialize();
///
/// final repPresets = await service.getRepRangePresets();
/// print('Loaded ${repPresets.length} rep presets');
/// ```
class JSONPresetService implements IPresetService {
  /// In-memory cache for rep range presets
  List<RepRangePreset>? _repRangePresetsCache;

  /// In-memory cache for set count presets
  List<SetCountPreset>? _setCountPresetsCache;

  /// In-memory cache for rest time presets
  List<RestTimePreset>? _restTimePresetsCache;

  /// Flag to track initialization state
  bool _isInitialized = false;

  /// Asset paths for JSON files
  static const String _repPresetsPath = 'assets/data/rep_presets.json';
  static const String _setPresetsPath = 'assets/data/set_presets.json';
  static const String _restTimePresetsPath = 'assets/data/rest_time_presets.json';

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        debugPrint('⚠️ JSONPresetService already initialized');
      }
      return;
    }

    try {
      // Load all presets in parallel
      await Future.wait([
        _loadRepRangePresets(),
        _loadSetCountPresets(),
        _loadRestTimePresets(),
      ]);

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ JSONPresetService initialized');
        debugPrint('   - ${_repRangePresetsCache?.length} rep presets');
        debugPrint('   - ${_setCountPresetsCache?.length} set presets');
        debugPrint('   - ${_restTimePresetsCache?.length} rest time presets');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ JSONPresetService initialization error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<RepRangePreset>> getRepRangePresets() async {
    _ensureInitialized();

    if (_repRangePresetsCache == null) {
      await _loadRepRangePresets();
    }

    return List.unmodifiable(_repRangePresetsCache!);
  }

  @override
  Future<RepRangePreset?> getRepRangePresetById(String id) async {
    final presets = await getRepRangePresets();
    try {
      return presets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SetCountPreset>> getSetCountPresets() async {
    _ensureInitialized();

    if (_setCountPresetsCache == null) {
      await _loadSetCountPresets();
    }

    return List.unmodifiable(_setCountPresetsCache!);
  }

  @override
  Future<SetCountPreset?> getSetCountPresetById(String id) async {
    final presets = await getSetCountPresets();
    try {
      return presets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<RestTimePreset>> getRestTimePresets() async {
    _ensureInitialized();

    if (_restTimePresetsCache == null) {
      await _loadRestTimePresets();
    }

    return List.unmodifiable(_restTimePresetsCache!);
  }

  @override
  Future<RestTimePreset?> getRestTimePresetById(String id) async {
    final presets = await getRestTimePresets();
    try {
      return presets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> refresh() async {
    if (kDebugMode) {
      debugPrint('🔄 Refreshing presets from JSON files...');
    }

    // Clear cache
    _repRangePresetsCache = null;
    _setCountPresetsCache = null;
    _restTimePresetsCache = null;

    // Reload
    await Future.wait([
      _loadRepRangePresets(),
      _loadSetCountPresets(),
      _loadRestTimePresets(),
    ]);

    if (kDebugMode) {
      debugPrint('✅ Presets refreshed');
    }
  }

  @override
  Future<void> dispose() async {
    _repRangePresetsCache = null;
    _setCountPresetsCache = null;
    _restTimePresetsCache = null;
    _isInitialized = false;

    if (kDebugMode) {
      debugPrint('🔒 JSONPresetService disposed');
    }
  }

  /// Load rep range presets from JSON
  Future<void> _loadRepRangePresets() async {
    try {
      final jsonString = await rootBundle.loadString(_repPresetsPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final presetsList = jsonData['presets'] as List;

      _repRangePresetsCache = presetsList
          .map((json) => RepRangePreset.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      if (kDebugMode) {
        debugPrint('   ✓ Loaded ${_repRangePresetsCache!.length} rep presets from $_repPresetsPath');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ✗ Error loading rep presets: $e');
      }
      rethrow;
    }
  }

  /// Load set count presets from JSON
  Future<void> _loadSetCountPresets() async {
    try {
      final jsonString = await rootBundle.loadString(_setPresetsPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final presetsList = jsonData['presets'] as List;

      _setCountPresetsCache = presetsList
          .map((json) => SetCountPreset.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      if (kDebugMode) {
        debugPrint('   ✓ Loaded ${_setCountPresetsCache!.length} set presets from $_setPresetsPath');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ✗ Error loading set presets: $e');
      }
      rethrow;
    }
  }

  /// Load rest time presets from JSON
  Future<void> _loadRestTimePresets() async {
    try {
      final jsonString = await rootBundle.loadString(_restTimePresetsPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final presetsList = jsonData['presets'] as List;

      _restTimePresetsCache = presetsList
          .map((json) => RestTimePreset.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      if (kDebugMode) {
        debugPrint('   ✓ Loaded ${_restTimePresetsCache!.length} rest time presets from $_restTimePresetsPath');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('   ✗ Error loading rest time presets: $e');
      }
      rethrow;
    }
  }

  /// Ensure service is initialized before operations
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'JSONPresetService not initialized. Call initialize() first.',
      );
    }
  }
}
