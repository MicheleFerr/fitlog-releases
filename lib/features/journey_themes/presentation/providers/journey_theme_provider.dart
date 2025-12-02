/// GymBro TrackLog - Flutter Fitness App
///
/// Layer: features/journey_themes/presentation/providers
/// Feature: Journey Themes Gamification
/// Type: Provider (Riverpod)
///
/// State management for journey theme selection and previewing.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/journey_themes/data/repositories/journey_theme_repository.dart';
import 'package:gymbro_flutter_new/features/journey_themes/domain/entities/journey_theme.dart';
import 'package:gymbro_flutter_new/features/profile/presentation/widgets/compact_profile_header.dart';
import 'package:gymbro_flutter_new/features/home/providers/achievement_xp_provider.dart';

/// Provider for the journey theme repository
final journeyThemeRepositoryProvider = Provider<JourneyThemeRepository>((ref) {
  return JourneyThemeRepository.instance;
});

/// State class for journey theme
@immutable
class JourneyThemeState {
  const JourneyThemeState({
    required this.selectedTheme,
    required this.userTier,
    this.currentXP = 0,
    this.previewTheme,
    this.isPreviewMode = false,
    this.isLoading = false,
    this.error,
    this.customNickname,
  });

  /// Currently selected/active theme
  final JourneyTheme selectedTheme;

  /// User's current tier (determines unlocked features)
  final UserTier userTier;

  /// User's current XP (for calculating remaining XP to unlock)
  final int currentXP;

  /// Theme being previewed (null if not in preview mode)
  final JourneyTheme? previewTheme;

  /// Whether currently in preview mode
  final bool isPreviewMode;

  /// Loading state
  final bool isLoading;

  /// Error message if any
  final String? error;

  /// Custom nickname for personalized greetings
  final String? customNickname;

  /// Get the effective theme (preview or selected)
  JourneyTheme get effectiveTheme => previewTheme ?? selectedTheme;

  /// Get the greeting name (custom nickname or theme display name)
  String get greetingName => customNickname?.isNotEmpty == true
      ? customNickname!
      : effectiveTheme.displayName;

  JourneyThemeState copyWith({
    JourneyTheme? selectedTheme,
    UserTier? userTier,
    int? currentXP,
    JourneyTheme? previewTheme,
    bool? isPreviewMode,
    bool? isLoading,
    String? error,
    String? customNickname,
    bool clearPreview = false,
    bool clearError = false,
    bool clearNickname = false,
  }) {
    return JourneyThemeState(
      selectedTheme: selectedTheme ?? this.selectedTheme,
      userTier: userTier ?? this.userTier,
      currentXP: currentXP ?? this.currentXP,
      previewTheme: clearPreview ? null : (previewTheme ?? this.previewTheme),
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      customNickname: clearNickname ? null : (customNickname ?? this.customNickname),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyThemeState &&
          runtimeType == other.runtimeType &&
          selectedTheme == other.selectedTheme &&
          userTier == other.userTier &&
          currentXP == other.currentXP &&
          previewTheme == other.previewTheme &&
          isPreviewMode == other.isPreviewMode;

  @override
  int get hashCode => Object.hash(selectedTheme, userTier, currentXP, previewTheme, isPreviewMode);

  @override
  String toString() =>
      'JourneyThemeState(theme: ${selectedTheme.displayName}, tier: ${userTier.displayName}, preview: ${isPreviewMode ? previewTheme?.displayName : 'none'})';
}

/// Notifier for managing journey theme state
///
/// Migrated from StateNotifier to Notifier (Riverpod 2.0+ pattern)
class JourneyThemeNotifier extends Notifier<JourneyThemeState> {
  late final JourneyThemeRepository _repository;

  /// Saved theme before preview (for revert)
  JourneyTheme? _savedThemeBeforePreview;

  @override
  JourneyThemeState build() {
    _repository = ref.watch(journeyThemeRepositoryProvider);

    // Initialize on creation (fire-and-forget)
    Future.microtask(() => initialize());

    return const JourneyThemeState(
      selectedTheme: JourneyTheme.hunter,
      userTier: UserTier.starter,
    );
  }

  /// Initialize the notifier and connect to XP provider
  Future<void> initialize({UserTier? userTier, int? currentXP}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.initialize();

      final config = _repository.getConfig();

      // Try to get XP from achievement provider, default to 0 if unavailable
      int totalXP = currentXP ?? 0;
      UserTier calculatedTier = userTier ?? UserTier.starter;

      try {
        final achievementData = await ref.read(achievementXPProvider.future);
        totalXP = achievementData.totalXP;
        calculatedTier = UserTier.fromXP(totalXP);

        // Listen to XP changes and update tier automatically
        ref.listen<AsyncValue<AchievementData>>(
          achievementXPProvider,
          (previous, next) {
            next.whenData((data) {
              final newTier = UserTier.fromXP(data.totalXP);
              if (state.userTier != newTier || state.currentXP != data.totalXP) {
                updateUserTier(newTier, xp: data.totalXP);
              }
            });
          },
        );
      } catch (e) {
        // XP provider not available (user not authenticated, etc.)
        // Continue with default tier - will update when XP becomes available
        if (kDebugMode) {
          debugPrint('⚠️ XP provider not available, using default tier: $e');
        }
      }

      state = state.copyWith(
        selectedTheme: config.selectedTheme,
        userTier: userTier ?? calculatedTier,
        currentXP: currentXP ?? totalXP,
        isPreviewMode: config.previewMode,
        customNickname: config.customNickname,
        isLoading: false,
      );

      if (kDebugMode) {
        debugPrint('🎨 JourneyThemeNotifier initialized: ${state.selectedTheme.displayName}');
        debugPrint('🎖️ User tier: ${calculatedTier.displayName} (XP: $totalXP)');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize: $e',
      );
      if (kDebugMode) {
        debugPrint('❌ JourneyThemeNotifier init failed: $e');
      }
    }
  }

  /// Update user tier and XP (called when XP changes)
  void updateUserTier(UserTier tier, {int? xp}) {
    if (state.userTier != tier || (xp != null && state.currentXP != xp)) {
      state = state.copyWith(userTier: tier, currentXP: xp);
      if (kDebugMode) {
        debugPrint('🎖️ User tier updated: ${tier.displayName} (XP: ${xp ?? state.currentXP})');
      }
    }
  }

  /// Update custom nickname for personalized greetings
  Future<void> updateNickname(String? nickname) async {
    try {
      await _repository.updateNickname(nickname);
      state = state.copyWith(
        customNickname: nickname,
        clearNickname: nickname == null || nickname.isEmpty,
      );
      if (kDebugMode) {
        debugPrint('👤 Nickname updated: ${nickname ?? "(using theme name)"}');
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to update nickname: $e');
    }
  }

  /// Select a new theme (permanent selection)
  Future<void> selectTheme(JourneyTheme theme) async {
    if (state.selectedTheme == theme && !state.isPreviewMode) return;

    // CRITICAL FIX: Ensure repository is initialized
    try {
      await _repository.initialize();
    } catch (e) {
      debugPrint('🎨 [Provider] Repository initialize check: $e');
    }

    try {
      await _repository.selectTheme(theme);
      state = state.copyWith(
        selectedTheme: theme,
        isPreviewMode: false,
        clearPreview: true,
        clearError: true,
      );
      _savedThemeBeforePreview = null;

      if (kDebugMode) {
        debugPrint('🎨 Theme selected: ${theme.displayName}');
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to select theme: $e');
    }
  }

  /// Enter preview mode for a theme
  Future<void> previewTheme(JourneyTheme theme) async {
    debugPrint('🎨 [Provider] previewTheme called for ${theme.displayName}');

    // CRITICAL FIX: Ensure repository is initialized before any operation
    // This prevents race condition when user clicks theme before initialization completes
    try {
      await _repository.initialize();
    } catch (e) {
      // Already initialized or failed - continue anyway
      debugPrint('🎨 [Provider] Repository initialize check: $e');
    }

    // Save current theme for potential revert
    if (!state.isPreviewMode) {
      _savedThemeBeforePreview = state.selectedTheme;
      debugPrint('🎨 [Provider] Saved theme before preview: ${_savedThemeBeforePreview?.displayName}');
    }

    try {
      debugPrint('🎨 [Provider] Calling repository.enterPreviewMode...');
      await _repository.enterPreviewMode(theme);
      debugPrint('🎨 [Provider] Repository call successful');

      state = state.copyWith(
        previewTheme: theme,
        isPreviewMode: true,
        clearError: true,
      );
      debugPrint('🎨 [Provider] State updated: isPreviewMode=${state.isPreviewMode}, previewTheme=${state.previewTheme?.displayName}');

      if (kDebugMode) {
        debugPrint('👀 Preview: ${theme.displayName}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Provider] ERROR in previewTheme: $e');
      debugPrint('❌ [Provider] StackTrace: $stackTrace');
      state = state.copyWith(error: 'Failed to preview theme: $e');
    }
  }

  /// Confirm the preview selection
  Future<void> confirmPreview() async {
    if (!state.isPreviewMode || state.previewTheme == null) return;

    // CRITICAL FIX: Ensure repository is initialized
    try {
      await _repository.initialize();
    } catch (e) {
      debugPrint('🎨 [Provider] Repository initialize check: $e');
    }

    try {
      await _repository.confirmPreview();
      state = state.copyWith(
        selectedTheme: state.previewTheme,
        isPreviewMode: false,
        clearPreview: true,
        clearError: true,
      );
      _savedThemeBeforePreview = null;

      if (kDebugMode) {
        debugPrint('✅ Preview confirmed: ${state.selectedTheme.displayName}');
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to confirm: $e');
    }
  }

  /// Cancel preview and revert to saved theme
  Future<void> cancelPreview() async {
    if (!state.isPreviewMode) return;

    // CRITICAL FIX: Ensure repository is initialized
    try {
      await _repository.initialize();
    } catch (e) {
      debugPrint('🎨 [Provider] Repository initialize check: $e');
    }

    try {
      await _repository.exitPreviewMode(_savedThemeBeforePreview);
      state = state.copyWith(
        selectedTheme: _savedThemeBeforePreview ?? state.selectedTheme,
        isPreviewMode: false,
        clearPreview: true,
        clearError: true,
      );
      _savedThemeBeforePreview = null;

      if (kDebugMode) {
        debugPrint('🔙 Preview cancelled');
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to cancel: $e');
    }
  }

  /// Reset to default theme
  Future<void> resetToDefault() async {
    // CRITICAL FIX: Ensure repository is initialized
    try {
      await _repository.initialize();
    } catch (e) {
      debugPrint('🎨 [Provider] Repository initialize check: $e');
    }

    try {
      await _repository.resetToDefault();
      state = state.copyWith(
        selectedTheme: JourneyTheme.hunter,
        isPreviewMode: false,
        clearPreview: true,
        clearError: true,
      );
      _savedThemeBeforePreview = null;

      if (kDebugMode) {
        debugPrint('🔄 Theme reset to default');
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to reset: $e');
    }
  }

  /// Get list of all themes
  List<JourneyTheme> get allThemes => JourneyTheme.values;

  /// Get unlocked features for current theme and tier
  int get unlockedFeaturesCount =>
      state.effectiveTheme.getUnlockedFeaturesCount(state.userTier);

  /// Get unlock percentage for current theme
  double get unlockPercentage =>
      state.effectiveTheme.getUnlockPercentage(state.userTier);
}

/// Main provider for journey theme
///
/// Migrated to NotifierProvider (Riverpod 2.0+ pattern)
final journeyThemeProvider =
    NotifierProvider<JourneyThemeNotifier, JourneyThemeState>(
  JourneyThemeNotifier.new,
);

/// Provider for current effective theme (preview or selected)
final effectiveJourneyThemeProvider = Provider<JourneyTheme>((ref) {
  final state = ref.watch(journeyThemeProvider);
  return state.effectiveTheme;
});

/// Provider for current user tier
final journeyThemeUserTierProvider = Provider<UserTier>((ref) {
  final state = ref.watch(journeyThemeProvider);
  return state.userTier;
});

/// Provider for theme unlock percentage
final journeyThemeUnlockPercentageProvider = Provider<double>((ref) {
  final state = ref.watch(journeyThemeProvider);
  return state.effectiveTheme.getUnlockPercentage(state.userTier);
});
