import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:gymbro_flutter_new/shared/domain/entities/exercise_card_settings.dart';
import 'package:gymbro_flutter_new/core/data/providers/hive_box_manager_provider.dart';

/// Provider for Exercise Card Settings
/// Manages the visual appearance configuration of exercise cards during workouts
final exerciseCardSettingsProvider =
    NotifierProvider<ExerciseCardSettingsNotifier, ExerciseCardSettings>(
  ExerciseCardSettingsNotifier.new,
);

class ExerciseCardSettingsNotifier extends Notifier<ExerciseCardSettings> {
  static const String _boxName = 'exercise_card_settings';
  Box<ExerciseCardSettings>? _settingsBox;

  bool _isInitialized = false;
  bool _isDisposed = false;
  Completer<void>? _initCompleter;
  bool _isInitializing = false;

  static ExerciseCardSettings? _cachedSettings;

  @override
  ExerciseCardSettings build() {
    ref.keepAlive();

    ref.onDispose(() {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Starting disposal');
      }
      _isDisposed = true;
      _initCompleter = null;
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Disposal completed (cache preserved)');
      }
    });

    if (_cachedSettings != null) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Returning cached settings');
      }
      _initCompleter = Completer<void>();
      _initializeSettings();
      return _cachedSettings!;
    }

    _initCompleter = Completer<void>();
    _initializeSettings();

    return const ExerciseCardSettings();
  }

  Future<void> _initializeSettings() async {
    if (_isInitializing) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Init already in progress, waiting...');
      }
      await _initCompleter?.future;
      return;
    }

    try {
      _isInitializing = true;

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Starting initialization');
      }

      final boxManager = ref.read(hiveBoxManagerProvider);
      _settingsBox = await boxManager.openBox<ExerciseCardSettings>(_boxName);
      final savedSettings = _settingsBox!.get('settings');

      if (savedSettings != null) {
        // Migration: ensure footerElements has default values if empty
        // This handles cases where settings were saved before footerElements was added
        // or when user accidentally cleared all footer elements
        final migratedSettings = savedSettings.footerElements.isEmpty
            ? savedSettings.copyWith(
                footerElements: const [
                  ExerciseFooterElement.tips,
                  ExerciseFooterElement.tut,
                  ExerciseFooterElement.notes,
                ],
              )
            : savedSettings;
        state = migratedSettings;
        _cachedSettings = migratedSettings;
        if (kDebugMode) {
          debugPrint('[ExerciseCardSettings] Loaded saved settings');
          if (savedSettings.footerElements.isEmpty) {
            debugPrint('[ExerciseCardSettings] Migrated empty footerElements to defaults');
          }
        }
      } else {
        state = const ExerciseCardSettings();
        _cachedSettings = state;
        if (kDebugMode) {
          debugPrint('[ExerciseCardSettings] Using defaults');
        }
      }

      _isInitialized = true;
      _initCompleter?.complete();

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Initialization completed');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Initialization failed: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      state = const ExerciseCardSettings();
      if (!_initCompleter!.isCompleted) {
        _initCompleter?.completeError(e, stackTrace);
      }
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    if (_initCompleter != null) {
      try {
        await _initCompleter!.future.timeout(const Duration(seconds: 10));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[ExerciseCardSettings] Ensure initialized timeout: $e');
        }
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _ensureInitialized();
      if (_isDisposed || _settingsBox == null) return;

      await _settingsBox!.put('settings', state);
      _cachedSettings = state;

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Settings saved');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Failed to save: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Update GIF size
  Future<void> setGifSize(ExerciseGifSize size) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(gifSize: size);
      await _saveSettings();

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] GIF size set to: ${size.name}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Error setting GIF size: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Update card density
  Future<void> setDensity(ExerciseCardDensity density) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(density: density);
      await _saveSettings();

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Density set to: ${density.name}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Error setting density: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Update show insight setting
  Future<void> setShowInsight(bool show) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(showInsight: show);
      await _saveSettings();

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Show insight set to: $show');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Error setting show insight: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Update show timer setting
  Future<void> setShowTimer(bool show) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(showTimer: show);
      await _saveSettings();

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Show timer set to: $show');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Error setting show timer: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Update show plates setting
  Future<void> setShowPlates(bool show) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(showPlates: show);
      await _saveSettings();

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Show plates set to: $show');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Error setting show plates: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Update show RPE setting
  Future<void> setShowRpe(bool show) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(showRpe: show);
      await _saveSettings();

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Show RPE set to: $show');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Error setting show RPE: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Update footer elements
  Future<void> setFooterElements(List<ExerciseFooterElement> elements) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(footerElements: elements);
      await _saveSettings();

      if (kDebugMode) {
        debugPrint(
          '[ExerciseCardSettings] Footer elements set to: ${elements.map((e) => e.name).join(", ")}',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Error setting footer elements: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Toggle a specific footer element
  Future<void> toggleFooterElement(ExerciseFooterElement element) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      final currentElements = List<ExerciseFooterElement>.from(state.footerElements);
      if (currentElements.contains(element)) {
        currentElements.remove(element);
      } else {
        currentElements.add(element);
      }

      state = state.copyWith(footerElements: currentElements);
      await _saveSettings();

      if (kDebugMode) {
        debugPrint(
          '[ExerciseCardSettings] Toggled footer element: ${element.name}',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Error toggling footer element: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Update footer expanded default
  Future<void> setFooterExpanded(bool expanded) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = state.copyWith(footerExpanded: expanded);
      await _saveSettings();

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Footer expanded set to: $expanded');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Error setting footer expanded: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Apply a preset configuration
  Future<void> applyPreset(ExerciseCardSettings preset) async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = preset;
      await _saveSettings();

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Preset applied');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Error applying preset: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    try {
      await _ensureInitialized();
      if (_isDisposed) return;

      state = const ExerciseCardSettings();
      await _saveSettings();

      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Reset to defaults');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ExerciseCardSettings] Error resetting to defaults: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }
}

// Convenience providers for specific settings

/// Provider for GIF size only
final exerciseGifSizeProvider = Provider<ExerciseGifSize>((ref) {
  return ref.watch(exerciseCardSettingsProvider.select((s) => s.gifSize));
});

/// Provider for card density only
final exerciseCardDensityProvider = Provider<ExerciseCardDensity>((ref) {
  return ref.watch(exerciseCardSettingsProvider.select((s) => s.density));
});

/// Provider for show insight only
final showExerciseInsightProvider = Provider<bool>((ref) {
  return ref.watch(exerciseCardSettingsProvider.select((s) => s.showInsight));
});

/// Provider for show timer only
final showExerciseTimerProvider = Provider<bool>((ref) {
  return ref.watch(exerciseCardSettingsProvider.select((s) => s.showTimer));
});

/// Provider for show plates only
final showExercisePlatesProvider = Provider<bool>((ref) {
  return ref.watch(exerciseCardSettingsProvider.select((s) => s.showPlates));
});

/// Provider for show RPE only
final showExerciseRpeProvider = Provider<bool>((ref) {
  return ref.watch(exerciseCardSettingsProvider.select((s) => s.showRpe));
});

/// Provider for footer elements only
final exerciseFooterElementsProvider = Provider<List<ExerciseFooterElement>>((ref) {
  return ref.watch(exerciseCardSettingsProvider.select((s) => s.footerElements));
});

/// Provider for footer expanded default only
final exerciseFooterExpandedProvider = Provider<bool>((ref) {
  return ref.watch(exerciseCardSettingsProvider.select((s) => s.footerExpanded));
});
