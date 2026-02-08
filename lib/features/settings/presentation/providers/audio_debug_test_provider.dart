/// 🏋️‍♂️ GymBro TrackLog - Flutter Fitness App
///
/// 📁 Layer: presentation/providers
/// 🎯 Feature: settings
/// 🔧 Type: provider (audio debug test management)
///
/// Manages automated audio debugging test execution
/// Tracks progress and results for quick and full test suites
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:gymbro_flutter_new/features/settings/domain/services/audio_debug_test_service.dart';

/// Audio debug test state
class AudioDebugTestState {
  const AudioDebugTestState({
    this.isRunning = false,
    this.currentProgress,
    this.quickResults,
    this.fullResults,
    this.errorMessage,
  });

  final bool isRunning;
  final TestProgress? currentProgress;
  final QuickTestResults? quickResults;
  final FullTestResults? fullResults;
  final String? errorMessage;

  AudioDebugTestState copyWith({
    bool? isRunning,
    TestProgress? currentProgress,
    QuickTestResults? quickResults,
    FullTestResults? fullResults,
    String? errorMessage,
    bool clearProgress = false,
    bool clearError = false,
  }) {
    return AudioDebugTestState(
      isRunning: isRunning ?? this.isRunning,
      currentProgress: clearProgress
          ? null
          : (currentProgress ?? this.currentProgress),
      quickResults: quickResults ?? this.quickResults,
      fullResults: fullResults ?? this.fullResults,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Audio debug test provider
class AudioDebugTestNotifier extends Notifier<AudioDebugTestState> {
  late final AudioDebugTestService _service;

  @override
  AudioDebugTestState build() {
    _service = ref.watch(audioDebugTestServiceProvider);

    // 📥 Load saved results from previous sessions (works in release mode!)
    _loadSavedResults();

    return const AudioDebugTestState();
  }

  /// Load saved results from SharedPreferences
  Future<void> _loadSavedResults() async {
    final quickResults = await _service.loadSavedQuickResults();

    if (quickResults != null) {
      if (kDebugMode) {
        debugPrint(
          '[AudioDebugTest] Loaded previous quick results: ${quickResults.tests.length} tests',
        );
      }

      state = state.copyWith(quickResults: quickResults);
    }
  }

  /// Run quick test suite (3 tests, ~30 minutes)
  Future<void> runQuickTests() async {
    if (state.isRunning) {
      if (kDebugMode) {
        debugPrint(
          '[AudioDebugTest] Cannot start quick tests - tests already running',
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[AudioDebugTest] Starting quick test suite (3 tests)');
    }

    state = state.copyWith(
      isRunning: true,
      errorMessage: null,
      clearError: true,
      clearProgress: true,
    );

    try {
      final results = await _service.runQuickTests(
        onProgress: (progress) {
          if (kDebugMode) {
            debugPrint(
              '[AudioDebugTest] Progress: ${progress.currentTest}/${progress.totalTests} - ${progress.testName}',
            );
          }
          state = state.copyWith(currentProgress: progress);
        },
      );

      if (kDebugMode) {
        debugPrint(
          '[AudioDebugTest] Quick tests completed - Success rate: ${(results.successRate * 100).toStringAsFixed(1)}%',
        );
      }

      state = state.copyWith(
        isRunning: false,
        quickResults: results,
        clearProgress: true,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[AudioDebugTest] Quick tests failed: $e\n$stack');
      }

      state = state.copyWith(
        isRunning: false,
        errorMessage: 'Quick tests failed: $e',
        clearProgress: true,
      );
    }
  }

  /// Run full test matrix (40 tests, 2-3 hours)
  Future<void> runFullTests() async {
    if (state.isRunning) {
      if (kDebugMode) {
        debugPrint(
          '[AudioDebugTest] Cannot start full tests - tests already running',
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[AudioDebugTest] Starting full test matrix (40 tests)');
    }

    state = state.copyWith(
      isRunning: true,
      errorMessage: null,
      clearError: true,
      clearProgress: true,
    );

    try {
      final results = await _service.runFullTests(
        onProgress: (progress) {
          if (kDebugMode) {
            debugPrint(
              '[AudioDebugTest] Progress: ${progress.currentTest}/${progress.totalTests} - ${progress.testName}',
            );
          }
          state = state.copyWith(currentProgress: progress);
        },
      );

      if (kDebugMode) {
        debugPrint(
          '[AudioDebugTest] Full tests completed - Success rate: ${(results.successRate * 100).toStringAsFixed(1)}%',
        );
      }

      state = state.copyWith(
        isRunning: false,
        fullResults: results,
        clearProgress: true,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[AudioDebugTest] Full tests failed: $e\n$stack');
      }

      state = state.copyWith(
        isRunning: false,
        errorMessage: 'Full tests failed: $e',
        clearProgress: true,
      );
    }
  }

  /// Clear all results and reset state
  void clearResults() {
    if (kDebugMode) {
      debugPrint('[AudioDebugTest] Clearing all results');
    }

    state = const AudioDebugTestState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for audio debug test management
final audioDebugTestProvider =
    NotifierProvider<AudioDebugTestNotifier, AudioDebugTestState>(
      AudioDebugTestNotifier.new,
    );
